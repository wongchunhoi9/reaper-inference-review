# Inference Review and Presentation Kit: inventory and phase plan

Working checklist. Tick items as they land. Newest decisions are at the top of each phase.
Last updated: 2026-10-28.

---

## 0. Inventory (what exists today)

### Theme: `Inference_Review_and_Presentation.ReaperThemeZip`
Based on Cockos Default 7.0 (Stash download, LGPL v2+). Source in `theme/src/`, original in `theme/upstream/`.

| Part | State |
|---|---|
| Layout **Review** (config lanes): number, large name, fader, meter, FX (+ bypass half), M, S (M/S pinned right) | done |
| Layout **Review Note** (prompt / findings lanes): name only | done |
| Folder indent (grey indent area + edge line, follows "TCP Folder Indent") | done |
| Name size 1-5, name width, compact-below-height as theme parameters | done |
| 150% / 200% versions of both layouts (Windows high-DPI) | done |
| Brand palette in the panel (yellow selection, blue note lanes) | done |
| Item label / take marker font 17 px Calibri | done |
| Font slots: REAPER only has user_font1-15 (16+ are ignored) | known limit |

### Scripts: `scripts/` (installed copy: REAPER/Scripts/Inference Review and Presentation/)
| Script | Group | State |
|---|---|---|
| Initiate session (was Build review session) | setup | done |
| Set selected tracks as config (button: Set config lane) | setup | done |
| Set selected tracks as note | setup | done |
| Fit tracks to window | setup | done |
| Toggle height lock on selected tracks | setup | done |
| Lock / Unlock height of all tracks | setup | done |
| Add prompt (region lane 1 + note items) | annotate | done |
| Add region lane 2 | annotate | done (REAPER 7.62+) |
| Add note item | annotate | done |
| Add take marker (point, or duration pair with time selection) | annotate | done |
| Refresh take marker colours | annotate | done |
| Safe playback mode (toggle) | playback | done |
| Solo previous / next config | playback | done |
| A-B swap | playback | done |
| Swap and replay, A-B window (read-out + crossfader), Audition config 0-9 | playback | done |
| Level match ON-OFF, Level match settings (lib/level_match.lua) | playback | done |
| Export findings (.md + .csv) | output | done |
| Theme settings (slider window) | output | done |
| About (kit / theme / REAPER versions + warnings) | output | done |
| Create toolbar file (+ coloured icons) | output | done |
| lib/inference_review_lib.lua (palette, roles, helpers) | shared | done |

### Other
| Item | State |
|---|---|
| Toolbars 16 (Session, Annotate) + 15 (Playback, Output), coloured image buttons with tooltips (icons/ 100/150/200%) | done |
| README.md (install + use) | done |
| Dev bridge for testing (`dev/`) | dev only, not shipped |
| Layout mockup artifact (claude.ai) | reference |

---

## Phase 0: Repository and naming (first Claude Code session)

- [x] Folder renamed to `reaper-inference-review` (now on the Desktop; move off Desktop later if iCloud Desktop sync is on).
- [x] GitHub repo created: https://github.com/wongchunhoi9/reaper-inference-review (made public 2026-10-28 for teammates)
- [x] Dev bridge re-loaded from `dev/irp_dev_bridge.lua` in the new folder.
- [x] Product renamed to **Inference Review and Presentation** (2026-10-28): theme `Inference_Review_and_Presentation`,
      layouts `Review` / `Review Note`, script prefix `Inference Review and Presentation - …`, P_EXT key `InferenceReview`,
      icons `irp_*.png`, kit folder `Inference Review and Presentation Kit`. Repo name: `reaper-inference-review`.
- [x] Repo layout: `theme/src` (from build/), `theme/upstream` (_src, Cockos Default 7.0, LGPL), `scripts/`, `icons/`,
      `tools/` (pack, make_icons, dev bridge), `docs/` (README, CHANGELOG, PLAN), `dist/` (ignored, built release zip).
      Done 2026-10-28 with two changes: `dev/` stays at the top (so the bridge action keeps working);
      README / CHANGELOG / LICENSE / VERSION sit at the top (GitHub shows them there), PLAN in docs/. Build: `python3 tools/build.py`.
