# TAM Motion — Android visual QA & polish

Date: 2026-11-12
Checkout: /home/hazem/projects/tam-motion-vslice
Branch: codex/tam-motion-vslice-20261112
Device: Medium Phone Android emulator (1080 x 2400 px screenshot, 360dp-class viewport)

## Scope
Actual Flutter Android app launched with `flutter run -d emulator-5554 --debug --no-pub`.
Reached guest home, booking, origin/destination place picker, vehicle selection.
No backend, external maps, phone calls, or payments were involved. Booking uses
mock data in the existing feature data mode.

## Findings and changes
1. **Empty map:** private tile service not configured. Replaced the large empty
   map area in the booking surface with a compact, non-geographic pickup /
   destination summary. The true `RouteMapView` is preserved when a private
   tile endpoint is configured. The fallback explicitly states that the map
   service is unavailable and never invents a distance, path or ETA.
2. **Misleading progress indicator:** draft quotes load automatically, so `4/4`
   appeared before vehicle review. Use three accurately derived stages:
   pickup -> destination -> vehicle class. Auto-quoting does not advance
   beyond explicit choice.
3. **Double selected border:** removed redundant nested border in vehicle
   cards, retained gentle color/scale selection animation and radio feedback.
4. **Localization & accessibility:** existing ARB strings, central theme and
   system reduced-motion preference retained. Avoided duplicated tappable
   search-placeholder text in non-interactive route summary.
5. **Navigation regression:** existing scheduled-booking integration tests still
   pass with scheduling above map preview.

## Actual screenshots
All are direct Android emulator screencaps, not Figma renders or AI images.

- `screenshots/09-polished-initial.png` - booking with 1/3 stage.
- `screenshots/10-polished-selected-route.png` - origin/destination selected.
- `screenshots/12-final-route.png` - comfort vehicle selected and page scrolled.
- `screenshots/TAM-Android-Visual-QA.png` - side-by-side comparison of those
  unedited screen captures scaled to fit on one board.

## Verification
- Dart formatting: passes.
- Flutter static analyzer: passes, zero issues.
- Full Flutter test suite after polish: **683 passing**.
- Targeted tests: booking, scheduling, mock route summary, reduced motion.
- No runtime production map tiles configured; no performance/fps claim.
- Android debug/emulator log includes initial skipped frames. Profile mode
  on a physical Android device is required to judge frame pacing accurately.
- Android `screenrecord` produced an unusable one-frame MP4 in this emulator.
  No genuine motion video was delivered; the screenshots are authentic.

## Next independent review
- Test 320dp text scaling 2x and a tablet screenshot specifically with the
  new summary card in a fresh visual golden review.
- Measure Flutter frame timings in Profile Mode on Android before claiming
  smooth 60fps. Only apply Rive to complex brand motion if justified.
- Approve a final brand/art direction, then refine home and booking together;
  do not impose the exploratory violet/green concepts into the current
  burgundy theme before approval.

No pushes, merges, GitHub Actions, or edits to the original worktree.
