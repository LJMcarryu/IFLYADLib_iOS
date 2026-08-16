from __future__ import annotations

import subprocess
import sys
import tempfile
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
SCRIPTS = ROOT / "scripts"
sys.path.insert(0, str(SCRIPTS))

from verify_distribution_manifest import (  # noqa: E402
    EXPECTED,
    PREVIOUS_CHECKSUMS,
    RELEASE_DATE,
    VERSION,
    verify,
)


CONTRACT_FILES = (
    "README.md",
    "CHANGELOG.md",
    "RELEASING.md",
    "SECURITY.md",
    "Package.swift",
    "IFLYADLib.podspec",
    "IFLYADLibSimple/README.md",
    "IFLYADLibSimple/Podfile",
)


def pending_contract_commit() -> str:
    commits = subprocess.run(
        ["git", "rev-list", "HEAD", "--", "RELEASING.md"],
        cwd=ROOT,
        check=True,
        capture_output=True,
        text=True,
    ).stdout.splitlines()
    for commit in commits:
        releasing = subprocess.run(
            ["git", "show", f"{commit}:RELEASING.md"],
            cwd=ROOT,
            check=True,
            capture_output=True,
            text=True,
        ).stdout
        if "- `releaseState`：`PENDING`" in releasing:
            return commit
    raise AssertionError("Git 历史中找不到 6.2.3 PENDING 契约基线")


def copy_contract_files(destination: Path) -> None:
    commit = pending_contract_commit()
    for relative in CONTRACT_FILES:
        target = destination / relative
        target.parent.mkdir(parents=True, exist_ok=True)
        contents = subprocess.run(
            ["git", "show", f"{commit}:{relative}"],
            cwd=ROOT,
            check=True,
            capture_output=True,
        ).stdout
        target.write_bytes(contents)


def replace_all_pending_checksums(root: Path, checksums: list[str]) -> None:
    package = root / "Package.swift"
    source = package.read_text(encoding="utf-8")
    for (_, pending), checksum in zip(EXPECTED.values(), checksums, strict=True):
        source = source.replace(f'checksum: "{pending}"', f'checksum: "{checksum}"', 1)
    package.write_text(source, encoding="utf-8")


def make_frozen_repository(root: Path) -> None:
    final_checksums = [f"{index:064x}" for index in range(1, 8)]
    replace_all_pending_checksums(root, final_checksums)
    binary = "c" * 40
    metadata = "d" * 40
    combined_sha256 = "e" * 64
    replacements = {
        "README.md": (
            ("> **6.2.3 准备边界**：版本清单已切换到精确 PENDING checksum 与 A/B 占位；正式签名资产、tag、Release 和匿名消费验证均未生成，当前 `6.2.3` URL 不可用于生产依赖。", f"> **6.2.3 冻结边界**：正式签名资产已从提交 A 构建并冻结；`IFLYADLib-modelA-6.2.3.zip` 的冻结 SHA-256 为 `{combined_sha256}`。tag、Release 与匿名消费验证尚未完成，当前 URL 不可用于生产依赖。"),
            ("`releaseState=PENDING` 明确表示 `6.2.3` 不能发布；不得复用 `6.2.2` 的 checksum 或 A/B 提交。上文 `6.2.2` 的 tag、Release 与终验证据继续作为历史正式事实保留。", "`releaseState=FORMAL` 只表示本版正式资产与发布元数据已冻结，不表示 tag、Release 或匿名消费验证已完成。"),
            ("- 当前 `Package.swift` 的 7 个 checksum 均为本版精确 PENDING 占位，尚未生成或核对；正式签名 zip 冻结后须整体回填，并在 Release 创建后与匿名下载件逐项复验。", "- `Package.swift` 的 7 个 checksum 已与冻结资产逐项核对；Release 创建后仍须复验匿名下载件。"),
        ),
        "CHANGELOG.md": (
            ("- 正式签名资产、7 个 SwiftPM checksum、tag、Release 与匿名消费验证尚未生成；不得将本节写成已发布。", f"- 正式签名资产和 7 个 SwiftPM checksum 已冻结；`IFLYADLib-modelA-6.2.3.zip` 的冻结 SHA-256 为 `{combined_sha256}`。tag、Release 与匿名消费验证尚未完成。"),
        ),
        "RELEASING.md": (
            ("当前最新公开正式版仍是 [`6.2.2`](https://github.com/LJMcarryu/IFLYADLib_iOS/releases/tag/6.2.2)（2026-08-10）。`main` 正在准备 `6.2.3`；该版正式资产、checksum、tag、Release 与匿名消费验证均未生成。", f"当前最新公开正式版仍是 [`6.2.2`]（2026-08-10）。`6.2.3` 正式资产和 checksum 已冻结；`IFLYADLib-modelA-6.2.3.zip` 的冻结 SHA-256 为 `{combined_sha256}`，但 tag、Release 与匿名消费验证尚未完成。"),
            ("`releaseState=PENDING` 明确禁止候选、tag 或 Release 消费。正式产物冻结后必须整体回填 7 个 checksum 与两个不同的真实 A/B 提交；不得沿用 `6.2.2` 的值。", "`releaseState=FORMAL` 只表示本版正式资产与发布元数据已冻结，不表示 tag、Release 或匿名消费验证已完成。"),
        ),
        "Package.swift": (
            ("// 下列 checksum 为 6.2.3 唯一 PENDING 占位；正式签名 zip 冻结后必须整体回填，", "// 下列 checksum 来自 6.2.3 正式签名 zip。"),
        ),
    }
    provenance_replacements = (
        ("- `releaseState`：`PENDING`", "- `releaseState`：`FORMAL`"),
        ("__IFLYADLIB_6_2_3_BINARY_SOURCE_COMMIT_PENDING__", binary),
        ("__IFLYADLIB_6_2_3_RELEASE_METADATA_COMMIT_PENDING__", metadata),
    )
    for relative, pairs in replacements.items():
        path = root / relative
        source = path.read_text(encoding="utf-8")
        for old, new in pairs:
            assert source.count(old) == 1, f"{relative} 测试夹具替换项非唯一：{old}"
            source = source.replace(old, new, 1)
        if relative in {"README.md", "CHANGELOG.md", "RELEASING.md"}:
            for old, new in provenance_replacements:
                assert source.count(old) == 1, (
                    f"{relative} provenance 测试夹具替换项非唯一：{old}"
                )
                source = source.replace(old, new, 1)
        path.write_text(source, encoding="utf-8")