- [x] One build command that packs the theme + scripts + icons + README into `dist/<name>-<version>.zip`.
- [x] `.gitignore`: dist/, dev runtime files (cmd.lua, out.txt), test projects (*.RPP, *findings*), probe images,
      old test themes (TTS_Diag, *.bak, zig*).
- [x] Licences: theme is a derivative of Cockos Default 7.0 → LGPL v2 or later (keep notice); choose a licence
      for scripts/icons (e.g. MIT) – owner decides. **Decided: MIT** (LICENSE.md).
- [x] git init, first commit, GitHub repo (private or org), tag `v1.0.0`, GitHub Release with the dist zip.
- [x] README: "Install from release" (download zip) and "Install from clone" (for testers) sections.

## Phase 1: Toolbar and naming (next)

- [x] **Tooltips** on every button: one-line description + the original script name, plus what it needs
      (edit cursor, time selection, selected track, selected item). REAPER shows the toolbar item label as
      the tooltip when the button uses an image icon, so the label text in the .ReaperMenu becomes:
      `+ Take marker · Point at edit cursor, or duration over time selection. Needs: item under cursor on selected track. [Inference Review and Presentation - Add take marker]`
      Also write the same text into each script header and the README table so hotkeys are easy to set.
- [x] **Safe playback ON/OFF clearly visible**: two distinct icon states.
      Proposal: OFF = dark grey button, grey text "Safe playback OFF"; ON = solid yellow, black text "Safe playback ON".
      (REAPER uses icon frame 3 for toggle-on; frames are normal / hover / on.)
- [x] Renames (label and, where noted, script file):
  - [x] "Build session" -> **Initiate session** (script: Inference Review and Presentation - Initiate session)
  - [x] "Set config" -> **Set config lane**
  - [x] "Set note lane" stays
  - [x] "+ Prompt" -> **+ Prompt & Region lane 1**
  - [x] "+ Marker" -> **+ Take marker**
  - [x] "Marker colour" -> **Take marker colour reset**
  - Renaming a script file changes its action ID: re-run Create toolbar file and re-import afterwards;
    teammates' custom shortcuts to the old names must be re-assigned (note this in the changelog).
