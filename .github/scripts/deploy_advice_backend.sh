#!/usr/bin/env bash
# Reproducible deploy path for the advice backend and its puzzle catalog route
# (ADR-0010, ADR-0013; CMP-catalog-service R8).
#
# From a clean checkout this prepares the served snapshot from the Lichess
# export and starts the one Python server that answers both routes. Nothing is
# installed globally and no snapshot bytes enter the repository: the export and
# the prepared snapshot live under a directory the operator chooses.
#
#   PUZZLE_CATALOG_CSV=/srv/lichess_puzzles.csv \
#   PUZZLE_CATALOG_PATH=/srv/puzzle_snapshot.json \
#   ADVICE_API_KEY=<configured key> \
#   .github/scripts/deploy_advice_backend.sh
#
# A new snapshot is a new ADR-0008 decision: re-running `true` (default) keeps
# the existing snapshot and never rewrites it in place (L2-L3).
set -euo pipefail

cd "$(dirname "$0")/../.."

: "${ADVICE_API_KEY:?ADVICE_API_KEY is required}"
: "${PUZZLE_CATALOG_PATH:?PUZZLE_CATALOG_PATH is the served snapshot path}"
catalog_csv="${PUZZLE_CATALOG_CSV:-}"
rebuild="${PUZZLE_CATALOG_REBUILD:-true}"

if [[ -n "${catalog_csv}" && "${rebuild}" == "true" ]]; then
  echo "Preparing snapshot ${PUZZLE_CATALOG_PATH} from ${catalog_csv}"
  python3 -m advice_backend.catalog build "${catalog_csv}" "${PUZZLE_CATALOG_PATH}"
fi

if [[ ! -f "${PUZZLE_CATALOG_PATH}" ]]; then
  echo "No served snapshot at ${PUZZLE_CATALOG_PATH}; every deal will fail (FAIL.T14)." >&2
fi

# Host-side integrity checks before serving (SCH-puzzle-catalog I1-I3).
if [[ -f "${PUZZLE_CATALOG_PATH}" ]]; then
  python3 -m advice_backend.catalog check "${PUZZLE_CATALOG_PATH}"
fi

exec python3 -m advice_backend
