"""Run the advice backend.

Environment: ``ADVICE_API_KEY`` (required, the configured key of ADR-0010),
``ADVICE_HOST`` and ``ADVICE_PORT`` (listen address the process is given),
``ADVICE_TIME_MS`` (search cap, default 2000), ``STOCKFISH_PATH`` (the
operator-installed Stockfish, default ``stockfish`` on ``PATH``).
TLS terminates at whatever proxy fronts this process; no accounts exist.
"""

from __future__ import annotations

import logging
import os
import sys

from .protocol import DEFAULT_ADVICE_TIME_MS
from .server import AdviceService, make_server


def _required_key() -> str:
    key = os.environ.get("ADVICE_API_KEY", "")
    if not key:
        sys.exit("ADVICE_API_KEY is required")
    return key


def main() -> None:
    logging.basicConfig(
        level=logging.INFO,
        format="%(asctime)s %(levelname)s %(name)s %(message)s",
    )
    service = AdviceService(
        api_key=_required_key(),
        cap_ms=int(os.environ.get("ADVICE_TIME_MS", DEFAULT_ADVICE_TIME_MS)),
        engine_path=os.environ.get("STOCKFISH_PATH") or None,
    )
    host = os.environ.get("ADVICE_HOST", "127.0.0.1")
    port = int(os.environ.get("ADVICE_PORT", "8080"))
    server = make_server(service, host, port)
    logging.getLogger("advice_backend").info("listening on %s:%d", host, port)
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        server.shutdown()


if __name__ == "__main__":
    main()
