from __future__ import annotations

import sys
import unittest
from pathlib import Path


SCRIPTS = Path(__file__).resolve().parents[1] / "scripts"
sys.path.insert(0, str(SCRIPTS))

from verify_private_release_provenance import (  # noqa: E402
    CURRENT_VERSION,
    PENDING_BINARY,
    PENDING_METADATA,
    VerificationError,
    parse_document,
    validate_release_body,
)


def record(state: str, binary: str, metadata: str) -> str:
    return (
        f"- `releaseState`：`{state}`\n"
        f"- `binarySourceCommit`（SDK 二进制源码提交）：`{binary}`\n"
        "- `releaseMetadataCommit`（仅回填 checksum、扫描汇总和发布验收事实，"
        f"不是 SDK 二进制源码提交）：`{metadata}`\n"
    )


class PrivateReleaseProvenanceTests(unittest.TestCase):
    def test_accepts_private_orchestrator_canonical_release_body(self) -> None:
        binary = "c" * 40
        metadata = "d" * 40
        body = (
            f"# {CURRENT_VERSION}\n\n"
            f"- `binarySourceCommit`（SDK 二进制源码提交）：`{binary}`\n"
            "- `releaseMetadataCommit`（仅回填 checksum、扫描汇总和发布验收事实，"
            f"不是 SDK 二进制源码提交）：`{metadata}`\n"
            f"- `candidateId`：`{'e' * 64}`\n"
            f"- `uploadInventorySha256`：`{'f' * 64}`\n\n"
            "B 仅用于 checksum、扫描汇总和验收事实，不是 SDK 二进制源码提交。\n"
            "主动 Apple 扫描证据只保存在 candidate state。\n\n"
            "该发布不代表最终宿主合规、App Store Connect `Validate App` "
            "或 Apple 审核通过。\n"
        )

        validate_release_body(body, binary, metadata)

    def test_release_body_requires_b_explanation_as_independent_line(self) -> None:
        binary = "c" * 40
        metadata = "d" * 40
        body = (
            f"- `binarySourceCommit`（SDK 二进制源码提交）：`{binary}`\n"
            "- `releaseMetadataCommit`（仅回填 checksum、扫描汇总和发布验收事实，"
            f"不是 SDK 二进制源码提交）：`{metadata}`\n"
            "前缀 B 仅用于 checksum、扫描汇总和验收事实，不是 SDK 二进制源码提交。\n"
        )

        with self.assertRaisesRegex(VerificationError, "Release body 缺少或重复"):
            validate_release_body(body, binary, metadata)

    def test_pending_current_section_ignores_historical_formal_section(self) -> None:
        document = (
            f"## [{CURRENT_VERSION}] - 待发布\n\n"
            f"{record('PENDING', PENDING_BINARY, PENDING_METADATA)}\n"
            "## [6.2.2] - 2026-08-10\n\n"
            f"{record('FORMAL', 'a' * 40, 'b' * 40)}"
        )

        self.assertEqual(
            parse_document(document, "CHANGELOG"),
            ("PENDING", PENDING_BINARY, PENDING_METADATA),
        )

    def test_formal_current_section_ignores_historical_formal_section(self) -> None:
        document = (
            f"## [{CURRENT_VERSION}] - 2026-08-13\n\n"
            f"{record('FORMAL', 'c' * 40, 'd' * 40)}\n"
            "## [6.2.2] - 2026-08-10\n\n"
            f"{record('FORMAL', 'a' * 40, 'b' * 40)}"
        )

        self.assertEqual(
            parse_document(document, "CHANGELOG"),
            ("FORMAL", "c" * 40, "d" * 40),
        )

    def test_readme_current_status_section_is_supported(self) -> None:
        document = (
            f"## {CURRENT_VERSION} 发布状态\n\n"
            f"{record('FORMAL', 'c' * 40, 'd' * 40)}\n"
            "## 版本记录\n\n历史内容\n"
        )

        self.assertEqual(
            parse_document(document, "README"),
            ("FORMAL", "c" * 40, "d" * 40),
        )

    def test_rejects_duplicate_current_version_sections(self) -> None:
        document = (
            f"## {CURRENT_VERSION} 发布状态\n\n"
            f"{record('PENDING', PENDING_BINARY, PENDING_METADATA)}\n"
            f"## [{CURRENT_VERSION}] - 待发布\n\n"
            f"{record('PENDING', PENDING_BINARY, PENDING_METADATA)}"
        )

        with self.assertRaisesRegex(VerificationError, "必须唯一声明"):
            parse_document(document, "README")

    def test_rejects_duplicate_records_inside_current_section(self) -> None:
        current = record("PENDING", PENDING_BINARY, PENDING_METADATA)
        document = f"## [{CURRENT_VERSION}] - 待发布\n\n{current}{current}"

        with self.assertRaisesRegex(VerificationError, "必须唯一声明"):
            parse_document(document, "CHANGELOG")


if __name__ == "__main__":
    unittest.main()
