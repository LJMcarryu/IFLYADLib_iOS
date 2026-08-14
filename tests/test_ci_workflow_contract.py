from __future__ import annotations

import re
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
WORKFLOW = (ROOT / ".github/workflows/ci.yml").read_text(encoding="utf-8")


def job_block(name: str) -> str:
    match = re.search(
        rf"(?ms)^  {re.escape(name)}:\n(.*?)(?=^  [a-zA-Z0-9_-]+:\n|\Z)",
        WORKFLOW,
    )
    if match is None:
        raise AssertionError(f"缺少 CI job: {name}")
    return match.group(1)


class CIWorkflowContractTests(unittest.TestCase):
    def test_local_python_validation_cannot_dirty_candidate_worktree(self) -> None:
        ignore = (ROOT / ".gitignore").read_text(encoding="utf-8")
        self.assertRegex(ignore, r"(?m)^__pycache__/$")
        self.assertRegex(ignore, r"(?m)^\*\.py\[cod\]$")

    def test_candidate_dispatch_identity_is_branch_and_run_name_bound(self) -> None:
        for input_name in ("draft_release_id", "candidate_id", "dispatch_nonce"):
            self.assertRegex(WORKFLOW, rf"(?m)^      {input_name}:$")
        self.assertIn("draft-candidate:{0}:{1}:{2}", WORKFLOW)
        self.assertIn("formal-release:{0}:{1}", WORKFLOW)
        self.assertIn(
            'candidate_branch="release-candidate/$version-$candidate_id"',
            WORKFLOW,
        )
        self.assertIn('"$checkout_sha" != "$EVENT_SHA"', WORKFLOW)
        self.assertNotIn("--target-branch main", WORKFLOW)

    def test_distribution_manifest_receives_exact_release_stage(self) -> None:
        preflight = job_block("preflight")
        self.assertIn(
            "RELEASE_MODE: ${{ steps.release-mode.outputs.release_mode }}",
            preflight,
        )
        self.assertIn('--mode "$RELEASE_MODE"', preflight)
        self.assertIn("release_mode='candidate'", preflight)
        self.assertIn("release_mode='tag'", preflight)
        self.assertIn("release_mode='formal'", preflight)

    def test_tag_and_formal_post_facts_are_proved_by_event_specific_gates(self) -> None:
        preflight = job_block("preflight")
        self.assertIn(
            "steps.release-mode.outputs.release_mode == 'tag' || "
            "steps.release-mode.outputs.release_mode == 'formal'",
            preflight,
        )
        self.assertIn('git cat-file -t "refs/tags/$RELEASE_VERSION"', preflight)

        release_assets = job_block("release-assets")
        anonymous = release_assets.split(
            "- name: 正式态无 Token 匿名下载精确 10 个 Release 资产", 1
        )[1].split("- name: Candidate 认证下载", 1)[0]
        self.assertIn("release_mode == 'formal'", anonymous)
        self.assertIn("scripts/download_release_anonymously.py", anonymous)
        self.assertIn("校验 Release body 的 A/B provenance 声明", release_assets)

        summary = job_block("release-summary")
        self.assertIn("$RELEASE_MODE" + '" == \'candidate\' || "$RELEASE_MODE" == \'formal\'', summary)
        self.assertIn("test \"$ASSETS_RESULT\" = 'success'", summary)

    def test_draft_binaries_are_not_transferred_between_jobs(self) -> None:
        self.assertNotIn("actions/upload-artifact", WORKFLOW)
        self.assertNotIn("actions/download-artifact", WORKFLOW)
        release_assets = job_block("release-assets")
        self.assertIn(
            "asset_inventory_sha256: "
            "${{ steps.release-inventory.outputs.asset_inventory_sha256 }}",
            release_assets,
        )
        self.assertIn("固化本次 Release 精确库存身份", release_assets)

    def test_release_inventory_passes_candidate_or_formal_download_slug(self) -> None:
        release_assets = job_block("release-assets")
        inventory_step = release_assets.split(
            "- name: 固化本次 Release 精确库存身份", 1
        )[1].split("- name: 校验 7 个模块与合并包逐字节同源", 1)[0]
        self.assertIn("release_download_slug,", inventory_step)
        self.assertIn(
            "download_slug = release_download_slug(metadata, repository, tag)",
            inventory_step,
        )
        self.assertRegex(
            inventory_step,
            r"validate_asset_inventory\(\s*metadata, repository, tag, download_slug\s*\)",
        )

    def test_each_candidate_download_boundary_has_one_token_step(self) -> None:
        token_binding = (
            "GITHUB_TOKEN: ${{ secrets.DRAFT_RELEASE_READ_TOKEN }}"
        )
        self.assertNotIn("${{ github.token }}", WORKFLOW)
        expected_fingerprint = (
            "EXPECTED_ASSET_INVENTORY_SHA256: "
            "${{ needs.release-assets.outputs.asset_inventory_sha256 }}"
        )
        for name in (
            "release-assets",
            "swiftpm-consumer",
            "cocoapods-demo-consumer",
        ):
            with self.subTest(job=name):
                block = job_block(name)
                self.assertEqual(1, block.count(token_binding))
                self.assertEqual(1, block.count("scripts/download_draft_release.py"))
                if name != "release-assets":
                    self.assertEqual(1, block.count(expected_fingerprint))
                    self.assertEqual(
                        1, block.count("--expected-inventory-sha256")
                    )

    def test_formal_download_remains_anonymous(self) -> None:
        block = job_block("release-assets")
        anonymous_step = block.split(
            "- name: 正式态无 Token 匿名下载精确 10 个 Release 资产", 1
        )[1].split("- name: Candidate 认证下载", 1)[0]
        self.assertIn("scripts/download_release_anonymously.py", anonymous_step)
        for name in (
            "GH_TOKEN",
            "GITHUB_TOKEN",
            "GITHUB_AUTH_TOKEN",
            "IFLY_PRIVATE_SOURCE_TOKEN",
        ):
            self.assertIn(f"-u {name}", anonymous_step)

    def test_release_concurrency_timeouts_and_summary_are_fail_closed(self) -> None:
        self.assertIn("concurrency:", WORKFLOW)
        self.assertIn("inputs.candidate_id, inputs.draft_release_id", WORKFLOW)
        self.assertIn("github.event.release.tag_name", WORKFLOW)
        self.assertRegex(WORKFLOW, r"(?m)^  cancel-in-progress: false$")

        for name, timeout in (
            ("preflight", 30),
            ("release-assets", 55),
            ("swiftpm-consumer", 55),
            ("cocoapods-demo-consumer", 55),
            ("release-summary", 5),
        ):
            with self.subTest(job=name):
                self.assertIn(f"timeout-minutes: {timeout}", job_block(name))

        summary = job_block("release-summary")
        self.assertIn("if: ${{ always() }}", summary)
        for dependency in (
            "preflight",
            "release-assets",
            "swiftpm-consumer",
            "cocoapods-demo-consumer",
        ):
            self.assertIn(dependency, summary)
        self.assertIn("permissions: {}", summary)
        self.assertIn("GITHUB_STEP_SUMMARY", summary)
        self.assertIn("ASSET_INVENTORY", summary)
        self.assertIn("failure|cancelled|timed_out|action_required", summary)
        self.assertNotIn("GITHUB_TOKEN", summary)

    def test_releasing_declares_private_orchestrator_as_only_entry(self) -> None:
        releasing = (ROOT / "RELEASING.md").read_text(encoding="utf-8")
        self.assertIn("## 正式发布唯一入口", releasing)
        self.assertIn("scripts/release-orchestrator.py", releasing)
        self.assertIn("底层门禁或故障诊断入口", releasing)

    def test_cocoapods_consumer_gates_new_native_feed_api(self) -> None:
        block = job_block("cocoapods-demo-consumer")
        self.assertIn("校验 NativeFeed 新 API 正向与旧 API 反向", block)
        for marker in (
            "detachFromCurrentContainer",
            "allowsExternalClickViews",
            "nativeFeedAd:didRejectClickWithError:",
            "IFLYAdErrorCodeNativeFeedClickViewsInvalid",
        ):
            self.assertIn(marker, block)
        for marker in (
            "IFLYNativeFeedDisplaySession",
            "IFLYNativeFeedAdBinding",
            "beginDisplaySessionWithError:",
            "bindAdWithViewBinder:",
        ):
            self.assertIn(marker, block)


if __name__ == "__main__":
    unittest.main()
