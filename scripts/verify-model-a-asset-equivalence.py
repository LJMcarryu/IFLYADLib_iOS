#!/usr/bin/env python3
"""校验模型 A 单模块 zip 与 CocoaPods 合并包来自同一批逐字节产物。"""

from __future__ import annotations

import argparse
import hashlib
import os
import plistlib
import re
import stat
import tempfile
import zipfile
from pathlib import Path, PurePosixPath
from urllib.parse import urlparse


class AssetValidationError(RuntimeError):
    """分发资产不满足冻结契约。"""


MODULE_ASSETS = {
    "IFLYAdCore": "IFLYAdCore.xcframework.zip",
    "IFLYAdVideoUI": "IFLYAdVideoUI.xcframework.zip",
    "IFLYAdBanner": "IFLYAdBanner.xcframework.zip",
    "IFLYAdSplash": "IFLYAdSplash.xcframework.zip",
    "IFLYAdInterstitial": "IFLYAdInterstitial.xcframework.zip",
    "IFLYAdNativeFeed": "IFLYAdNativeFeed.xcframework.zip",
    "IFLYAdReward": "IFLYAdReward.xcframework.zip",
}

CHECKSUM_LABELS = {
    "IFLYAdCore": "Core",
    "IFLYAdVideoUI": "VideoUI",
    "IFLYAdBanner": "Banner",
    "IFLYAdSplash": "Splash",
    "IFLYAdInterstitial": "Interstitial",
    "IFLYAdNativeFeed": "NativeFeed",
    "IFLYAdReward": "Reward",
}

RESOURCE_SOURCES = {
    "Core": (
        "spm/Core/IFLYADLibCoreResources.bundle",
        "spm/Core/Resources",
    ),
    "VideoUI": ("spm/VideoUI/IFLYADLibVideoUIResources.bundle",),
    "Reward": ("spm/Reward/IFLYADLibRewardResources.bundle",),
}

EXPECTED_LIBRARY_IDENTIFIERS = {
    "ios-arm64",
    "ios-arm64_x86_64-simulator",
}


def fail(message: str) -> None:
    raise AssetValidationError(message)


