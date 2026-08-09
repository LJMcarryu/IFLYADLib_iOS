#!/usr/bin/env python3
"""在不携带任何 GitHub 凭据的情况下下载并核对模型 A Release。"""

from __future__ import annotations

import argparse
import hashlib
import json
import os
import re
import sys
from pathlib import Path
from urllib.parse import quote, urlsplit
from urllib.request import Request, urlopen


TOKEN_ENVIRONMENT_VARIABLES = (
    "GH_TOKEN",
    "GITHUB_TOKEN",
    "GITHUB_AUTH_TOKEN",
    "IFLY_PRIVATE_SOURCE_TOKEN",
)
USER_AGENT = "IFLYADLib-anonymous-release-verifier"
MODULE_ASSETS = {
    "IFLYAdCore.xcframework.zip",
    "IFLYAdVideoUI.xcframework.zip",
    "IFLYAdBanner.xcframework.zip",
    "IFLYAdSplash.xcframework.zip",
    "IFLYAdInterstitial.xcframework.zip",
    "IFLYAdNativeFeed.xcframework.zip",
    "IFLYAdReward.xcframework.zip",
}


class VerificationError(RuntimeError):
    """Release 元数据或下载内容不满足契约。"""


def require(condition: bool, message: str) -> None:
    if not condition:
        raise VerificationError(message)


def anonymous_request(url: str, accept: str) -> Request:
    request = Request(url, headers={"Accept": accept, "User-Agent": USER_AGENT})
    names = {name.lower() for name, _ in request.header_items()}
    require("authorization" not in names, "匿名请求不得携带 Authorization")
    require(names == {"accept", "user-agent"}, f"匿名请求头异常: {sorted(names)}")
    return request


def expected_assets(tag: str) -> set[str]:
    return MODULE_ASSETS | {
        f"IFLYADLib-modelA-{tag}.zip",
        "checksums.txt",
        "binary-targets.remote.swift",
    }


def validate_release(release: dict, repository: str, tag: str) -> dict[str, dict]:
    require(release.get("tag_name") == tag, "Release tag 与目标版本不一致")
    require(release.get("draft") is False, "Release 不得为 draft")
    require(release.get("prerelease") is False, "Release 不得为 prerelease")
    require(bool(release.get("published_at")), "Release 缺少 published_at")
    require(isinstance(release.get("body"), str), "Release body 缺失")
    assets = release.get("assets")
    require(isinstance(assets, list), "Release assets 不是数组")
    names = [asset.get("name") for asset in assets if isinstance(asset, dict)]
    expected = expected_assets(tag)
    require(len(assets) == len(expected), f"Release 必须精确包含 10 个资产: {names}")
    require(len(set(names)) == len(names) and set(names) == expected,
            f"实际资产 {sorted(names)}，期望 {sorted(expected)}")
    by_name: dict[str, dict] = {}
    for asset in assets:
        name = asset["name"]
        digest = asset.get("digest")
        require(isinstance(digest, str) and re.fullmatch(r"sha256:[0-9a-f]{64}", digest),
                f"{name} 缺少合法 GitHub sha256 digest")
        require(isinstance(asset.get("size"), int) and asset["size"] >= 0,
                f"{name} 缺少合法 size")
        expected_url = (
            f"https://github.com/{repository}/releases/download/"
            f"{quote(tag, safe='')}/{quote(name, safe='')}"
        )
        require(asset.get("browser_download_url") == expected_url,
                f"{name} browser_download_url 非预期")
        by_name[name] = asset
    return by_name


def download(asset: dict, destination: Path) -> str:
    request = anonymous_request(asset["browser_download_url"], "application/octet-stream")
    digest = hashlib.sha256()
    size = 0
    with urlopen(request, timeout=300) as response, destination.open("wb") as output:
        location = urlsplit(response.geturl())
        host = (location.hostname or "").lower()
        require(location.scheme == "https", f"资产重定向不是 HTTPS: {response.geturl()}")
        require(host == "github.com" or host.endswith(".githubusercontent.com"),
                f"资产重定向到非 GitHub 主机: {response.geturl()}")
        while chunk := response.read(1024 * 1024):
            output.write(chunk)
            digest.update(chunk)
            size += len(chunk)
    require(size == asset["size"], f"{asset['name']} 下载大小不一致")
    actual = digest.hexdigest()
    require(actual == asset["digest"].removeprefix("sha256:"),
            f"{asset['name']} SHA-256 与 GitHub digest 不一致")
    return actual


def run(repository: str, tag: str, destination: Path, metadata_output: Path) -> None:
    leaked = [name for name in TOKEN_ENVIRONMENT_VARIABLES if os.environ.get(name)]
    require(not leaked, f"匿名下载环境不得包含凭据变量: {leaked}")
    require(re.fullmatch(r"[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+", repository) is not None,
            f"非法 GitHub repository: {repository}")
    require(re.fullmatch(r"[0-9]+\.[0-9]+\.[0-9]+", tag) is not None,
            f"非法 Release tag: {tag}")
    destination.mkdir(parents=True, exist_ok=True)
    require(not any(destination.iterdir()), f"下载目录必须为空: {destination}")
    api_url = f"https://api.github.com/repos/{repository}/releases/tags/{quote(tag, safe='')}"
    with urlopen(anonymous_request(api_url, "application/vnd.github+json"), timeout=60) as response:
        release = json.loads(response.read().decode("utf-8"))
    assets = validate_release(release, repository, tag)
    for name in sorted(assets):
        download(assets[name], destination / name)
    actual = {path.name for path in destination.iterdir() if path.is_file()}
    require(actual == expected_assets(tag), f"下载库存不精确: {sorted(actual)}")
    metadata_output.write_text(json.dumps(release, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
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
