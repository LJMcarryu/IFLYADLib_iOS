#!/usr/bin/env python3
"""GitHub Release 资产契约、受控请求与下载的公共实现。"""

from __future__ import annotations

import hashlib
import hmac
import json
import re
from pathlib import Path
from urllib.parse import quote, urlsplit
from urllib.request import HTTPRedirectHandler, Request, build_opener, urlopen


TOKEN_ENVIRONMENT_VARIABLES = (
    "GH_TOKEN",
    "GITHUB_TOKEN",
    "GITHUB_AUTH_TOKEN",
    "IFLY_PRIVATE_SOURCE_TOKEN",
)
USER_AGENT = "IFLYADLib-release-verifier"
MODULE_ASSET_NAMES = {
    "IFLYAdCore": "IFLYAdCore.xcframework.zip",
    "IFLYAdVideoUI": "IFLYAdVideoUI.xcframework.zip",
    "IFLYAdBanner": "IFLYAdBanner.xcframework.zip",
    "IFLYAdSplash": "IFLYAdSplash.xcframework.zip",
    "IFLYAdInterstitial": "IFLYAdInterstitial.xcframework.zip",
    "IFLYAdNativeFeed": "IFLYAdNativeFeed.xcframework.zip",
    "IFLYAdReward": "IFLYAdReward.xcframework.zip",
}
MODULE_ASSETS = set(MODULE_ASSET_NAMES.values())
CANDIDATE_LINE_RE = re.compile(
    r"^- `candidateId`：`([0-9a-f]{64})`\s*$", re.MULTILINE
)


class VerificationError(RuntimeError):
    """Release 元数据或下载内容不满足契约。"""


def require(condition: bool, message: str) -> None:
    if not condition:
        raise VerificationError(message)


def validate_repository_and_tag(repository: str, tag: str) -> None:
    require(
        re.fullmatch(r"[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+", repository) is not None,
        f"非法 GitHub repository: {repository}",
    )
    require(
        re.fullmatch(r"[0-9]+\.[0-9]+\.[0-9]+", tag) is not None,
        f"非法 Release tag: {tag}",
    )


def expected_assets(tag: str) -> set[str]:
    return MODULE_ASSETS | {
        f"IFLYADLib-modelA-{tag}.zip",
        "checksums.txt",
        "binary-targets.remote.swift",
    }


def _expected_browser_download_url(
    repository: str, download_slug: str, name: str
) -> str:
    return (
        f"https://github.com/{repository}/releases/download/"
        f"{quote(download_slug, safe='')}/{quote(name, safe='')}"
    )


def _draft_download_slug(release: dict, repository: str) -> str:
    html_url = release.get("html_url")
    require(isinstance(html_url, str), "Draft Release html_url 缺失")
    match = re.fullmatch(
        rf"https://github\.com/{re.escape(repository)}/releases/tag/"
        r"(untagged-[0-9a-f]+)",
        html_url,
    )
    require(match is not None, "Draft Release html_url 必须是同仓 HTTPS untagged URL")
    return match.group(1)


def validate_asset_inventory(
    release: dict, repository: str, tag: str, download_slug: str
) -> dict[str, dict]:
    assets = release.get("assets")
    require(isinstance(assets, list), "Release assets 不是数组")
    require(all(isinstance(asset, dict) for asset in assets), "Release asset 条目非法")
    names = [asset.get("name") for asset in assets]
    require(all(isinstance(name, str) for name in names), "Release asset name 非字符串")
    expected = expected_assets(tag)
    require(len(assets) == len(expected), f"Release 必须精确包含 10 个资产: {names}")
    require(
        len(set(names)) == len(names) and set(names) == expected,
        f"实际资产 {sorted(names)}，期望 {sorted(expected)}",
    )

    by_name: dict[str, dict] = {}
    for asset in assets:
        name = asset["name"]
        digest = asset.get("digest")
        require(
            isinstance(digest, str) and re.fullmatch(r"sha256:[0-9a-f]{64}", digest),
            f"{name} 缺少合法 GitHub sha256 digest",
        )
        require(
            isinstance(asset.get("size"), int) and asset["size"] >= 0,
            f"{name} 缺少合法 size",
        )
        require(
            asset.get("browser_download_url")
            == _expected_browser_download_url(repository, download_slug, name),
            f"{name} browser_download_url 非预期",
        )
        by_name[name] = asset
    return by_name


