#!/usr/bin/env python3
"""校验 6.2.4 通用分发清单、版本状态与 10 资产静态契约。"""

from __future__ import annotations

import argparse
import re
import sys
from pathlib import Path
from urllib.parse import urlparse


VERSION = "6.2.4"
RELEASE_DATE = "2026-08-17"
REPOSITORY = "LJMcarryu/IFLYADLib_iOS"
EXPECTED = {
    "IFLYAdCore": (
        "IFLYAdCore.xcframework.zip",
        "__IFLYADLIB_6_2_4_CORE_CHECKSUM_PENDING__",
    ),
    "IFLYAdVideoUI": (
        "IFLYAdVideoUI.xcframework.zip",
        "__IFLYADLIB_6_2_4_VIDEO_UI_CHECKSUM_PENDING__",
    ),
    "IFLYAdBanner": (
        "IFLYAdBanner.xcframework.zip",
        "__IFLYADLIB_6_2_4_BANNER_CHECKSUM_PENDING__",
    ),
    "IFLYAdSplash": (
        "IFLYAdSplash.xcframework.zip",
        "__IFLYADLIB_6_2_4_SPLASH_CHECKSUM_PENDING__",
    ),
    "IFLYAdInterstitial": (
        "IFLYAdInterstitial.xcframework.zip",
        "__IFLYADLIB_6_2_4_INTERSTITIAL_CHECKSUM_PENDING__",
    ),
    "IFLYAdNativeFeed": (
        "IFLYAdNativeFeed.xcframework.zip",
        "__IFLYADLIB_6_2_4_NATIVE_FEED_CHECKSUM_PENDING__",
    ),
    "IFLYAdReward": (
        "IFLYAdReward.xcframework.zip",
        "__IFLYADLIB_6_2_4_REWARD_CHECKSUM_PENDING__",
    ),
}
PREVIOUS_CHECKSUMS = {
    "26cc27dc2aebce8bec5dac2d0840492eb022c2959585465f3d130ea52ddb50d5",
    "abfea29151c3e739d67b5221a2cc1da2bfbda1a1773d42e5418bd95f9c39c012",
    "adb21f48c17b20db44554a54ab696aed47380b7d474dd77e9911b126c9096678",
    "a55504f4781559a9d2697cf364a8ff86e2865f61f0701e0b78a775ac36da5d6c",
    "11c232e39b12de30421fc07076801b57e45a8a4d634840b135005b02658de632",
    "781d2e0c7bbca8ba11f26d1e038887cd698fc6d2be7bde472fae4bed9bc484b2",
    "6deb887ba912a2a6ec91ba281b394cbf43973dd53d3543737bcfd657f50cb2ce",
    "d7f6931fdc9613bb5497d122c1410b4768094da56e352fa32b0ac2979a07e6e0",
    "185b6e26b22a12e9776dae0e621e99f4722c42859f6d86ceed63cba51ba67213",
    "8432807c3c767f7c165de8a9517f70b0ed3e357b4c28ad75cdfd8829a64f4d8c",
    "58c7aab22624c4cfeda05f20271fa109051af063a50a7e624064fe80f1778427",
    "8a65097a81f8354a2c4ade78a09fc9e4dac6e3029a2e9990a94386594dc3205d",
    "6d33bc2876ac7a1f84ff84e1b78ba0ec5fe33cef489e2ad814858a6c845176aa",
    "2b7b94447fbe50f24c20f25c324cda98285d8ced3050ed8a0c56561d99419a3d",
    "397b10feb631331bf8edf2491cf4b66513d5662432d151c68c9a832154a35661",
    "f01b7c4c6829029935c34ef32186b1359ec2298630de4663896576e348325a77",
    "abea4cd9e38f443b7f8fa363e75cd857f4e6835cbafcd99582cd817747e27bb1",
    "0e2885577f73636c290245108f91b4335e6a92ef74257ee85d8a7433f1401a27",
    "8e97a74dfa63400273036bd0d33f1ff111c882ba9a292654570574fc4be3362d",
    "bfd00324f2d91803c9e3939c09b64f5c80c2f1f7a09fe839f1c14b6945e08844",
    "8ef01583768f7d2b1c7f9a6089ddad3a7dc2c5d689a6af680a2842feec1d0759",
}
PREVIOUS_COMBINED_SHA256 = {
    "f24cf6ea1d4e4319fbcef0fdb79a29aee5906f9bc35d81453052a6341379a673",
    "f6331ecf01aa902b5831a62ea8e205799c4301aa689f87bc216c0d1798e6f469",
}
RELEASE_MODES = {"local", "candidate", "tag", "formal"}
PENDING_IDENTITY_MARKERS = (
    "- `releaseState`：`PENDING`",
    "__IFLYADLIB_6_2_4_BINARY_SOURCE_COMMIT_PENDING__",
    "__IFLYADLIB_6_2_4_RELEASE_METADATA_COMMIT_PENDING__",
    "下列 checksum 为 6.2.4 唯一 PENDING 占位",
)
PREPUBLICATION_MARKERS = (
    "最新公开正式版仍为 `IFLYADLib 6.2.3`",
    "`main` 正在准备全渠道共享优化版 `6.2.4`",
    "正式签名资产、tag、Release 和匿名消费验证均未生成",
    "当前 `6.2.4` URL 不可用于生产依赖",
    "## [6.2.4] - 待发布",
    "正式签名资产、7 个 SwiftPM checksum、tag、Release 与匿名消费验证尚未生成",
    "`main` 正在准备 `6.2.4`",
    "该版正式资产、checksum、tag、Release 与匿名消费验证均未生成",
    "### `6.2.4` 发布准备",
    "`6.2.4` 当前为 `PENDING`",
    "正式资产、tag 和 Release 尚不存在",
    "正式资产公开前 `pod install` 失败是预期结果",
    "正式资产、tag 和 Release 尚不存在，当前远程依赖不可用",
)
FROZEN_REQUIRED_MARKERS = {
    "README": (
        "- `releaseState`：`FORMAL`",
        "当前最新公开正式版仍为 `IFLYADLib 6.2.3`",
        "IFLYADLib-modelA-6.2.4.zip",
        "冻结 SHA-256",
    ),
    "CHANGELOG": (
        "- `releaseState`：`FORMAL`",
        "## [6.2.4] - 待发布",
        "IFLYADLib-modelA-6.2.4.zip",
        "冻结 SHA-256",
    ),
    "RELEASING": (
        "- `releaseState`：`FORMAL`",
        "当前最新公开正式版仍是 [`6.2.3`]",
        "IFLYADLib-modelA-6.2.4.zip",
        "冻结 SHA-256",
    ),
    "SECURITY": (
        "最新公开正式版本（当前为 `6.2.3`）",
        "不属于受支持的公开正式版本",
    ),
    "DEMO": (
        "生产项目继续使用已发布的 `6.2.3`",
    ),
}
PUBLISHED_REQUIRED_MARKERS = {
    "README": (
        "- `releaseState`：`FORMAL`",
        "当前最新公开正式版为 `IFLYADLib 6.2.4`",
        f"已于 {RELEASE_DATE} 正式发布",
        "IFLYADLib-modelA-6.2.4.zip",
        "冻结 SHA-256",
        "匿名下载",
    ),
    "CHANGELOG": (
        "- `releaseState`：`FORMAL`",
        f"## [6.2.4] - {RELEASE_DATE}",
        "IFLYADLib-modelA-6.2.4.zip",
        "冻结 SHA-256",
        "匿名下载",
    ),
    "RELEASING": (
        "- `releaseState`：`FORMAL`",
        "当前最新公开正式版是 [`6.2.4`]",
        "IFLYADLib-modelA-6.2.4.zip",
        "冻结 SHA-256",
        "匿名下载",
    ),
    "SECURITY": (
        "最新公开正式版本（当前为 `6.2.4`）",
        f"`6.2.4` 已于 {RELEASE_DATE}",
    ),
    "DEMO": (
        f"已于 {RELEASE_DATE} 正式发布的 `6.2.4`",
        "不可变 `6.2.4` tag",
    ),
    "PODFILE": (
        "IFLYADLib 6.2.4 已正式发布并完成匿名消费复验",
        "不可变 tag",
    ),
}
PUBLISHED_CLAIM_MARKERS = (
    "当前最新公开正式版为 `IFLYADLib 6.2.4`",
    f"## [6.2.4] - {RELEASE_DATE}",
    "当前最新公开正式版是 [`6.2.4`]",
    "最新公开正式版本（当前为 `6.2.4`）",
    f"`6.2.4` 已于 {RELEASE_DATE}",
    f"已于 {RELEASE_DATE} 正式发布的 `6.2.4`",
    "IFLYADLib 6.2.4 已正式发布并完成匿名消费复验",
)
STRICT_REVIEW_POLICY = (
    "failOn=high`、`failOnWarning=true`、`strict=true`、"
    "`requireManual=true` 且接受名单为空"
)
RISK_AUTHORIZATION_BOUNDARY = "`6.2.4` 不沿用历史版本的启发式风险授权"
HISTORICAL_REVIEW_POLICY_MARKERS = (
    "failOnWarning=false",
    "strict=false",
    "requireManual=false",
)


