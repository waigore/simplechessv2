"""Wire messages for CTR-advice-stream (specs/technical/contracts/advice-stream.md).

Only the shapes the backend owns live here: the O1 request it reads, the E1
update it emits, and the E2 end message. Field names are the wire names.
"""

from __future__ import annotations

from dataclasses import dataclass

# CTR-advice-stream G2 and CFG.ADVICE_TIME_MS.
DEFAULT_ADVICE_TIME_MS = 2000

END_CAP = "cap"
END_CANCEL = "cancel"
END_ERROR = "error"


@dataclass(frozen=True)
class AdviceRequest:
    """O1 request: a position, a search cap, and the client's API key."""

    fen: str
    time_ms: int
    api_key: str


@dataclass(frozen=True)
class AdviceUpdate:
    """E1 update: one search tick, eval in White centipawns (SCH-advice-update)."""

    best_move_uci: str
    eval_cp: int
    mate_in: int | None = None
    depth: int | None = None
    time_ms: int | None = None

    def to_wire(self) -> dict[str, object]:
        message: dict[str, object] = {
            "best_move_uci": self.best_move_uci,
            "eval_cp": self.eval_cp,
        }
        if self.mate_in is not None:
            message["mate_in"] = self.mate_in
        if self.depth is not None:
            message["depth"] = self.depth
        if self.time_ms is not None:
            message["time_ms"] = self.time_ms
        return message


def end_message(reason: str) -> dict[str, str]:
    """E2 end message; ``reason`` is ``cap``, ``cancel``, or ``error``."""
    return {"reason": reason}


def parse_request(payload: object) -> AdviceRequest:
    """Read an O1 request. Raises ValueError when a required field is missing or malformed."""
    if not isinstance(payload, dict):
        raise ValueError("request must be a JSON object")
    fen = payload.get("fen")
    if not isinstance(fen, str) or not fen.strip():
        raise ValueError("fen must be a non-empty string")
    time_ms = payload.get("time_ms")
    if isinstance(time_ms, bool) or not isinstance(time_ms, int):
        raise ValueError("time_ms must be an integer")
    api_key = payload.get("api_key")
    if not isinstance(api_key, str):
        raise ValueError("api_key must be a string")
    return AdviceRequest(fen=fen.strip(), time_ms=time_ms, api_key=api_key)