def asset_inventory_sha256(assets: dict[str, dict], tag: str) -> str:
    """绑定精确资产名与 GitHub digest，供独立下载 Job 交叉核对。"""

    expected = expected_assets(tag)
    require(set(assets) == expected, "资产库存无法生成公共指纹")
    digest = hashlib.sha256()
    for name in sorted(expected):
        value = assets[name].get("digest")
        require(
            isinstance(value, str) and re.fullmatch(r"sha256:[0-9a-f]{64}", value),
            f"{name} 缺少合法 GitHub sha256 digest",
        )
        digest.update(name.encode("utf-8"))
        digest.update(b"\0")
        digest.update(value.removeprefix("sha256:").encode("ascii"))
        digest.update(b"\n")
    return digest.hexdigest()


def verify_expected_inventory_sha256(actual: str, expected: str | None) -> None:
    if expected is None:
        return
    require(
        re.fullmatch(r"[0-9a-f]{64}", expected) is not None,
        "期望的公共资产库存 SHA-256 非法",
    )
    require(
        hmac.compare_digest(actual, expected),
        f"公共资产库存 SHA-256 不一致：actual={actual} expected={expected}",
    )


def validate_public_release(
    release: dict, repository: str, tag: str
) -> dict[str, dict]:
    require(release.get("tag_name") == tag, "Release tag 与目标版本不一致")
    require(release.get("draft") is False, "Release 不得为 draft")
    require(release.get("prerelease") is False, "Release 不得为 prerelease")
    require(bool(release.get("published_at")), "Release 缺少 published_at")
    require(isinstance(release.get("body"), str), "Release body 缺失")
    require(
        release.get("html_url")
        == f"https://github.com/{repository}/releases/tag/{quote(tag, safe='')}",
        "正式 Release html_url 与当前仓库/tag 不一致",
    )
    return validate_asset_inventory(release, repository, tag, tag)


def validate_draft_release(
    release: dict,
    repository: str,
    tag: str,
    release_id: int,
    candidate_id: str,
    expected_target_commit: str,
    target_branch: str,
    resolve_branch,
) -> dict[str, dict]:
    """校验同仓 draft 身份，并将 target_commitish 解析到候选分支提交。"""

    require(release.get("id") == release_id, "Draft Release ID 与请求不一致")
    expected_api_url = f"https://api.github.com/repos/{repository}/releases/{release_id}"
    require(release.get("url") == expected_api_url, "Draft Release API URL 非预期仓库/ID")
    require(release.get("tag_name") == tag, "Draft Release tag 与目标版本不一致")
    require(release.get("draft") is True, "候选 Release 必须保持 draft")
    require(release.get("prerelease") is False, "候选 Release 不得为 prerelease")
    require(release.get("published_at") is None, "Draft Release 不得已有 published_at")
    require(isinstance(release.get("body"), str), "Draft Release body 缺失")
    require(
        re.fullmatch(r"[0-9a-f]{64}", candidate_id) is not None,
        "candidateId 必须是 64 位小写十六进制",
    )
    body = release["body"]
    require(
        CANDIDATE_LINE_RE.findall(body) == [candidate_id]
        and body.count("`candidateId`") == 1,
        "Draft Release body 必须唯一声明输入 candidateId",
    )
    require(
        re.fullmatch(r"[0-9a-f]{40}", expected_target_commit) is not None,
        "候选目标提交必须是完整小写 SHA",
    )

    target = release.get("target_commitish")
    if target == expected_target_commit:
        resolved_target = target
    else:
        require(target == target_branch, f"Draft target_commitish 必须是 {target_branch} 或精确 SHA")
        resolved_target = resolve_branch(target_branch)
    require(
        resolved_target == expected_target_commit,
        "Draft Release 未绑定触发时的候选分支提交",
    )

    download_slug = _draft_download_slug(release, repository)
    assets = validate_asset_inventory(release, repository, tag, download_slug)
    seen_ids: set[int] = set()
    for name, asset in assets.items():
        asset_id = asset.get("id")
        require(isinstance(asset_id, int) and asset_id > 0, f"{name} 缺少合法 asset ID")
        require(asset_id not in seen_ids, f"{name} 与其他资产复用了 asset ID")
        seen_ids.add(asset_id)
        require(asset.get("state") == "uploaded", f"{name} 尚未完成 uploaded")
        expected_url = (
            f"https://api.github.com/repos/{repository}/releases/assets/{asset_id}"
        )
        require(asset.get("url") == expected_url, f"{name} asset API URL 非预期")
    return assets


