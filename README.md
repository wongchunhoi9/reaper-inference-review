# Inference Review and Presentation Kit for REAPER

A presentation setup for A/B reviews of generated-audio experiments (TTS, RVC and other inference
pipelines) in REAPER: large readable track names, note lanes for prompts and findings, one-key A/B
soloing, and a findings export. Works on macOS and Windows, REAPER 7 (7.62+ for region lanes),
no extensions needed.

Version: see `VERSION` and `CHANGELOG.md`.

## Install from release (teammates)

1. Go to the repository's **Releases** page and download `inference-review-and-presentation-<version>.zip`.
2. Unzip it. Inside you get:

| File | What it is |
|---|---|
| `Inference_Review_and_Presentation.ReaperThemeZip` | The theme. Based on Cockos Default 7.0 (LGPL), adds two track panel layouts: **Review** and **Review Note**. |
| `Scripts/Inference Review and Presentation/` | 19 Lua scripts, `lib/` and `icons/` (keep the folder together). |
| `README.md`, `CHANGELOG.md`, `VERSION`, `LICENSE.md`, `LICENSE-LGPL-2.1.txt` | This guide, what changed, licences. |

3. Follow **Install (once per computer)** below.

## Install from clone (testers / development)

```
git clone https://github.com/wongchunhoi9/reaper-inference-review.git
cd reaper-inference-review
python3 tools/build.py
```

This writes `dist/inference-review-and-presentation-<version>.zip` (the same zip as a release) and
`dist/Inference_Review_and_Presentation.ReaperThemeZip`. Unzip the kit zip and follow the steps below,
or use the dev bridge (`dev/`, see `CLAUDE.md`) to install straight from the repo.
Needs Python 3 (no extra packages; `tools/make_icons.py` needs Pillow only if you redraw the icons).

Repository layout:

| Folder | What it is |
|---|---|
| `theme/src/` | The theme source (WALTER `rtconfig.txt`, images, `.ReaperTheme` colours/fonts). |
| `theme/upstream/` | Untouched Cockos Default 7.0, for comparison. Never edited. |
| `scripts/` | The Lua scripts and `lib/`. Installed as `REAPER/Scripts/Inference Review and Presentation/`. |
| `icons/` | Toolbar button images (100 %, `150/`, `200/`), made by `tools/make_icons.py`. |
| `tools/` | `build.py` (makes the release zip), `make_icons.py`. |
| `dev/` | Test bridge into a running REAPER (not shipped). |
| `docs/` | `PLAN.md` (roadmap / checklist). |

## Install (once per computer)

1. **Theme**: double-click `Inference_Review_and_Presentation.ReaperThemeZip` (or drag it onto REAPER).
   It appears in **Options > Themes**. Switch back to your usual theme the same way.
2. **Scripts**: copy the whole `Scripts/Inference Review and Presentation` folder into REAPER's Scripts folder
   (**Options > Show REAPER resource path in explorer/finder**, then `Scripts`).
   In REAPER: **Actions > Show action list > New action > Load ReaScript**,
   select all the `Inference Review and Presentation - ….lua` files (not `lib`), **Open**.
3. **Toolbar**: run **Inference Review and Presentation - Create toolbar file**. It installs the coloured button icons
   and writes `Inference Review and Presentation toolbar.ReaperMenu` next to the scripts, using this computer's action IDs.
   Then **Options > Customize menus/toolbars**, pick **Floating toolbar 16** in the top list,
   **Import/Export > Import**, choose that file, **OK**. Open it with **View > Toolbars > Toolbar 16**
   (drag its edge to widen it, or right-click it to dock it).
   Button colours: **grey** = setup, **blue** = prompts / notes / markers, **yellow** = playback,
   **orange** = export and settings. If the colours look pale, reset
   **Options > Themes > Theme Adjuster / Color Controls** for this theme: its gamma/contrast also tints toolbar icons.
   To turn any other toolbar button into text: right-click it in Customize menus/toolbars >
   **Set tooltip/text icon…**, Mode **Text double-wide icon**.
