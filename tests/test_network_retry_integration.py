from __future__ import annotations

import io
import json
import sys
import unittest
from pathlib import Path
from unittest import mock
from urllib.error import HTTPError


ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "scripts"))
import github_http_retry
import release_asset_downloader as downloader
import verify_private_release_provenance as provenance


class NetworkRetryIntegrationTests(unittest.TestCase):
    def test_anonymous_metadata_retry_keeps_anonymous_request(self):
        request = downloader.anonymous_request("https://api.github.com/repos/owner/sdk/releases/tags/1.0.0",
                                               "application/vnd.github+json")
        error = HTTPError(request.full_url, 403, "Forbidden", {"Retry-After": "1"}, io.BytesIO(b"{}"))
        opener = mock.Mock()
        opener.open.side_effect = [error, io.BytesIO(b"{}")]
        try:
            with mock.patch.object(downloader, "build_opener", return_value=opener):
                with mock.patch.object(github_http_retry.time, "sleep") as sleeper:
                    self.assertEqual({}, downloader.read_json(request))
            self.assertEqual(2, opener.open.call_count)
            for call in opener.open.call_args_list:
                self.assertIs(request, call.args[0])
                self.assertIsNone(call.args[0].get_header("Authorization"))
            sleeper.assert_called_once_with(1)
        finally:
            error.close()

    def test_private_provenance_retries_request_then_validates_response(self):
        error = HTTPError("https://api.github.com/fixture", 503, "Unavailable", {}, io.BytesIO())
        try:
            with (
                mock.patch.object(provenance, "urlopen", side_effect=[error, io.BytesIO(b"{}")]) as request,
                mock.patch.object(provenance, "validate_compare") as validate,
                mock.patch.object(github_http_retry.time, "sleep") as sleeper,
            ):
                provenance.compare_with_private("a" * 40, "b" * 40, "fixture-token")
            validate.assert_called_once_with({}, "a" * 40, "b" * 40)
            self.assertEqual(2, request.call_count)
            first = request.call_args_list[0].args[0]
            self.assertIs(first, request.call_args_list[1].args[0])
            self.assertEqual("Bearer fixture-token", first.get_header("Authorization"))
            self.assertTrue(first.full_url.startswith("https://api.github.com/repos/LJMcarryu/IFLYADLibDemo/compare/"))
            sleeper.assert_called_once_with(1)
        finally:
            error.close()

    def test_manual_formal_control_allowlist_contains_retry_module_and_tests(self):
        workflow = (ROOT / ".github/workflows/ci.yml").read_text()
        allowed = workflow.split("unexpected_paths=$(git diff --name-only", 1)[1].split(")\n", 1)[0]
        for path in ("scripts/github_http_retry.py", "scripts/verify_private_release_provenance.py",
                     "tests/test_github_http_retry.py", "tests/test_network_retry_integration.py"):
            with self.subTest(path=path):
                self.assertIn(f"':(exclude){path}'", allowed)


if __name__ == "__main__":
    unittest.main()
