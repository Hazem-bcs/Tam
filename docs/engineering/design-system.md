# Tam design system

## Scope and reference decisions

The customer application's visual foundation is exposed through the existing
`AppTheme.light` interface. No screens, routes, feature state, API contracts or
backend behavior are implemented by this change.

The 24 JPEG files in `apps/customer/Tam Cusstomer UI/` were reviewed, including
the customer references and the driver references mixed into that directory.
The shared visual language is deep burgundy actions, soft rose selected surfaces,
warm off-white backgrounds, white cards, restrained borders, readable headings,
and rounded rectangular controls. Mockup photographs, phone frames, driver flows
and the previous brand are not part of the design system. The brand is **Tam | تم**.

References are visual guidance, not exact color/font specifications: JPEG
compression and rendered device mockups prevent reliable source-token extraction.
The palette below is a normalized interpretation with tested foreground contrast.

## Colors

Use `Theme.of(context).colorScheme` in components and screens. Literal colors
belong in `app_colors.dart`; do not import `AppColors.light` into widgets.

| Role | Light value | Use |
| --- | --- | --- |
| `primary` / `onPrimary` | `#8D153A` / `#FFFFFF` | Main actions and brand emphasis |
| `primaryContainer` / `onPrimaryContainer` | `#FCE7EE` / `#4A0A21` | Selected or highlighted surfaces |
| `secondary` / `onSecondary` | `#715361` / `#FFFFFF` | Supporting emphasis |
| `surface` / `onSurface` | `#FCF8F9` / `#241A1E` | Background and primary content |
| `surfaceContainerLowest` | `#FFFFFF` | Cards, inputs, sheets and dialogs |
| `onSurfaceVariant` | `#66535B` | Secondary copy and icons |
| `outline` / `outlineVariant` | `#8C737B` / `#E4D5DA` | Inputs / subtle dividers and card borders |
| `error` / `onError` | `#B3261E` / `#FFFFFF` | Error emphasis |
| `errorContainer` / `onErrorContainer` | `#F9DEDC` / `#410E0B` | Error surfaces |

The palette also defines Material surface levels, tertiary roles, inverse colors
for snackbars and the fixed accent roles. In Material 3, `surface` replaces the
deprecated `background` role. `scaffoldBackgroundColor` is set from `surface`.

Success and warning are the only custom theme extension because `ColorScheme`
does not provide these meanings:

```dart
final status = Theme.of(context).extension<AppStatusColors>()!;
// A soft success surface: status.successContainer + status.onSuccessContainer.
// A solid success surface: status.success + status.onSuccess.
```

| Status | Solid / foreground | Container / foreground |
| --- | --- | --- |
| Success | `#22643D` / `#FFFFFF` | `#E5F4E9` / `#143D24` |
| Warning | `#795800` / `#FFFFFF` | `#FFF1C7` / `#4D3900` |

Always accompany status colors with localized text and/or an accessible icon.
Error messages are rendered as text as well as an error border.

Disabled controls use Material-style `onSurface` opacity: 38% for foreground and
8% for filled-button background. These are resolved by component themes, not
duplicated in widgets. Disabled content is not included in the normal-text
contrast claim.

## Typography

Consume `Theme.of(context).textTheme`, choosing by semantic purpose:

| Family | Large / medium / small size (logical pixels) | Weight / line height |
| --- | --- | --- |
| Display | 40 / 36 / 32 | 700 / 1.3 |
| Headline | 28 / 24 / 22 | 700, 700, 600 / 1.4 |
| Title | 20 / 18 / 16 | 700, 600, 600 / 1.4 |
| Body | 18 / 16 / 14 | 400 / 1.5 |
| Label | 16 / 14 / 12 | 600 / 1.4 |

Body-medium is the default reading size. Label-small is for short metadata, not
paragraphs. Tracking is zero, avoiding artificial spacing in joined Arabic text.
Keep the device's `TextScaler`; do not cap text size or set fixed text heights.

No font files are present in the project. Use Material's native platform fonts
and system Arabic fallback for now, with no font package, runtime downloads or
redistributed font license. Glyph appearance varies across Android and iOS; this
does not promise exact font matching to the mockups. A future brand font requires
an identified family, verified redistribution license and bundled assets, followed
by a review of both scripts. This can be changed centrally in typography.

## Layout tokens

Use `app_tokens.dart` and directional padding/alignment:

| Token | Values |
| --- | --- |
| `AppSpacing.xs / sm / md / lg / xl / xxl` | 4 / 8 / 12 / 16 / 24 / 32 |
| `AppSpacing.pagePadding` | 24 horizontal, 16 vertical |
| `AppRadii.sm / md / lg / sheet` | 8 / 12 / 16 / 24 |
| `AppDimensions.minTapTarget` | 48 |
| `AppDimensions.controlMinHeight` | 52; a minimum, never a fixed height |
| `AppDimensions.iconSize / progressSize / buttonProgressSize` | 24 / 24 / 20 |
| `AppDimensions.borderWidth / focusBorderWidth` | 1 / 2 |
| `AppDimensions.progressStroke` | 2.5 |
| `AppElevation.flat / raised` | 0 / 1 |

