from __future__ import annotations

import contextlib
import copy
import io
import json
import sys
import tempfile
import unittest
from pathlib import Path
from unittest import mock

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "scripts"))
import release_state  # noqa: E402


ARTIFACTS = [
    {"name": "binary-targets.remote.swift", "contentSha256": "be7dd39e3775d6891a4216099b1c01ad516091d1a25c1170a989dcb34a7a2d24"},
    {"name": "checksums.txt", "contentSha256": "75adf3cc8a1cc79e43be98196770958fe68825c35e7a449f173b2e180f2659c1"},
    {"name": "IFLYAdBanner.xcframework.zip", "contentSha256": "adb21f48c17b20db44554a54ab696aed47380b7d474dd77e9911b126c9096678"},
    {"name": "IFLYAdCore.xcframework.zip", "contentSha256": "26cc27dc2aebce8bec5dac2d0840492eb022c2959585465f3d130ea52ddb50d5"},
    {"name": "IFLYAdInterstitial.xcframework.zip", "contentSha256": "11c232e39b12de30421fc07076801b57e45a8a4d634840b135005b02658de632"},
    {"name": "IFLYADLib-modelA-6.2.3.zip", "contentSha256": "f6331ecf01aa902b5831a62ea8e205799c4301aa689f87bc216c0d1798e6f469"},
    {"name": "IFLYAdNativeFeed.xcframework.zip", "contentSha256": "781d2e0c7bbca8ba11f26d1e038887cd698fc6d2be7bde472fae4bed9bc484b2"},
    {"name": "IFLYAdReward.xcframework.zip", "contentSha256": "6deb887ba912a2a6ec91ba281b394cbf43973dd53d3543737bcfd657f50cb2ce"},
    {"name": "IFLYAdSplash.xcframework.zip", "contentSha256": "a55504f4781559a9d2697cf364a8ff86e2865f61f0701e0b78a775ac36da5d6c"},
    {"name": "IFLYAdVideoUI.xcframework.zip", "contentSha256": "abfea29151c3e739d67b5221a2cc1da2bfbda1a1773d42e5418bd95f9c39c012"},
]