def read(root: Path, relative: str) -> str:
    return (root / relative).read_text(encoding="utf-8")


def current_version_section(document: str, label: str) -> str:
    heading = re.compile(
        rf"^##[ \t]+(?:\[{re.escape(VERSION)}\]|{re.escape(VERSION)})(?:[ \t]|$).*$",
        re.M,
    )
    matches = list(heading.finditer(document))
    assert len(matches) == 1, f"{label} 必须唯一声明 {VERSION} 二级章节"
    start = matches[0].start()
    following = re.search(r"^#{1,2}[ \t]+", document[matches[0].end():], re.M)
    end = matches[0].end() + following.start() if following else len(document)
    return document[start:end]


def require_formal_combined_sha256(
    documents: dict[str, str], checksums: dict[str, str]
) -> str:
    values: dict[str, str] = {}
    pattern = re.compile(
        rf"IFLYADLib-modelA-{re.escape(VERSION)}\.zip"
        r".{0,300}?冻结 SHA-256(?: 为|：)?\s*`([0-9a-f]{64})`",
        re.S,
    )
    for label in ("README", "CHANGELOG", "RELEASING"):
        matches = pattern.findall(documents[label])
        assert len(matches) == 1, f"{label} 必须唯一记录本版正式合并包 SHA-256"
        values[label] = matches[0]
    assert len(set(values.values())) == 1, f"正式合并包 SHA-256 文档不一致：{values}"
    combined_sha256 = next(iter(values.values()))
    assert combined_sha256 not in PREVIOUS_COMBINED_SHA256, "禁止沿用历史合并包 SHA-256"
    assert combined_sha256 not in checksums.values(), "合并包 SHA-256 不得冒充模块 checksum"
    return combined_sha256


