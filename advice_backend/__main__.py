"""Run the advice backend.

Environment: ``ADVICE_API_KEY`` (required, the configured key of ADR-0010),
``ADVICE_HOST`` and ``ADVICE_PORT`` (listen address the process is given),
``ADVICE_TIME_MS`` (search cap, default 2000), ``STOCKFISH_PATH`` (the
operator-installed Stockfish, default ``stockfish`` on ``PATH``), and the
catalog route's settings: ``PUZZLE_CATALOG_PATH`` (the prepared snapshot from
``python3 -m advice_backend.catalog``; unset serves advice only) and
``PUZZLE_CATALOG_RATE_LIMIT`` (T11, default 30 requests per key per minute).
TLS terminates at whatever proxy fronts this process; no accounts exist.
"""

from __future__ import annotations

import logging
import os
import sys
from typing import TYPE_CHECKING

from .protocol import DEFAULT_ADVICE_TIME_MS
from .server import AdviceService, make_server

if TYPE_CHECKING:
    from .catalog import CatalogService


def _required_key() -> str:
    key = os.environ.get("ADVICE_API_KEY", "")
    if not key:
        sys.exit("ADVICE_API_KEY is required")
    return key


def _catalog(api_key: str) -> CatalogService | None:
    """The deal route (ADR-0013), or None when no snapshot is configured.

    A missing route is a failed read for every deal (``FAIL.T14``): nothing is
    dealt and ``GS.playerElo`` is unchanged, while advice keeps working.
    """
    path = os.environ.get("PUZZLE_CATALOG_PATH", "")
    if not path:
        logging.getLogger("advice_backend").warning("catalog route disabled: PUZZLE_CATALOG_PATH is unset")
        return None
    # Imported here so `python3 -m advice_backend.catalog` is not pre-imported
    # by this package entry point.
    from .catalog import DEFAULT_RATE_LIMIT, CatalogService, CatalogStore

    return CatalogService(
        CatalogStore.from_json(path),
        api_key,
        rate_limit=int(os.environ.get("PUZZLE_CATALOG_RATE_LIMIT", DEFAULT_RATE_LIMIT)),
    )


def main() -> None:
    logging.basicConfig(
        level=logging.INFO,
        format="%(asctime)s %(levelname)s %(name)s %(message)s",
    )
    api_key = _required_key()
    service = AdviceService(
        api_key=api_key,
        cap_ms=int(os.environ.get("ADVICE_TIME_MS", DEFAULT_ADVICE_TIME_MS)),
        engine_path=os.environ.get("STOCKFISH_PATH") or None,
    )
    catalog = _catalog(api_key)
    host = os.environ.get("ADVICE_HOST", "127.0.0.1")
    port = int(os.environ.get("ADVICE_PORT", "8080"))
    server = make_server(service, host, port, catalog)
    logging.getLogger("advice_backend").info(
        "listening on %s:%d catalog_records=%s",
        host,
        port,
        len(catalog.store) if catalog is not None else "off",
    )
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        server.shutdown()


if __name__ == "__main__":
    main()
