#!/usr/bin/env python3
"""从可信 main 控制提交复验当前目标版 Tag 的 CLOSED 后继链；不改发布事实。"""

from __future__ import annotations

import argparse
import json
import re
import subprocess
import sys
from pathlib import Path

# workflow 使用 git show <workflow_sha>:<script> | python3 -，依赖固定于同一 checkout。
sys.path.insert(0, str(Path.cwd() / "scripts"))
from release_metadata_control import validate_release_control
from release_state import validate_state, validate_closeout_transition


CONTROL_PATHS = frozenset({
    ".github/workflows/ci.yml",
    ".github/fixtures/swiftpm-consumer/Package.swift",
    ".github/fixtures/swiftpm-consumer/Sources/ReleaseConsumer/ReleaseConsumer.swift",
    "Package.swift", "README.md", "CHANGELOG.md", "RELEASING.md", "SECURITY.md",
    "IFLYADLibSimple/README.md", "IFLYADLibSimple/Podfile",
    "scripts/download_release_anonymously.py", "scripts/download_draft_release.py",
    "scripts/release_asset_downloader.py", "scripts/github_http_retry.py",
    "scripts/verify_private_release_provenance.py", "scripts/prepare_release_consumers.py",
    "scripts/verify_distribution_manifest.py", "scripts/verify_repository_contract.py",
    "scripts/validate_release_control.py", "scripts/verify_manual_formal_reverification.py",
    "tests/test_ci_workflow_contract.py", "tests/test_release_asset_downloader.py",
    "tests/test_github_http_retry.py", "tests/test_network_retry_integration.py",
    "tests/test_prepare_release_consumers.py", "tests/test_verify_distribution_manifest.py",
    "tests/test_validate_release_control.py", "tests/test_verify_manual_formal_reverification.py",
})


def require(condition: bool, message: str) -> None:
    if not condition:
        raise ValueError(message)


def git(*args: str) -> bytes:
    return subprocess.check_output(["git", *args])


def revision(ref: str) -> str:
    return git("rev-parse", "--verify", ref).decode().strip()


def changes(parent: str, commit: str) -> list[tuple[str, str, str, str]]:
    # NUL 分隔避免空格/换行路径绕过；关闭 rename 检测后改名必含 D，仍被拒绝。
    fields = git("diff-tree", "--no-commit-id", "--raw", "-z", "-r",
                 "--no-renames", parent, commit).split(b"\0")
    result = []
    for index in range(0, len(fields) - 1, 2):
        before, after, _, _, status = fields[index].decode().split()
        result.append((fields[index + 1].decode(), before[1:], after, status))
    return result


def check_files(delta: list[tuple[str, str, str, str]], allowed: frozenset[str]) -> None:
    for path, before, after, status in delta:
        require(path in allowed, f"非获准路径: {path}")
        require(status in {"A", "M"}, f"禁止删除/改名/类型变化: {path} ({status})")
        require(after in {"100644", "100755"}, f"必须为普通文件: {path}")
        require((status == "A" and before == "000000")
                or (status == "M" and before == after), f"禁止模式变化: {path}")


def state_at(commit: str, repository: str, tag: str) -> dict:
    entries = git("ls-tree", commit, "--", "release-state.json").decode().split()
    require(len(entries) == 4 and entries[:2] == ["100644", "blob"],
            "release-state.json 必须为 100644 普通文件")
    return validate_state(json.loads(git("show", f"{commit}:release-state.json")),
                          expected_repository=repository, expected_channel="general",
                          expected_version=tag)


