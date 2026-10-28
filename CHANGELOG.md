# Changelog

One version number for the whole kit (theme + scripts + toolbar). Each entry says what changed and
what teammates must redo after updating (re-import the toolbar, re-assign shortcuts, reload the theme).

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
