from __future__ import annotations

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
        self.assertEqual(verify(ROOT, VERSION, "local"), "已发布资产本地复验")
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

    def test_candidate_rejects_prepublication_claim(self) -> None:
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            copy_contract_files(root)
            readme = root / "README.md"
            source = readme.read_text(encoding="utf-8")
            source = source.replace(
                "当前最新公开正式版为 `IFLYADLib 6.3.0`",
                "当前最新公开正式版仍为 `IFLYADLib 6.2.4`",
                1,
            )
            readme.write_text(source, encoding="utf-8")
            with self.assertRaisesRegex(AssertionError, "发布后态缺少发布事实"):
                verify(root, VERSION, "candidate")

    def test_rejects_historical_module_checksum(self) -> None:
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            copy_contract_files(root)
            package = root / "Package.swift"
            source = package.read_text(encoding="utf-8")
            source = re.sub(
                r'checksum:\s*"[0-9a-f]{64}"',
                f'checksum: "{next(iter(PREVIOUS_CHECKSUMS))}"',
                source,
                count=1,
            )
            package.write_text(source, encoding="utf-8")
            with self.assertRaisesRegex(AssertionError, "不得混用"):
                verify(root, VERSION, "candidate")

    def test_rejects_historical_combined_sha256(self) -> None:
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            copy_contract_files(root)
            current = "fdf7c98bf1332b78cc6e2c7a840dd8cc804fb607e754cc457f969ce6e448a6f2"
            historical = next(iter(PREVIOUS_COMBINED_SHA256))
            for relative in ("README.md", "CHANGELOG.md", "RELEASING.md"):
                path = root / relative
                path.write_text(
                    path.read_text(encoding="utf-8").replace(current, historical),
                    encoding="utf-8",
                )
            with self.assertRaisesRegex(AssertionError, "禁止沿用历史合并包"):
                verify(root, VERSION, "candidate")

    def test_current_section_rejects_historical_review_policy(self) -> None:
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            copy_contract_files(root)
            readme = root / "README.md"
            readme.write_text(
                readme.read_text(encoding="utf-8").replace(
                    "failOnWarning=true", "failOnWarning=false", 1
                ),
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