def anonymous_request(url: str, accept: str) -> Request:
    request = Request(url, headers={"Accept": accept, "User-Agent": USER_AGENT})
    names = {name.lower() for name, _ in request.header_items()}
    require("authorization" not in names, "匿名请求不得携带 Authorization")
    require(names == {"accept", "user-agent"}, f"匿名请求头异常: {sorted(names)}")
    return request


def _validate_authenticated_api_url(url: str) -> None:
    location = urlsplit(url)
    require(
        location.scheme == "https"
        and (location.hostname or "").lower() == "api.github.com",
        "Token 只能通过 HTTPS 发送至 api.github.com",
    )


def authenticated_api_request(url: str, token: str, accept: str) -> Request:
    require(token.strip(), "Draft 下载缺少 GITHUB_TOKEN")
    _validate_authenticated_api_url(url)
    return Request(
        url,
        headers={
            "Accept": accept,
            "Authorization": f"Bearer {token}",
            "User-Agent": USER_AGENT,
            "X-GitHub-Api-Version": "2022-11-28",
        },
    )


def _validate_download_url(url: str) -> None:
    location = urlsplit(url)
    host = (location.hostname or "").lower()
    require(location.scheme == "https", f"资产重定向不是 HTTPS: {url}")
    require(
        host in {"api.github.com", "github.com"}
        or host.endswith(".githubusercontent.com"),
        f"资产重定向到非 GitHub 主机: {url}",
    )


class TokenStrippingRedirectHandler(HTTPRedirectHandler):
    """Draft 资产 API 跳转后移除 Authorization，避免令牌发送给 CDN。"""

    def redirect_request(self, request, fp, code, msg, headers, newurl):
        _validate_download_url(newurl)
        return Request(
            newurl,
            headers={
                "Accept": "application/octet-stream",
                "User-Agent": USER_AGENT,
            },
            method="GET",
        )


class ApiOnlyRedirectHandler(HTTPRedirectHandler):
    """API JSON 请求如发生重定向，只允许继续访问 HTTPS GitHub API。"""

    def redirect_request(self, request, fp, code, msg, headers, newurl):
        _validate_authenticated_api_url(newurl)
        return super().redirect_request(request, fp, code, msg, headers, newurl)


def read_json(request: Request) -> dict:
    opener = build_opener(ApiOnlyRedirectHandler())
    with opener.open(request, timeout=60) as response:
        value = json.loads(response.read().decode("utf-8"))
    require(isinstance(value, dict), "GitHub API 响应不是对象")
    return value


def _write_and_verify(response, asset: dict, destination: Path) -> str:
    _validate_download_url(response.geturl())
    digest = hashlib.sha256()
    size = 0
    with destination.open("wb") as output:
        while chunk := response.read(1024 * 1024):
            output.write(chunk)
            digest.update(chunk)
            size += len(chunk)
    require(size == asset["size"], f"{asset['name']} 下载大小不一致")
    actual = digest.hexdigest()
    require(
        actual == asset["digest"].removeprefix("sha256:"),
        f"{asset['name']} SHA-256 与 GitHub digest 不一致",
    )
    return actual


def download_anonymously(asset: dict, destination: Path) -> str:
    request = anonymous_request(asset["browser_download_url"], "application/octet-stream")
    with urlopen(request, timeout=300) as response:
        return _write_and_verify(response, asset, destination)


def download_authenticated(asset: dict, destination: Path, token: str) -> str:
    request = authenticated_api_request(asset["url"], token, "application/octet-stream")
    opener = build_opener(TokenStrippingRedirectHandler())
    with opener.open(request, timeout=300) as response:
        return _write_and_verify(response, asset, destination)


def prepare_destination(destination: Path) -> None:
    destination.mkdir(parents=True, exist_ok=True)
    require(not any(destination.iterdir()), f"下载目录必须为空: {destination}")


def verify_download_inventory(destination: Path, tag: str) -> None:
    actual = {
        path.name
        for path in destination.iterdir()
        if path.is_file() and not path.is_symlink()
    }
    unexpected = [
        path.name
        for path in destination.iterdir()
        if not path.is_file() or path.is_symlink()
    ]
    require(
        not unexpected and actual == expected_assets(tag),
        f"下载库存不精确: files={sorted(actual)} unexpected={sorted(unexpected)}",
    )


def write_metadata(metadata_output: Path, release: dict) -> None:
    metadata_output.parent.mkdir(parents=True, exist_ok=True)
    metadata_output.write_text(
        json.dumps(release, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )
