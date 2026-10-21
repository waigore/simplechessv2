"""Parallel per-skill loops with gates, worktrees, and cooldowns."""

from __future__ import annotations

import asyncio
import logging
from pathlib import Path

from agent_orc.config import (
    AgentConfig,
    AppConfig,
    resolved_cooldown_seconds,
    resolved_gate_backoff_initial_seconds,
    resolved_gate_backoff_max_seconds,
)
from agent_orc.crew.factory import run_skill_once
from agent_orc.gate import gate_passes, next_gate_backoff
from agent_orc.shutdown import ShutdownController
from agent_orc.worktree import (
    WorktreeSession,
    create_worktree,
    delete_worktree,
    pull_repo,
)

logger = logging.getLogger("agent_orc.supervisor")


async def run_supervisor(
    config: AppConfig,
    agents: list[AgentConfig],
    *,
    count: int | None = None,
    shutdown: ShutdownController | None = None,
    repo_root: Path | None = None,
) -> int:
    """
    Run selected agents in parallel.

    count=None means daemon (forever). count=N means each agent runs N times
    (gate misses do not count).
    """
    ctl = shutdown or ShutdownController()
    root = (repo_root or Path(config.orchestrator.repo_root)).resolve()
    worktrees_dir = (root / config.orchestrator.worktrees_dir).resolve()
    logs_dir = (root / config.orchestrator.logs_dir).resolve()
    logs_dir.mkdir(parents=True, exist_ok=True)
    worktrees_dir.mkdir(parents=True, exist_ok=True)

    tasks = [
        asyncio.create_task(
            _skill_loop(
                config,
                agent,
                index=index,
                count=count,
                shutdown=ctl,
                repo_root=root,
                worktrees_dir=worktrees_dir,
                logs_dir=logs_dir,
            ),
            name=f"skill:{agent.name}",
        )
        for index, agent in enumerate(agents)
    ]
    results = await asyncio.gather(*tasks, return_exceptions=True)
    exit_code = 0
    for agent, result in zip(agents, results, strict=True):
        if isinstance(result, Exception):
            logger.error("skill loop %s failed: %s", agent.name, result)
            exit_code = 1
        elif isinstance(result, int) and result != 0:
            exit_code = result
    return exit_code


async def _skill_loop(
    config: AppConfig,
    agent: AgentConfig,
    *,
    index: int,
    count: int | None,
    shutdown: ShutdownController,
    repo_root: Path,
    worktrees_dir: Path,
    logs_dir: Path,
) -> int:
    orch = config.orchestrator
    if index > 0 and orch.stagger_seconds > 0:
        await asyncio.sleep(orch.stagger_seconds * index)

    runs_done = 0
    consecutive_misses = 0
    logger.info("skill loop started: %s (count=%s)", agent.name, count)

    while True:
        if shutdown.shutting_down:
            return 0
        if count is not None and runs_done >= count:
            logger.info("skill loop finished: %s (%s runs)", agent.name, runs_done)
            return 0

        passed = await asyncio.to_thread(gate_passes, agent, cwd=repo_root)
        if not passed:
            consecutive_misses += 1
            delay = next_gate_backoff(
                0.0,
                initial=resolved_gate_backoff_initial_seconds(agent, orch),
                maximum=resolved_gate_backoff_max_seconds(agent, orch),
                consecutive_misses=consecutive_misses,
            )
            logger.info(
                "%s gate miss #%s; sleeping %.1fs",
                agent.name,
                consecutive_misses,
                delay,
            )
            await _sleep_interruptible(delay, shutdown)
            continue

        consecutive_misses = 0
        session: WorktreeSession | None = None
        try:
            if orch.pull_before_run:
                await asyncio.to_thread(
                    pull_repo, repo_root, orch.default_branch
                )
            session = await asyncio.to_thread(
                create_worktree,
                repo_root,
                worktrees_dir,
                agent.name,
                base_branch=orch.default_branch,
            )
            shutdown.register_worktree(session)

            def on_pid(pid: int) -> None:
                shutdown.register_pid(pid)

            def on_pid_done(pid: int) -> None:
                shutdown.unregister_pid(pid)

            code = await asyncio.to_thread(
                run_skill_once,
                agent,
                config,
                workdir=session.path,
                logs_dir=logs_dir,
                on_pid=on_pid,
                on_pid_done=on_pid_done,
            )
            if code != 0:
                logger.error("%s run exited %s", agent.name, code)
            else:
                logger.info("%s run completed ok", agent.name)
        except Exception:
            logger.exception("%s run failed", agent.name)
        finally:
            if session is not None:
                await asyncio.to_thread(delete_worktree, session)
                shutdown.unregister_worktree(session)

        runs_done += 1
        if count is not None and runs_done >= count:
            logger.info("skill loop finished: %s (%s runs)", agent.name, runs_done)
            return 0

        cooldown = resolved_cooldown_seconds(agent, orch)
        if cooldown > 0:
            await _sleep_interruptible(cooldown, shutdown)


async def _sleep_interruptible(
    seconds: float, shutdown: ShutdownController
) -> None:
    if seconds <= 0:
        return
    end = asyncio.get_event_loop().time() + seconds
    while asyncio.get_event_loop().time() < end:
        if shutdown.shutting_down:
            return
        await asyncio.sleep(min(0.2, end - asyncio.get_event_loop().time()))
