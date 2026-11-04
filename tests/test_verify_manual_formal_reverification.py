from __future__ import annotations

import copy
import json
import os
import shutil
import subprocess
import sys
import tempfile
import textwrap
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "scripts"))
from verify_manual_formal_reverification import CONTROL_PATHS


class ManualFormalReverificationTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name) / "repo"
        self.root.mkdir()
        self.output = Path(self.temp.name) / "output"
        self.workflow = (ROOT / ".github/workflows/ci.yml").read_text()
        self.contract = json.loads((ROOT / "scripts/release-control.json").read_text())
        self.frozen = json.loads((ROOT / "release-state.json").read_text())
        self.tag = self.frozen["version"]
        self.contract.update(state="CANDIDATE", targetVersion=self.tag, closedVersion="0.0.0")
        self.repository = self.contract["repository"]
        self.git("init", "-q", "-b", "main")
        self.git("config", "user.name", "Test")
        self.git("config", "user.email", "test@example.invalid")
        self.git("config", "core.filemode", "true")
        paths = [
            "Package.swift", "IFLYADLib.podspec", "IFLYADLibSimple/Podfile",
            "README.md", "CHANGELOG.md", "RELEASING.md", "SECURITY.md",
            "IFLYADLibSimple/README.md", "scripts/release-control.json",
            "scripts/release_state.py", "scripts/release_metadata_control.py",
            "scripts/github_http_retry.py", "scripts/verify_repository_contract.py",
            "scripts/verify_distribution_manifest.py",
        ]
        for path in paths:
            target = self.root / path
            target.parent.mkdir(parents=True, exist_ok=True)
            shutil.copyfile(ROOT / path, target)
        self.write("payload.txt", "immutable SDK\n")
        self.write("scripts/release-control.json", json.dumps(self.contract))
        self.frozen.update(version=self.tag, phase="FROZEN", publication=None)
        self.write_state(self.frozen)
        self.frozen_commit = self.commit()
        self.git("tag", "-a", self.tag, "-m", "frozen")
        self.tag_object = self.git("rev-parse", f"refs/tags/{self.tag}").strip()
        self.closed = copy.deepcopy(self.frozen)
        self.closed.update(phase="CLOSED", publication={
            "releaseId": 42, "tagName": self.tag,
            "tagObjectSha": self.tag_object, "tagCommitSha": self.frozen_commit,
            "releaseUrl": f"https://github.com/{self.repository}/releases/tag/{self.tag}",
            "publishedAt": "2026-10-26T10:00:00Z", "formalConsumerRunId": 123,
            "formalConsumerRunUrl": f"https://github.com/{self.repository}/actions/runs/123",
            "conclusion": "success", "verifiedAt": "2026-10-26T11:00:00Z",
        })
        self.write_state(self.closed)
        self.closed_commit = self.commit()
        self.bootstrap()

    def git(self, *args):
        return subprocess.check_output(["git", *args], cwd=self.root, text=True,
                                       stderr=subprocess.PIPE)

    def write(self, path, value):
        destination = self.root / path
        destination.parent.mkdir(parents=True, exist_ok=True)
        destination.write_text(value)

    def write_state(self, state):
        self.write("release-state.json", json.dumps(state, indent=2) + "\n")

    def commit(self):
        self.git("add", "-A")
        self.git("commit", "-qm", "fixture")
        return self.git("rev-parse", "HEAD").strip()

    def bootstrap(self):
        for path in ("scripts/verify_manual_formal_reverification.py",
                     "scripts/validate_release_control.py",
                     "tests/test_validate_release_control.py"):
            self.write(path, (ROOT / path).read_text())
        self.write(".github/workflows/ci.yml", self.workflow)
        self.head = self.commit()

    def arguments(self, **overrides):
        values = dict(repository=self.repository, tag=self.tag, release_id="42",
                      event_name="workflow_dispatch", event_ref="refs/heads/main",
                      event_sha=self.git("rev-parse", "HEAD").strip(),
                      workflow_sha=self.git("rev-parse", "HEAD").strip())
        values.update(overrides)
        return [part for key, value in values.items()
                for part in ("--" + key.replace("_", "-"), value)]

    def run_check(self, **overrides):
        return subprocess.run(
            [sys.executable, "-B", str(ROOT / "scripts/verify_manual_formal_reverification.py"),
             *self.arguments(**overrides)], cwd=self.root, text=True, capture_output=True)

    def reject(self, **overrides):
        result = self.run_check(**overrides)
        self.assertNotEqual(result.returncode, 0, result.stdout)
        return result

    def step_source(self, name):
        section = self.workflow.split(f"      - name: {name}\n", 1)[1]
        section = section.split("\n      - name: ", 1)[0]
        return textwrap.dedent(section.split("        run: |\n", 1)[1])

    def test_legal_closeout_and_bootstrap(self):
        result = self.run_check()
        self.assertEqual(result.returncode, 0, result.stderr)

    def test_exact_historical_archive_addition_and_update_are_allowed(self):
        path = "docs/需求设计/发布验收/历史发布记录.md"
        self.write(path, "# 历史发布记录\n")
        self.commit()
        result = self.run_check()
        self.assertEqual(result.returncode, 0, result.stderr)
        self.write(path, "# 历史发布记录\n\n历史证据引用。\n")
        self.commit()
        result = self.run_check()
        self.assertEqual(result.returncode, 0, result.stderr)

    def test_other_document_paths_are_rejected(self):
        for path in ("docs/需求设计/发布验收/其他记录.md",
                     "docs/其他目录/历史发布记录.md",
                     "docs/需求设计/发布验收/历史发布记录.md.py"):
            with self.subTest(path=path):
                self.git("reset", "--hard", self.head)
                self.write(path, "unapproved\n")
                self.commit()
                result = self.reject()
                self.assertIn("非获准路径", result.stderr)

    def test_historical_archive_symlink_is_rejected(self):
        path = self.root / "docs/需求设计/发布验收/历史发布记录.md"
        path.parent.mkdir(parents=True)
        path.symlink_to("../../../payload.txt")
        self.commit()
        result = self.reject()
        self.assertIn("必须为普通文件", result.stderr)

    def test_real_workflow_binding_and_tag_contracts_keep_main_closed(self):
        source = self.step_source("Tag/正式态校验不可变 annotated tag 与 checkout 绑定")
        environment = dict(os.environ, PYTHONDONTWRITEBYTECODE="1",
                           RELEASE_VERSION=self.tag, FORMAL_RELEASE_ID="42",
                           EVENT_NAME="workflow_dispatch", EVENT_REF="refs/heads/main",
                           EVENT_SHA=self.head, WORKFLOW_CONTROL_SHA=self.head,
                           GITHUB_REPOSITORY=self.repository, GITHUB_OUTPUT=str(self.output),
                           RUNNER_TEMP=self.temp.name)
        result = subprocess.run(["bash", "-c", source], cwd=self.root, env=environment,
                                capture_output=True, text=True)
        self.assertEqual(result.returncode, 0, result.stderr)
        snapshot = self.output.read_text().strip().split("=", 1)[1]
        self.assertEqual(json.loads((Path(snapshot) / "release-state.json").read_text())["phase"],
                         "FROZEN")
        for name in ("阻断校验版本、checksum 与通用仓 10 资产机器契约",
                     "阻断校验 Markdown 发布状态契约"):
            with self.subTest(name=name):
                source = self.step_source(name).replace(
                    "${{ steps.tag-binding.outputs.repository_root || github.workspace }}", snapshot)
                result = subprocess.run(["bash", "-eo", "pipefail", "-c", source], cwd=self.root,
                                        env=dict(environment, RELEASE_MODE="formal"),
                                        capture_output=True, text=True)
                self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(json.loads((self.root / "release-state.json").read_text()), self.closed)
        self.assertEqual(self.git("status", "--porcelain"), "")

    def test_wrong_event_ref_sha_tag_and_release_id(self):
        for override in ({"event_name": "push"}, {"event_ref": "refs/heads/other"},
                         {"event_sha": "a" * 40}, {"workflow_sha": self.frozen_commit},
                         {"tag": "6.0.0"}, {"tag": "../6.4.4"},
                         {"release_id": "43"}, {"release_id": "0"}, {"release_id": "01"}):
            with self.subTest(override=override):
                self.reject(**override)

    def test_lightweight_tag_is_rejected(self):
        self.git("tag", "-d", self.tag)
        self.git("tag", self.tag, self.frozen_commit)
        self.reject()

    def test_recreated_annotated_tag_object_is_rejected(self):
        self.git("tag", "-f", "-a", self.tag, self.frozen_commit, "-m", "different object")
        self.reject()

    def test_other_named_tag_object_is_rejected(self):
        self.git("tag", "-a", "other", self.frozen_commit, "-m", "other")
        self.git("update-ref", f"refs/tags/{self.tag}", self.git("rev-parse", "refs/tags/other").strip())
        self.reject()

    def test_closeout_symlink_or_executable_state_is_rejected(self):
        for mode in ("symlink", "executable"):
            with self.subTest(mode=mode):
                self.git("reset", "--hard", self.frozen_commit)
                self.write_state(self.closed)
                path = self.root / "release-state.json"
                if mode == "symlink":
                    path.unlink()
                    path.symlink_to("payload.txt")
                else:
                    path.chmod(0o755)
                self.commit()
                self.bootstrap()
                self.reject()

    def test_tag_must_be_frozen_and_match_control_target(self):
        self.git("reset", "--hard", self.closed_commit)
        self.git("tag", "-f", "-a", self.tag, "-m", "closed tag")
        self.bootstrap()
        self.reject()
        self.git("tag", "-f", "-a", self.tag, self.frozen_commit, "-m", "frozen tag")
        contract = copy.deepcopy(self.contract)
        contract["targetVersion"] = "99.0.0"
        self.write("scripts/release-control.json", json.dumps(contract))
        self.commit()
        self.reject()

    def test_frozen_main_without_closeout_is_rejected(self):
        self.git("reset", "--hard", self.frozen_commit)
        self.reject()

    def test_dirty_checkout_is_rejected(self):
        self.write("README.md", "dirty")
        self.reject()

    def test_closeout_must_be_single_state_file_direct_child(self):
        self.git("reset", "--hard", self.frozen_commit)
        self.write("README.md", "premature bootstrap")
        self.commit()
        self.write_state(self.closed)
        self.commit()
        self.bootstrap()
        self.reject()

    def test_closeout_with_extra_file_is_rejected(self):
        self.git("reset", "--hard", self.frozen_commit)
        self.write_state(self.closed)
        self.write("README.md", "extra change")
        self.commit()
        self.bootstrap()
        self.reject()

    def test_closeout_inventory_provenance_and_publication_must_match(self):
        mutations = [
            ("binarySourceCommit", "e" * 40), ("releaseMetadataCommit", "f" * 40),
            ("artifactInventory", {"count": 11, "sha256": "d" * 64}),
            ("artifactInventory", {"count": 10, "sha256": "d" * 64}),
            ("unexpected", True), ("phase", "VERIFIED"),
        ]
        for key, value in mutations:
            with self.subTest(key=key, value=value):
                self.git("reset", "--hard", self.frozen_commit)
                state = copy.deepcopy(self.closed)
                state[key] = value
                self.write_state(state)
                self.commit()
                self.bootstrap()
                self.reject()
        for key, value in (("tagObjectSha", "a" * 40), ("tagCommitSha", "b" * 40),
                           ("releaseId", 43), ("tagName", "6.0.0")):
            with self.subTest(publication=key):
                self.git("reset", "--hard", self.frozen_commit)
                state = copy.deepcopy(self.closed)
                state["publication"][key] = value
                self.write_state(state)
                self.commit()
                self.bootstrap()
                self.reject()

    def test_post_closeout_state_or_contract_edits_are_rejected_even_if_reverted(self):
        for path in ("release-state.json", "scripts/release-control.json", "payload.txt"):
            with self.subTest(path=path):
                self.git("reset", "--hard", self.head)
                original = (self.root / path).read_text()
                self.write(path, original + "\n")
                self.commit()
                self.write(path, original)
                self.commit()
                self.reject()

    def test_allowed_path_symlink_deletion_rename_and_mode_change_are_rejected(self):
        for operation in ("symlink", "delete", "rename", "mode"):
            with self.subTest(operation=operation):
                self.git("reset", "--hard", self.head)
                path = self.root / "README.md"
                if operation == "symlink":
                    path.unlink()
                    path.symlink_to("payload.txt")
                elif operation == "delete":
                    path.unlink()
                elif operation == "rename":
                    self.git("mv", "-f", "README.md", "SECURITY.md")
                else:
                    path.chmod(0o755)
                self.commit()
                self.reject()

    def test_new_symlink_and_unlisted_control_path_are_rejected(self):
        for path, symlink in (("tests/test_verify_manual_formal_reverification.py", True),
                              ("scripts/unapproved.py", False)):
            with self.subTest(path=path):
                self.git("reset", "--hard", self.head)
                if symlink:
                    (self.root / path).symlink_to("../payload.txt")
                else:
                    self.write(path, "print('unapproved')")
                self.commit()
                self.reject()

    def test_merge_is_rejected(self):
        self.git("checkout", "-qb", "branch", self.head)
        self.write("README.md", "branch doc")
        self.commit()
        self.git("checkout", "main")
        self.write("SECURITY.md", "main doc")
        self.commit()
        self.git("merge", "--no-ff", "branch", "-m", "merge")
        self.reject()

    def test_comment_only_package_changes_pass_but_code_changes_fail_even_if_reverted(self):
        for path, prefix in (("Package.swift", "//"), ("IFLYADLibSimple/Podfile", "#")):
            with self.subTest(path=path):
                self.git("reset", "--hard", self.head)
                original = (self.root / path).read_text()
                self.write(path, original + f"{prefix} comment\n")
                self.commit()
                self.assertEqual(self.run_check().returncode, 0)
                self.write(path, original + "code change\n")
                self.commit()
                self.write(path, original)
                self.commit()
                self.reject()

    def test_tag_and_release_event_paths_do_not_require_new_script_on_old_tag(self):
        self.git("reset", "--hard", self.frozen_commit)
        self.assertFalse((self.root / "scripts/verify_manual_formal_reverification.py").exists())
        source = self.step_source("Tag/正式态校验不可变 annotated tag 与 checkout 绑定")
        for event in ("push", "release"):
            with self.subTest(event=event):
                result = subprocess.run(["bash", "-c", source], cwd=self.root,
                                        env=dict(os.environ, EVENT_NAME=event, RELEASE_VERSION=self.tag),
                                        text=True, capture_output=True)
                self.assertEqual(result.returncode, 0, result.stderr)

    def test_gate_precedes_formal_contracts_and_pins_control_source(self):
        binding = self.workflow.index("      - name: Tag/正式态校验不可变 annotated tag")
        self.assertLess(binding, self.workflow.index("      - name: 校验版本控制状态拓扑"))
        self.assertLess(binding, self.workflow.index("      - name: 阻断校验版本、checksum"))
        source = self.step_source("Tag/正式态校验不可变 annotated tag 与 checkout 绑定")
        self.assertLess(source.index('test "$(git rev-parse HEAD)" = "$WORKFLOW_CONTROL_SHA"'),
                        source.index('git show "${WORKFLOW_CONTROL_SHA}:scripts/verify_manual'))
        self.assertNotIn("release-state.json", CONTROL_PATHS)
        self.assertNotIn("scripts/release-control.json", CONTROL_PATHS)


if __name__ == "__main__":
    unittest.main()
