# Inference Review and Presentation Kit (REAPER) — context for Claude Code

Owner: audio engineer, reads code, not a coder. Explain changes in plain words; keep scripts commented.
Remote: https://github.com/wongchunhoi9/reaper-inference-review (public since 2026-10-28; was private).
Plan / checklist: **docs/PLAN.md** (work through it item by item; tick boxes when done).
Version: one number for theme + scripts + toolbar, in `VERSION`, lib `T.VERSION` and theme param `rvKitVersion`;
change it only with `python3 tools/set_version.py X.Y.Z` (build.py refuses mismatches). What changed: `CHANGELOG.md`.

## Folder map
- `theme/upstream/` untouched Cockos Default 7.0 theme (from REAPER Stash, LGPL). Never edit.
- `theme/src/Inference_Review_and_Presentation_unpacked/rtconfig.txt` the WALTER layout (our section: "INFERENCE REVIEW TRACK PANEL",
  macros `reviewCommon`, `drawReviewTcp`, `drawReviewNoteTcp`). `theme/src/Inference_Review_and_Presentation_unpacked.ReaperTheme` colours + fonts.
- `scripts/` the Lua scripts + `lib/inference_review_lib.lua` (installed as REAPER/Scripts/Inference Review and Presentation/).
- `icons/` toolbar PNGs (100 %, `150/`, `200/`); made by `tools/make_icons.py`; shipped inside the scripts folder as `icons/`.
- `tools/build.py` → `dist/Inference_Review_and_Presentation.ReaperThemeZip` + `dist/inference-review-and-presentation-<VERSION>.zip`
  (theme + Scripts/… + icons + README + CHANGELOG + licences). `dist/` is git-ignored; releases go on GitHub.
- `dev/` test tools (not shipped): `irp_dev_bridge.lua`, `run.sh`, `harness.lua`, `install.lua`, `state.lua`.
- Licences: theme LGPL v2+ (`theme/LICENSE-LGPL-2.1.txt`), everything else MIT (`LICENSE.md`).

## Rules learned the hard way
- WALTER custom elements: **first declared is drawn on top** (declare backgrounds last).
- Theme fonts: only `user_font1`..`user_font15` work. Font entries are LOGFONT hex + a checksum byte (sum of the 60 bytes mod 256).
- `.ReaperTheme` has mixed CRLF/LF line endings: edit with regex on the whole text, not line splits.
- Zip must contain directory entries (pack.py does this).
- Item notes "Stretch image/text" = `IMGRESOURCEFLAGS 3` in the item chunk.
- Region lane = `SetRegionOrMarkerInfo_Value(..., "I_LANENUMBER", n)` (REAPER 7.62+).
- Take markers have no length (7.83). Toolbar text button = `icon_N=text_wide`; image button = `icon_N=<file>.png`
  in `Data/toolbar_icons` (+ `150/`, `200/`); the label after the action ID is the tooltip for image buttons.
- Script action IDs (`_RS…`) come from the script path; renaming a file = new ID.
- Track roles live in track P_EXT `InferenceReview_role` (prompt / ref / config / findings / note).
- Scripts must run on plain REAPER 7 (Mac + Windows), no SWS / JS extensions. Each script starts with
  `if not T.check_reaper() then return end` (pass `true` if it needs region lanes, 7.62+).
- REAPER 7.83 Mac has no View > Toolbars menu: open toolbars with actions 41942 / 41943 (Open/close toolbar 15 / 16).

## Paths
Dev tools no longer hard-code the folder: the bridge sets `IRP_DEV_DIR` and `IRP_ROOT` (folder above dev/).
After moving/renaming the folder, delete the old "irp_dev_bridge.lua" action and load it again from the new dev/.

## Testing (Mac, REAPER running)
1. In REAPER run the action "irp_dev_bridge.lua" (Actions list). It watches `dev/cmd.lua`.
2. `dev/run.sh file.lua` (or stdin) sends Lua to REAPER and prints the result.
   In cmd code, call `_G.print = print` before `dofile` if the loaded file prints.
3. `dofile(dev/harness.lua)` then `RUNKIT("Inference Review and Presentation - <name>", {"answer for dialog 1", ...})` runs a kit script
   with faked dialogs (runs from repo `scripts/`; set `_G.RUNKIT_DIR = INSTALLED_DIR` after install.lua to run the installed copy; plain globals in cmd code stay in the bridge sandbox, so use `_G.` (also `_G.LOG = {}` to read the harness log)). Always test in a new project tab (`reaper.Main_OnCommand(40859, 0)`), never the user's project.
4. `dofile(dev/install.lua)` copies `scripts/` + `icons/` into REAPER/Scripts/Inference Review and Presentation and registers them.
5. Build with `python3 tools/build.py`, reload theme: `reaper.OpenColorThemeFile(IRP_ROOT .. "dist/Inference_Review_and_Presentation.ReaperThemeZip")`.