- [x] **Regroup the toolbar** (proposal, left to right):
  1. Session (grey): Initiate session · Set config lane · Set note lane · Fit to window · Lock height
  2. Annotate (blue): + Prompt & Region lane 1 · + Region lane 2 · + Note · + Take marker · Take marker colour reset
  3. Playback (yellow): Safe playback ON/OFF · ◀ Previous · Next ▶ · A/B swap · Swap & replay · A/B crossfader · (1-9 later)
  4. Output (orange): Export findings · Settings · About/version
  Two rows: groups 1+2 on row 1, groups 3+4 on row 2, separators between groups.
  Done 2026-10-28 as **two toolbars** (REAPER can't force a line break): Floating toolbar 16 = groups 1+2,
  Floating toolbar 15 = groups 3+4 (Swap & replay, crossfader, About come in later phases).

## Phase 2: Versioning and compatibility

- [x] One version number for the whole kit (theme + scripts + toolbar), semantic: `1.0.0`.
      Stored in `VERSION` and in `lib/inference_review_lib.lua` (`T.VERSION`, `T.MIN_REAPER = "7.62"`).
      Done: `tools/set_version.py X.Y.Z` writes all three (VERSION, lib, theme); build.py stops if they differ.
      Lib has `T.MIN_REAPER = "7.0"` (hard stop) and `T.FEATURE_REAPER = "7.62"` (region lanes; one-time note, lane-2 script stops).
- [x] Theme carries the same version: a define_parameter `rvKitVersion` (read-only display) + a comment line in rtconfig.
- [x] **About / check** script + toolbar button: shows kit version, theme version actually loaded,
      REAPER version, and warns if REAPER < 7.62 (region lanes) or the theme is not active / out of date.
- [x] Every script checks `T.MIN_REAPER` on start and explains what will not work instead of failing.
- [x] `CHANGELOG.md` in the kit (what changed, what teammates must redo: re-import toolbar, re-assign keys).
- [ ] Windows test pass (Parsec machine): install from README only, note any differences.

## Phase 3: Playback tools

- [x] **A/B labels**: A = the previously heard config, B = the current one (same memory A/B swap already uses).
      Show them: A/B swap button tooltip + the crossfader window title + a small "A ▸ name / B ▸ name" read-out.
      Optional: mark them in the track panel (prefix in name is intrusive; better a small A/B badge via a
      theme parameter per track is not possible in WALTER, so the read-out window is the realistic option).
- [x] **Swap & replay** (item 10): switch to the other config and restart playback from where the last play started.
      Name proposal: **"Swap & replay"** (alt: "A/B from start"). Uses the play start position
      (edit cursor when playback began), sets it, switches, restarts. Works with Safe playback.
- [x] **A/B crossfader** (fun tool): small window with one slider A ⇄ B.
      Both A and B are soloed (exception allowed by Safe playback while the window is open), equal-power curve
      on track volume (or a JSFX on each track for sample-accurate fades), centre = both at -3 dB.
      Keys: left/right arrows nudge, space = jump to the other end. Closing the window returns to exclusive solo on B.
- [x] **Number keys 1-9** (plan):
  - 10 tiny scripts "Audition config 0..9": `0` = REF, `1`..`9` = configs A..I in track order (skips note lanes).
  - Each calls the same exclusive-solo function, so they work with Safe playback and A/B memory.
  - Default REAPER keys 1-9 jump to markers; the README will suggest either replacing them or using
    `Shift+1..9` / numpad. Shortcuts are set per computer in the Action list (scripts can't assign keys).
  - Toolbar: optional compact row "REF 1 2 3 4 5 6 7 8 9". (Decided: no row for now.)
- [x] **Level-matched switching** (how it will work):
  - Measure each config's loudness per prompt with REAPER's built-in `CalculateNormalization`
    (no extensions): integrated LUFS (speech) or RMS, over the item inside the prompt region.
  - **Reference level**, two modes (setting in the window):
    1. *Match REF*: target = REF's loudness in that prompt (everything sounds as loud as the reference read), or
    2. *Fixed target*: e.g. -23 LUFS-I (EBU R128) or -16 LUFS-I (typical online speech).
    Decided: Match REF by default; a prompt with no REF falls back to -23 LUFS-I.
  - Apply the difference as **take volume** (non-destructive), remember the original in the take's P_EXT,
    write the offset into a column of the export ("LM +1.8 dB").
  - One button toggles level matching on/off (restores original take volumes), one re-measures after new renders.
  - Safety: cap boost at e.g. +12 dB; warn if a take would clip after gain (true peak > -1 dBTP).
- [ ] **Loop current prompt** (maybe; skipped 2026-10-28, owner: later): toggle that sets the loop to the prompt region under the play cursor and
      enables repeat; follows the cursor when you move to the next prompt. Pairs well with A/B swap.

## Phase 4: Distribution

- [ ] Kit folder = theme zip + Scripts/Inference Review and Presentation (scripts, lib, icons) + README + CHANGELOG + VERSION.
- [ ] Optional ReaPack repository (index.xml) so teammates update with one click instead of copying folders.
- [ ] Optional project template (.RPP) generated by Initiate session, saved to ProjectTemplates.

## Known limits (keep in README)
- Take markers have no length (checked to 7.83) → duration = `▸` start + `◂` end pair.
- Take marker labels have no background box → black/white text by item brightness.
- Toolbar buttons can't be coloured natively → coloured PNG icons; the theme's Colour Controls tint them.
- Name size steps collapse at 200% (Retina Mac) because only 15 font slots exist.
- Region lanes need REAPER 7.62+.

## Housekeeping
- [ ] Remove dev bridge action from the action list when development ends (Actions > find "irp_dev_bridge" > Delete).
- [x] Delete test leftovers (moved to Trash 2026-10-28): `TTS_Diag.ReaperThemeZip` (also in REAPER/ColorThemes), `TTS_Review_v0.1a.ReaperThemeZip.bak`, `zig6AJJp`,
      `dev/marker test.RPP`, `dev/*findings*`, `dev/probe_*.png`, `Documents/REAPER Media/Unsaved project - findings 2026-10-27 2221.*`.
- [ ] Still on disk, kept for now (git-ignored or harmless): old theme zips + empty `Inference Review and Presentation Kit/` and `_src/`,
      `Default_7.0.ReaperThemeZip`, `build/` (tts_macro.txt, tts_v02.txt, diag/ 23 MB), `dev/rename_irp.py`, `dev/icon_sheet.png`, `START_HERE.md`.
