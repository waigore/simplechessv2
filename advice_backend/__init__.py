"""Advice backend (specs/technical/components/advice-backend.md).

A separate Python server that is the sole UCI peer of Stockfish. Import
nothing from the Godot client; nothing here may reach the browser (R1, R4).
"""

from .protocol import DEFAULT_ADVICE_TIME_MS, AdviceRequest, AdviceUpdate
from .server import ADVICE_PATH, AdviceService, make_server

__all__ = [
    "ADVICE_PATH",
    "DEFAULT_ADVICE_TIME_MS",
    "AdviceRequest",
    "AdviceService",
    "AdviceUpdate",
    "make_server",
]