def make_published_repository(root: Path) -> None:
    make_frozen_repository(root)
    replacements = {
        "README.md": (
            ("当前最新公开正式版仍为 `IFLYADLib 6.2.2`；`main` 正在准备全渠道共享优化版 `6.2.3`", f"当前最新公开正式版为 `IFLYADLib 6.2.3`，已于 {RELEASE_DATE} 正式发布"),
            ("tag、Release 与匿名消费验证尚未完成，当前 URL 不可用于生产依赖。", "10 个资产已完成匿名下载复验。"),
            ("`releaseState=FORMAL` 只表示本版正式资产与发布元数据已冻结，不表示 tag、Release 或匿名消费验证已完成。", "`releaseState=FORMAL` 表示本版正式资产与发布元数据已冻结，公开发布另由不可变 tag、Release 与匿名下载终验证明。"),
            ("| 6.2.3 | 待发布 |", f"| 6.2.3 | {RELEASE_DATE} |"),
            ("- `Package.swift` 的 7 个 checksum 已与冻结资产逐项核对；Release 创建后仍须复验匿名下载件。", "- `Package.swift` 的 7 个 checksum 已与冻结资产和匿名下载件逐项核对。"),
        ),
        "CHANGELOG.md": (
            ("## [6.2.3] - 待发布", f"## [6.2.3] - {RELEASE_DATE}"),
            ("tag、Release 与匿名消费验证尚未完成。", "tag、Release 与匿名下载复验均已完成。"),
        ),
        "RELEASING.md": (
            (f"当前最新公开正式版仍是 [`6.2.2`]（2026-08-10）。`6.2.3` 正式资产和 checksum 已冻结；`IFLYADLib-modelA-6.2.3.zip` 的冻结 SHA-256 为 `{'e' * 64}`，但 tag、Release 与匿名消费验证尚未完成。", f"当前最新公开正式版是 [`6.2.3`]（{RELEASE_DATE}）。`IFLYADLib-modelA-6.2.3.zip` 的冻结 SHA-256 为 `{'e' * 64}`，并已完成匿名下载复验。"),
            ("`releaseState=FORMAL` 只表示本版正式资产与发布元数据已冻结，不表示 tag、Release 或匿名消费验证已完成。", "`releaseState=FORMAL` 表示本版正式资产与发布元数据已冻结，公开发布另由不可变 tag、Release 与匿名下载终验证明。"),
        ),
        "SECURITY.md": (
            ("最新公开正式版本（当前为 `6.2.2`）", "最新公开正式版本（当前为 `6.2.3`）"),
            ("### `6.2.3` 发布准备\n\n`6.2.3` 当前为 `PENDING`，尚无可验证正式资产、tag 或 Release，不属于受支持的公开正式版本。", f"`6.2.3` 已于 {RELEASE_DATE} 完成发布与匿名消费验证。"),
        ),
        "IFLYADLibSimple/README.md": (
            ("当前清单为 `6.2.3` 发布准备版本，正式资产、tag 和 Release 尚不存在；生产项目继续使用已发布的 `6.2.2`。", f"当前示例固定到已于 {RELEASE_DATE} 正式发布的 `6.2.3`。"),
            ("Podfile 已预置待发布 `6.2.3` tag 的 `:podspec`；正式资产公开前 `pod install` 失败是预期结果。", "Podfile 已预置不可变 `6.2.3` tag 的 `:podspec`。"),
        ),
        "IFLYADLibSimple/Podfile": (
            ("# IFLYADLib 6.2.3 正在准备；正式资产、tag 和 Release 尚不存在，当前远程依赖不可用。", "# IFLYADLib 6.2.3 已正式发布并完成匿名消费复验；本示例固定到不可变 tag。"),
        ),
    }
    for relative, pairs in replacements.items():
        path = root / relative
        source = path.read_text(encoding="utf-8")
        for old, new in pairs:
            assert source.count(old) == 1, f"{relative} 发布后夹具替换项非唯一：{old}"
            source = source.replace(old, new, 1)
        path.write_text(source, encoding="utf-8")