4. Optional: give the scripts shortcuts in the action list (suggested below).

## Start a review session

1. Switch to the **Inference_Review_and_Presentation** theme.
2. New project, run **Inference Review and Presentation - Build review session**. Enter the number of
   configs and, optionally, their names separated by `;`.
   You get PROMPT, REF, configs A, B, C … and FINDINGS, coloured, laid out and
   height-locked, with a spacer under REF.
3. Drop the rendered audio for each config on its track.
4. Make a time selection over each prompt's audio and run **Add prompt**: it
   creates region P01, P02 … and note items on PROMPT and FINDINGS.
5. Save the project.

## During the presentation

**Turn on Safe playback first** (yellow outlined button; it lights up when on). While it is on:

* only **one** of REF / configs is ever audible (exclusive solo in place), so nothing can play all at once;
* **click a config's name** to switch to it instantly; playback keeps running at the same position;
* pressing **S** on another track switches to it; "unsolo all" falls back to the last one instead of opening everything;
* PROMPT / FINDINGS never make sound.

| Script / button | Suggested key | What it does |
|---|---|---|
| Safe playback | `P` | Toggle the mode above. |
| ◀ Previous / Next ▶ | `[` / `]` | Step through REF → A → B … (lights up the playing name). |
| A/B swap | `Tab` | Flip between the current and the previously heard config. |
| + Marker | `M` | No time selection: point marker at the edit cursor. With a time selection: duration marker, `▸ text · 1.25 s` at the start and `◂` at the end. Black text on light items, white on dark. |
| + Note | `N` | Note item on the selected track over the time selection, opens the notes window. |
| + Prompt | — | Region P01, P02 … in **ruler lane 1** + note items on PROMPT and FINDINGS. |
| + Region lane 2 | — | Region over the time selection in **ruler lane 2** (rounds, sections, issues). Needs REAPER 7.62+. |
| Marker colour | — | Re-picks black/white text for every take marker after you change track or item colours. |
| Fit to window | `F` | Re-fits all review lanes to the window (after resizing / screen sharing). |
| Export findings | — | Markdown report + CSV of take markers (start, end, duration) next to the saved project. |

## Track roles and layouts

| Role | Layout | Output |
|---|---|---|
| REF, configs | **Review**: number, large name, then volume, meter and M/S at the right edge | normal |
| PROMPT, FINDINGS, other notes | **Review Note**: name only | **none** (master send off, no hardware outs) |

* **Set selected tracks as config / as note** changes a track's role, layout and output.
* **Toggle height lock on selected tracks**, **Lock / Unlock height of all tracks**.
  REAPER has no lock button on the track panel; these scripts do it.
* Folder tracks indent as usual (theme setting "TCP Folder Indent").

## Adjusting the track panel

Run **Inference Review and Presentation - Theme settings** (theme must be active):

* **Track name size** 1–5: 15 / 16 / 18 / 20 / 24 px at 100% screens,
  21 / 24 / 27 / 32 / 36 px at 150%. On 200% screens (Retina Macs) sizes 3–5 all show at the
  largest available size: REAPER themes only have 15 font slots.
* **Track name width** in points (default 402).
* **Hide row 2 below** a track height (default 60): short tracks show only the name.

These only affect the Review / Review Note layouts.

## Notes and limits

* **Regions in two lanes** need REAPER **7.62 or later**; tested on 7.83.
* **Take marker labels** are text only; REAPER does not draw a filled box behind them. The
  marker script picks black or white text for contrast instead.
* **Take markers have no length** in REAPER (checked up to 7.83), so a duration is a pair of markers (`▸` start, `◂` end).
  Export findings pairs them back into one row with the duration.
* **Note text size** comes from the item's size ("Stretch image/text"), not from a font
  setting: taller lanes and wider items give larger text.
* Brand palette used: yellow `#F0F44A`, blue `#98D1EA`, grey `#757575`, orange `#F4743B`, black `#070709`.

## Licence

Theme: LGPL v2 or later (derived from Cockos Default 7.0). Scripts, icons and tools: MIT. Details in `LICENSE.md`.
