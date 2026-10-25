"""Generate the 日本語辞書 launcher icon (option B: black 白 on yellow, red 日 badge).

Writes, under android/app/src/main/res/:
  drawable-<dpi>/ic_jp_dict_foreground.png   adaptive foreground (108 dp)
  mipmap-<dpi>/jp_dict_icon.png              legacy icon (48 dp), pre-26
The adaptive XML and the yellow background colour are hand-written resources.

Usage: python3 -I gen-jp-dict-icon.py <repo root>
"""
import sys
from PIL import Image, ImageDraw, ImageFont

repo = sys.argv[1]
res = f"{repo}/android/app/src/main/res"
FG = Image.open(f"{res}/drawable-xxxhdpi/ic_launcher_foreground.png").convert("RGBA")
KANTEI = "/home/shiroikuma/.local/share/fonts/ｄ/ＤＦＧ勘亭流W6_2.20.ttc.ttf"
YELLOW = (250, 225, 20, 255)
RED = (200, 16, 46, 255)
BLACK = (0, 0, 0, 255)
WHITE = (255, 255, 255, 255)
S = 432  # 108 dp at xxxhdpi; the visible zone is the centre 288 px


def foreground():
    """Transparent canvas with the 白 strokes in black and the badge."""
    img = Image.new("RGBA", (S, S), (0, 0, 0, 0))
    r, g, b, a = FG.split()
    lum = Image.merge("RGB", (r, g, b)).convert("L")
    strokes = lum.point(lambda v: 255 if v > 120 else 0)
    img.paste(BLACK, (0, 0), strokes)
    d = ImageDraw.Draw(img)
    cx, cy, rr = 282, 282, 58
    # Yellow ring separates the badge from the black strokes it overlaps.
    d.ellipse((cx - rr - 7, cy - rr - 7, cx + rr + 7, cy + rr + 7), fill=YELLOW)
    d.ellipse((cx - rr, cy - rr, cx + rr, cy + rr), fill=RED)
    d.text((cx, cy), "日", font=ImageFont.truetype(KANTEI, 84), fill=WHITE, anchor="mm")
    return img


fg = foreground()
full = Image.new("RGBA", (S, S), YELLOW)
full.alpha_composite(fg)
legacy = full.crop((72, 72, 360, 360)).convert("RGB")

for dpi, scale in (("mdpi", 1), ("hdpi", 1.5), ("xhdpi", 2), ("xxhdpi", 3), ("xxxhdpi", 4)):
    fg.resize((round(108 * scale),) * 2, Image.LANCZOS).save(f"{res}/drawable-{dpi}/ic_jp_dict_foreground.png")
    legacy.resize((round(48 * scale),) * 2, Image.LANCZOS).save(f"{res}/mipmap-{dpi}/jp_dict_icon.png")
