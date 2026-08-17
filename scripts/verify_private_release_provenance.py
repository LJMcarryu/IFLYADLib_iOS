#!/usr/bin/env python3
"""验证正式公开仓的 A/B provenance；令牌只允许访问私有仓 compare API。"""

from __future__ import annotations

import argparse
import json
import os
import re
import sys
from pathlib import Path
from urllib.parse import quote, urlsplit
from urllib.request import Request, urlopen

PRIVATE_SOURCE_REPOSITORY = "LJMcarryu/IFLYADLibDemo"
CURRENT_VERSION = "6.2.4"
PENDING_BINARY = "__IFLYADLIB_6_2_4_BINARY_SOURCE_COMMIT_PENDING__"
PENDING_METADATA = "__IFLYADLIB_6_2_4_RELEASE_METADATA_COMMIT_PENDING__"
ALLOWED_METADATA_FILES = {"Package.swift", "README.md", "CONTEXT.md"}


class VerificationError(RuntimeError):
    pass


def require(condition: bool, message: str) -> None:
    if not condition:
        raise VerificationError(message)


def _find(document: str, label: str) -> list[str]:
    # 同时兼容准备阶段旧格式和新文档统一采用的列表格式。
    if label == "binary":
        patterns = (
            r"^\s*-\s*`binarySourceCommit`（SDK 二进制源码提交）：`([^`]+)`\s*$",
            r"^\s*binarySourceCommit（提交 A）：`([^`]+)`\s*$",
        )
    else:
        patterns = (
            r"^\s*-\s*`releaseMetadataCommit`（仅回填 checksum、扫描汇总和发布验收事实，"
            r"不是 SDK 二进制源码提交）：`([^`]+)`\s*$",
            r"^\s*releaseMetadataCommit（提交 B）：`([^`]+)`\s*$",
        )
    return [value for pattern in patterns for value in re.findall(pattern, document, re.M)]


def current_version_section(document: str, label: str) -> str:
    heading = re.compile(
        rf"^##[ \t]+(?:\[{re.escape(CURRENT_VERSION)}\]|"
        rf"{re.escape(CURRENT_VERSION)})(?:[ \t]|$).*$",
        re.M,
    )
    matches = list(heading.finditer(document))
    require(len(matches) == 1, f"{label} 必须唯一声明 {CURRENT_VERSION} 二级章节")
    start = matches[0].start()
    following = re.search(r"^#{1,2}[ \t]+", document[matches[0].end():], re.M)
    end = matches[0].end() + following.start() if following else len(document)
    return document[start:end]


def parse_document(document: str, label: str) -> tuple[str, str, str]:
    section = current_version_section(document, label)
    binary = _find(section, "binary")
    metadata = _find(section, "metadata")
    states = re.findall(
        r"^\s*-\s*`releaseState`：`(PENDING|FORMAL)`\s*$",
        section,
        re.M,
    )
    require(
        len(binary) == len(metadata) == len(states) == 1,
        f"{label} 的 {CURRENT_VERSION} 章节必须唯一声明 releaseState/A/B",
    )
    return states[0], binary[0], metadata[0]


def validate_documents(paths: list[Path]) -> tuple[str, str, str]:
    values = [parse_document(path.read_text(encoding="utf-8"), str(path)) for path in paths]
    require(len(set(values)) == 1, "README/CHANGELOG/RELEASING 的 releaseState/A/B 不一致")
    state, binary, metadata = values[0]
    pending = state == "PENDING" and binary == PENDING_BINARY and metadata == PENDING_METADATA
    formal = state == "FORMAL" and re.fullmatch(r"[0-9a-f]{40}", binary) and re.fullmatch(r"[0-9a-f]{40}", metadata) and binary != metadata
    require(pending or formal, "A/B 必须同时为精确 PENDING 或正式的两个不同 SHA")
    return values[0]


def validate_release_body(body: str, binary: str, metadata: str) -> None:
    lines = [line.strip() for line in body.splitlines()]
    expected = (
        f"- `binarySourceCommit`（SDK 二进制源码提交）：`{binary}`",
        f"- `releaseMetadataCommit`（仅回填 checksum、扫描汇总和发布验收事实，不是 SDK 二进制源码提交）：`{metadata}`",
        "B 仅用于 checksum、扫描汇总和验收事实，不是 SDK 二进制源码提交。",
    )
    for line in expected:
        require(lines.count(line) == 1, f"Release body 缺少或重复 provenance 声明: {line}")
    require(not any(metadata in line and "sourceCommit" in line for line in lines),
            "Release body 不得把 B 声明为 sourceCommit")


