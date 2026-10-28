# One-off rename: "TTS Review" -> "Inference Review and Presentation" across the project.
import os, re, shutil
ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
os.chdir(ROOT)
NAME = "Inference Review and Presentation"
THEME = "Inference_Review_and_Presentation"

# 1) folders / files (mv only, no deletes)
moves = [
  ("TTS Review Kit/Scripts/TTS Review/lib/tts_review_lib.lua", "TTS Review Kit/Scripts/TTS Review/lib/inference_review_lib.lua"),
  ("TTS Review Kit/Scripts/TTS Review", "TTS Review Kit/Scripts/" + NAME),
  ("TTS Review Kit", NAME + " Kit"),
  ("build/TTS_Review_unpacked", "build/" + THEME + "_unpacked"),
  ("build/TTS_Review_unpacked.ReaperTheme", "build/" + THEME + "_unpacked.ReaperTheme"),
  ("dev/TTS_dev_bridge.lua", "dev/irp_dev_bridge.lua"),
]
for a, b in moves:
    if os.path.exists(a): os.rename(a, b); print("mv", a, "->", b)
kit = NAME + " Kit/"
sdir = kit + "Scripts/" + NAME + "/"
for f in sorted(os.listdir(sdir)):
    if f.startswith("TTS Review - "):
        os.rename(sdir + f, sdir + f.replace("TTS Review - ", NAME + " - ")); print("mv script", f)
for sub in ("", "150/", "200/"):
    d = sdir + "icons/" + sub
    for f in os.listdir(d):
        if f.startswith("tts_"): os.rename(d + f, d + "irp_" + f[4:])
for f in ("TTS_Review.ReaperThemeZip", kit + "TTS_Review.ReaperThemeZip"):
    if os.path.exists(f): os.rename(f, f.replace("TTS_Review.ReaperThemeZip", THEME + ".ReaperThemeZip")); print("mv", f)

# 2) text content
subs = [
  ("TTS Review Kit", NAME + " Kit"),
  ("tts_review_lib.lua", "inference_review_lib.lua"),
  ("TTS_Review", THEME),
  ("TTSReview", "InferenceReview"),
  ("TTS review theme", "reaper-inference-review"),  # folder name in docs (folder rename is done by the owner)
  ("TTS_dev_bridge.lua", "irp_dev_bridge.lua"),
  ("TTS Review", NAME),
  ('"TTS Note"', '"Review Note"'),
  ("'TTS Note'", "'Review Note'"),
  ("TTS Note", "Review Note"),
  ('LAYOUT_CONFIG = "TTS"', 'LAYOUT_CONFIG = "Review"'),
  ('Layout "TTS"', 'Layout "Review"'),
  ('Layout "150%_TTS"', 'Layout "150%_Review"'),
  ('Layout "200%_TTS"', 'Layout "200%_Review"'),
  ("'TTS' ", "'Review' "),
  ("'150%_TTS'", "'150%_Review'"),
  ("'200%_TTS'", "'200%_Review'"),
  ("'TTS - ", "'Review - "),
  ('"TTS - ', '"Review - '),
  ("tts_\" ..", "irp_\" .."),
  ('"tts_" ..', '"irp_" ..'),
  ("tts_", "irp_"),          # icon file names in scripts / docs / make_icons
  ("drawTtsTcp", "drawReviewTcp"), ("drawTtsNoteTcp", "drawReviewNoteTcp"), ("ttsCommon", "reviewCommon"),
  ("TTS_ROOT", "IRP_ROOT"), ("TTS_DEV_DIR", "IRP_DEV_DIR"),
]
# internal WALTER vars tts* -> rv* (only inside our block, done separately)
textext = (".lua", ".md", ".py", ".txt", ".sh", ".ReaperTheme", ".ReaperMenu")
changed = []
for base, dirs, files in os.walk("."):
    if base.startswith("./_src") or "/150" in base[-4:] and False: pass
    if base.startswith("./_src"): continue
    for f in files:
        p = os.path.join(base, f)
        if not f.endswith(textext): continue
        if base.startswith("./build/" + THEME + "_unpacked") and f != "rtconfig.txt": continue
        raw = open(p, "rb").read()
        try: s = raw.decode("utf-8")
        except UnicodeDecodeError: s = raw.decode("latin-1")
        o = s
        for a, b in subs: s = s.replace(a, b)
        if p.endswith("rtconfig.txt"):
            # internal names inside our layout block
            s = re.sub(r"\btts([A-Z]\w*)", r"rv\1", s)
            s = s.replace("tcp.custom.tts", "tcp.custom.rv")
        if p.endswith("rename_irp.py"): continue
        if s != o:
            open(p, "wb").write(s.encode("utf-8") if not p.endswith((".ReaperTheme", "rtconfig.txt")) else s.encode("latin-1"))
            changed.append(p)
print("\n".join("edited " + c for c in changed))