class ReleaseStateTests(unittest.TestCase):
    def setUp(self) -> None:
        self.state = json.loads((ROOT / "release-state.json").read_text(encoding="utf-8"))
        self.facts = {
            key: copy.deepcopy(value)
            for key, value in self.state.items()
            if key != "artifactInventory"
        }
        self.facts["artifacts"] = copy.deepcopy(ARTIFACTS)

    def write_facts(self, directory: Path) -> Path:
        path = directory / "facts.json"
        path.write_text(json.dumps(self.facts), encoding="utf-8")
        return path

    def test_current_state_is_rebuilt_exactly_from_content_digests(self) -> None:
        generated = release_state.build_closed_state(self.facts)
        self.assertEqual(generated, self.state)
        self.assertEqual(
            release_state.canonical_json(generated),
            (ROOT / "release-state.json").read_text(encoding="utf-8"),
        )
        self.assertEqual(generated["artifactInventory"], {
            "count": 10,
            "sha256": "75ece4ae736143231c7ac8b027797d22cd604f4cdb8f8098865d4dd7d8409ea2",
        })

    def test_dry_run_prints_state_without_writing(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            target = root / "release-state.json"
            target.write_text("原内容\n", encoding="utf-8")
            output = io.StringIO()
            with contextlib.redirect_stdout(output):
                result = release_state.main([str(target), "--facts", str(self.write_facts(root))])
            self.assertEqual(result, 0)
            self.assertEqual(target.read_text(encoding="utf-8"), "原内容\n")
            self.assertEqual(json.loads(output.getvalue()), self.state)

    def test_write_atomically_generates_closed_state(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            target = root / "release-state.json"
            output = io.StringIO()
            with contextlib.redirect_stdout(output):
                result = release_state.main([
                    str(target), "--facts", str(self.write_facts(root)), "--write",
                    "--expected-channel", "general",
                    "--expected-repository", "LJMcarryu/IFLYADLib_iOS",
                    "--expected-version", "6.2.3",
                ])
            self.assertEqual(result, 0)
            self.assertEqual(target.read_text(encoding="utf-8"),
                             release_state.canonical_json(self.state))

    def test_rejects_extra_facts_fields(self) -> None:
        for mutate in (
            lambda value: value.update({"unexpected": True}),
            lambda value: value["artifacts"][0].update({"size": 1}),
        ):
            value = copy.deepcopy(self.facts)
            mutate(value)
            with self.assertRaises(release_state.ReleaseStateError):
                release_state.build_closed_state(value)

    def test_rejects_non_closed_failure_and_fake_apple_success(self) -> None:
        for mutate in (
            lambda value: value.update({"phase": "VERIFIED"}),
            lambda value: value["publication"].update({"conclusion": "failure"}),
            lambda value: value["appleReview"].update({"statusAtFreeze": "success"}),
            lambda value: value["publication"].update({"releaseId": "370458965"}),
        ):
            value = copy.deepcopy(self.facts)
            mutate(value)
            with self.assertRaises(release_state.ReleaseStateError):
                release_state.build_closed_state(value)

    def test_failed_replace_preserves_original_and_removes_temporary_file(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            target = root / "release-state.json"
            target.write_text("不可破坏的原状态\n", encoding="utf-8")
            with mock.patch.object(release_state.os, "replace", side_effect=OSError("失败")):
                with self.assertRaises(OSError):
                    release_state.atomic_write_state(target, self.state)
            self.assertEqual(target.read_text(encoding="utf-8"), "不可破坏的原状态\n")
            self.assertEqual(list(root.glob(".release-state.json.*.tmp")), [])

    def test_closeout_accepts_only_same_frozen_identity_and_is_idempotent(self) -> None:
        frozen = copy.deepcopy(self.state)
        frozen["phase"] = "FROZEN"
        frozen["publication"] = None
        release_state.validate_closeout_transition(frozen, self.state)
        release_state.validate_closeout_transition(self.state, self.state)

        drifted = copy.deepcopy(frozen)
        drifted["artifactInventory"]["sha256"] = "0" * 64
        with self.assertRaises(release_state.ReleaseStateError):
            release_state.validate_closeout_transition(drifted, self.state)
        preparing = copy.deepcopy(frozen)
        preparing["phase"] = "PREPARING"
        with self.assertRaises(release_state.ReleaseStateError):
            release_state.validate_closeout_transition(preparing, self.state)

    def test_freeze_facts_generate_frozen_state_with_null_publication(self) -> None:
        facts = copy.deepcopy(self.facts)
        facts.pop("publication")
        facts["phase"] = "FROZEN"
        frozen = release_state.build_state_from_facts(facts)
        self.assertEqual(frozen["phase"], "FROZEN")
        self.assertIsNone(frozen["publication"])
        self.assertEqual(frozen["artifactInventory"], self.state["artifactInventory"])

        facts["publication"] = None
        with self.assertRaises(release_state.ReleaseStateError):
            release_state.build_frozen_state(facts)

    def test_phase_specific_publication_and_transition_contract(self) -> None:
        frozen = copy.deepcopy(self.state)
        frozen["phase"] = "FROZEN"
        frozen["publication"] = None
        preparing = copy.deepcopy(frozen)
        preparing["phase"] = "PREPARING"
        release_state.validate_state_transition(preparing, frozen)
        release_state.validate_state_transition(frozen, self.state)

        invalid_publication = copy.deepcopy(frozen)
        invalid_publication["publication"] = {}
        with self.assertRaises(release_state.ReleaseStateError):
            release_state.validate_state(invalid_publication)

        next_frozen = copy.deepcopy(frozen)
        next_frozen["version"] = "6.2.4"
        release_state.validate_state_transition(self.state, next_frozen)
        with self.assertRaises(release_state.ReleaseStateError):
            release_state.validate_state_transition(self.state, frozen)

        cross_version_closed = copy.deepcopy(self.state)
        cross_version_closed["version"] = "6.2.4"
        cross_version_closed["publication"]["tagName"] = "6.2.4"
        cross_version_closed["publication"]["releaseUrl"] = (
            "https://github.com/LJMcarryu/IFLYADLib_iOS/releases/tag/6.2.4"
        )
        with self.assertRaises(release_state.ReleaseStateError):
            release_state.validate_state_transition(self.state, cross_version_closed)


if __name__ == "__main__":
    unittest.main()
