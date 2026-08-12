#!/usr/bin/env python3
"""用仅限当前步骤的 GITHUB_TOKEN 下载并核对同仓 draft candidate。"""

from __future__ import annotations

import argparse
import json
import os
import re
import sys
from pathlib import Path
from urllib.parse import quote

from release_asset_downloader import (
    TOKEN_ENVIRONMENT_VARIABLES,
    VerificationError,
    asset_inventory_sha256,
    authenticated_api_request,
    download_authenticated,
    prepare_destination,
    read_json,
    validate_draft_release,
    validate_repository_and_tag,
    verify_expected_inventory_sha256,
    verify_download_inventory,
    write_metadata,
)


def run(
    repository: str,
    tag: str,
    release_id: int,
    candidate_id: str,
    expected_target_commit: str,
    target_branch: str,
    destination: Path,
    metadata_output: Path,
    inventory_sha256_output: Path | None = None,
    expected_inventory_sha256: str | None = None,
) -> str:
    unexpected = [
        name
        for name in TOKEN_ENVIRONMENT_VARIABLES
        if name != "GITHUB_TOKEN" and os.environ.get(name)
    ]
    if unexpected:
        raise VerificationError(f"Draft 下载环境包含非预期凭据变量: {unexpected}")
    token = os.environ.get("GITHUB_TOKEN", "")
    if not token.strip():
        raise VerificationError("Draft 下载缺少 GITHUB_TOKEN")
    validate_repository_and_tag(repository, tag)
    if release_id <= 0:
        raise VerificationError("Draft Release ID 必须为正整数")
    if re.fullmatch(r"[0-9a-f]{64}", candidate_id) is None:
        raise VerificationError("candidateId 必须是 64 位小写十六进制")
    if re.fullmatch(r"[0-9a-f]{40}", expected_target_commit) is None:
        raise VerificationError("候选目标提交必须是完整小写 SHA")
    expected_branch = f"release-candidate/{tag}-{candidate_id}"
    if target_branch != expected_branch:
        raise VerificationError(f"Draft candidate 只允许绑定 {expected_branch}")
    prepare_destination(destination)

    release_url = f"https://api.github.com/repos/{repository}/releases/{release_id}"
    release = read_json(
        authenticated_api_request(release_url, token, "application/vnd.github+json")
    )

    def resolve_branch(branch: str) -> str:
        ref_url = (
            f"https://api.github.com/repos/{repository}/git/ref/heads/"
            f"{quote(branch, safe='')}"
        )
        reference = read_json(
            authenticated_api_request(ref_url, token, "application/vnd.github+json")
        )
        value = reference.get("object", {}).get("sha")
        if not isinstance(value, str):
            raise VerificationError(f"无法解析远端分支 {branch} 的提交")
        return value

    assets = validate_draft_release(
        release,
        repository,
        tag,
        release_id,
        candidate_id,
        expected_target_commit,
        target_branch,
        resolve_branch,
    )
    for name in sorted(assets):
        download_authenticated(assets[name], destination / name, token)
    verify_download_inventory(destination, tag)
    inventory_sha256 = asset_inventory_sha256(assets, tag)
    verify_expected_inventory_sha256(inventory_sha256, expected_inventory_sha256)
    write_metadata(metadata_output, release)
    if inventory_sha256_output is not None:
        inventory_sha256_output.parent.mkdir(parents=True, exist_ok=True)
        inventory_sha256_output.write_text(inventory_sha256 + "\n", encoding="ascii")
    print(
        f"Draft Release ID {release_id} 的 10 个资产已认证下载并绑定 "
        f"{target_branch}@{expected_target_commit}，"
        f"inventorySha256={inventory_sha256}"
    )
    return inventory_sha256


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--repository", required=True)
    parser.add_argument("--tag", required=True)
    parser.add_argument("--release-id", required=True, type=int)
    parser.add_argument("--candidate-id", required=True)
    parser.add_argument("--expected-target-commit", required=True)
    parser.add_argument("--target-branch", required=True)
    parser.add_argument("--destination", required=True, type=Path)
    parser.add_argument("--metadata-output", required=True, type=Path)
    parser.add_argument("--inventory-sha256-output", type=Path)
    parser.add_argument("--expected-inventory-sha256")
    args = parser.parse_args()
    try:
        run(
            args.repository,
            args.tag,
            args.release_id,
            args.candidate_id,
            args.expected_target_commit,
            args.target_branch,
            args.destination,
            args.metadata_output,
            args.inventory_sha256_output,
            args.expected_inventory_sha256,
        )
    except (OSError, ValueError, json.JSONDecodeError, VerificationError) as error:
        print(f"ERROR: {error}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
