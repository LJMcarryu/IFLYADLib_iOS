from __future__ import annotations

import os
import re
import subprocess
import sys
import tempfile
import textwrap
import unittest
from pathlib import Path
from unittest import mock


ROOT = Path(__file__).resolve().parents[1]
WORKFLOW = (ROOT / ".github/workflows/ci.yml").read_text(encoding="utf-8")
sys.path.insert(0, str(ROOT / "scripts"))
import verify_repository_contract as repository_contract  # noqa: E402


def job_block(name: str) -> str:
    match = re.search(
        rf"(?ms)^  {re.escape(name)}:\n(.*?)(?=^  [a-zA-Z0-9_-]+:\n|\Z)",
        WORKFLOW,
    )
    if match is None:
        raise AssertionError(f"缺少 CI job: {name}")
    return match.group(1)


def step_block(job: str, name: str) -> str:
    match = re.search(
        rf"(?ms)^      - name: {re.escape(name)}\n"
        r"(.*?)(?=^      - name: |\Z)",
        job,
    )
    if match is None:
        raise AssertionError(f"缺少 CI step: {name}")
    return match.group(1)


def embedded_python(step: str) -> str:
    marker = "          python3 - <<'PY'\n"
    if marker not in step:
        raise AssertionError("CI step 缺少内嵌 Python")
    source = step.split(marker, 1)[1].split("\n          PY", 1)[0]
    return textwrap.dedent(source)


def write_native_feed_headers(pod_root: Path) -> None:
    native_feed_source = """\
- (BOOL)attachWithViewBinder:(id)binder error:(id)error;
+ (void)detachAdFromContainerView:(id)containerView;
- (void)detachFromCurrentContainer;
@property (nonatomic) BOOL allowsExternalClickViews;
- (void)nativeFeedAd:(id)ad didRejectClickWithError:(id)error;
"""
    for slice_name in ("ios-arm64", "ios-arm64_x86_64-simulator"):
        native_feed_header = (
            pod_root
            / "IFLYAdNativeFeed.xcframework"
            / slice_name
            / "Headers/IFLYADLib/IFLYNativeFeedAd.h"
        )
        native_feed_header.parent.mkdir(parents=True)
        native_feed_header.write_text(native_feed_source, encoding="utf-8")
        error_header = (
            pod_root
            / "IFLYAdCore.xcframework"
            / slice_name
            / "Headers/IFLYADLib/IFLYAdError.h"
        )
        error_header.parent.mkdir(parents=True)
        error_header.write_text(
            "IFLYAdErrorCodeNativeFeedClickViewsInvalid = 71503;\n",
            encoding="utf-8",
        )


def run_native_feed_header_gate(
    demo_root: Path,
    release_mode: str,
    pod_root: Path | None = None,
) -> subprocess.CompletedProcess[str]:
    step = step_block(
        job_block("cocoapods-demo-consumer"),
        "校验 NativeFeed 新 API 正向与旧 API 反向",
    )
    environment = os.environ.copy()
    environment["DEMO_ROOT"] = str(demo_root)
    environment["RELEASE_MODE"] = release_mode
    environment["POD_ROOT"] = str(pod_root) if pod_root is not None else ""
    return subprocess.run(
        [sys.executable, "-c", embedded_python(step)],
        check=False,
        capture_output=True,
        text=True,
        env=environment,
    )


