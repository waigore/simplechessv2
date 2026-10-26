"""List the packed routes of a Godot 4 PCK, for the #879 pack comparison: the
published `index.pck` against a fresh local export of the same sha.

Uses the same standalone-v4 read as `.github/scripts/web_export.py`
(`_version, major, _minor, _patch, _flags` at 4; `_file_base, directory` at 24;
each entry is `length`, path, then offset/size/checksum/flags). Prints one route
per line so the two packs can be diffed.

    python3 scripts/pack_routes.py <index.pck>
"""
import struct
import sys

PACK_MAGIC = b"GDPC"
PACK_ENTRY_TAIL = 8 + 8 + 16 + 4


def routes(pack):
    data = open(pack, "rb").read()
    if data[:4] != PACK_MAGIC or len(data) < 32:
        raise SystemExit(f"{pack}: not a Godot PCK")
    _version, major, _minor, _patch, _flags = struct.unpack_from("<IIIII", data, 4)
    _file_base, directory = struct.unpack_from("<QQ", data, 24)
    if major != 4 or directory == 0 or directory >= len(data):
        raise SystemExit(f"{pack}: unsupported pack header (major {major}, dir {directory})")
    count = struct.unpack_from("<I", data, directory)[0]
    offset = directory + 4
    out = []
    for _ in range(count):
        length = struct.unpack_from("<I", data, offset)[0]
        offset += 4
        path = data[offset : offset + length].rstrip(b"\x00").decode("utf-8", "replace")
        offset += length
        entry_offset, size = struct.unpack_from("<QQ", data, offset)
        offset += PACK_ENTRY_TAIL
        out.append((path, size, entry_offset))
    return count, out


if __name__ == "__main__":
    count, entries = routes(sys.argv[1])
    print(f"# entries={count}", file=sys.stderr)
    for path, size, _ in sorted(entries):
        print(f"{size}\t{path}")
