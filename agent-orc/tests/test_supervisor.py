from __future__ import annotations

import asyncio
import time
from pathlib import Path

import pytest

from agent_orc.config import load_config
from agent_orc.shutdown import ShutdownController
from agent_orc.supervisor import run_supervisor
from helpers import write_test_config


@pytest.mark.asyncio
async def test_limited_count_one_skill(
    temp_git_repo: Path, fake_cli: Path, tmp_path: Path, monkeypatch: pytest.MonkeyPatch
) -> None:
    record = tmp_path / "record.jsonl"
    monkeypatch.setenv("ORC_FAKE_RECORD", str(record))
    cfg_dir = temp_git_repo / ".orc"
    write_test_config(
        cfg_dir,
        fake_cli=fake_cli,
        agents=["issue-workflow-review-agent"],
        cooldown=0,
        stagger=0,
    )
    config = load_config(cfg_dir)
    agents = [config.agents["issue-workflow-review-agent"]]
    code = await run_supervisor(
        config, agents, count=2, repo_root=temp_git_repo
    )
    assert code == 0
    lines = record.read_text(encoding="utf-8").strip().splitlines()
    assert len(lines) == 2
    wt = temp_git_repo / ".orc" / "worktrees"
    assert not any(wt.iterdir()) if wt.exists() else True
    logs = list((temp_git_repo / ".orc" / "logs" / "issue-workflow-review-agent").glob("run-*.log"))
    assert len(logs) == 2


@pytest.mark.asyncio
async def test_two_skills_parallel(
    temp_git_repo: Path, fake_cli: Path, tmp_path: Path, monkeypatch: pytest.MonkeyPatch
) -> None:
    monkeypatch.setenv("ORC_FAKE_DELAY", "0.15")
    record = tmp_path / "record.jsonl"
    monkeypatch.setenv("ORC_FAKE_RECORD", str(record))
    cfg_dir = temp_git_repo / ".orc"
    write_test_config(
        cfg_dir,
        fake_cli=fake_cli,
        agents=["project-planner-agent", "issue-workflow-review-agent"],
        cooldown=0,
        stagger=0,
    )
    config = load_config(cfg_dir)
    agents = list(config.agents.values())
    t0 = time.monotonic()
    code = await run_supervisor(config, agents, count=1, repo_root=temp_git_repo)
    elapsed = time.monotonic() - t0
    assert code == 0
    assert len(record.read_text(encoding="utf-8").strip().splitlines()) == 2
    # parallel: well under sequential 2 * delay (+ overhead)
    assert elapsed < 0.7


@pytest.mark.asyncio
async def test_stagger(
    temp_git_repo: Path, fake_cli: Path, tmp_path: Path, monkeypatch: pytest.MonkeyPatch
) -> None:
    starts: list[float] = []
    monkeypatch.setenv("ORC_FAKE_RECORD", str(tmp_path / "r.jsonl"))

    # wrap run_skill_once timing via delay 0 and stagger on supervisor
    cfg_dir = temp_git_repo / ".orc"
    write_test_config(
        cfg_dir,
        fake_cli=fake_cli,
        agents=["a", "b", "c"],
        cooldown=0,
        stagger=0.2,
    )
    # rewrite agent names properly
    write_test_config(
        cfg_dir,
        fake_cli=fake_cli,
        agents=[
            "project-planner-agent",
            "issue-workflow-review-agent",
            "issue-workflow-refine-agent",
        ],
        cooldown=0,
        stagger=0.2,
    )
    config = load_config(cfg_dir)
    agents = list(config.agents.values())

    original = run_supervisor.__module__
    from agent_orc import supervisor as sup

    real_run = sup.run_skill_once

    def timed_run(*args, **kwargs):
        starts.append(time.monotonic())
        return real_run(*args, **kwargs)

    monkeypatch.setattr(sup, "run_skill_once", timed_run)
    await run_supervisor(config, agents, count=1, repo_root=temp_git_repo)
    assert len(starts) == 3
    assert starts[1] - starts[0] >= 0.15
    assert starts[2] - starts[1] >= 0.15
    _ = original


@pytest.mark.asyncio
async def test_cooldown_between_runs(
    temp_git_repo: Path, fake_cli: Path, tmp_path: Path, monkeypatch: pytest.MonkeyPatch
) -> None:
    times: list[float] = []
    cfg_dir = temp_git_repo / ".orc"
    write_test_config(
        cfg_dir,
        fake_cli=fake_cli,
        agents=["project-planner-agent"],
        cooldown=0.3,
        stagger=0,
    )
    config = load_config(cfg_dir)
    from agent_orc import supervisor as sup

    real = sup.run_skill_once

    def wrapped(*a, **k):
        times.append(time.monotonic())
        return real(*a, **k)

    monkeypatch.setattr(sup, "run_skill_once", wrapped)
    await run_supervisor(
        config,
        [config.agents["project-planner-agent"]],
        count=2,
        repo_root=temp_git_repo,
    )
    assert len(times) == 2
    assert times[1] - times[0] >= 0.25