class CIWorkflowContractTests(unittest.TestCase):
    def test_local_python_validation_cannot_dirty_candidate_worktree(self) -> None:
        ignore = (ROOT / ".gitignore").read_text(encoding="utf-8")
        self.assertRegex(ignore, r"(?m)^__pycache__/$")
        self.assertRegex(ignore, r"(?m)^\*\.py\[cod\]$")

    def test_candidate_dispatch_identity_is_branch_and_run_name_bound(self) -> None:
        for input_name in (
            "draft_release_id", "candidate_id", "dispatch_nonce",
            "control_plane_canary", "canary_tag", "canary_release_id",
            "canary_candidate_id",
        ):
            self.assertRegex(WORKFLOW, rf"(?m)^      {input_name}:$")
        self.assertIn("draft-candidate:{0}:{1}:{2}", WORKFLOW)
        self.assertIn("formal-release:{0}:{1}", WORKFLOW)
        self.assertIn("control-plane-canary:{0}:{1}:{2}", WORKFLOW)
        self.assertIn(
            'candidate_branch="release-candidate/$version-$candidate_id"',
            WORKFLOW,
        )
        self.assertIn('"$checkout_sha" != "$EVENT_SHA"', WORKFLOW)
        self.assertNotIn("--target-branch main", WORKFLOW)

    def test_control_plane_canary_reuses_draft_downloader_without_heavy_builds(self) -> None:
        block = job_block("control-plane-canary")
        self.assertIn("needs: [preflight]", block)
        self.assertIn("DRAFT_RELEASE_READ_TOKEN", block)
        self.assertIn("scripts/download_draft_release.py", block)
        self.assertIn('test "$CANARY_TAG" != "$state_version"', block)
        self.assertIn("release-candidate/${CANARY_TAG}-${CANARY_CANDIDATE_ID}", block)
        self.assertIn("release_control_plane_checks.py fixture", block)
        self.assertIn("didRejectClickWithError:", block)
        production = (ROOT / "scripts/release_control_plane_checks.py").read_text(
            encoding="utf-8"
        )
        self.assertIn("symlink_to", production)
        self.assertIn("resolve_pod_root", production)
        for forbidden in ("xcodebuild", "pod install", "swift build"):
            self.assertNotIn(forbidden, block)

    def test_simple_job_has_scheme_bound_name_and_integer_json_contract(self) -> None:
        block = job_block("cocoapods-demo-consumer")
        self.assertIn("name: Simple IFLYADLibSimple｜", block)
        self.assertIn(
            "simple_result_json: ${{ steps.simple-result.outputs.json }}", block
        )
        step = step_block(block, "输出统一 Simple 验证结果")
        self.assertIn(
            "RELEASE_ID: ${{ needs.release-assets.outputs.release_id }}", step
        )
        release_assets = job_block("release-assets")
        self.assertIn(
            "release_id: ${{ steps.release-inventory.outputs.release_id }}",
            release_assets,
        )
        for marker in (
            '"schemaVersion": 1', '"channel": "general"',
            '"simpleScheme": "IFLYADLibSimple"',
            '"artifactInventorySha256"', '"buildResult": "success"',
            '"runId"', 'int(os.environ["RELEASE_ID"])',
        ):
            self.assertIn(marker, step)

    def test_repository_contract_receives_exact_release_stage(self) -> None:
        preflight = job_block("preflight")
        machine = step_block(
            preflight, "阻断校验版本、checksum 与通用仓 10 资产机器契约"
        )
        self.assertIn(
            "RELEASE_MODE: ${{ steps.release-mode.outputs.release_mode }}", machine
        )
        self.assertIn("scripts/verify_repository_contract.py", machine)
        self.assertIn('--scope machine --release-kind "${RELEASE_MODE}"', machine)
        self.assertIn("release_mode='candidate'", preflight)
        self.assertIn("release_mode='tag'", preflight)
        self.assertIn("release_mode='formal'", preflight)

    def test_machine_and_document_contracts_are_blocking(self) -> None:
        preflight = job_block("preflight")
        machine = step_block(
            preflight, "阻断校验版本、checksum 与通用仓 10 资产机器契约"
        )
        self.assertNotIn("continue-on-error", machine)
        documentation = step_block(
            preflight, "阻断校验 Markdown 发布状态契约"
        )
        self.assertNotIn("continue-on-error", documentation)
        self.assertIn("--scope docs", documentation)
        maintenance = step_block(
            preflight, "校验 A/B provenance 文档一致性（main/PR 不访问私有仓）"
        )
        self.assertNotIn("continue-on-error", maintenance)
        self.assertEqual(WORKFLOW.count("continue-on-error: true"), 0)
        release_provenance = step_block(
            job_block("release-assets"), "校验 Release body 的 A/B provenance 声明"
        )
        self.assertIn("--release-state release-state.json", release_provenance)
        self.assertNotIn("--readme", release_provenance)

    def test_docs_drift_is_isolated_but_checksum_drift_fails_machine_scope(self) -> None:
        original_read = repository_contract.read

        def docs_drift(root: Path, relative: str) -> str:
            value = original_read(root, relative)
            if relative == "README.md":
                return value.replace(
                    "<!-- ifly-release-status:",
                    "<!-- removed-release-status:",
                    1,
                )
            return value

        with mock.patch.object(repository_contract, "read", side_effect=docs_drift):
            repository_contract.verify_machine(ROOT, "local")
            with self.assertRaises(repository_contract.ContractError):
                repository_contract.verify_docs(ROOT, "local")

        def checksum_drift(root: Path, relative: str) -> str:
            value = original_read(root, relative)
            if relative == "Package.swift":
                return re.sub(
                    r'checksum:\s*"[0-9a-f]{64}"',
                    'checksum: "not-a-checksum"',
                    value,
                    count=1,
                )
            return value

        with mock.patch.object(repository_contract, "read", side_effect=checksum_drift):
            with self.assertRaises(repository_contract.ContractError):
                repository_contract.verify_machine(ROOT, "local")

        def version_drift(root: Path, relative: str) -> str:
            value = original_read(root, relative)
            if relative == "IFLYADLib.podspec":
                return re.sub(
                    r"(s\.version\s*=\s*['\"])6\.3\.0",
                    r"\g<1>6.3.1",
                    value,
                    count=1,
                )
            return value

        with mock.patch.object(repository_contract, "read", side_effect=version_drift):
            with self.assertRaises(repository_contract.ContractError):
                repository_contract.verify_machine(ROOT, "local")

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
        self.assertIn(
            "RELEASE_MODE: ${{ needs.preflight.outputs.release_mode }}",
            block,
        )
        self.assertIn(
            "POD_ROOT: ${{ steps.consumer-paths.outputs.pod_root }}",
            block,
        )
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

    def test_cocoapods_header_gate_uses_candidate_pod_root_output(self) -> None:
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            output = root / "ifly-cocoapods-local"
            demo_root = output / "IFLYADLibSimple"
            candidate_pod_root = output / "IFLYADLib"
            demo_root.mkdir(parents=True)
            write_native_feed_headers(candidate_pod_root)
            self.assertFalse((demo_root / "Pods/IFLYADLib").exists())

            result = run_native_feed_header_gate(
                demo_root,
                "candidate",
                candidate_pod_root,
            )

            self.assertEqual(0, result.returncode, result.stderr)

    def test_cocoapods_header_gate_supports_formal_directory_layout(self) -> None:
        with tempfile.TemporaryDirectory() as temporary:
            demo_root = Path(temporary) / "IFLYADLibSimple"
            write_native_feed_headers(demo_root / "Pods/IFLYADLib")

            result = run_native_feed_header_gate(demo_root, "formal")

            self.assertEqual(0, result.returncode, result.stderr)

    def test_previous_closed_state_is_allowed_only_on_local_main(self) -> None:
        state = {"version": "6.2.4", "phase": "CLOSED"}
        repository_contract.validate_state_version(state, "local")
        for release_kind in ("candidate", "tag", "formal"):
            with self.subTest(release_kind=release_kind), self.assertRaises(
                repository_contract.ContractError
            ):
                repository_contract.validate_state_version(state, release_kind)

    def test_current_frozen_state_is_allowed_for_all_release_modes(self) -> None:
        state = {"version": "6.3.0", "phase": "FROZEN"}
        for release_kind in ("local", "candidate", "tag", "formal"):
            with self.subTest(release_kind=release_kind):
                repository_contract.validate_state_version(state, release_kind)

    def test_candidate_tag_and_formal_reject_current_non_frozen_state(self) -> None:
        for phase in ("PREPARING", "PUBLISHED", "VERIFIED", "CLOSED"):
            state = {"version": "6.3.0", "phase": phase}
            for release_kind in ("candidate", "tag", "formal"):
                with self.subTest(
                    phase=phase, release_kind=release_kind
                ), self.assertRaises(repository_contract.ContractError):
                    repository_contract.validate_state_version(state, release_kind)

    def test_older_closed_and_previous_non_closed_states_are_rejected(self) -> None:
        for state in (
            {"version": "6.2.3", "phase": "CLOSED"},
            {"version": "6.2.4", "phase": "FROZEN"},
            {"version": "6.2.4", "phase": "PREPARING"},
        ):
            with self.subTest(state=state), self.assertRaises(
                repository_contract.ContractError
            ):
                repository_contract.validate_state_version(state, "local")


if __name__ == "__main__":
    unittest.main()
