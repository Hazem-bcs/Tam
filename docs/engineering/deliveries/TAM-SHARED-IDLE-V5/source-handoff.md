# Shared Idle V5 — 2026-11-17

Baseline: `62f452e47db20fbd4ebe412fa312f06d9ebf6415` (approved V4 hands/events).
Owner: root, sole source writer. Branch `codex/mascot-idle-v5` in
`/home/hazem/projects/tam-hand-worktrees/idle-v5`.

## Authored performance

`TAM Shared Idle 16s` (`0:2200`) is960 frames at60fps:

- 0–4s: anchored breathing, eye contact and a short blink near1.9s.
- 4–7s: slight body lean and a small side glance, then return to eye contact.
- 7–10.5s: one left shoulder adjustment with delayed wrist follow-through.
- 10.5–13s: quiet breathing and another blink near11.5s.
- 13–16s: settle into the identical starting pose and continue seamlessly.

The relaxed glove drawing stays the same throughout Idle. No sprite swaps or
crossfades occur within this performance. Existing hand/facial artwork is kept.
Body rotation is below0.7 degrees, breath scale at most0.7%, shoulder/wrist
motion small and asymmetric. The pin tip at stage(250,455) is compensated during
lean/breath, preventing apparent floating or cumulative displacement.

Transforms use dense, continuously interpolated numeric keys. Avoid adding an
ease-in/out stop at every small sample: this would produce mechanical motion.
Sparse gaze and blink keys retain cubic easing. The runtime still interpolates
at its own frame rate; the30fps preview is a recording, not a frame sequence
used as the app animation.

## One persistent base, page reactions above it

The `TAM Shared Idle Base` layer plays continuously while Rive is active.
Existing event states override it, then reveal its current phase. Simply setting
AnimationState.reset=false was tested and did NOT preserve phase on re-entry;
the persistent layer is the verified implementation.

The existing gaze/eyelid layers defer to Idle only when all event/focus flags are
false and motion is enabled; otherwise their V4 behavior is retained. All original
keyed values/durations in14 approved static/event/eye clips are checked unchanged.
Identity scale keys in event poses restore the exact approved scale after breath.
Five reduced-motion expressions remain pixel-stable even while CLI advances time.
Flutter still pauses the entire controller when hidden/backgrounded/reduced.
No Flutter production code, input contract or backend behavior was changed.

Future pages should reuse this asset/base; page-specific one-shot reactions belong
above it. This task does not add the mascot to more pages or extract a new wrapper.

## Reproduce and verify

```sh
./rebuild_and_publish.sh
python3 render_shared_idle_v5.py
```

- Rive verify:0 errors,0 warnings; publish local succeeded.
- Export:1854700bytes, SHA256
  `47af1098b9837f110aad537cd38b1ee31eb56bebee14a46da68fe0d2378d2802`.
- Scene SHA256:
  `6aa6d000bb6db7e9b58624740ce0655de4d5d1f37b9b48a3e2a9003847935e5a`.
-26 looping properties have matching first/last values; first/last rendered frame
  RMS difference0.00667/255, below a visible seam.
-481 captures cover a whole16s cycle;30fpsMP4 and15fps lightweight GIF generated.
  Five static poses are identical after240 additional frames each.
- Native Flutter test advances the real exported runtime through a waiting event,
  verifies continuing glance phase, stable anchor for960 frames, genuine wrist
  motion, and equal transforms after a complete cycle. App integration owns logs.

Output: `build/shared_idle_v5_qa/{storyboard.png,shared_idle_16s_30fps.mp4,
shared_idle_16s_preview.gif,assertions.json}`. QA captures enter Idle directly;
the actual export retains the original first-appearance Welcome.

No independent reviewer participated in this follow-up; source/runtime/render
verification was performed by the author. Prior eyelid alpha limitations and the
Rive export-plan watermark warning remain as documented for V4. No physical
Android profile benchmark or release-readiness claim. No remote push/web publish.
