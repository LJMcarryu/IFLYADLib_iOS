#!/usr/bin/env python3
"""把已验证的 candidate 资产转换成不访问公开 Release 的本地消费端。"""

from __future__ import annotations

import argparse
import re
import shutil
import stat
import sys
import tempfile
import zipfile
from pathlib import Path, PurePosixPath

from release_asset_downloader import (
    MODULE_ASSET_NAMES,
    VerificationError,
    expected_assets,
)


def require(condition: bool, message: str) -> None:
    if not condition:
        raise VerificationError(message)


def require_empty_output(output: Path) -> None:
    output.mkdir(parents=True, exist_ok=True)
    require(not any(output.iterdir()), f"输出目录必须为空: {output}")


def validate_asset_directory(asset_dir: Path, version: str) -> None:
    require(asset_dir.is_dir() and not asset_dir.is_symlink(), f"资产目录非法: {asset_dir}")
    files = {
        path.name
        for path in asset_dir.iterdir()
        if path.is_file() and not path.is_symlink()
    }
    unexpected = [
        path.name
        for path in asset_dir.iterdir()
        if not path.is_file() or path.is_symlink()
    ]
    require(
        not unexpected and files == expected_assets(version),
        f"candidate 资产库存不精确: files={sorted(files)} unexpected={sorted(unexpected)}",
    )


def safe_extract(archive_path: Path, destination: Path) -> None:
    destination.mkdir(parents=True, exist_ok=True)
    seen: set[str] = set()
    with zipfile.ZipFile(archive_path) as archive:
        for info in archive.infolist():
            raw_name = info.filename
            require("\\" not in raw_name, f"{archive_path.name} 含反斜线 zip 路径")
            pure = PurePosixPath(raw_name)
            require(
                not pure.is_absolute() and bool(pure.parts) and ".." not in pure.parts,
                f"{archive_path.name} 含路径穿越项: {raw_name!r}",
            )
            normalized = pure.as_posix().rstrip("/")
            if not normalized:
                continue
            require(normalized not in seen, f"{archive_path.name} 含重复项: {normalized}")
            seen.add(normalized)

            target = destination.joinpath(*pure.parts)
            unix_mode = info.external_attr >> 16
            file_type = stat.S_IFMT(unix_mode)
            if info.is_dir() or file_type == stat.S_IFDIR:
                target.mkdir(parents=True, exist_ok=True)
                continue
            require(file_type != stat.S_IFLNK, f"{archive_path.name} 禁止符号链接: {normalized}")
            require(
                file_type in {0, stat.S_IFREG},
                f"{archive_path.name} 含特殊文件: {normalized}",
            )
            target.parent.mkdir(parents=True, exist_ok=True)
            target.write_bytes(archive.read(info))
            if unix_mode:
                target.chmod(unix_mode & 0o777)


def find_framework(root: Path, module: str) -> Path:
    matches = [path for path in root.rglob(f"{module}.xcframework") if path.is_dir()]
    require(len(matches) == 1, f"{module} candidate XCFramework 数量不是 1: {matches}")
    return matches[0]


def localize_package_manifest(source: str) -> str:
    pattern = re.compile(
        r'(?P<indent>[ \t]*)\.binaryTarget\(\s*name:\s*"(?P<name>[^"]+)"\s*,'
        r'\s*url:\s*"(?P<url>[^"]+)"\s*,'
        r'\s*checksum:\s*"(?P<checksum>[^"]+)"\s*\)',
        re.S,
    )
    found: list[str] = []

    def replace(match: re.Match[str]) -> str:
        name = match.group("name")
        require(name in MODULE_ASSET_NAMES, f"未知 binaryTarget: {name}")
        require(
            Path(match.group("url")).name == MODULE_ASSET_NAMES[name],
            f"{name} URL 资产名不一致",
        )
        found.append(name)
        return (
            f'{match.group("indent")}.binaryTarget(\n'
            f'{match.group("indent")}    name: "{name}",\n'
            f'{match.group("indent")}    path: "{name}.xcframework"\n'
            f'{match.group("indent")})'
        )

    localized = pattern.sub(replace, source)
    require(
        len(found) == len(MODULE_ASSET_NAMES) and set(found) == set(MODULE_ASSET_NAMES),
        f"Package.swift binaryTarget 库存不精确: {found}",
    )
    require("releases/download" not in localized, "本地 SwiftPM 清单仍引用公开 Release")
    return localized


