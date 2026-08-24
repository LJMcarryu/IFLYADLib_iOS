#!/usr/bin/env python3
"""分别校验通用仓机器分发契约与阻断式 Markdown 发布契约。"""

from __future__ import annotations

import argparse
import json
import re
import sys
from pathlib import Path
from urllib.parse import urlparse

sys.path.insert(0, str(Path.cwd() / "scripts"))
from verify_distribution_manifest import (
    EXPECTED,
    PREVIOUS_CHECKSUMS,
    REPOSITORY,
    VERSION,
)

PREVIOUS_RELEASE_VERSION = "6.2.4"
RELEASE_STATUS_RE = re.compile(
    r"<!--\s*ifly-release-status:\s*(\{[^\r\n]*\})\s*-->"
)


class ContractError(RuntimeError):
    pass


def require(condition: bool, message: str) -> None:
    if not condition:
        raise ContractError(message)


def read(root: Path, relative: str) -> str:
    return (root / relative).read_text(encoding="utf-8")


def verify_release_status(label: str, document: str) -> None:
    markers = RELEASE_STATUS_RE.findall(document)
    require(len(markers) == 1, f"{label} 发布状态标记数量错误: {len(markers)}")
    try:
        marker = json.loads(markers[0])
    except json.JSONDecodeError as error:
        raise ContractError(f"{label} 发布状态标记不是合法 JSON") from error
    expected = {
        "schemaVersion": 1,
        "version": VERSION,
        "releaseState": "FORMAL",
        "distribution": "github-release",
        "releaseUrl": f"https://github.com/{REPOSITORY}/releases/tag/{VERSION}",
    }
    require(marker == expected, f"{label} 发布状态标记漂移: {marker}")


def machine_state(root: Path) -> dict[str, object]:
    state = json.loads(read(root, "release-state.json"))
    require(state.get("channel") == "general", "release-state 渠道不匹配")
    return state


def validate_state_version(state: dict[str, object], release_kind: str) -> None:
    version = state.get("version")
    phase = state.get("phase")
    if release_kind in {"candidate", "tag", "formal"}:
        require(
            version == VERSION and phase == "FROZEN",
            "candidate/tag/formal 必须使用当前分发版本的 FROZEN 状态",
        )
        return
    if version == VERSION:
        return
    require(
        release_kind == "local"
        and version == PREVIOUS_RELEASE_VERSION
        and phase == "CLOSED",
        "release-state 版本不匹配：普通 main 只允许保留上一版 CLOSED，"
        "candidate/tag/formal 必须使用当前分发版本的 FROZEN 状态",
    )


def verify_machine(root: Path, release_kind: str) -> None:
    require(release_kind in {"local", "candidate", "tag", "formal"}, "非法发布模式")
    state = machine_state(root)
    validate_state_version(state, release_kind)
    package = read(root, "Package.swift")
    podspec = read(root, "IFLYADLib.podspec")
    podfile = read(root, "IFLYADLibSimple/Podfile")

    blocks = re.findall(
        r'\.binaryTarget\(\s*name:\s*"([^"]+)"\s*,'
        r'\s*url:\s*"([^"]+)"\s*,'
        r'\s*checksum:\s*"([^"]+)"\s*\)',
        package,
        re.S,
    )
    require(len(blocks) == 7, f"binaryTarget 数量错误: {len(blocks)}")
    require({name for name, _, _ in blocks} == set(EXPECTED), "binaryTarget 集合错误")
    checksums: dict[str, str] = {}
    assets: set[str] = set()
    for name, url, checksum in blocks:
        asset, pending = EXPECTED[name]
        expected_url = (
            f"https://github.com/{REPOSITORY}/releases/download/{VERSION}/{asset}"
        )
        require(url == expected_url, f"{name} URL 不精确")
        require(Path(urlparse(url).path).name == asset, f"{name} 资产名不匹配")
        checksums[name] = checksum
        assets.add(asset)

    pending = all(checksums[name] == EXPECTED[name][1] for name in EXPECTED)
    final = all(
        re.fullmatch(r"[0-9a-f]{64}", value)
        and value != "0" * 64
        and value not in PREVIOUS_CHECKSUMS
        for value in checksums.values()
    )
    require(pending or final, "checksum 必须全部为精确 PENDING 或全部为本版 SHA-256")
    require(len(set(checksums.values())) == 7, "七个模块 checksum 必须唯一")
    preparing = state.get("phase") == "PREPARING"
    if state.get("version") == VERSION:
        require(pending == preparing, "checksum 状态与 release-state phase 不一致")
    else:
        require(final, "上一版 CLOSED 与当前分发清单并存时必须使用最终 checksum")
    if release_kind != "local":
        require(final, f"{release_kind} 模式禁止 PENDING checksum")

    version = re.findall(r"s\.version\s*=\s*'([^']+)'", podspec)
    sources = re.findall(r":http\s*=>\s*'([^']+)'", podspec)
    require(version == [VERSION], f"podspec 版本错误: {version}")
    combined = f"IFLYADLib-modelA-{VERSION}.zip"
    expected_source = (
        f"https://github.com/{REPOSITORY}/releases/download/{VERSION}/{combined}"
    )
    require(sources == [expected_source], f"podspec source 错误: {sources}")
    expected_podspec = (
        f"https://raw.githubusercontent.com/{REPOSITORY}/{VERSION}/IFLYADLib.podspec"
    )
    active = re.findall(
        r"(?m)^[ \t]*pod 'IFLYADLib', :podspec => '([^']+)'[ \t]*$",
        podfile,
    )
    require(active == [expected_podspec], f"Demo podspec 版本错误: {active}")
    require(len(assets | {combined, "checksums.txt", "binary-targets.remote.swift"}) == 10,
            "通用仓资产契约必须为 10 项")


def verify_docs(root: Path, _release_kind: str) -> None:
    state = machine_state(root)
    validate_state_version(state, _release_kind)
    documents = {
        name: read(root, name)
        for name in ("README.md", "CHANGELOG.md", "RELEASING.md", "SECURITY.md")
    }
    demo = read(root, "IFLYADLibSimple/README.md")
    if state.get("phase") == "PREPARING":
        require("待发布" in documents["CHANGELOG.md"], "CHANGELOG 缺少待发布展示")
        require("PENDING" in documents["RELEASING.md"], "RELEASING 缺少 PENDING 展示")
        require(VERSION in demo and "发布准备" in demo, "Demo 缺少发布准备说明")
    else:
        for label in ("README.md", "CHANGELOG.md", "RELEASING.md"):
            verify_release_status(label, documents[label])
        require(VERSION in demo, "Demo 缺少当前版本展示")


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--repository-root", type=Path, default=Path.cwd())
    parser.add_argument("--scope", choices=("machine", "docs"), required=True)
    parser.add_argument(
        "--release-kind",
        choices=("local", "candidate", "tag", "formal"),
        default="local",
    )
    args = parser.parse_args()
    try:
        root = args.repository_root.resolve()
        if args.scope == "machine":
            verify_machine(root, args.release_kind)
        else:
            verify_docs(root, args.release_kind)
    except (ContractError, OSError, ValueError, json.JSONDecodeError) as error:
        print(f"FAIL {error}", file=sys.stderr)
        return 1
    print(f"OK {args.scope} contract")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