def verify(*, repository: str, tag: str, release_id: str, event_name: str,
           event_ref: str, event_sha: str, workflow_sha: str) -> None:
    require(event_name == "workflow_dispatch" and event_ref == "refs/heads/main",
            "手动正式复验只允许 workflow_dispatch/main")
    require(re.fullmatch(r"[0-9]+\.[0-9]+\.[0-9]+", tag) is not None, "tag 格式非法")
    require(re.fullmatch(r"[1-9][0-9]*", release_id) is not None, "Release ID 格式非法")
    require(re.fullmatch(r"[0-9a-f]{40}", workflow_sha) is not None,
            "workflow_sha 必须为完整 SHA")
    head = revision("HEAD")
    require(head == event_sha == workflow_sha, "HEAD/event SHA/workflow_sha 必须一致")
    require(not git("status", "--porcelain"), "checkout 必须干净")
    tag_ref = f"refs/tags/{tag}"
    require(git("cat-file", "-t", tag_ref).strip() == b"tag", "必须是 annotated Tag")
    tag_object = revision(tag_ref)
    tag_commit = revision(f"{tag_ref}^{{commit}}")
    header = git("cat-file", "-p", tag_ref).decode().split("\n\n", 1)[0].splitlines()
    require(header[:3] == [f"object {tag_commit}", "type commit", f"tag {tag}"],
            "annotated Tag 必须以同名直接指向冻结提交")
    frozen = state_at(tag_commit, repository, tag)
    require(frozen["phase"] == "FROZEN", "Tag 必须绑定 FROZEN 状态")
    contract = json.loads(git("show", f"{head}:scripts/release-control.json"))
    validate_release_control(contract, repository=repository, channel="general",
                             release_phase="FROZEN", release_version=tag,
                             validation_mode="formal")
    require(git("show", f"{head}:scripts/release-control.json")
            == git("show", f"{tag_commit}:scripts/release-control.json"),
            "复验不得改变 Tag 的版本控制合同")

    # 反向追踪单父链，避免 merge 或短暂越界改动在最终树中被掩盖。
    chain = []
    cursor = head
    while cursor != tag_commit:
        parents = git("rev-list", "--parents", "-n", "1", cursor).decode().split()
        require(len(parents) == 2, "main 必须沿单父后继链到达精确 Tag")
        chain.append((parents[1], cursor))
        cursor = parents[1]
    require(bool(chain), "main 必须包含 Tag 的直接 CLOSED 收口提交")
    chain.reverse()
    parent, closed_commit = chain[0]
    closeout_delta = changes(parent, closed_commit)
    require(len(closeout_delta) == 1 and closeout_delta[0][0] == "release-state.json"
            and closeout_delta[0][3] == "M", "CLOSED 必须仅修改 release-state.json")
    check_files(closeout_delta, frozenset({"release-state.json"}))
    closed = state_at(closed_commit, repository, tag)
    validate_closeout_transition(frozen, closed)
    publication = closed["publication"]
    require(publication["tagObjectSha"] == tag_object
            and publication["tagCommitSha"] == tag_commit, "CLOSED 的 Tag 对象/提交身份漂移")
    require(publication["releaseId"] == int(release_id), "CLOSED 的 Release ID 不匹配")
    for parent, commit in chain[1:]:
        check_files(changes(parent, commit), CONTROL_PATHS)
        # 白名单中的包管理器入口仍只允许整行注释变化，逐提交阻断改后再还原。
        for path, prefix in (("Package.swift", "//"), ("IFLYADLibSimple/Podfile", "#")):
            def code_at(ref: str) -> list[str]:
                return [line for line in git("show", f"{ref}:{path}").decode().splitlines()
                        if not line.lstrip().startswith(prefix)]
            require(code_at(commit) == code_at(tag_commit), f"{path} 存在非注释修改")
    require(git("show", f"{head}:release-state.json")
            == git("show", f"{closed_commit}:release-state.json"), "CLOSED 后状态字节漂移")


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    for name in ("repository", "tag", "release-id", "event-name", "event-ref",
                 "event-sha", "workflow-sha"):
        parser.add_argument(f"--{name}", required=True)
    args = parser.parse_args()
    try:
        verify(**vars(args))
    except (ValueError, OSError, subprocess.CalledProcessError) as error:
        print(f"手动正式复验拓扑校验失败: {error}", file=sys.stderr)
        return 1
    print("手动正式复验拓扑校验通过")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