def localize_consumer_manifest(source: str) -> str:
    pattern = re.compile(
        r'\.package\(\s*url:\s*"https://github\.com/LJMcarryu/'
        r'IFLYADLib_iOS\.git"\s*,\s*exact:\s*"6\.2\.2"\s*\)',
        re.S,
    )
    localized, count = pattern.subn('.package(path: "../IFLYADLib_iOS")', source)
    require(count == 1, f"SwiftPM 消费端远程依赖数量不是 1: {count}")
    require("https://github.com" not in localized, "SwiftPM candidate 消费端仍引用远程仓")
    return localized


def prepare_swiftpm(asset_dir: Path, repository_root: Path, output: Path, version: str) -> None:
    validate_asset_directory(asset_dir, version)
    require_empty_output(output)
    sdk_root = output / "IFLYADLib_iOS"
    consumer_root = output / "consumer"
    sdk_root.mkdir()
    shutil.copytree(repository_root / "spm", sdk_root / "spm")
    source_manifest = (repository_root / "Package.swift").read_text(encoding="utf-8")
    (sdk_root / "Package.swift").write_text(
        localize_package_manifest(source_manifest), encoding="utf-8"
    )

    fixture = repository_root / ".github/fixtures/swiftpm-consumer"
    shutil.copytree(
        fixture,
        consumer_root,
        ignore=shutil.ignore_patterns(".build", ".swiftpm", "Package.resolved"),
    )
    consumer_manifest = (consumer_root / "Package.swift").read_text(encoding="utf-8")
    (consumer_root / "Package.swift").write_text(
        localize_consumer_manifest(consumer_manifest), encoding="utf-8"
    )

    with tempfile.TemporaryDirectory(prefix="ifly-candidate-spm-") as temporary:
        extraction_root = Path(temporary)
        for module, archive_name in MODULE_ASSET_NAMES.items():
            module_root = extraction_root / module
            safe_extract(asset_dir / archive_name, module_root)
            shutil.copytree(
                find_framework(module_root, module),
                sdk_root / f"{module}.xcframework",
            )
    print(f"SwiftPM candidate 本地消费端已生成: {consumer_root}")


def _copy_demo(repository_root: Path, demo_root: Path) -> None:
    shutil.copytree(
        repository_root / "IFLYADLibSimple",
        demo_root,
        ignore=shutil.ignore_patterns(
            "Pods",
            "Podfile.lock",
            "*.xcworkspace",
            "build",
            "xcuserdata",
        ),
    )


def localize_podfile(source: str) -> str:
    pattern = re.compile(
        r"(?m)^(?P<indent>[ \t]*)pod 'IFLYADLib', :podspec => "
        r"'https://raw\.githubusercontent\.com/LJMcarryu/IFLYADLib_iOS/"
        r"6\.2\.2/IFLYADLib\.podspec'[ \t]*$"
    )
    localized, count = pattern.subn(
        r"\g<indent>pod 'IFLYADLib', :path => '../IFLYADLib'", source
    )
    require(count == 1, f"Demo Podfile 正式依赖行数量不是 1: {count}")
    active_lines = [
        line for line in localized.splitlines() if line.lstrip().startswith("pod 'IFLYADLib'")
    ]
    require(
        active_lines == ["  pod 'IFLYADLib', :path => '../IFLYADLib'"],
        f"Demo Podfile candidate 活跃依赖不精确: {active_lines}",
    )
    return localized


def prepare_cocoapods(asset_dir: Path, repository_root: Path, output: Path, version: str) -> None:
    validate_asset_directory(asset_dir, version)
    require_empty_output(output)
    pod_root = output / "IFLYADLib"
    demo_root = output / "IFLYADLibSimple"
    safe_extract(asset_dir / f"IFLYADLib-modelA-{version}.zip", pod_root)
    shutil.copy2(repository_root / "IFLYADLib.podspec", pod_root / "IFLYADLib.podspec")
    _copy_demo(repository_root, demo_root)
    podfile = demo_root / "Podfile"
    podfile.write_text(localize_podfile(podfile.read_text(encoding="utf-8")), encoding="utf-8")
    print(f"CocoaPods candidate 本地消费端已生成: {demo_root}")


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--kind", choices=("swiftpm", "cocoapods"), required=True)
    parser.add_argument("--asset-dir", type=Path, required=True)
    parser.add_argument("--repository-root", type=Path, required=True)
    parser.add_argument("--output", type=Path, required=True)
    parser.add_argument("--version", default="6.2.2")
    args = parser.parse_args()
    try:
        if args.kind == "swiftpm":
            prepare_swiftpm(
                args.asset_dir.resolve(),
                args.repository_root.resolve(),
                args.output.resolve(),
                args.version,
            )
        else:
            prepare_cocoapods(
                args.asset_dir.resolve(),
                args.repository_root.resolve(),
                args.output.resolve(),
                args.version,
            )
    except (OSError, ValueError, zipfile.BadZipFile, VerificationError) as error:
        print(f"FAIL {error}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