def _allowed(path: str) -> bool:
    return path in ALLOWED_METADATA_FILES or path.startswith("docs/")


def validate_compare(comparison: dict, binary: str, metadata: str) -> None:
    require(comparison.get("status") == "ahead" and comparison.get("ahead_by", 0) >= 1,
            "B 必须是 A 的后代")
    require(comparison.get("behind_by") == 0, "B 不得落后于 A")
    require(comparison.get("base_commit", {}).get("sha") == binary,
            "compare base_commit 不是 A")
    require(comparison.get("merge_base_commit", {}).get("sha") == binary,
            "A 不是 B 的 merge base")
    commits = comparison.get("commits")
    require(isinstance(commits, list) and commits and commits[-1].get("sha") == metadata,
            "compare 提交列表不完整")
    require(comparison.get("total_commits") == comparison.get("ahead_by") == len(commits),
            "compare 提交列表被分页截断")
    files = comparison.get("files")
    require(isinstance(files, list) and files and len(files) < 300,
            "A→B 文件列表为空或达到 API 截断上限")
    for item in files:
        for path in (item.get("filename"), item.get("previous_filename")):
            if path is not None:
                require(isinstance(path, str) and _allowed(path),
                        f"A→B 修改了非元数据路径: {path!r}")


def compare_with_private(binary: str, metadata: str, token: str) -> None:
    require(token.strip(), "正式 provenance 缺少 IFLY_PRIVATE_SOURCE_TOKEN")
    url = (f"https://api.github.com/repos/{PRIVATE_SOURCE_REPOSITORY}/compare/"
           f"{quote(binary, safe='')}...{quote(metadata, safe='')}?per_page=100")
    request = Request(url, headers={
        "Accept": "application/vnd.github+json",
        "Authorization": f"Bearer {token}",
        "User-Agent": "IFLYADLib-private-provenance-verifier",
        "X-GitHub-Api-Version": "2022-11-28",
    })
    require((urlsplit(request.full_url).hostname or "").lower() == "api.github.com",
            "令牌只能发送至 api.github.com")
    with urlopen(request, timeout=60) as response:
        comparison = json.loads(response.read().decode("utf-8"))
    validate_compare(comparison, binary, metadata)


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--readme", type=Path)
    parser.add_argument("--changelog", type=Path)
    parser.add_argument("--releasing", type=Path)
    parser.add_argument("--release-state", type=Path)
    parser.add_argument("--release-metadata", type=Path)
    parser.add_argument("--skip-compare", action="store_true")
    args = parser.parse_args()
    try:
        if args.release_state:
            from release_state import validate_state

            machine_state = validate_state(json.loads(args.release_state.read_text(encoding="utf-8")))
            require(machine_state["phase"] != "PREPARING", "发布 provenance 不接受 PREPARING")
            state = "FORMAL"
            binary = machine_state["binarySourceCommit"]
            metadata = machine_state["releaseMetadataCommit"]
            require(not any((args.readme, args.changelog, args.releasing)),
                    "--release-state 不得混入 Markdown provenance 输入")
        else:
            require(all((args.readme, args.changelog, args.releasing)),
                    "维护检查必须同时提供 README/CHANGELOG/RELEASING")
            state, binary, metadata = validate_documents(
                [args.readme, args.changelog, args.releasing]
            )
        if args.skip_compare:
            require(not args.release_metadata,
                    "--skip-compare 只允许校验 README/CHANGELOG/RELEASING 文档一致性")
        else:
            require(state == "FORMAL", "PENDING 状态只能在 --skip-compare 下运行")
            compare_with_private(binary, metadata, os.environ.get("IFLY_PRIVATE_SOURCE_TOKEN", ""))
            if args.release_metadata:
                release = json.loads(args.release_metadata.read_text(encoding="utf-8"))
                validate_release_body(release.get("body", ""), binary, metadata)
        print(f"A/B provenance 文档通过：state={state}, A={binary}, B={metadata}")
    except (OSError, ValueError, json.JSONDecodeError, VerificationError) as error:
        print(f"ERROR: {error}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
