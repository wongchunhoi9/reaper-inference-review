# Sets the kit version everywhere it is stored.   Usage:  python3 tools/set_version.py 1.2.0
#   VERSION                                   1.2.0
#   scripts/lib/inference_review_lib.lua      T.VERSION = "1.2.0"
#   theme rtconfig.txt                        define_parameter rvKitVersion 'Review - Kit version 1.2.0 (info only)' 10200 ...
# tools/build.py refuses to build if these three disagree. Add a CHANGELOG.md entry yourself.
import os, re, sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
LIB = os.path.join(ROOT, "scripts", "lib", "inference_review_lib.lua")
RTCONFIG = os.path.join(ROOT, "theme", "src", "Inference_Review_and_Presentation_unpacked", "rtconfig.txt")

def number(v):
    # 1.2.3 -> 10203: the theme parameter value (REAPER theme parameters are whole numbers)
    a, b, c = (int(x) for x in v.split("."))
    return a * 10000 + b * 100 + c

def theme_line(v):
    n = number(v)
    return "define_parameter rvKitVersion \t\t\t\t'Review - Kit version %s (info only)' %d %d %d" % (v, n, n, n)

def read_versions():
    # returns the version found in each place (None if missing)
    ver = open(os.path.join(ROOT, "VERSION")).read().strip()
    m = re.search(r'^T\.VERSION = "([^"]+)"', open(LIB, encoding="utf-8").read(), re.M)
    t = re.search(r"'Review - Kit version ([0-9.]+) ", open(RTCONFIG, encoding="latin-1").read())
    return {"VERSION": ver, "lib T.VERSION": m and m.group(1), "theme rvKitVersion": t and t.group(1)}

if __name__ == "__main__":
    if len(sys.argv) != 2 or not re.fullmatch(r"\d+\.\d+\.\d+", sys.argv[1]):
        sys.exit("usage: python3 tools/set_version.py 1.2.0")
    v = sys.argv[1]
    open(os.path.join(ROOT, "VERSION"), "w").write(v + "\n")
    s = open(LIB, encoding="utf-8").read()
    s = re.sub(r'^T\.VERSION = "[^"]*"', 'T.VERSION = "%s"' % v, s, flags=re.M)
    open(LIB, "w", encoding="utf-8").write(s)
    s = open(RTCONFIG, encoding="latin-1").read()  # theme files are not UTF-8; keep bytes as they are
    s = re.sub(r"^define_parameter rvKitVersion [^\n]*", lambda m: theme_line(v), s, flags=re.M)
    s = re.sub(r"^; Kit version [0-9.]+", "; Kit version " + v, s, flags=re.M)
    open(RTCONFIG, "w", encoding="latin-1", newline="").write(s)
    print(read_versions())
