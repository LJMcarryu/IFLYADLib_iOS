#!/usr/bin/env python3
"""校验 6.2.2 通用分发清单、版本状态与 10 资产静态契约。"""

from __future__ import annotations

import argparse
import re
import sys
from pathlib import Path
from urllib.parse import urlparse


VERSION = "6.2.2"
REPOSITORY = "LJMcarryu/IFLYADLib_iOS"
EXPECTED = {
    "IFLYAdCore": (
        "IFLYAdCore.xcframework.zip",
        "__IFLYADLIB_6_2_2_CORE_CHECKSUM_PENDING__",
    ),
    "IFLYAdVideoUI": (
        "IFLYAdVideoUI.xcframework.zip",
        "__IFLYADLIB_6_2_2_VIDEO_UI_CHECKSUM_PENDING__",
    ),
    "IFLYAdBanner": (
        "IFLYAdBanner.xcframework.zip",
        "__IFLYADLIB_6_2_2_BANNER_CHECKSUM_PENDING__",
    ),
    "IFLYAdSplash": (
        "IFLYAdSplash.xcframework.zip",
        "__IFLYADLIB_6_2_2_SPLASH_CHECKSUM_PENDING__",
    ),
    "IFLYAdInterstitial": (
        "IFLYAdInterstitial.xcframework.zip",
        "__IFLYADLIB_6_2_2_INTERSTITIAL_CHECKSUM_PENDING__",
    ),
    "IFLYAdNativeFeed": (
        "IFLYAdNativeFeed.xcframework.zip",
        "__IFLYADLIB_6_2_2_NATIVE_FEED_CHECKSUM_PENDING__",
    ),
    "IFLYAdReward": (
        "IFLYAdReward.xcframework.zip",
        "__IFLYADLIB_6_2_2_REWARD_CHECKSUM_PENDING__",
    ),
}
OLD_621 = {
    "d7f6931fdc9613bb5497d122c1410b4768094da56e352fa32b0ac2979a07e6e0",
    "185b6e26b22a12e9776dae0e621e99f4722c42859f6d86ceed63cba51ba67213",
    "8432807c3c767f7c165de8a9517f70b0ed3e357b4c28ad75cdfd8829a64f4d8c",
    "58c7aab22624c4cfeda05f20271fa109051af063a50a7e624064fe80f1778427",
    "8a65097a81f8354a2c4ade78a09fc9e4dac6e3029a2e9990a94386594dc3205d",
    "6d33bc2876ac7a1f84ff84e1b78ba0ec5fe33cef489e2ad814858a6c845176aa",
    "2b7b94447fbe50f24c20f25c324cda98285d8ced3050ed8a0c56561d99419a3d",
}
COMBINED_SHA = "f24cf6ea1d4e4319fbcef0fdb79a29aee5906f9bc35d81453052a6341379a673"
RELEASE_MODES = {"local", "candidate", "tag", "formal"}


def read(root: Path, relative: str) -> str:
    return (root / relative).read_text(encoding="utf-8")


