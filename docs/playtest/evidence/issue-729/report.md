# Report — #729 Observability row build envelope

- **Issue**: #729 — the Observability `quality.md` row was judged on the wrong build
- **Environment**: `headless` — Godot `4.7.2.stable.official.ed1daf0bf`, Linux
- **Builds read**: `origin/main` @ `8f9c591` — playtest `res://main.tscn` and release `res://main_release.tscn`
- **Coverage mode**: `critical-only` — the two reproduction steps the issue names

A **record-correctness** defect. No code change is owed, and none is made. The run proves the premise on this
tree rather than taking it from the issue text.

## Readings

### 1. Playtest build emits — conformant

```
$ GODOT --headless --path game
{"TEL.1":"jump","TEL.2":1792828894825,"TEL.3":"sess-1792828894807-2259980-playtest-1032801","TEL.4":"mode-pick","TEL.5":"pass"}
{"TEL.1":"smoke_inspect","TEL.2":1792828894825,"TEL.3":"sess-1792828894807-2259980-playtest-1032801","TEL.4":"EX.loading","TEL.5":"pass"}
{"TEL.1":"pause","TEL.2":1792828894825,"TEL.3":"sess-1792828894807-2259980-playtest-1032801","TEL.5":"pass"}
{"TEL.1":"resume","TEL.2":1792828894825,"TEL.3":"sess-1792828894807-2259980-playtest-1032801","TEL.5":"pass"}
```

One NDJSON object per line on stdout (`H3`), `TEL.1`–`TEL.5` present with `TEL.4` omitted where no story applies
(`tools.md:36`), `TEL.3` stable across all four, `E1` the sink (`S7`). Exit 0. The build conforms, which is what
`SIT.5` over `E1` reads.

### 2. Release build emits nothing — as specified

```
$ GODOT --headless --path game res://main_release.tscn   # 20 s bounded
Godot Engine v4.7.2.stable.official.ed1daf0bf - https://godotengine.org/
```

`TEL` hits **0**; `ERROR`/`SCRIPT ERROR` hits **0**. `_bind_seams` (`session_router.gd:98–109`) finds no
`PlaytestSeams` node in `main_release.tscn`, so `_emit_tel` (`:115–117`) is a no-op. That is `CTR-playtest-drive`
G2, `verification.md` H1/I3, and `CMP-playtest-seams` R3 exactly.

### 3. Headless smoke still passes

`GODOT --headless --path game` exits 0, so the conformant behavior this defect must leave unchanged is unchanged.

## What this establishes

- The row's *How checked* reads `SIT.5`, realized by `S12` over the `E1` sink: the **playtest-certified build**.
  It never describes a release build.
- `quality.md`'s Target is "visible locally … for AI-agent playtests"; ADR-0004 and `tools.md` put `TEL.1–5` as a
  Must in `ENV.1`/`ENV.2`, the playtest session kinds.
- So zero `TEL.*` on a release build is **specified**; reading it as the row's failure was a build-envelope
  error in the record, not a code defect.

## Corrections made (docs only)

| Record | Before | After |
|---|---|---|
| `…T020500Z/manifest.md` row | `fail` — zero `TEL.*` on published | `not-judged` — out of envelope; silence specified |
| same, totals | 2 fail, 8 not-judged | 1 fail, 9 not-judged |
| same, defects | "release emits no `TEL.*`; the row fails" | row read on the wrong build; silence specified |
| `…T020500Z/notes.md` | "Observability is independent of #630 … fails" | out of envelope; not build-independent |
| `…T020500Z/builds.md` | "the defect cited for the row" | build property, specified |
| `…T011500Z/manifest.md` + `notes.md` | `fail` — no `TEL.*` | `not-judged` — playtest build only |

## Out of scope, as the issue directs

- **`#402`'s verdict change** — its edit, after `#506` states the envelope.
- **`#506`'s envelope** — the row's wording; not edited here.
- **`#763`** — whether the shipped build needs its own emission. Not implemented.
- **Release-side emission** — not added; `G2`, `H1`, `H3`, `I3`, `R3` stand unchanged.

Records the row's **build envelope**, not "the Observability row passes".