def stage_document(document: str, label: str) -> str:
    if label in {"README", "CHANGELOG", "RELEASING"}:
        return current_version_section(document, label)
    return document


def require_markers(
    documents: dict[str, str], expected: dict[str, tuple[str, ...]], stage: str
) -> None:
    for label, markers in expected.items():
        scoped = stage_document(documents[label], label)
        for marker in markers:
            assert marker in scoped, f"{label} {stage}缺少发布事实：{marker}"


def require_formal_identity(documents: dict[str, str], package: str) -> None:
    for label in ("README", "CHANGELOG", "RELEASING"):
        current = current_version_section(documents[label], label)
        assert "- `releaseState`：`FORMAL`" in current, (
            f"{label} 的 {VERSION} 章节未声明 releaseState=FORMAL"
        )
        for marker in PENDING_IDENTITY_MARKERS:
            assert marker not in current, f"{label} 正式资产冻结态残留 PENDING 身份：{marker}"
    for marker in PENDING_IDENTITY_MARKERS:
        assert marker not in package, f"Package.swift 正式资产冻结态残留 PENDING 身份：{marker}"


def require_frozen_prepublication(
    documents: dict[str, str], package: str, checksums: dict[str, str]
) -> None:
    require_formal_identity(documents, package)
    current_documents = "\n".join(
        stage_document(documents[label], label) for label in documents
    )
    for marker in PUBLISHED_CLAIM_MARKERS:
        assert marker not in current_documents, (
            f"冻结态不得宣称已正式发布或完成发布后验证：{marker}"
        )
    require_markers(documents, FROZEN_REQUIRED_MARKERS, "冻结态")
    require_formal_combined_sha256(documents, checksums)