def verify(root: Path, version: str, mode: str) -> str:
    if version != VERSION:
        raise AssertionError(f"本门禁只接受版本 {VERSION}，实际为 {version}")
    if mode not in RELEASE_MODES:
        raise AssertionError(f"非法 CI 发布模式: {mode}")

    readme = read(root, "README.md")
    changelog = read(root, "CHANGELOG.md")
    releasing = read(root, "RELEASING.md")
    security = read(root, "SECURITY.md")
    package = read(root, "Package.swift")

    blocks = re.findall(
        r'\.binaryTarget\(\s*name:\s*"([^"]+)"\s*,'
        r'\s*url:\s*"([^"]+)"\s*,'
        r'\s*checksum:\s*"([^"]+)"\s*\)',
        package,
        re.S,
    )
    assert len(blocks) == 7, f"binaryTarget 数量不是 7：{len(blocks)}"
    assert {name for name, _, _ in blocks} == set(EXPECTED), blocks

    checksums: dict[str, str] = {}
    module_assets: set[str] = set()
    for name, url, checksum in blocks:
        expected_asset, _ = EXPECTED[name]
        asset = Path(urlparse(url).path).name
        assert asset == expected_asset, (name, asset, expected_asset)
        expected_url = (
            f"https://github.com/{REPOSITORY}/releases/download/"
            f"{version}/{expected_asset}"
        )
        assert url == expected_url, f"{name} URL 非预期：{url}"
        module_assets.add(asset)
        checksums[name] = checksum

    all_pending = all(checksums[name] == EXPECTED[name][1] for name in EXPECTED)
    all_final = all(
        re.fullmatch(r"[0-9a-f]{64}", checksums[name])
        and checksums[name] != "0" * 64
        and checksums[name] not in OLD_621
        for name in EXPECTED
    )
    assert all_pending or all_final, (
        "7 个 checksum 必须全部是精确 PENDING，或全部是本版非零、"
        "非 6.2.1 的 64 位小写 SHA-256；不得混用"
    )
    if mode != "local":
        assert all_final, f"{mode} 模式禁止保留 PENDING checksum"

    if all_pending:
        assert mode == "local"
        assert "最新正式版仍是 `6.2.1`" in readme
        assert re.search(r"^## \[6\.2\.2\] - 待发布\s*$", changelog, re.M)
        assert "`main` 正在准备 `6.2.2`" in releasing
        assert "`6.2.2` 发布准备" in security
        state = "准备"
    else:
        for label, document in (
            ("README", readme),
            ("CHANGELOG", changelog),
            ("RELEASING", releasing),
        ):
            assert document.count(COMBINED_SHA) == 1, (
                f"{label} 必须唯一记录正式合并包 SHA-256"
            )

        if mode in {"tag", "formal"}:
            assert "当前最新公开正式版为 `IFLYADLib 6.2.2`" in readme
            assert "已于 2026-08-10 正式发布" in readme
            assert "actions/runs/31347794760" in readme
            assert re.search(r"^## \[6\.2\.2\] - 2026-08-10\s*$", changelog, re.M)
            assert "当前最新公开正式版是 [`6.2.2`]" in releasing
            assert "actions/runs/31347794760" in releasing
            assert "最新公开正式版本（当前为 `6.2.2`）" in security
            stale_markers = (
                "最新公开正式版仍是 `6.2.1`",
                "无 Token 匿名下载和最终消费验证尚未完成",
                "6.2.2] - 待发布",
                "`6.2.2` 正式资产准备",
            )
            for marker in stale_markers:
                assert marker not in readme + changelog + releasing + security, marker
            state = "正式发布复验"
        elif mode == "candidate":
            state = "Draft candidate 预验"
        else:
            state = "已冻结资产或已发布资产"

    assert len(set(checksums.values())) == 7, "7 个模块 checksum/PENDING 必须唯一"

    podspec = read(root, "IFLYADLib.podspec")
    pod_version = re.search(r"s\.version\s*=\s*'([^']+)'", podspec)
    pod_sources = re.findall(r":http\s*=>\s*'([^']+)'", podspec)
    assert pod_version and pod_version.group(1) == version, pod_version
    assert len(pod_sources) == 1, f"podspec :http source 数量不是 1：{pod_sources}"
    pod_source = pod_sources[0]
    combined = Path(urlparse(pod_source).path).name
    assert combined == f"IFLYADLib-modelA-{version}.zip", combined
    expected_combined_url = (
        f"https://github.com/{REPOSITORY}/releases/download/"
        f"{version}/{combined}"
    )
    assert pod_source == expected_combined_url, f"podspec 合并包 URL 非预期：{pod_source}"

    release_assets = module_assets | {
        combined,
        "checksums.txt",
        "binary-targets.remote.swift",
    }
    assert len(release_assets) == 10, release_assets

    podfile = read(root, "IFLYADLibSimple/Podfile")
    if mode in {"tag", "formal"}:
        for marker in (
            "tag/Release 尚未创建",
            "资产未上传",
            "公开 tag/Release 创建并完成匿名下载复验前",
            "这些 URL 仍不可用于远程依赖解析",
        ):
            assert marker not in package + podfile, marker
    expected_podspec_url = (
        f"https://raw.githubusercontent.com/{REPOSITORY}/"
        f"{version}/IFLYADLib.podspec"
    )
    active_podspec_urls = re.findall(
        r"(?m)^[ \t]*pod 'IFLYADLib', :podspec => '([^']+)'[ \t]*$",
        podfile,
    )
    assert active_podspec_urls == [expected_podspec_url], (
        f"Demo 活跃 :podspec 依赖非预期：{active_podspec_urls}"
    )
    return state


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--repository-root", type=Path, default=Path.cwd())
    parser.add_argument("--version", required=True)
    parser.add_argument("--mode", choices=sorted(RELEASE_MODES), required=True)
    args = parser.parse_args()
    try:
        state = verify(args.repository_root.resolve(), args.version, args.mode)
    except (AssertionError, OSError, ValueError) as error:
        print(f"FAIL {error}", file=sys.stderr)
        return 1
    print(f"OK {state}：7 模块 + 合并包 + checksums.txt + binary-targets.remote.swift")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
