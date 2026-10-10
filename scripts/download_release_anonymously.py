#!/usr/bin/env python3
"""在不携带任何 GitHub 凭据的情况下下载并核对正式 Release。"""

from __future__ import annotations

import argparse
import json
import os
import sys
from pathlib import Path

from release_asset_downloader import (
    VerificationError,
    download_anonymously,
    prepare_destination,
    validate_public_release,
    validate_repository_and_tag,
    verify_download_inventory,
    write_metadata,
)
from release_metadata_control import formal_release_metadata
from github_http_retry import failure_classification


def run(
    repository: str,
    tag: str,
    destination: Path,
    metadata_output: Path,
    *,
    release_id: str,
    event_name: str,
    event_path: Path | None,
) -> None:
    validate_repository_and_tag(repository, tag)
    prepare_destination(destination)

    release = formal_release_metadata(
        repository=repository,
        tag=tag,
        release_id=release_id,
        event_name=event_name,
        event_path=event_path,
        token=os.environ.get("GITHUB_TOKEN", "").strip(),
    )
    assets = validate_public_release(release, repository, tag)
    for name in sorted(assets):
        # 控制 API 可认证；资产真实性仍必须由无 Authorization 的公开 URL 下载证明。
        download_anonymously(assets[name], destination / name)
    verify_download_inventory(destination, tag)
    write_metadata(metadata_output, release)
    print(f"Release {tag} 的 10 个资产已无 Token 匿名下载并校验")


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--repository", required=True)
    parser.add_argument("--tag", required=True)
    parser.add_argument("--destination", required=True, type=Path)
    parser.add_argument("--metadata-output", required=True, type=Path)
    parser.add_argument("--release-id", required=True)
    parser.add_argument("--event-name", required=True)
    parser.add_argument("--event-path", type=Path)
    args = parser.parse_args()
    try:
        run(
            args.repository,
            args.tag,
            args.destination,
            args.metadata_output,
            release_id=args.release_id,
            event_name=args.event_name,
            event_path=args.event_path,
        )
    except (OSError, ValueError, json.JSONDecodeError, VerificationError) as error:
        print(f"ERROR[{failure_classification(error)}]: {error}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
