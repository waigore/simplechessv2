from __future__ import annotations

from pathlib import Path

import pytest
import yaml

from agent_orc.config import ConfigError, deep_merge, enabled_agents, load_config


def test_deep_merge_nested() -> None:
    base = {"a": {"x": 1, "y": 2}, "b": 3}
    override = {"a": {"y": 9}, "c": 4}
    assert deep_merge(base, override) == {"a": {"x": 1, "y": 9}, "b": 3, "c": 4}


def test_load_defaults_and_local(tmp_path: Path) -> None:
    cfg_dir = tmp_path / ".orc"
    cfg_dir.mkdir()
    (cfg_dir / "config.yaml").write_text(
        yaml.dump(
            {
                "orchestrator": {"cooldown_seconds": 10},
                "providers": {"cursor": {"command": ["agent"]}},
                "agents": {
                    "a": {
                        "skill": "a",
                        "provider": "cursor",
                        "enabled": True,
                        "prompt": "go",
                    }
                },
            }
        ),
        encoding="utf-8",
    )
    (cfg_dir / "config.local.yaml").write_text(
        yaml.dump(
            {
                "orchestrator": {"cooldown_seconds": 3},
                "agents": {"a": {"enabled": False}},
            }
        ),
        encoding="utf-8",
    )
    cfg = load_config(cfg_dir)
    assert cfg.orchestrator.cooldown_seconds == 3
    assert enabled_agents(cfg) == []


def test_missing_local_ok(tmp_path: Path) -> None:
    cfg_dir = tmp_path / ".orc"
    cfg_dir.mkdir()
    (cfg_dir / "config.yaml").write_text(
        yaml.dump(
            {
                "providers": {"p": {"command": ["echo"]}},
                "agents": {
                    "a": {
                        "skill": "a",
                        "provider": "p",
                        "enabled": True,
                        "prompt": "x",
                    }
                },
            }
        ),
        encoding="utf-8",
    )
    cfg = load_config(cfg_dir)
    assert "a" in cfg.agents


def test_invalid_provider_ref(tmp_path: Path) -> None:
    cfg_dir = tmp_path / ".orc"
    cfg_dir.mkdir()
    (cfg_dir / "config.yaml").write_text(
        yaml.dump(
            {
                "providers": {"p": {"command": ["echo"]}},
                "agents": {
                    "a": {
                        "skill": "a",
                        "provider": "missing",
                        "enabled": True,
                        "prompt": "x",
                    }
                },
            }
        ),
        encoding="utf-8",
    )
    with pytest.raises(ConfigError, match="not defined"):
        load_config(cfg_dir)


def test_shipped_config_loads() -> None:
    root = Path(__file__).resolve().parents[2]
    cfg = load_config(root / ".orc")
    assert "project-planner-agent" in cfg.agents
    assert cfg.agents["project-planner-agent"].gate is None
    assert cfg.agents["project-planner-agent"].provider == "opencode-qwen38-max"
    assert "opencode-go/qwen3.8-max" in cfg.providers["opencode-qwen38-max"]
    assert cfg.agents["issue-workflow-refine-agent"].provider == "grok"
    assert cfg.agents["issue-workflow-verify-agent"].provider == "opencode-deepseek-v41-flash"
    assert "opencode-go/deepseek-v4.1-flash" in cfg.providers["opencode-deepseek-v41-flash"]
    assert cfg.agents["issue-workflow-review-agent"].gate is not None
    assert cfg.orchestrator.cooldown_seconds == 10
    assert len(enabled_agents(cfg)) == 7
