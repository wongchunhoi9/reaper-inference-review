# Builds REAPER toolbar icons (3 states side by side: normal, hover, on/pressed) with full text labels,
# coloured by function using the brand palette. 100%, 150%, 200% sizes.
# Usage: python3 tools/make_icons.py [output folder]   (default: icons/ at the top of the repo; needs Pillow)
import os, sys
from PIL import Image, ImageDraw, ImageFont
ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
OUT = sys.argv[1] if len(sys.argv) > 1 else os.path.join(ROOT, "icons")
# Icons are drawn with DejaVu Sans Bold (found on Linux, or inside matplotlib); otherwise Arial Bold (looks slightly different).
FONTS = ["/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf", os.path.expanduser("~/Library/Fonts/DejaVuSans-Bold.ttf"),
         "/Library/Fonts/DejaVuSans-Bold.ttf"]
try:  # matplotlib ships DejaVu Sans Bold, so a Mac with matplotlib draws identical icons
    import matplotlib; FONTS.append(os.path.join(os.path.dirname(matplotlib.__file__), "mpl-data/fonts/ttf/DejaVuSans-Bold.ttf"))
except ImportError: pass
FONTS += ["/System/Library/Fonts/Supplemental/Arial Bold.ttf", "C:/Windows/Fonts/arialbd.ttf"]
FONT = next(f for f in FONTS if os.path.exists(f))
PAL = {"yellow": (240,244,74), "blue": (152,209,234), "grey": (117,117,117), "orange": (244,116,59), "black": (7,7,9), "white": (245,245,245)}
GROUP = {
  "setup":    ("grey",   "white"),
  "annotate": ("blue",   "black"),
  "play":     ("yellow", "black"),
  "output":   ("orange", "black"),
}
# Labels must match the button labels in "Create toolbar file".
# A toggle button gets a pair of labels: (off text, on text). REAPER shows frame 3 while the toggle is ON.
BUTTONS = [  # file key, label, group, toggle?
  ("build", "Initiate session", "setup", False),
  ("config", "Set config lane", "setup", False),
  ("notelane", "Set note lane", "setup", False),
  ("fit", "Fit to window", "setup", False),
  ("lock", "Lock height", "setup", False),
  ("prompt", "+ Prompt & Region lane 1", "annotate", False),
  ("region2", "+ Region lane 2", "annotate", False),
  ("note", "+ Note", "annotate", False),
  ("marker", "+ Take marker", "annotate", False),
  ("markercol", "Take marker colour reset", "annotate", False),
  ("safeplay", ("Safe playback OFF", "Safe playback ON"), "play", True),
  ("prev", "◀ Previous", "play", False),
  ("next", "Next ▶", "play", False),
  ("abswap", "A/B swap", "play", False),
  ("export", "Export findings", "output", False),
  ("settings", "Settings", "output", False),
  ("about", "About", "output", False),
]
OFF_BG, OFF_HOVER, OFF_TEXT = (58, 58, 62), (78, 78, 84), (170, 170, 170)  # toggle OFF: dark grey button, grey text
def mix(c, t, a): return tuple(int(round(c[i] + (t[i]-c[i])*a)) for i in range(3))
for scale, sub in ((1, ""), (1.5, "150"), (2, "200")):
    H = int(round(30*scale)); fs = int(round(13*scale)); pad = int(round(10*scale)); r = int(round(4*scale)); m = max(1, int(round(1*scale)))
    font = ImageFont.truetype(FONT, fs)
    for key, label, grp, toggle in BUTTONS:
        fill, txt = PAL[GROUP[grp][0]], PAL[GROUP[grp][1]]
        labels = [label[0], label[0], label[1]] if toggle else [label] * 3  # frames: normal, hover, on/pressed
        W = max(int(round(60*scale)), max(font.getbbox(t)[2] for t in labels) + 2*pad)
        img = Image.new("RGBA", (W*3, H), (0,0,0,0))
        d = ImageDraw.Draw(img)
        for st in range(3):
            x0 = st*W
            if toggle:
                # OFF: dark grey, grey text; hover: a bit lighter; ON: solid group colour, black text
                if st == 2:
                    bg, fg = fill, PAL["black"]
                else:
                    bg, fg = (OFF_HOVER if st == 1 else OFF_BG), OFF_TEXT
            else:
                bg = fill if st == 0 else (mix(fill, (255,255,255), 0.25) if st == 1 else mix(fill, (0,0,0), 0.25))
                fg = txt
            d.rounded_rectangle([x0+m, m, x0+W-1-m, H-1-m], radius=r, fill=bg+(255,))
            bb = d.textbbox((0,0), labels[st], font=font)
            tx = x0 + (W - (bb[2]-bb[0]))//2 - bb[0]
            ty = (H - (bb[3]-bb[1]))//2 - bb[1]
            d.text((tx, ty), labels[st], font=font, fill=fg+(255,))
        os.makedirs(os.path.join(OUT, sub), exist_ok=True)
        img.save(os.path.join(OUT, sub, "irp_" + key + ".png"))
print("ok")
