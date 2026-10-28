# First Claude Code session

Paste this into Claude Code (opened on this folder):

```
This folder is my REAPER kit "Inference Review and Presentation", used to present A/B
reviews of generated-audio experiments (TTS, RVC and other inference pipelines). Read
CLAUDE.md and PLAN.md first; they explain the folder, how to build the theme, and how to
test inside my running REAPER through the dev bridge (it's running now).

Today: finish Phase 0 in PLAN.md (the product rename is already done), one item at a time,
and tell me before anything I need to decide.

1. Restructure into the repo layout proposed in PLAN.md, with one build command that makes
   dist/inference-review-and-presentation-<version>.zip (theme + scripts + icons + README +
   CHANGELOG), version 1.0.0. Keep dev tools working.
2. Add .gitignore, licence notices (the theme is LGPL because it's based on Cockos Default 7.0;
   ask me which licence to use for the scripts and icons), CHANGELOG.md, and a README with
   "install from release" and "install from clone" sections.
3. git init, first commit, push to https://github.com/wongchunhoi9/reaper-inference-review.git
   (private, empty), tag v1.0.0 and create a GitHub release with the dist zip.
   Ask me before pushing.
4. Clean up the old test files listed under Housekeeping in PLAN.md (ask before deleting).
5. Reinstall from this folder through the bridge, test in a new project tab (never my
   open projects), and confirm the toolbar file still imports.

Then we continue with Phase 1.
Explain changes in plain words. I read code but I'm not a coder.
```
