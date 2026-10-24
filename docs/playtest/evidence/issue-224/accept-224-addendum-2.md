### Addendum 2 — the evidence docs link fix

The acceptance comment above was written for GitHub rendering, so its links read `../blob/main/…`; the in-repo copies now use relative links, because `Spec lint` resolves links inside `docs/` from the repo. That is a link-form fix only — no judgement, verdict, or status changed. `python3 .github/scripts/spec_lint.py` on the branch: **0 errors**, 1 pre-existing `specs/view/glossary.md` warning.
