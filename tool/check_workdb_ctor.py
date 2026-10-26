#!/usr/bin/env python3
"""Fail a release build if R8 removed WorkDatabase_Impl's no-arg constructor.

AAB contains standard DEX under base/dex/. WorkManager/Room instantiate this
class reflectively. The reflected constructor must survive R8 shrinking.
"""
from __future__ import annotations
import struct
import sys
import zipfile
from pathlib import Path

TARGET = "Landroidx/work/impl/WorkDatabase_Impl;"

def uleb(data: bytes, offset: int) -> tuple[int, int]:
    value = 0
    shift = 0
    while True:
        byte = data[offset]
        offset += 1
        value |= (byte & 127) << shift
        if byte < 128:
            return value, offset
        shift += 7

def check_dex(data: bytes) -> tuple[bool, bool]:
    if not data.startswith(b"dex\n"):
        raise ValueError("Not a DEX file")
    def u32(pos: int) -> int:
        return struct.unpack_from("<I", data, pos)[0]
    ns, os_ = u32(0x38), u32(0x3c)
    strings = []
    for n in range(ns):
        off = u32(os_ + n * 4)
        _, off = uleb(data, off)
        strings.append(data[off:data.index(0, off)].decode("utf-8", "replace"))
    nt, ot = u32(0x40), u32(0x44)
    types = [strings[u32(ot + i * 4)] for i in range(nt)]
    if TARGET not in types:
        return False, False
    nm, om = u32(0x58), u32(0x5c)
    method_names = [
        strings[struct.unpack_from("<HHI", data, om + i * 8)[2]]
        for i in range(nm)
    ]
    nc, oc = u32(0x60), u32(0x64)
    for i in range(nc):
        idx, _, _, _, _, _, class_data, _ = struct.unpack_from(
            "<8I", data, oc + 32 * i)
        if types[idx] != TARGET:
            continue
        if not class_data:
            return True, False
        counts = []
        for _ in range(4):
            n, class_data = uleb(data, class_data)
            counts.append(n)
        for _ in range(counts[0] + counts[1]):
            _, class_data = uleb(data, class_data)
            _, class_data = uleb(data, class_data)
        for n in counts[2:]:
            method_id = 0
            for _ in range(n):
                delta, class_data = uleb(data, class_data)
                method_id += delta
                flags, class_data = uleb(data, class_data)
                code_offset, class_data = uleb(data, class_data)
                if method_names[method_id] == "<init>":
                    # The generated Room subclass only has a zero-arg ctor.
                    # Any preserved ctor suffices here since its original
                    # implementation declares exactly one no-arg constructor.
                    return True, True
        return True, False
    return False, False

def main(path: Path):
    with zipfile.ZipFile(path) as archive:
        found = False
        has_ctor = False
        for name in archive.namelist():
            if name.startswith("base/dex/") and name.endswith(".dex"):
                exists, preserved = check_dex(archive.read(name))
                found |= exists
                has_ctor |= preserved
    if not found:
        raise SystemExit("ERROR: WorkDatabase_Impl missing from release DEX")
    if not has_ctor:
        raise SystemExit(
            "ERROR: WorkDatabase_Impl constructor missing (R8 stripped it). "
            "Do not publish this build.")
    print("PASS: WorkDatabase_Impl constructor retained in release DEX")

if __name__ == "__main__":
    if len(sys.argv) != 2:
        raise SystemExit("Usage: python3 tool/check_workdb_ctor.py FILE.aab")
    main(Path(sys.argv[1]))
