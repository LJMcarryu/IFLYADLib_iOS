from __future__ import annotations

import json
import re
import shutil
import sys
import tempfile
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
SCRIPTS = ROOT / "scripts"
sys.path.insert(0, str(SCRIPTS))

from verify_distribution_manifest import (  # noqa: E402
    PREVIOUS_CHECKSUMS,
    PREVIOUS_COMBINED_SHA256,
    PUBLIC_RELEASE_STATUS_RE,
    REPOSITORY,
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


def copy_contract_files(destination: Path) -> None:
    for relative in CONTRACT_FILES:
        target = destination / relative
        target.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(ROOT / relative, target)


class DistributionManifestTests(unittest.TestCase):
    def test_current_release_ready_repository_passes_all_static_modes(self) -> None:
        self.assertEqual(verify(ROOT, VERSION, "local"), "已冻结正式资产")
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

    def test_candidate_rejects_release_status_version_drift(self) -> None:
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            copy_contract_files(root)
            readme = root / "README.md"
            source = readme.read_text(encoding="utf-8")
            source = source.replace(
                f'"version":"{VERSION}"',
                '"version":"6.3.5"',
                1,
            )
            readme.write_text(source, encoding="utf-8")
            with self.assertRaisesRegex(AssertionError, "发布状态标记漂移"):
                verify(root, VERSION, "candidate")

    def test_public_podfile_comments_do_not_control_release_stage(self) -> None:
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            copy_contract_files(root)
            podfile = root / "IFLYADLibSimple/Podfile"
            podfile.write_text(
                "# IFLYADLib 6.3.5 已正式发布并完成匿名消费复验\n"
                + podfile.read_text(encoding="utf-8"),
                encoding="utf-8",
            )
            self.assertEqual(verify(root, VERSION, "candidate"), "Draft candidate 冻结资产预验")

    def test_restored_history_does_not_replace_current_frozen_hash(self) -> None:
        changelog = (ROOT / "CHANGELOG.md").read_text(encoding="utf-8")
        current, historical = changelog.split("## [6.3.5] - 冻结与发布记录", 1)
        previous_hash = "e98a475110012cbe7399238bee61956ae6fd7ac37108c79a63bd80919a326884"
        self.assertNotIn(previous_hash, current)
        self.assertIn(previous_hash, historical.split("## [6.3.1]", 1)[0])
        self.assertEqual(verify(ROOT, VERSION, "candidate"), "Draft candidate 冻结资产预验")

    def test_rejects_historical_module_checksum(self) -> None:
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            copy_contract_files(root)
            package = root / "Package.swift"
            source = package.read_text(encoding="utf-8")
            source = re.sub(
                r'checksum:\s*"[0-9a-f]{64}"',
                'checksum: "587a94d47380fc73398b8d31e7fa9e63c3954a90ee290e17dc763abb1b5bd77e"',
                source,
                count=1,
            )
            package.write_text(source, encoding="utf-8")
            with self.assertRaisesRegex(AssertionError, "不得混用"):
                verify(root, VERSION, "candidate")

    def test_previous_hash_sets_include_6_3_5_assets(self) -> None:
        self.assertIn(
            "587a94d47380fc73398b8d31e7fa9e63c3954a90ee290e17dc763abb1b5bd77e",
            PREVIOUS_CHECKSUMS,
        )
        self.assertIn(
            "e98a475110012cbe7399238bee61956ae6fd7ac37108c79a63bd80919a326884",
            PREVIOUS_COMBINED_SHA256,
        )

    def test_public_readme_does_not_require_internal_review_policy(self) -> None:
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            copy_contract_files(root)
            readme = root / "README.md"
            source = readme.read_text(encoding="utf-8")
            self.assertNotIn("failOnWarning=", source)
            self.assertEqual(verify(root, VERSION, "local"), "已冻结正式资产")

    def test_public_guides_do_not_require_release_engineering_prose(self) -> None:
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            copy_contract_files(root)
            path = root / "README.md"
            marker = PUBLIC_RELEASE_STATUS_RE.search(path.read_text(encoding="utf-8"))
            self.assertIsNotNone(marker)
            path.write_text(
                "# SDK 接入\n\n## 当前版本\n\n" + marker.group(0)
                + f"\n\n正式版本：[{VERSION}](https://github.com/{REPOSITORY}/releases/tag/{VERSION})\n",
                encoding="utf-8",
            )
            (root / "IFLYADLibSimple/README.md").write_text(
                f"# 示例工程\n\n本示例固定 SDK {VERSION}，安装后打开 workspace。\n",
                encoding="utf-8",
            )
            podfile = root / "IFLYADLibSimple/Podfile"
            podfile.write_text(
                "\n".join(line for line in podfile.read_text(encoding="utf-8").splitlines()
                          if not line.lstrip().startswith("#")) + "\n",
                encoding="utf-8",
            )
            self.assertEqual(verify(root, VERSION, "formal"), "正式 Release 冻结文档与清单复验")

    def test_public_readme_rejects_malformed_duplicate_or_drifted_markers(self) -> None:
        document = (ROOT / "README.md").read_text(encoding="utf-8")
        match = PUBLIC_RELEASE_STATUS_RE.search(document)
        self.assertIsNotNone(match)
        original = match.group(0)
        marker = json.loads(match.group(1))
        mutations = [
            "<!-- ifly-release-status: broken -->",
            original + "\n" + original,
            original + "\n<!-- ifly-release-status: broken -->",
            original.replace('"schemaVersion":1', '"schemaVersion":1,"schemaVersion":1'),
        ]
        for field, value in (
            ("schemaVersion", True),
            ("releaseState", "PENDING"),
            ("distribution", "trunk"),
            ("releaseUrl", f"https://github.com/other/repo/releases/tag/{VERSION}"),
            ("unexpected", "field"),
        ):
            changed = dict(marker, **{field: value})
            mutations.append("<!-- ifly-release-status: " + json.dumps(changed) + " -->")
        for replacement in mutations:
            with self.subTest(marker=replacement), tempfile.TemporaryDirectory() as temporary:
                root = Path(temporary)
                copy_contract_files(root)
                (root / "README.md").write_text(document.replace(original, replacement, 1), encoding="utf-8")
                with self.assertRaisesRegex(AssertionError, "发布状态标记"):
                    verify(root, VERSION, "local")

    def test_markerless_readme_still_requires_legacy_review_policy(self) -> None:
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            copy_contract_files(root)
            (root / "README.md").write_text(f"# SDK\n\n## {VERSION} 版本\n", encoding="utf-8")
            with self.assertRaisesRegex(
                AssertionError, rf"README 缺少 {re.escape(VERSION)} 严格扫描策略"
            ):
                verify(root, VERSION, "local")

    def test_public_guides_require_structured_release_status(self) -> None:
        for relative in ("CHANGELOG.md", "RELEASING.md"):
            with self.subTest(document=relative), tempfile.TemporaryDirectory() as temporary:
                root = Path(temporary)
                copy_contract_files(root)
                path = root / relative
                document = path.read_text(encoding="utf-8")
                marker = PUBLIC_RELEASE_STATUS_RE.search(document)
                self.assertIsNotNone(marker)
                path.write_text(document.replace(marker.group(0), "", 1), encoding="utf-8")
                with self.assertRaisesRegex(AssertionError, "发布状态标记漂移"):
                    verify(root, VERSION, "local")

    def test_public_demo_and_security_require_current_version(self) -> None:
        for relative in ("IFLYADLibSimple/README.md", "SECURITY.md"):
            with self.subTest(document=relative), tempfile.TemporaryDirectory() as temporary:
                root = Path(temporary)
                copy_contract_files(root)
                path = root / relative
                path.write_text(path.read_text(encoding="utf-8").replace(VERSION, "6.4.00"), encoding="utf-8")
                with self.assertRaisesRegex(AssertionError, "缺少当前版本"):
                    verify(root, VERSION, "local")

    def test_extra_or_mutable_demo_dependency_is_rejected(self) -> None:
        for dependency in (
            "pod 'IFLYADLib', :git => 'https://github.com/LJMcarryu/IFLYADLib_iOS.git'",
            "pod 'IFLYADLib/Core', :path => '../local-sdk'",
            "pod('IFLYADLib', :path => '../local-sdk')",
        ):
            with self.subTest(dependency=dependency), tempfile.TemporaryDirectory() as temporary:
                root = Path(temporary)
                copy_contract_files(root)
                path = root / "IFLYADLibSimple/Podfile"
                path.write_text(path.read_text(encoding="utf-8") + dependency + "\n", encoding="utf-8")
                with self.assertRaisesRegex(AssertionError, "活跃 :podspec"):
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
                f"IFLYADLib_iOS/{VERSION}/IFLYADLib.podspec'"
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
