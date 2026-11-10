# Changelog

One version number for the whole kit (theme + scripts + toolbar). Each entry says what changed and
what teammates must redo after updating (re-import the toolbar, re-assign shortcuts, reload the theme).

## 1.2.0 (2026-11-10)

- **One-step installer** `Install Inference Review and Presentation.lua` (in the release zip): load it once in the action
  list and run it. It copies the scripts, lib and icons, adds every script to the action list, installs and switches to
  the theme, writes Floating toolbars 16 and 15, and adds two **logo buttons** to the Main toolbar that show / hide them.
  Restart REAPER afterwards. Keeps your other toolbars and your Main toolbar buttons (a never-changed Main toolbar gets
  REAPER's default buttons plus the logos); backs up your menus once as `reaper-menu.ini.before-inference-review`;
  asks before replacing a toolbar 16 / 15 that holds something else. Running it again updates without duplicates.
- **Unlock height** button on toolbar 16 (script *Unlock height of all tracks*).
- **Create toolbar file** now writes into REAPER's `MenuSets` folder instead of next to the scripts, and adds
  `… toolbars 16 + 15.ReaperMenuSet`: one import sets up both toolbars (other toolbars and menus are left alone).
  Old toolbar files next to the scripts are removed.
- README: quick install, plus a by-hand guide for the toolbars and Main toolbar buttons.

**After updating:** run the new installer (it replaces toolbars 16 and 15 with the new button set), then restart REAPER.
Tested on Mac (REAPER 7.83); Windows not yet tested.

## 1.1.0 (2026-10-28)

Added to the release after publishing (same scripts and theme otherwise):
- **Demo project** `demo/Inference Review Demo/` and **tutorial** `docs/TUTORIAL.md`; README screenshots.
- Fix: **+ Prompt** suggests the next prompt number counting prompt regions only (lane-2 regions were counted too).
- Fix: folders inside the release zip now unzip with normal permissions (before, some unzip tools made folders
  that couldn't be opened). Affected the first 1.0.0 / 1.1.0 zips.

Playback tools (toolbar 15, yellow):
- **Swap & replay**: switch to the other config and play again from where playback started.
- **A/B window**: live "A = heard before / B = playing now" read-out with an A ⇄ B equal-power crossfader
  (restores track faders afterwards; Safe playback allows both while fading).
- **Level match ON/OFF** + **LM settings**: every config as loud as REF in the same prompt (LUFS-I), −23 LUFS-I where a
  prompt has no REF, or a fixed target; take volume only, fully reversible; boost limit and clip warnings.
  Export findings shows the offset per take.
- **Audition config 0–9** scripts for number keys (0 = REF).

Earlier in 1.1.0:

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
action and load the new scripts (Initiate session, About, Swap and replay, A-B window, Level match ON-OFF,
Level match settings, Audition config 0-9). Run *Create toolbar file*, then import the *toolbar 16* file
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
