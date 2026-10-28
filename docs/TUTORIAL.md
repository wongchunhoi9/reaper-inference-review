# Tutorial: the demo review session

A 15-minute walk through the kit using the ready-made demo project. Nothing here can damage the demo:
if you change things, close it **without saving** (or download it again).

The demo is in `demo/Inference Review Demo/` (in the repository and in the release zip):

```
Inference Review Demo/
  Inference Review Demo.RPP   the project
  Media/                      12 short audio files (ref, a, b, c × prompts 1-3)
```

The audio is **made-up test sound** (speech-like noise bursts, not real voices), recorded at different
levels on purpose so level matching has something to do. The config names are examples.

![The demo session](images/review-layout.png)

---

## 0. Before you start

1. Install the kit (README, *Install (once per computer)*): theme, scripts, both toolbars.
2. Switch to the theme: **Options > Themes > Inference_Review_and_Presentation**.
3. Press **About** (toolbar 15, orange). It should say *All good*. If it warns about the theme or REAPER version,
   fix that first.

## 1. Open the demo and look around

**File > Open project…** → `Inference Review Demo/Inference Review Demo.RPP`.
(Keep the `Media` folder next to it; if REAPER says media is offline, the folder was moved apart.)

What you see, top to bottom:

| Lane | Role | What it shows |
|---|---|---|
| **PROMPT** | note lane | The prompt text for each region (P01–P03). Never makes sound. |
| **REF · reference** | config (REF) | The reference read for each prompt. |
| **A · VITS fine-tune**, **B · RVC v2**, **C · baseline TTS** | configs | One rendered take per prompt and config. |
| **FINDINGS** | note lane | Your conclusions per prompt. Never makes sound. |

In the ruler: **P01, P02, P03** are prompt regions in **lane 1**; **Round 1** is a region in **lane 2**
(rounds, sections, issues). B has a duration take marker (`▸ metallic s · 0.80 s` … `◂`), C has a point
marker (`word dropped`).

Press **Fit to window** (toolbar 16, grey) whenever the window size changes: the lanes fill the screen again.

## 2. Safe playback: one config at a time

1. Press **Safe playback** so it turns **yellow (ON)**.
2. Press play (Space). Only one lane plays: the one whose name is lit (B when the demo opens).
3. **Click a name** (REF, A, B, C) while it plays: it switches instantly, same position.
4. Try the **S** button on another config: it switches too. Un-soloing everything falls back to the last one.
   You can't end up with everything playing at once.
5. **◀ Previous / Next ▶** step REF → A → B → C.

Tip: give **Audition config 0** (REF) … **Audition config 3** keys in the action list (e.g. Shift+0…3).
Then one key per config.

## 3. A/B: compare two configs

*A* = the config you heard before, *B* = the one playing now.

1. Click **A** then **B** (names). Now A = *A · VITS fine-tune*, B = *B · RVC v2*.
2. **A/B swap** flips between them, playback keeps going.
3. **Swap & replay** flips *and* jumps back to where you pressed play: the same phrase again, in the other config.
   This is the quickest way to compare one sentence.
4. Open **A/B window**. It shows which is A and which is B, and stays up to date.
   Drag the slider (or **← →**) to hear both together: centre = both at −3 dB. **Space** jumps to the other end.
   Close it (or **Esc**): the side you were nearer keeps playing on its own, and the faders are back as before.

## 4. Level matching: compare quality, not loudness

In the demo the configs are deliberately at different levels: A is about 4–5 dB quieter than REF,
B about 2–3 dB louder, C about 8 dB quieter. Louder usually *sounds* better, which biases a review.

1. Press **Level match** so it turns **yellow (ON)**. The report says 9 takes were matched to REF.
2. Switch between configs: they now play as loud as REF in each prompt.
3. Press it again (**OFF**): every original volume comes back.

**LM settings** chooses *REF* (default; prompts without a REF take use −23 LUFS-I) or a *fixed* target
(e.g. −23 or −16 LUFS-I for every take, REF included), and the boost limit (+12 dB). It only changes **take volume**;
your faders are untouched.

## 5. Annotate

Try these in empty space (or on a copy of the demo):

* **+ Take marker** (blue): select a config lane, put the edit cursor on its item → a point marker.
  Make a time selection over part of the item first → a duration pair `▸ text · 1.25 s` … `◂`.
* **+ Note**: select FINDINGS, make a time selection → a note item; type in the window that opens.
* **+ Prompt & Region lane 1**: time selection over a new prompt's audio → region P04 plus note items on PROMPT
  and FINDINGS.
* **+ Region lane 2**: time selection → a region in the second ruler lane (needs REAPER 7.62+).
* **Take marker colour reset**: after changing track colours, re-picks black or white marker text for contrast.

## 6. Export the findings

Export writes next to the project file, so first **File > Save project as…** into a folder of your own
(so the demo stays clean). Then press **Export findings** (orange). You get:

* `… - findings <date>.md`: configs, each prompt with its text, take markers per config and findings notes;
  takes listed there show their level-match offset (`LM +4.9 dB`) if level matching was on;
* `… - findings <date> - markers.csv`: one row per take marker (start, end, duration, level-match offset).

## 7. Your own session

1. **File > New project**, then **Initiate session**: enter the number of configs (e.g. `3`) and, optionally,
   their names separated by `;` (e.g. `VITS;RVC;baseline`).
2. Drag each config's rendered files onto its lane, REF's onto REF.
3. For each prompt: time selection over its audio → **+ Prompt & Region lane 1**, type the prompt text.
4. **Fit to window**, **Safe playback ON**, and present.

Track roles can be changed any time with **Set config lane** / **Set note lane** (selected tracks).
**Settings** (orange) adjusts name size, name width and when the second row hides.
