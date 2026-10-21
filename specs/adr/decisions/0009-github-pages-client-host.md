# ADR-0009: GitHub Pages client host

Authoring rules: [`.agents/specs/rules/adr/decision.md`](../../../.agents/specs/rules/adr/decision.md).

- **Status**: Accepted
- **Date**: 2026-10-21
- **Category**: Integration
- **Supersedes**: None
- **Informed by**: No-install browser commute (definition); Web platform (definition); Load time / latency (quality); uncommitted `build/web/` (ADR-0007); public build omits playtest debug UI (ADR-0004); Web/HTML5 export (ADR-0001)

## Context

The definition requires a no-install Web commute. ADR-0001 ships a Godot 4.7.2 Web client. ADR-0007 writes the export to uncommitted `build/web/` and names no host or URL. ADR-0004 keeps debug UI and the story-ID overlay out of the public build. The client-host cost envelope is $0. Advice hosting (ADR-0002) and catalog reads (ADR-0008) are separate.

## Purpose

Where is the public client served, and how does a clean checkout's release export reach that URL?

In scope: host, URL, deploy path, runner, and cost. Out of scope: the advice backend, the puzzle-catalog API, and the workflow file that carries out this path.

## Decision

GitHub Pages on the public repository `waigore/simplechessv2` serves the client at `https://waigore.github.io/simplechessv2/`. Cost is the free tier only ($0).

A CI workflow checks out a clean tree, runs the release Web export into `build/web/` (ADR-0007), and publishes that directory. The published tree omits playtest debug UI and the story-ID overlay (ADR-0004). `build/web/` stays uncommitted. The workflow does not publish a playtest build and does not host the advice backend.

## Reasoning

1. The no-install commute needs one public URL (definition).
2. The $0 envelope fits GitHub Pages on this public repository.
3. CI from a clean checkout is reproducible; `build/web/` is the artifact (ADR-0007).
4. The release export, not the playtest export, keeps debug seams off the public URL (ADR-0004).

Costs accepted: the site depends on GitHub Pages and on a downstream CI workflow.

## Rejected alternatives

| Alternative | Why rejected |
|-------------|--------------|
| Self-hosting | Cost or ops outside the $0 envelope |
| A paid static host | Breaks the free-tier envelope |
| A manual upload runbook | Not a clean-checkout CI publish |
| Publish the playtest export | Puts debug UI and story IDs on the public URL (ADR-0004) |

## Non-functional requirements

Quality and engineering rows: [non-functional requirements](0009-github-pages-client-host/non-functional.md).

### Quality expectations

Load time / latency is Affects. The other categories are No effect. Detail is in the split.

### Engineering qualities

Free-tier GitHub Pages, Web only, public release bytes. Detail is in the split.

## Imposes

| Spec or element | Constraint |
|-----------------|------------|
| None | — |

## Validation

| Check | Method | When |
|-------|--------|------|
| Pages URL, $0 free tier, CI publish of release `build/web/`, no playtest debug UI | Review of this ADR against ADR-0004 and ADR-0007 | Before acceptance |
| Board playable within 3 seconds on the public URL | Timed cold open to first legal move (quality.md) | Every release |
