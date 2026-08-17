from __future__ import annotations

import os
import sys
import tempfile
import unittest
from pathlib import Path
from unittest import mock
from urllib.request import Request


SCRIPTS = Path(__file__).resolve().parents[1] / "scripts"
sys.path.insert(0, str(SCRIPTS))

from release_asset_downloader import (  # noqa: E402
    ApiOnlyRedirectHandler,
    TokenStrippingRedirectHandler,
    VerificationError,
    asset_inventory_sha256,
    authenticated_api_request,
    expected_assets,
    release_download_slug,
    validate_draft_release,
    validate_public_release,
    verify_expected_inventory_sha256,
)
from download_draft_release import run as run_draft_download  # noqa: E402


REPOSITORY = "LJMcarryu/IFLYADLib_iOS"
TAG = "6.2.4"
TARGET = "1" * 40
CANDIDATE_ID = "2" * 64
CANDIDATE_BRANCH = f"release-candidate/{TAG}-{CANDIDATE_ID}"
DRAFT_SLUG = "untagged-" + "3" * 16


def asset(name: str, asset_id: int, download_slug: str = TAG) -> dict:
    return {
        "id": asset_id,
        "name": name,
        "state": "uploaded",
        "size": 12,
        "digest": "sha256:" + "a" * 64,
        "url": f"https://api.github.com/repos/{REPOSITORY}/releases/assets/{asset_id}",
        "browser_download_url": (
            f"https://github.com/{REPOSITORY}/releases/download/{download_slug}/{name}"
        ),
    }


def release_assets(download_slug: str = TAG) -> list[dict]:
    return [
        asset(name, index, download_slug)
        for index, name in enumerate(sorted(expected_assets(TAG)), 1)
    ]


