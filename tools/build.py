# Builds the release.  Run from anywhere:   python3 tools/build.py
#
# Makes two files in dist/ (dist/ is not stored in git):
#   dist/Inference_Review_and_Presentation.ReaperThemeZip     the theme on its own (handy for reloading while testing)
#   dist/inference-review-and-presentation-<version>.zip     the full kit for teammates:
#       inference-review-and-presentation-<version>/
#           Inference_Review_and_Presentation.ReaperThemeZip
#           Scripts/Inference Review and Presentation/   (scripts, lib/, icons/)
#           README.md  CHANGELOG.md  VERSION  LICENSE.md  LICENSE-LGPL-2.1.txt
# The version comes from the VERSION file at the top of the repo.
import os, zipfile

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
THEME = "Inference_Review_and_Presentation"
SCRIPTS = "Inference Review and Presentation"
VERSION = open(os.path.join(ROOT, "VERSION")).read().strip()
NAME = "inference-review-and-presentation-" + VERSION
DIST = os.path.join(ROOT, "dist")
os.makedirs(DIST, exist_ok=True)

def skip(name):
    return name.startswith(".")  # .DS_Store and other hidden files

def add_tree(z, src, dest):
    # Copy a folder into the zip, with directory entries (REAPER needs them in theme zips).
    for base, dirs, files in os.walk(src):
        dirs[:] = sorted(d for d in dirs if not skip(d))
        rel = os.path.relpath(base, src)
        zdir = dest if rel == "." else dest + "/" + rel.replace(os.sep, "/")
        z.writestr(zipfile.ZipInfo(zdir + "/"), "")
        for f in sorted(files):
            if not skip(f):
                z.write(os.path.join(base, f), zdir + "/" + f)

# 1) theme zip: the unpacked folder + the .ReaperTheme file, as REAPER expects
theme_zip = os.path.join(DIST, THEME + ".ReaperThemeZip")
src = os.path.join(ROOT, "theme", "src")
with zipfile.ZipFile(theme_zip, "w", zipfile.ZIP_DEFLATED) as z:
    add_tree(z, os.path.join(src, THEME + "_unpacked"), THEME + "_unpacked")
    z.write(os.path.join(src, THEME + "_unpacked.ReaperTheme"), THEME + "_unpacked.ReaperTheme")
print("theme  ", os.path.relpath(theme_zip, ROOT), os.path.getsize(theme_zip), "bytes")

# 2) kit zip
kit_zip = os.path.join(DIST, NAME + ".zip")
with zipfile.ZipFile(kit_zip, "w", zipfile.ZIP_DEFLATED) as z:
    z.writestr(zipfile.ZipInfo(NAME + "/"), "")
    z.write(theme_zip, NAME + "/" + THEME + ".ReaperThemeZip")
    sdest = NAME + "/Scripts/" + SCRIPTS
    z.writestr(zipfile.ZipInfo(NAME + "/Scripts/"), "")
    add_tree(z, os.path.join(ROOT, "scripts"), sdest)
    add_tree(z, os.path.join(ROOT, "icons"), sdest + "/icons")
    for f in ("README.md", "CHANGELOG.md", "VERSION", "LICENSE.md"):
        z.write(os.path.join(ROOT, f), NAME + "/" + f)
    z.write(os.path.join(ROOT, "theme", "LICENSE-LGPL-2.1.txt"), NAME + "/LICENSE-LGPL-2.1.txt")
print("kit    ", os.path.relpath(kit_zip, ROOT), os.path.getsize(kit_zip), "bytes")
