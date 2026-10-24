# Story row out of playtest scope

Authoring rules: [`.agents/specs/rules/playtest/traceability.md`](../../../.agents/specs/rules/playtest/traceability.md).

The home for a story row no build run can observe, recorded by [#701](https://github.com/waigore/simplechessv2/issues/701) and tracked by its live successor defect [#788](https://github.com/waigore/simplechessv2/issues/788). The row unit and the `none` vocabulary are owned by [`story-rows.md`](../story-rows.md); this file records no rule of its own.

## Recorded rows

| Row | Scenarios | Why no run judges it | How it is judged |
|-----|-----------|----------------------|------------------|
| [`localization.md#US2`](../../ux/stories/localization.md#US2) (`LOC.US2`) | `LOC.US2.1`, `LOC.US2.2` | The interface cannot show the state. No situational tool lengthens a string or rewords a Copy row (`LOC.US2.1`), and change control is a review outcome, not a build state (`LOC.US2.2`). | Spec read of [`ux/localization.md`](../../ux/localization.md) `LOC.L4` and `LOC.L5`, recorded in `notes.md`. |

**`LOC.US2.1`** reads the `S3 EX.save-failure` table of [`ux/screens/puzzle-play.md`](../../ux/screens/puzzle-play.md): `save_failed` and `dismiss` grow 40% in `ja` and stay inside 720×1280 with Dismiss at 44 px or more.

**`LOC.US2.2`** reads the Copy tables of [`ux/screens/shared-play.md`](../../ux/screens/shared-play.md) and [`ux/screens/puzzle-play.md`](../../ux/screens/puzzle-play.md): a reworded `refused_place` is accepted only against a cited element such as `EX.rejected` ([`ux/exceptions.md`](../../ux/exceptions.md)).

**Row state.** The story-to-protocol map keeps the row as `none — LOC.US2 is out of playtest scope; judged by spec read` and links here; `out` and `not-judged` stay unrecorded, per [`story-rows.md`](../story-rows.md).
