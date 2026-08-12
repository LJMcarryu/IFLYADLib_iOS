#!/usr/bin/env python3
"""在不携带任何 GitHub 凭据的情况下下载并核对正式 Release。"""

from __future__ import annotations

import argparse
import json
import os
import sys
from pathlib import Path
from urllib.parse import quote

from release_asset_downloader import (
    TOKEN_ENVIRONMENT_VARIABLES,
    VerificationError,
    anonymous_request,
    download_anonymously,
    prepare_destination,
    read_json,
    validate_public_release,
    validate_repository_and_tag,
    verify_download_inventory,
    write_metadata,
)


def run(repository: str, tag: str, destination: Path, metadata_output: Path) -> None:
    leaked = [name for name in TOKEN_ENVIRONMENT_VARIABLES if os.environ.get(name)]
    if leaked:
        raise VerificationError(f"匿名下载环境不得包含凭据变量: {leaked}")
    validate_repository_and_tag(repository, tag)
    prepare_destination(destination)

    api_url = f"https://api.github.com/repos/{repository}/releases/tags/{quote(tag, safe='')}"
    release = read_json(anonymous_request(api_url, "application/vnd.github+json"))
    assets = validate_public_release(release, repository, tag)
    for name in sorted(assets):
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
    args = parser.parse_args()
    try:
        run(args.repository, args.tag, args.destination, args.metadata_output)
    except (OSError, ValueError, json.JSONDecodeError, VerificationError) as error:
        print(f"ERROR: {error}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