class DistributionManifestTests(unittest.TestCase):
    def test_current_repository_matches_declared_release_state(self) -> None:
        releasing = (ROOT / "RELEASING.md").read_text(encoding="utf-8")
        if "- `releaseState`：`PENDING`" in releasing:
            self.assertEqual(verify(ROOT, VERSION, "local"), "准备")
            for mode in ("candidate", "tag", "formal"):
                with self.subTest(mode=mode), self.assertRaisesRegex(
                    AssertionError, "禁止保留 PENDING"
                ):
                    verify(ROOT, VERSION, mode)
            return

        self.assertIn("- `releaseState`：`FORMAL`", releasing)
        local_state = verify(ROOT, VERSION, "local")
        if local_state == "已发布资产本地复验":
            for mode in ("candidate", "tag", "formal"):
                with self.subTest(mode=mode), self.assertRaisesRegex(
                    AssertionError, "冻结态不得宣称已正式发布"
                ):
                    verify(ROOT, VERSION, mode)
            return

        self.assertEqual(local_state, "已冻结正式资产")
        self.assertEqual(
            verify(ROOT, VERSION, "candidate"),
            "Draft candidate 冻结资产预验",
        )
        self.assertEqual(
            verify(ROOT, VERSION, "tag"),
            "不可变 tag 冻结资产复验",
        )
        self.assertEqual(
            verify(ROOT, VERSION, "formal"),
            "正式 Release 冻结文档与清单复验",
        )

    def test_frozen_repository_passes_local_candidate_and_tag_modes(self) -> None:
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            copy_contract_files(root)
            make_frozen_repository(root)

            self.assertEqual(verify(root, VERSION, "local"), "已冻结正式资产")
            self.assertEqual(
                verify(root, VERSION, "candidate"),
                "Draft candidate 冻结资产预验",
            )
            self.assertEqual(
                verify(root, VERSION, "tag"),
                "不可变 tag 冻结资产复验",
            )

    def test_frozen_repository_passes_formal_static_mode(self) -> None:
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            copy_contract_files(root)
            make_frozen_repository(root)

            self.assertEqual(
                verify(root, VERSION, "formal"),
                "正式 Release 冻结文档与清单复验",
            )

    def test_published_repository_passes_local_mode_but_not_release_tag_mode(self) -> None:
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            copy_contract_files(root)
            make_published_repository(root)

            self.assertEqual(verify(root, VERSION, "local"), "已发布资产本地复验")
            with self.assertRaisesRegex(
                AssertionError, "冻结态缺少发布事实|冻结态不得宣称"
            ):
                verify(root, VERSION, "formal")

    def test_candidate_rejects_published_claims(self) -> None:
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            copy_contract_files(root)
            make_published_repository(root)

            with self.assertRaisesRegex(AssertionError, "冻结态缺少发布事实|冻结态不得宣称"):
                verify(root, VERSION, "candidate")

    def test_published_repository_rejects_pending_wording(self) -> None:
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            copy_contract_files(root)
            make_published_repository(root)
            readme = root / "README.md"
            readme.write_text(
                readme.read_text(encoding="utf-8")
                + "\n正式签名资产、tag、Release 和匿名消费验证均未生成\n",
                encoding="utf-8",
            )

            with self.assertRaisesRegex(AssertionError, "残留未发布文案"):
                verify(root, VERSION, "local")

    def test_formal_repository_rejects_historical_checksum(self) -> None:
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            copy_contract_files(root)
            make_frozen_repository(root)
            checksums = [next(iter(PREVIOUS_CHECKSUMS))] + [
                f"{index:064x}" for index in range(2, 8)
            ]
            package = root / "Package.swift"
            source = package.read_text(encoding="utf-8")
            source = source.replace('checksum: "' + f"{1:064x}" + '"', 'checksum: "' + checksums[0] + '"', 1)
            package.write_text(source, encoding="utf-8")

            with self.assertRaisesRegex(AssertionError, "不得混用"):
                verify(root, VERSION, "candidate")

    def test_formal_repository_rejects_historical_combined_sha256(self) -> None:
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            copy_contract_files(root)
            make_frozen_repository(root)
            for relative in ("README.md", "CHANGELOG.md", "RELEASING.md"):
                path = root / relative
                source = path.read_text(encoding="utf-8")
                path.write_text(
                    source.replace("e" * 64, "f24cf6ea1d4e4319fbcef0fdb79a29aee5906f9bc35d81453052a6341379a673"),
                    encoding="utf-8",
                )

            with self.assertRaisesRegex(AssertionError, "禁止沿用历史合并包"):
                verify(root, VERSION, "candidate")

    def test_current_section_rejects_historical_review_policy(self) -> None:
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            copy_contract_files(root)
            readme = root / "README.md"
            source = readme.read_text(encoding="utf-8")
            readme.write_text(
                source.replace("failOnWarning=true", "failOnWarning=false", 1),
                encoding="utf-8",
            )

            with self.assertRaisesRegex(AssertionError, "严格扫描策略"):
                verify(root, VERSION, "local")

    def test_rejects_binary_target_on_different_host(self) -> None:
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            copy_contract_files(root)
            package = root / "Package.swift"
            package.write_text(
                package.read_text(encoding="utf-8").replace(
                    "https://github.com/LJMcarryu/IFLYADLib_iOS/releases/download/",
                    "https://downloads.example/releases/download/",
                    1,
                ),
                encoding="utf-8",
            )

            with self.assertRaisesRegex(AssertionError, "URL 非预期"):
                verify(root, VERSION, "local")

    def test_rejects_podspec_combined_asset_on_different_host(self) -> None:
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            copy_contract_files(root)
            podspec = root / "IFLYADLib.podspec"
            podspec.write_text(
                podspec.read_text(encoding="utf-8").replace(
                    "https://github.com/LJMcarryu/IFLYADLib_iOS/releases/download/",
                    "https://downloads.example/releases/download/",
                    1,
                ),
                encoding="utf-8",
            )

            with self.assertRaisesRegex(AssertionError, "合并包 URL 非预期"):
                verify(root, VERSION, "local")

    def test_rejects_demo_podspec_url_only_present_in_comment(self) -> None:
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            copy_contract_files(root)
            podfile = root / "IFLYADLibSimple/Podfile"
            source = podfile.read_text(encoding="utf-8")
            active = (
                "  pod 'IFLYADLib', :podspec => "
                "'https://raw.githubusercontent.com/LJMcarryu/"
                "IFLYADLib_iOS/6.2.3/IFLYADLib.podspec'"
            )
            podfile.write_text(
                source.replace(
                    active,
                    "  pod 'IFLYADLib', :podspec => "
                    "'https://downloads.example/IFLYADLib.podspec'",
                    1,
                ),
                encoding="utf-8",
            )

            with self.assertRaisesRegex(AssertionError, "活跃 :podspec"):
                verify(root, VERSION, "local")


if __name__ == "__main__":
    unittest.main()