def sha256_file(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        for chunk in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def safe_extract(archive_path: Path, destination: Path) -> None:
    """拒绝路径穿越、链接和特殊节点后解压，避免门禁自身被恶意 zip 绕过。"""

    destination.mkdir(parents=True, exist_ok=True)
    seen: set[str] = set()
    with zipfile.ZipFile(archive_path) as archive:
        for info in archive.infolist():
            raw_name = info.filename
            if "\\" in raw_name:
                fail(f"{archive_path.name} 含反斜线 zip 路径：{raw_name!r}")
            pure = PurePosixPath(raw_name)
            if pure.is_absolute() or not pure.parts or ".." in pure.parts:
                fail(f"{archive_path.name} 含路径穿越项：{raw_name!r}")
            normalized = pure.as_posix().rstrip("/")
            if not normalized:
                continue
            if normalized in seen:
                fail(f"{archive_path.name} 含重复项：{normalized}")
            seen.add(normalized)

            target = destination.joinpath(*pure.parts)
            unix_mode = info.external_attr >> 16
            file_type = stat.S_IFMT(unix_mode)
            if info.is_dir() or file_type == stat.S_IFDIR:
                target.mkdir(parents=True, exist_ok=True)
                continue
            if file_type == stat.S_IFLNK:
                fail(f"{archive_path.name} 禁止符号链接：{normalized}")
            if file_type not in {0, stat.S_IFREG}:
                fail(f"{archive_path.name} 含特殊文件：{normalized}")

            target.parent.mkdir(parents=True, exist_ok=True)
            target.write_bytes(archive.read(info))
            if unix_mode:
                target.chmod(unix_mode & 0o777)


def tree_inventory(root: Path) -> dict[str, tuple[object, ...]]:
    if not root.is_dir() or root.is_symlink():
        fail(f"库存根目录非法：{root}")
    inventory: dict[str, tuple[object, ...]] = {}
    for path in sorted(root.rglob("*")):
        relative = path.relative_to(root).as_posix()
        if path.is_symlink():
            inventory[relative] = ("symlink", os.readlink(path))
        elif path.is_dir():
            inventory[relative] = ("directory",)
        elif path.is_file():
            inventory[relative] = (
                "file",
                path.stat().st_size,
                sha256_file(path),
                path.stat().st_mode & 0o111,
            )
        else:
            fail(f"库存包含特殊节点：{path}")
    return inventory


def regular_file_inventory(root: Path) -> dict[str, tuple[int, str, int]]:
    if not root.is_dir() or root.is_symlink():
        fail(f"资源目录缺失或非法：{root}")
    result: dict[str, tuple[int, str, int]] = {}
    for path in sorted(root.rglob("*")):
        if path.is_symlink():
            fail(f"资源目录禁止符号链接：{path}")
        if path.is_file():
            result[path.relative_to(root).as_posix()] = (
                path.stat().st_size,
                sha256_file(path),
                path.stat().st_mode & 0o111,
            )
    return result


def describe_difference(
    left: dict[str, tuple[object, ...]],
    right: dict[str, tuple[object, ...]],
) -> str:
    left_paths = set(left)
    right_paths = set(right)
    missing = sorted(left_paths - right_paths)
    extra = sorted(right_paths - left_paths)
    changed = sorted(
        path for path in left_paths & right_paths if left[path] != right[path]
    )
    return f"缺失={missing[:10]}，多出={extra[:10]}，内容/模式不同={changed[:10]}"


def find_xcframework(root: Path, module: str) -> Path:
    expected_name = f"{module}.xcframework"
    matches = [path for path in root.rglob(expected_name) if path.is_dir()]
    if len(matches) != 1:
        fail(f"{root} 中 {expected_name} 数量不是 1：{matches}")
    return matches[0]


def validate_xcframework(root: Path, module: str) -> dict[str, int]:
    info_path = root / "Info.plist"
    if not info_path.is_file():
        fail(f"{module} 缺少 XCFramework Info.plist")
    try:
        info = plistlib.loads(info_path.read_bytes())
    except (OSError, plistlib.InvalidFileException) as exc:
        fail(f"{module} Info.plist 非法：{exc}")

    libraries = info.get("AvailableLibraries")
    if not isinstance(libraries, list) or not libraries:
        fail(f"{module} Info.plist 缺少 AvailableLibraries")
    identifiers = {
        item.get("LibraryIdentifier")
        for item in libraries
        if isinstance(item, dict)
    }
    if identifiers != EXPECTED_LIBRARY_IDENTIFIERS:
        fail(f"{module} 切片不精确：{sorted(identifiers)}")

    binary_count = 0
    header_count = 0
    module_file_count = 0
    for item in libraries:
        identifier = item.get("LibraryIdentifier")
        library_path = item.get("LibraryPath") or item.get("BinaryPath")
        if not isinstance(identifier, str) or not isinstance(library_path, str):
            fail(f"{module} AvailableLibraries 字段非法：{item}")
        binary = root / identifier / library_path
        if not binary.is_file():
            fail(f"{module} 缺少切片二进制：{binary.relative_to(root)}")
        binary_count += 1

        headers_path = item.get("HeadersPath")
        if headers_path is not None:
            if not isinstance(headers_path, str):
                fail(f"{module} HeadersPath 非字符串：{item}")
            headers = root / identifier / headers_path
            if not headers.is_dir():
                fail(f"{module} 缺少 Headers：{headers.relative_to(root)}")
            current_headers = [
                path
                for path in headers.rglob("*")
                if path.is_file() and not path.is_symlink()
            ]
            if not current_headers:
                fail(f"{module} Headers 为空：{headers.relative_to(root)}")
            header_count += len(current_headers)

        modules = root / identifier / "Modules"
        if modules.exists():
            if not modules.is_dir() or modules.is_symlink():
                fail(f"{module} Modules 节点非法：{modules.relative_to(root)}")
            module_file_count += sum(
                1 for path in modules.rglob("*") if path.is_file()
            )

    signature_dir = root / "_CodeSignature"
    signature_files = (
        [path for path in signature_dir.rglob("*") if path.is_file()]
        if signature_dir.is_dir() and not signature_dir.is_symlink()
        else []
    )
    if not signature_files or not (signature_dir / "CodeResources").is_file():
        fail(f"{module} 缺少 XCFramework 签名库存")

    privacy_count = sum(
        1 for path in root.rglob("*.xcprivacy") if path.is_file()
    )
    return {
        "binaries": binary_count,
        "headers": header_count,
        "modules": module_file_count,
        "privacy": privacy_count,
        "signatureFiles": len(signature_files),
        "totalFiles": sum(1 for path in root.rglob("*") if path.is_file()),
    }


def compare_framework_trees(single: Path, combined: Path, module: str) -> dict[str, int]:
    single_summary = validate_xcframework(single, module)
    combined_summary = validate_xcframework(combined, module)
    if single_summary != combined_summary:
        fail(
            f"{module} 单模块与合并包结构摘要不同："
            f"single={single_summary} combined={combined_summary}"
        )
    single_inventory = tree_inventory(single)
    combined_inventory = tree_inventory(combined)
    if single_inventory != combined_inventory:
        fail(
            f"{module} 单模块 zip 与合并包不是同一份 XCFramework："
            f"{describe_difference(single_inventory, combined_inventory)}"
        )
    return single_summary


def expected_resource_inventory(
    repository_root: Path, domain: str
) -> dict[str, tuple[int, str, int]]:
    expected: dict[str, tuple[int, str, int]] = {}
    for relative_source in RESOURCE_SOURCES[domain]:
        source = repository_root / relative_source
        for relative, fingerprint in regular_file_inventory(source).items():
            if relative in expected:
                fail(f"{domain} 受版本控制资源重名：{relative}")
            expected[relative] = fingerprint
    return expected


def validate_combined_resources(combined_root: Path, repository_root: Path) -> None:
    resources = combined_root / "resources"
    if not resources.is_dir() or resources.is_symlink():
        fail("合并包缺少 resources 目录")
    actual_domains = {path.name for path in resources.iterdir() if path.is_dir()}
    if actual_domains != set(RESOURCE_SOURCES):
        fail(f"合并包资源域不精确：{sorted(actual_domains)}")

    for domain in RESOURCE_SOURCES:
        actual = regular_file_inventory(resources / domain)
        expected = expected_resource_inventory(repository_root, domain)
        if actual != expected:
            fail(
                f"合并包 {domain} 资源与公开仓 spm/ 不一致："
                f"{describe_difference(expected, actual)}"
            )

    privacy = resources / "Core/PrivacyInfo.xcprivacy"
    if not privacy.is_file():
        fail("合并包缺少 resources/Core/PrivacyInfo.xcprivacy")

    combined_license = combined_root / "LICENSE"
    repository_license = repository_root / "LICENSE"
    if not combined_license.is_file() or not repository_license.is_file():
        fail("合并包或公开仓缺少 LICENSE")
    if combined_license.read_bytes() != repository_license.read_bytes():
        fail("合并包 LICENSE 与公开仓 LICENSE 不一致")


def validate_release_metadata(
    asset_dir: Path, repository_root: Path, version: str
) -> None:
    """将已匿名下载的 10 个资产与 tag 内分发清单逐项绑定。"""

    package = (repository_root / "Package.swift").read_text(encoding="utf-8")
    blocks = re.findall(
        r'\.binaryTarget\(\s*name:\s*"([^"]+)"\s*,'
        r'\s*url:\s*"([^"]+)"\s*,'
        r'\s*checksum:\s*"([0-9a-f]{64})"\s*\)',
        package,
        re.S,
    )
    expected_targets = set(MODULE_ASSETS)
    if len(blocks) != len(expected_targets) or {name for name, _, _ in blocks} != expected_targets:
        fail(f"Package.swift binaryTarget 不精确：{blocks}")
    package_targets = {name: (url, checksum) for name, url, checksum in blocks}

    checksum_lines = [
        line.strip()
        for line in (asset_dir / "checksums.txt").read_text(encoding="utf-8").splitlines()
        if line.strip()
    ]
    module_pattern = re.compile(
        r"^(\S+)  (\S+)  spm_checksum=([0-9a-f]{64})  sha256=([0-9a-f]{64})$"
    )
    combined_pattern = re.compile(r"^Combined  (\S+)  sha256=([0-9a-f]{64})$")
    modules: dict[str, tuple[str, str, str]] = {}
    combined: tuple[str, str] | None = None
    for line in checksum_lines:
        module_match = module_pattern.fullmatch(line)
        combined_match = combined_pattern.fullmatch(line)
        if module_match:
            label, filename, spm_checksum, sha256 = module_match.groups()
            if label in modules:
                fail(f"checksums.txt 模块重复：{label}")
            modules[label] = (filename, spm_checksum, sha256)
        elif combined_match:
            if combined is not None:
                fail("checksums.txt 合并包记录重复")
            combined = combined_match.groups()
        else:
            fail(f"checksums.txt 非法行：{line}")

    expected_labels = set(CHECKSUM_LABELS.values())
    if set(modules) != expected_labels or combined is None:
        fail(f"checksums.txt 模块库存不精确：{sorted(modules)}")

    for target, archive_name in MODULE_ASSETS.items():
        url, package_checksum = package_targets[target]
        if Path(urlparse(url).path).name != archive_name or f"/releases/download/{version}/" not in url:
            fail(f"{target} Package.swift URL 非本版 Release 资产：{url}")
        filename, spm_checksum, listed_sha = modules[CHECKSUM_LABELS[target]]
        actual_sha = sha256_file(asset_dir / archive_name)
        if (filename, package_checksum, spm_checksum, listed_sha, actual_sha) != (
            archive_name,
            actual_sha,
            actual_sha,
            actual_sha,
            actual_sha,
        ):
            fail(f"{target} checksum 与 Package.swift/资产不一致")

    combined_name = f"IFLYADLib-modelA-{version}.zip"
    if combined[0] != combined_name or combined[1] != sha256_file(asset_dir / combined_name):
        fail("合并包 checksum 与实际资产不一致")

    podspec = (repository_root / "IFLYADLib.podspec").read_text(encoding="utf-8")
    pod_source = re.search(r":http\s*=>\s*'([^']+)'", podspec)
    if (
        pod_source is None
        or Path(urlparse(pod_source.group(1)).path).name != combined_name
        or f"/releases/download/{version}/" not in pod_source.group(1)
    ):
        fail("podspec 合并包 URL 非本版 Release 资产")

    remote_manifest = (asset_dir / "binary-targets.remote.swift").read_text(encoding="utf-8")
    remote_blocks = re.findall(
        r'\.binaryTarget\(\s*name:\s*"([^"]+)"\s*,'
        r'\s*url:\s*"([^"]+)"\s*,'
        r'\s*checksum:\s*"([0-9a-f]{64})"\s*\)',
        remote_manifest,
        re.S,
    )
    if {name: (url, checksum) for name, url, checksum in remote_blocks} != package_targets:
        fail("binary-targets.remote.swift 与 Package.swift 不一致")


def verify_release_assets(asset_dir: Path, repository_root: Path, version: str) -> None:
    combined_name = f"IFLYADLib-modelA-{version}.zip"
    expected_assets = set(MODULE_ASSETS.values()) | {
        combined_name,
        "checksums.txt",
        "binary-targets.remote.swift",
    }
    actual_assets = {
        path.name
        for path in asset_dir.iterdir()
        if path.is_file() and not path.is_symlink()
    }
    unexpected_nodes = [
        path.name
        for path in asset_dir.iterdir()
        if not path.is_file() or path.is_symlink()
    ]
    if unexpected_nodes or actual_assets != expected_assets:
        fail(
            "Release 下载库存必须精确为 10 个普通文件："
            f"actual={sorted(actual_assets)} unexpected={sorted(unexpected_nodes)} "
            f"expected={sorted(expected_assets)}"
        )

    validate_release_metadata(asset_dir, repository_root, version)

    with tempfile.TemporaryDirectory(prefix="ifly-model-a-equivalence-") as temp:
        extraction_root = Path(temp)
        combined_extract = extraction_root / "combined"
        safe_extract(asset_dir / combined_name, combined_extract)

        combined_frameworks = {
            path.name
            for path in combined_extract.rglob("*.xcframework")
            if path.is_dir()
        }
        expected_frameworks = {f"{module}.xcframework" for module in MODULE_ASSETS}
        if combined_frameworks != expected_frameworks:
            fail(
                "合并包 XCFramework 库存不精确："
                f"actual={sorted(combined_frameworks)} "
                f"expected={sorted(expected_frameworks)}"
            )

        for module, filename in MODULE_ASSETS.items():
            single_extract = extraction_root / f"single-{module}"
            safe_extract(asset_dir / filename, single_extract)
            single_framework = find_xcframework(single_extract, module)
            combined_framework = find_xcframework(combined_extract, module)
            summary = compare_framework_trees(
                single_framework, combined_framework, module
            )
            print(
                f"OK {module}：单模块/合并包逐文件一致，"
                f"binary={summary['binaries']} headers={summary['headers']} "
                f"modules={summary['modules']} privacy={summary['privacy']} "
                f"signature={summary['signatureFiles']} files={summary['totalFiles']}"
            )

        validate_combined_resources(combined_extract, repository_root)

    print("OK 模型 A：7 个 XCFramework、三域资源、Privacy 与签名库存同源")


def parse_arguments() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("--asset-dir", required=True, type=Path)
    parser.add_argument("--repository-root", default=Path.cwd(), type=Path)
    parser.add_argument("--version", required=True)
    return parser.parse_args()


def main() -> int:
    arguments = parse_arguments()
    try:
        verify_release_assets(
            arguments.asset_dir.resolve(),
            arguments.repository_root.resolve(),
            arguments.version,
        )
    except (AssetValidationError, OSError, zipfile.BadZipFile) as exc:
        print(f"FAIL {exc}", file=os.sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
