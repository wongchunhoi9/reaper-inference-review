# Builds REAPER toolbar icons (3 states side by side: normal, hover, on/pressed) with full text labels,
# coloured by function using the brand palette. 100%, 150%, 200% sizes.
# Usage: python3 tools/make_icons.py [output folder]   (default: icons/ at the top of the repo; needs Pillow)
import os, sys
from PIL import Image, ImageDraw, ImageFont
ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
OUT = sys.argv[1] if len(sys.argv) > 1 else os.path.join(ROOT, "icons")
# The shipped icons were drawn with DejaVu Sans Bold; on a Mac without it, Arial Bold is used (looks slightly different).
FONTS = ["/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf", os.path.expanduser("~/Library/Fonts/DejaVuSans-Bold.ttf"),
         "/Library/Fonts/DejaVuSans-Bold.ttf", "/System/Library/Fonts/Supplemental/Arial Bold.ttf", "C:/Windows/Fonts/arialbd.ttf"]
FONT = next(f for f in FONTS if os.path.exists(f))
PAL = {"yellow": (240,244,74), "blue": (152,209,234), "grey": (117,117,117), "orange": (244,116,59), "black": (7,7,9), "white": (245,245,245)}
GROUP = {
  "setup":    ("grey",   "white"),
  "annotate": ("blue",   "black"),
  "play":     ("yellow", "black"),
  "output":   ("orange", "black"),
}
BUTTONS = [  # file key, label, group, toggle?
  ("build", "Build session", "setup", False),
  ("config", "Set config", "setup", False),
  ("notelane", "Set note lane", "setup", False),
  ("fit", "Fit to window", "setup", False),
  ("lock", "Lock height", "setup", False),
  ("prompt", "+ Prompt", "annotate", False),
  ("region2", "+ Region lane 2", "annotate", False),
  ("note", "+ Note", "annotate", False),
  ("marker", "+ Marker", "annotate", False),
  ("markercol", "Marker colour", "annotate", False),
  ("prev", "◀ Previous", "play", False),
  ("next", "Next ▶", "play", False),
  ("abswap", "A/B swap", "play", False),
  ("safeplay", "Safe playback", "play", True),
  ("export", "Export findings", "output", False),
  ("settings", "Settings", "output", False),
]
def mix(c, t, a): return tuple(int(round(c[i] + (t[i]-c[i])*a)) for i in range(3))
for scale, sub in ((1, ""), (1.5, "150"), (2, "200")):
    H = int(round(30*scale)); fs = int(round(13*scale)); pad = int(round(10*scale)); r = int(round(4*scale)); m = max(1, int(round(1*scale)))
    font = ImageFont.truetype(FONT, fs)
    for key, label, grp, toggle in BUTTONS:
        fill, txt = PAL[GROUP[grp][0]], PAL[GROUP[grp][1]]
        tw = font.getbbox(label)[2]
        W = max(int(round(60*scale)), tw + 2*pad)
        img = Image.new("RGBA", (W*3, H), (0,0,0,0))
        d = ImageDraw.Draw(img)
        for st in range(3):
            x0 = st*W
            if toggle:
                # off: dark with coloured outline + coloured text; hover: lighter; on: solid colour, black text
                if st == 2:
                    bg, fg, ol = fill, PAL["black"], PAL["white"]
                else:
                    bg, fg, ol = (mix((26,26,29), fill, 0.15 if st == 1 else 0)), fill, fill
            else:
                bg = fill if st == 0 else (mix(fill, (255,255,255), 0.25) if st == 1 else mix(fill, (0,0,0), 0.25))
                fg, ol = txt, None
            d.rounded_rectangle([x0+m, m, x0+W-1-m, H-1-m], radius=r, fill=bg+(255,), outline=(ol+(255,)) if ol else None, width=max(1,int(round(2*scale))) if ol else 1)
            bb = d.textbbox((0,0), label, font=font)
            tx = x0 + (W - (bb[2]-bb[0]))//2 - bb[0]
            ty = (H - (bb[3]-bb[1]))//2 - bb[1]
            d.text((tx, ty), label, font=font, fill=fg+(255,))
        os.makedirs(os.path.join(OUT, sub), exist_ok=True)
        img.save(os.path.join(OUT, sub, "irp_" + key + ".png"))
print("ok")