class ReleaseAssetDownloaderTests(unittest.TestCase):
    def test_release_download_slug_distinguishes_draft_and_formal(self) -> None:
        draft = {
            "draft": True,
            "html_url": f"https://github.com/{REPOSITORY}/releases/tag/{DRAFT_SLUG}",
        }
        formal = {
            "draft": False,
            "html_url": f"https://github.com/{REPOSITORY}/releases/tag/{TAG}",
        }

        self.assertEqual(
            release_download_slug(draft, REPOSITORY, TAG), DRAFT_SLUG
        )
        self.assertEqual(release_download_slug(formal, REPOSITORY, TAG), TAG)

        formal["html_url"] = draft["html_url"]
        with self.assertRaisesRegex(VerificationError, "正式 Release html_url"):
            release_download_slug(formal, REPOSITORY, TAG)

    def test_draft_download_wrapper_rejects_main_instead_of_candidate_branch(self) -> None:
        with tempfile.TemporaryDirectory() as directory, mock.patch.dict(
            os.environ, {"GITHUB_TOKEN": "token"}, clear=True
        ), self.assertRaisesRegex(VerificationError, "只允许绑定"):
            root = Path(directory)
            run_draft_download(
                REPOSITORY,
                TAG,
                42,
                CANDIDATE_ID,
                TARGET,
                "main",
                root / "assets",
                root / "metadata.json",
            )

    def test_public_inventory_sha256_is_stable_and_fail_closed(self) -> None:
        assets = release_assets()
        by_name = {item["name"]: item for item in reversed(assets)}
        fingerprint = asset_inventory_sha256(by_name, TAG)
        self.assertRegex(fingerprint, r"^[0-9a-f]{64}$")
        self.assertEqual(
            fingerprint,
            asset_inventory_sha256({item["name"]: item for item in assets}, TAG),
        )
        verify_expected_inventory_sha256(fingerprint, fingerprint)

        changed = {name: dict(item) for name, item in by_name.items()}
        changed[next(iter(changed))]["digest"] = "sha256:" + "b" * 64
        self.assertNotEqual(fingerprint, asset_inventory_sha256(changed, TAG))
        with self.assertRaisesRegex(VerificationError, "不一致"):
            verify_expected_inventory_sha256(fingerprint, "0" * 64)

    def test_public_release_requires_published_non_draft_and_exact_inventory(self) -> None:
        release = {
            "tag_name": TAG,
            "draft": False,
            "prerelease": False,
            "published_at": "2026-08-10T00:00:00Z",
            "html_url": f"https://github.com/{REPOSITORY}/releases/tag/{TAG}",
            "body": "body",
            "assets": release_assets(),
        }
        self.assertEqual(set(validate_public_release(release, REPOSITORY, TAG)), expected_assets(TAG))

        release["draft"] = True
        with self.assertRaisesRegex(VerificationError, "不得为 draft"):
            validate_public_release(release, REPOSITORY, TAG)

    def test_inventory_rejects_extra_asset(self) -> None:
        release = {
            "tag_name": TAG,
            "draft": False,
            "prerelease": False,
            "published_at": "2026-08-10T00:00:00Z",
            "html_url": f"https://github.com/{REPOSITORY}/releases/tag/{TAG}",
            "body": "body",
            "assets": release_assets() + [asset("extra.zip", 99)],
        }
        with self.assertRaisesRegex(VerificationError, "精确包含 10"):
            validate_public_release(release, REPOSITORY, TAG)

    def test_inventory_rejects_missing_asset(self) -> None:
        release = {
            "tag_name": TAG,
            "draft": False,
            "prerelease": False,
            "published_at": "2026-08-13T00:00:00Z",
            "html_url": f"https://github.com/{REPOSITORY}/releases/tag/{TAG}",
            "body": "body",
            "assets": release_assets()[:-1],
        }
        with self.assertRaisesRegex(VerificationError, "精确包含 10"):
            validate_public_release(release, REPOSITORY, TAG)

    def test_draft_release_binds_candidate_branch_to_expected_commit(self) -> None:
        release_id = 42
        release = {
            "id": release_id,
            "url": f"https://api.github.com/repos/{REPOSITORY}/releases/{release_id}",
            "tag_name": TAG,
            "target_commitish": CANDIDATE_BRANCH,
            "draft": True,
            "prerelease": False,
            "published_at": None,
            "html_url": f"https://github.com/{REPOSITORY}/releases/tag/{DRAFT_SLUG}",
            "body": f"- `candidateId`：`{CANDIDATE_ID}`\n",
            "assets": release_assets(DRAFT_SLUG),
        }
        resolved: list[str] = []

        def resolve(branch: str) -> str:
            resolved.append(branch)
            return TARGET

        result = validate_draft_release(
            release,
            REPOSITORY,
            TAG,
            release_id,
            CANDIDATE_ID,
            TARGET,
            CANDIDATE_BRANCH,
            resolve,
        )
        self.assertEqual(set(result), expected_assets(TAG))
        self.assertEqual(resolved, [CANDIDATE_BRANCH])

        release["target_commitish"] = "other"
        with self.assertRaisesRegex(VerificationError, "target_commitish"):
            validate_draft_release(
                release,
                REPOSITORY,
                TAG,
                release_id,
                CANDIDATE_ID,
                TARGET,
                CANDIDATE_BRANCH,
                resolve,
            )

        release["target_commitish"] = CANDIDATE_BRANCH
        release["body"] += f"- `candidateId`：`{CANDIDATE_ID}`\n"
        with self.assertRaisesRegex(VerificationError, "唯一声明"):
            validate_draft_release(
                release,
                REPOSITORY,
                TAG,
                release_id,
                CANDIDATE_ID,
                TARGET,
                CANDIDATE_BRANCH,
                resolve,
            )

    def test_draft_release_accepts_exact_sha_without_resolving_branch(self) -> None:
        release_id = 43
        release = {
            "id": release_id,
            "url": f"https://api.github.com/repos/{REPOSITORY}/releases/{release_id}",
            "tag_name": TAG,
            "target_commitish": TARGET,
            "draft": True,
            "prerelease": False,
            "published_at": None,
            "html_url": f"https://github.com/{REPOSITORY}/releases/tag/{DRAFT_SLUG}",
            "body": f"- `candidateId`：`{CANDIDATE_ID}`\n",
            "assets": release_assets(DRAFT_SLUG),
        }

        def unexpected(_: str) -> str:
            raise AssertionError("精确 SHA 不应查询分支")

        validate_draft_release(
            release,
            REPOSITORY,
            TAG,
            release_id,
            CANDIDATE_ID,
            TARGET,
            CANDIDATE_BRANCH,
            unexpected,
        )

    def test_draft_release_rejects_asset_with_different_untagged_slug(self) -> None:
        release_id = 44
        release = {
            "id": release_id,
            "url": f"https://api.github.com/repos/{REPOSITORY}/releases/{release_id}",
            "tag_name": TAG,
            "target_commitish": TARGET,
            "draft": True,
            "prerelease": False,
            "published_at": None,
            "html_url": f"https://github.com/{REPOSITORY}/releases/tag/{DRAFT_SLUG}",
            "body": f"- `candidateId`：`{CANDIDATE_ID}`\n",
            "assets": release_assets(DRAFT_SLUG),
        }
        release["assets"][0]["browser_download_url"] = release["assets"][0][
            "browser_download_url"
        ].replace(DRAFT_SLUG, "untagged-deadbeef")

        with self.assertRaisesRegex(VerificationError, "browser_download_url"):
            validate_draft_release(
                release,
                REPOSITORY,
                TAG,
                release_id,
                CANDIDATE_ID,
                TARGET,
                CANDIDATE_BRANCH,
                lambda _: TARGET,
            )

    def test_public_release_rejects_untagged_html_url(self) -> None:
        release = {
            "tag_name": TAG,
            "draft": False,
            "prerelease": False,
            "published_at": "2026-08-10T00:00:00Z",
            "html_url": f"https://github.com/{REPOSITORY}/releases/tag/{DRAFT_SLUG}",
            "body": "body",
            "assets": release_assets(),
        }

        with self.assertRaisesRegex(VerificationError, "html_url"):
            validate_public_release(release, REPOSITORY, TAG)

    def test_authenticated_request_only_allows_github_api(self) -> None:
        request = authenticated_api_request(
            "https://api.github.com/repos/example/repo/releases/1",
            "secret",
            "application/vnd.github+json",
        )
        self.assertEqual(request.get_header("Authorization"), "Bearer secret")
        with self.assertRaisesRegex(VerificationError, "api.github.com"):
            authenticated_api_request(
                "https://example.com/steal", "secret", "application/octet-stream"
            )
        with self.assertRaisesRegex(VerificationError, "HTTPS"):
            authenticated_api_request(
                "http://api.github.com/repos/example/repo/releases/1",
                "secret",
                "application/vnd.github+json",
            )

    def test_authenticated_api_redirect_stays_on_https_github_api(self) -> None:
        request = authenticated_api_request(
            "https://api.github.com/repos/example/repo/releases/1",
            "secret",
            "application/vnd.github+json",
        )
        redirected = ApiOnlyRedirectHandler().redirect_request(
            request,
            None,
            302,
            "Found",
            {},
            "https://api.github.com/repositories/1/releases/1",
        )
        self.assertEqual(redirected.get_header("Authorization"), "Bearer secret")

        for url in (
            "http://api.github.com/repositories/1/releases/1",
            "https://example.com/steal",
        ):
            with self.subTest(url=url), self.assertRaisesRegex(
                VerificationError, "HTTPS"
            ):
                ApiOnlyRedirectHandler().redirect_request(
                    request,
                    None,
                    302,
                    "Found",
                    {},
                    url,
                )

    def test_redirect_strips_token_and_rejects_non_github_host(self) -> None:
        request = Request(
            "https://api.github.com/repos/example/repo/releases/assets/1",
            headers={"Authorization": "Bearer secret"},
        )
        redirected = TokenStrippingRedirectHandler().redirect_request(
            request,
            None,
            302,
            "Found",
            {},
            "https://release-assets.githubusercontent.com/object?signature=abc",
        )
        self.assertIsNone(redirected.get_header("Authorization"))
        self.assertEqual(redirected.get_header("Accept"), "application/octet-stream")

        with self.assertRaisesRegex(VerificationError, "非 GitHub 主机"):
            TokenStrippingRedirectHandler().redirect_request(
                request,
                None,
                302,
                "Found",
                {},
                "https://example.com/object",
            )


if __name__ == "__main__":
    unittest.main()
