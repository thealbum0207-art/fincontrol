#!/usr/bin/env python3
"""Cria ícones FinControl para Android, sem dependências externas.

O Flutter gera ícones padrão em flutter create; este script substitui apenas
os mipmaps do ícone e o android:label (sem mudar packageName ou permissões).
"""
from __future__ import annotations

import math
from pathlib import Path
import re
import struct
import zlib


DENSITIES = {
    "mdpi": 48,
    "hdpi": 72,
    "xhdpi": 96,
    "xxhdpi": 144,
    "xxxhdpi": 192,
}


def rounded(x, y, left, top, right, bottom, radius):
    xx = max(left + radius, min(right - radius, x))
    yy = max(top + radius, min(bottom - radius, y))
    return (x - xx) ** 2 + (y - yy) ** 2 <= radius ** 2


def segment_distance(x, y, ax, ay, bx, by):
    vx, vy = bx - ax, by - ay
    t = max(0, min(1, ((x - ax) * vx + (y - ay) * vy) / (vx * vx + vy * vy)))
    return math.hypot(x - (ax + t * vx), y - (ay + t * vy))


def pixels(size):
    # Desenha em 2x para contornos suaves após reduzir.
    full = size * 2
    pixels_2x = bytearray(full * full * 4)
    poly = [(0.24, 0.62), (0.44, 0.43), (0.57, 0.51), (0.79, 0.28)]
    arrow = [(0.665, 0.28, 0.79, 0.28), (0.79, 0.28, 0.79, 0.405)]
    for yy in range(full):
        y = (yy + 0.5) / full
        for xx in range(full):
            x = (xx + 0.5) / full
            i = (yy * full + xx) * 4
            if not rounded(x, y, 0.035, 0.035, 0.965, 0.965, 0.22):
                continue
            # Base azul petróleo / esmeralda, com iluminação superior.
            light = max(0.0, 1.0 - math.hypot(x - 0.22, y - 0.08) / 0.96)
            rgb = [
                int(5 + 12 * light),
                int(28 + 49 * light),
                int(34 + 34 * light),
            ]
            # Halo muito sutil ao redor do símbolo.
            glow = max(0.0, 1 - math.hypot(x - 0.52, y - 0.52) / 0.64)
            rgb[1] = min(255, rgb[1] + int(glow * 7))
            rgb[2] = min(255, rgb[2] + int(glow * 6))
            # Barras ascendentes, leves e separadas da seta.
            bars = [
                (0.24, 0.66, 0.34, 0.78),
                (0.39, 0.60, 0.49, 0.78),
                (0.54, 0.61, 0.64, 0.78),
            ]
            if any(rounded(x, y, a, b, c, d, 0.023) for a, b, c, d in bars):
                rgb = [25, 176, 137]
            if any(segment_distance(x, y, *a, *b) < 0.035
                   for a, b in zip(poly, poly[1:])):
                rgb = [118, 244, 200]
            if any(segment_distance(x, y, *seg) < 0.033 for seg in arrow):
                rgb = [118, 244, 200]
            # Pequeno brilho na ponta: dá identidade sem texto minúsculo.
            if math.hypot(x - 0.79, y - 0.28) < 0.040:
                rgb = [172, 255, 221]
            pixels_2x[i:i + 4] = bytes((*rgb, 255))
    out = bytearray(size * size * 4)
    for yy in range(size):
        for xx in range(size):
            for channel in range(4):
                a = (2 * yy * full + 2 * xx) * 4 + channel
                out[(yy * size + xx) * 4 + channel] = (
                    pixels_2x[a] + pixels_2x[a + 4]
                    + pixels_2x[a + full * 4] + pixels_2x[a + full * 4 + 4]
                ) // 4
    return out


def png_rgba(size, rgba):
    scanlines = b"".join(
        b"\x00" + rgba[y * size * 4:(y + 1) * size * 4]
        for y in range(size)
    )

    def chunk(tag, data):
        return struct.pack(">I", len(data)) + tag + data + struct.pack(
            ">I", zlib.crc32(tag + data) & 0xFFFFFFFF)

    return (b"\x89PNG\r\n\x1a\n"
            + chunk(b"IHDR", struct.pack(">IIBBBBB", size, size, 8, 6, 0, 0, 0))
            + chunk(b"IDAT", zlib.compress(scanlines, level=9))
            + chunk(b"IEND", b""))


def main():
    base = Path("android/app/src/main")
    manifest = base / "AndroidManifest.xml"
    if not manifest.exists():
        raise SystemExit("AndroidManifest.xml ausente. Execute flutter create primeiro.")
    text = manifest.read_text(encoding="utf-8")
    updated, count = re.subn(r'android:label="[^"]+"', 'android:label="FinControl"', text, count=1)
    if count != 1:
        raise SystemExit("Falha ao localizar android:label; não alterar estrutura Android.")
    manifest.write_text(updated, encoding="utf-8")
    for density, size in DENSITIES.items():
        output = base / "res" / ("mipmap-" + density) / "ic_launcher.png"
        output.parent.mkdir(parents=True, exist_ok=True)
        output.write_bytes(png_rgba(size, pixels(size)))
        print(f"Marca FinControl: {density} {size}x{size}")
    print("Ícones e nome do app configurados, sem mudar identificador do pacote.")


if __name__ == "__main__":
    main()
