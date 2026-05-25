#!/usr/bin/env python3
"""𝕏 タイムライン風モック（共有カード + 投稿テキスト）を App Store 用に合成"""
from pathlib import Path

try:
    from PIL import Image, ImageDraw, ImageFont
except ImportError:
    raise SystemExit("pip install Pillow") from None

ROOT = Path(__file__).resolve().parents[2]
CARD = ROOT / "docs/screenshots/04-share-card-with-reflection.png"
OUT = ROOT / "docs/screenshots/08-x-timeline-mock.png"
W, H = 1290, 2796
BG = (0, 0, 0)
TEXT = (231, 231, 236)
MUTED = (113, 118, 123)
ACCENT = (29, 155, 240)


def main() -> None:
    if not CARD.exists():
        raise SystemExit(f"Missing {CARD}. Run generate-screenshots.sh first.")

    img = Image.new("RGB", (W, H), BG)
    draw = ImageDraw.Draw(img)

    try:
        font_name = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", 42)
        font_body = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", 36)
        font_small = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", 30)
    except OSError:
        font_name = font_body = font_small = ImageFont.load_default()

    pad = 48
    y = 120
    draw.ellipse((pad, y, pad + 72, y + 72), fill=(47, 51, 54))
    draw.text((pad + 96, y + 8), "っぽい格言", fill=TEXT, font=font_name)
    draw.text((pad + 96, y + 52), "@ppoi_app · たった今", fill=MUTED, font=font_small)

    y += 120
    body = "私の考察：意味不明だけど、なぜか沁みる…\n#っぽい格言"
    draw.multiline_text((pad, y), body, fill=TEXT, font=font_body, spacing=12)

    y += 160
    card = Image.open(CARD).convert("RGB")
    max_w = W - pad * 2
    scale = max_w / card.width
    new_size = (int(card.width * scale), int(card.height * scale))
    card = card.resize(new_size, Image.Resampling.LANCZOS)
    img.paste(card, (pad, y))

    draw.rounded_rectangle(
        (pad, y, pad + new_size[0], y + new_size[1]),
        radius=24,
        outline=(47, 51, 54),
        width=3,
    )

    OUT.parent.mkdir(parents=True, exist_ok=True)
    img.save(OUT, "PNG", optimize=True)
    print(f"Wrote {OUT}")


if __name__ == "__main__":
    main()
