# Changelog

One version number for the whole kit (theme + scripts + toolbar). Each entry says what changed and
what teammates must redo after updating (re-import the toolbar, re-assign shortcuts, reload the theme).

## 1.1.0 (unreleased)

- **Two toolbars** instead of one: Floating toolbar 16 = Session (grey) + Annotate (blue),
  Floating toolbar 15 = Playback (yellow) + Output (orange). Dock 15 under 16 for two rows.
- **Tooltips** on every button: what it does, what it needs, and the script name. Same text in each script header
  and in the README button table.
- **Safe playback** button now reads "Safe playback OFF" (dark grey) and turns solid yellow "Safe playback ON".
- Button renames: Build session → **Initiate session**, Set config → **Set config lane**,
  + Prompt → **+ Prompt & Region lane 1**, + Marker → **+ Take marker**, Marker colour → **Take marker colour reset**.
- Script renamed: *Build review session* → **Initiate session** (new action ID).
- **About** button (toolbar 15, orange): kit version, theme version actually loaded, REAPER version, with warnings.
- **Version checks**: every script checks the REAPER version first. Below 7.0 it stops with an explanation; on
  7.0–7.61 it shows a one-time note (no region lanes) and carries on; *Add region lane 2* needs 7.62.
- The theme now carries the kit version (theme parameter "Review - Kit version", shown under Theme adjuster parameters).

**After updating:** in the action list, remove the old "Inference Review and Presentation - Build review session"
action and load the new "Initiate session" and "About" scripts. Run *Create toolbar file*, then import the *toolbar 16* file
into Floating toolbar 16 and the *toolbar 15* file into Floating toolbar 15. Re-assign any shortcut you had
on "Build review session". Double-click the new theme zip so the theme version matches (About checks this).

## 1.0.0 (2026-10-28)

First release under the name **Inference Review and Presentation** (formerly "TTS Review").

- Theme `Inference_Review_and_Presentation` (based on Cockos Default 7.0, LGPL): track panel layouts
  **Review** (number, large name, fader, meter, FX, M/S) and **Review Note** (name only), 100 / 150 / 200 %.
- 19 scripts: build session, set config / note lanes, fit and height lock, prompts and region lane 2,
  note items, take markers (point or duration), safe playback, solo previous / next, A/B swap,
  export findings (.md + .csv), theme settings, create toolbar file.
- Coloured toolbar icons for Floating toolbar 16.

**If you used the earlier "TTS Review" version:** the script names changed, so their action IDs changed.
Load the new scripts, run *Create toolbar file* and re-import the toolbar, and re-assign any shortcuts.