Cards are flat and bordered. Sheets and dialogs use low Material elevation;
avoid custom `BoxShadow` stacks. Use `AlignmentDirectional` and
`EdgeInsetsDirectional` where start/end matters. A page owns safe areas, keyboard
insets, scrolling and layout constraints; shared controls must not add page logic.

## Shared components

### `TamButton.primary` and `TamButton.secondary`

Wrap native `FilledButton` and `OutlinedButton`; pressed, keyboard focus, pointer
feedback and button semantics remain native. Both support disabled state
(`onPressed: null`), a leading icon and loading. Loading blocks activation,
retains the button color, displays a spinner and keeps a readable label. Pass a
localized `loadingLabel` so a live region can announce progress. The spinner
does not duplicate the button's semantics.

Buttons fill bounded horizontal space by default. Inside a `Row`, use `Expanded`
or `fullWidth: false`. Long or scaled labels wrap and the button grows vertically.
The caller owns asynchronous state, success/error handling and retry behavior.

```dart
TamButton.primary(
  label: t.continueLabel,
  loadingLabel: t.loadingLabel,
  isLoading: isSaving,
  onPressed: canSave ? onSave : null,
)

TamButton.secondary(label: t.backLabel, onPressed: onBack)
```

The localization identifiers above are illustrative; add actual strings through
the existing ARB workflow when implementing the relevant feature.

### `TamTextField`

A `TextFormField` with the shared outlined/filled decoration, label, hint, helper,
prefix/suffix icons and focus/error styling. Supports form validation, external
error text, read-only and disabled states, obscured or multiline input, autofill,
keyboard configuration and callbacks. The caller creates and disposes controllers
and focus nodes; controller and initial value cannot be supplied together.

External `errorText` uses `forceErrorText` and takes precedence over validation;
the caller must clear it after correcting the input or receiving a new result.
Errors wrap naturally rather than being forced onto one line. Native fields also
inherit the theme, with a three-line helper/error default.

For a phone number in an Arabic form, set `textDirection: TextDirection.ltr` and
`keyboardType: TextInputType.phone`. The surrounding labels and layout retain the
page's direction. The component contains no country codes, validation business
rules or localized copy.

### `TamCard`

A white, bordered Material card with 16-pixel default directional padding and a
16-pixel radius. An optional `onTap` adds native ink, keyboard focus, button
semantics and a minimum 48-pixel target. Omit `onTap` for a static information
surface; put loading/disabled/error behavior on the relevant child action rather
than disabling an entire information card. Do not nest tappable controls inside a
tappable card.

### `TamLoadingIndicator`

A themed circular indicator, indeterminate by default. Supply `value` in `[0, 1]`
for measured progress and a localized `semanticLabel` when it stands alone.
Optional `size` and `color` allow compact/on-primary use. Keep it in a bounded
layout; the caller owns loading/retry states and surrounding content.

## Native Material components

The theme also configures text buttons, app bars, navigation bars, bottom sheets,
dialogs, dividers, text selection and snackbars. Use native Material components
for these patterns rather than adding wrappers without behavior to standardize.
Shared components read the ambient theme; none read the light palette directly.
The private theme builder accepts a color scheme and status extension, so a later
dark palette can reuse the same component rules. A dark theme is not implemented.

## File manifest

Modified:

- `apps/customer/lib/app/theme/app_theme.dart`

Created:

- `apps/customer/lib/app/theme/app_colors.dart`
- `apps/customer/lib/app/theme/app_tokens.dart`
- `apps/customer/lib/app/theme/app_typography.dart`
- `apps/customer/lib/shared/widgets/tam_button.dart`
- `apps/customer/lib/shared/widgets/tam_text_field.dart`
- `apps/customer/lib/shared/widgets/tam_card.dart`
- `apps/customer/lib/shared/widgets/tam_loading_indicator.dart`
- `apps/customer/test/shared/design_system_test.dart`
- `docs/engineering/design-system.md`

## Validation and remaining review

The baseline Flutter analyzer was clean before changes. Run from `apps/customer`:

```bash
dart format --output=none --set-exit-if-changed lib test
flutter analyze --no-pub
flutter test --no-pub
```

The 16 design-system tests cover foreground/background contrast (at least 4.5:1
for the tested normal-text pairs), enabled input boundary contrast (at least 3:1),
pressed/focus feedback, disabled/loading activation guards, keyboard activation,
form and external errors, focus/controller handling, read-only/disabled input,
card semantics and progress semantics. Layout tests cover both locales on a
320-pixel viewport at 1x, 2x and 3.2x text scale, including wrapped labels/errors
and direction-aware icon order. These are widget tests, not device certification.

Native Arabic glyph metrics and screen-reader behavior on physical Android/iOS
devices remain a later integration check. No emulator, Android build, GitHub
Actions, dependency addition or raw reference-image commit is required here.

Local result on Flutter 3.41.4 / Dart 3.11.1: formatting and analysis pass, and all
22 tests pass (16 design-system tests plus the 6 existing tests). Separate Arabic
and English component sheets were rendered with Flutter's widget-test renderer
and visually reviewed. The review renderer used a system font substitute because
test rendering does not load device fonts; it is a layout/color preview, not a
promise of identical device glyphs. Preview images and the temporary render
fixture are outside the repository. No dependencies were added.