def has_published_claim(documents: dict[str, str]) -> bool:
    text = "\n".join(stage_document(document, label) for label, document in documents.items())
    return any(marker in text for marker in PUBLISHED_CLAIM_MARKERS)


def require_published(
    documents: dict[str, str], package: str, checksums: dict[str, str]
) -> None:
    require_formal_identity(documents, package)
    require_markers(documents, PUBLISHED_REQUIRED_MARKERS, "发布后态")
    for marker in PREPUBLICATION_MARKERS:
        assert marker not in "\n".join(documents.values()) + package, (
            f"发布后态残留未发布文案：{marker}"
        )
    require_formal_combined_sha256(documents, checksums)


def verify(root: Path, version: str, mode: str) -> str:
    if version != VERSION:
        raise AssertionError(f"本门禁只接受版本 {VERSION}，实际为 {version}")
    if mode not in RELEASE_MODES:
        raise AssertionError(f"非法 CI 发布模式: {mode}")

    readme = read(root, "README.md")
    changelog = read(root, "CHANGELOG.md")
    releasing = read(root, "RELEASING.md")
    security = read(root, "SECURITY.md")
    demo_readme = read(root, "IFLYADLibSimple/README.md")
    podfile = read(root, "IFLYADLibSimple/Podfile")
    package = read(root, "Package.swift")
    for label, document in (("README", readme), ("RELEASING", releasing)):
        current = current_version_section(document, label)
        assert STRICT_REVIEW_POLICY in current, f"{label} 缺少 6.2.4 严格扫描策略"
        assert RISK_AUTHORIZATION_BOUNDARY in current, (
            f"{label} 缺少 6.2.4 不沿用历史风险授权的边界"
        )
        leaked = [marker for marker in HISTORICAL_REVIEW_POLICY_MARKERS if marker in current]
        assert not leaked, f"{label} 的 6.2.4 章节沿用了历史扫描策略：{leaked}"

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
        and checksums[name] not in PREVIOUS_CHECKSUMS
        for name in EXPECTED
    )
    assert all_pending or all_final, (
        "7 个 checksum 必须全部是精确 PENDING，或全部是本版非零、"
        "非历史版本的 64 位小写 SHA-256；不得混用"
    )
    if mode != "local":
        assert all_final, f"{mode} 模式禁止保留 PENDING checksum"

    if all_pending:
        assert mode == "local"
        assert "当前最新公开正式版仍为 `IFLYADLib 6.2.3`" in readme
        assert re.search(r"^## \[6\.2\.4\] - 待发布\s*$", changelog, re.M)
        assert "`main` 正在准备 `6.2.4`" in releasing
        assert "`6.2.4` 发布准备" in security
        assert "尚未生成或核对" in readme
        state = "准备"
    else:
        documents = {
            "README": readme,
            "CHANGELOG": changelog,
            "RELEASING": releasing,
            "SECURITY": security,
            "DEMO": demo_readme,
            "PODFILE": podfile,
        }
        if mode == "local" and has_published_claim(documents):
            require_published(documents, package, checksums)
            state = "已发布资产本地复验"
        else:
            require_frozen_prepublication(documents, package, checksums)
            if mode == "candidate":
                state = "Draft candidate 冻结资产预验"
            elif mode == "tag":
                state = "不可变 tag 冻结资产复验"
            elif mode == "formal":
                # release.published 检出的是不可变 tag 提交；发布与匿名消费事实由
                # workflow 的公开 Release 元数据、无 Token 下载和消费 Job 动态证明。
                state = "正式 Release 冻结文档与清单复验"
            else:
                state = "已冻结正式资产"

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

    if mode == "formal":
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