@pytest.mark.asyncio
async def test_gate_skip_no_cli(
    temp_git_repo: Path, fake_cli: Path, tmp_path: Path, monkeypatch: pytest.MonkeyPatch
) -> None:
    record = tmp_path / "record.jsonl"
    monkeypatch.setenv("ORC_FAKE_RECORD", str(record))
    cfg_dir = temp_git_repo / ".orc"
    write_test_config(
        cfg_dir,
        fake_cli=fake_cli,
        agents=["issue-workflow-review-agent"],
        cooldown=0.05,
        stagger=0,
        gate_max=0.05,
        gates={"issue-workflow-review-agent": ["false"]},
    )
    config = load_config(cfg_dir)
    shutdown = ShutdownController()

    async def stop_soon() -> None:
        await asyncio.sleep(0.25)
        shutdown.shutting_down = True

    stopper = asyncio.create_task(stop_soon())
    code = await run_supervisor(
        config,
        [config.agents["issue-workflow-review-agent"]],
        count=1,
        shutdown=shutdown,
        repo_root=temp_git_repo,
    )
    await stopper
    assert code == 0
    assert not record.exists() or record.read_text().strip() == ""


@pytest.mark.asyncio
async def test_gate_then_pass_counts_once(
    temp_git_repo: Path, fake_cli: Path, tmp_path: Path, monkeypatch: pytest.MonkeyPatch
) -> None:
    record = tmp_path / "record.jsonl"
    monkeypatch.setenv("ORC_FAKE_RECORD", str(record))
    gate_script = tmp_path / "gate.sh"
    state = tmp_path / "gate_state"
    state.write_text("0", encoding="utf-8")
    gate_script.write_text(
        f"""#!/bin/sh
n=$(cat "{state}")
n=$((n+1))
echo "$n" > "{state}"
if [ "$n" -lt 3 ]; then exit 1; fi
exit 0
""",
        encoding="utf-8",
    )
    gate_script.chmod(0o755)
    cfg_dir = temp_git_repo / ".orc"
    write_test_config(
        cfg_dir,
        fake_cli=fake_cli,
        agents=["issue-workflow-review-agent"],
        cooldown=0.05,
        stagger=0,
        gate_max=0.05,
        gates={"issue-workflow-review-agent": [str(gate_script)]},
    )
    config = load_config(cfg_dir)
    code = await run_supervisor(
        config,
        [config.agents["issue-workflow-review-agent"]],
        count=1,
        repo_root=temp_git_repo,
    )
    assert code == 0
    assert len(record.read_text(encoding="utf-8").strip().splitlines()) == 1


@pytest.mark.asyncio
async def test_pull_only_after_gate_pass(
    temp_git_repo: Path, fake_cli: Path, monkeypatch: pytest.MonkeyPatch
) -> None:
    pulls: list[str] = []
    cfg_dir = temp_git_repo / ".orc"
    write_test_config(
        cfg_dir,
        fake_cli=fake_cli,
        agents=["issue-workflow-review-agent"],
        cooldown=0,
        stagger=0,
        pull_before_run=True,
        gates={"issue-workflow-review-agent": ["true"]},
    )
    config = load_config(cfg_dir)
    from agent_orc import supervisor as sup

    monkeypatch.setattr(
        sup, "pull_repo", lambda root, branch: pulls.append(branch)
    )
    await run_supervisor(
        config,
        [config.agents["issue-workflow-review-agent"]],
        count=1,
        repo_root=temp_git_repo,
    )
    assert pulls == ["main"]


@pytest.mark.asyncio
async def test_agent_failure_continues(
    temp_git_repo: Path, fake_cli: Path, tmp_path: Path, monkeypatch: pytest.MonkeyPatch
) -> None:
    monkeypatch.setenv("ORC_FAKE_EXIT", "1")
    monkeypatch.setenv("ORC_FAKE_RECORD", str(tmp_path / "r.jsonl"))
    cfg_dir = temp_git_repo / ".orc"
    write_test_config(
        cfg_dir,
        fake_cli=fake_cli,
        agents=["project-planner-agent"],
        cooldown=0,
        stagger=0,
    )
    config = load_config(cfg_dir)
    code = await run_supervisor(
        config,
        [config.agents["project-planner-agent"]],
        count=2,
        repo_root=temp_git_repo,
    )
    assert code == 0
    wt = temp_git_repo / ".orc" / "worktrees"
    assert not wt.exists() or not any(wt.iterdir())
