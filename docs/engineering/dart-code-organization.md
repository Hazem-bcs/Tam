# Dart organization example

The mandatory rules live in [AGENTS.md](../../AGENTS.md#dart-readability-and-file-organization).
The goal is readable pages and focused files, with a preferred limit of 300 lines
for handwritten Dart. A longer cohesive file can be justified; splitting every
few lines into a separate file is not the goal.

For example, when the Home implementation needs these sections, it could use:

```text
lib/features/home/
  presentation/
    pages/
      home_page.dart
    widgets/
      home_header.dart
      destination_search_card.dart
      home_service_grid.dart
    bloc/
      home_cubit.dart
      home_state.dart
```

This is an illustration, not a list of files to create in advance. Follow the
existing feature's state-management convention and add domain/data code only
when the behavior needs it. If several pages eventually have many distinct
sections, group their widgets into descriptive subfolders then.

`HomePage` should make the screen's structure easy to scan: scaffold, responsive
content layout, header, destination input and services. Each substantial section
owns its UI details in a named widget. Continue to use the central theme, tokens,
localization and responsive constraints inside those widgets.

Keep state and controllers with the component responsible for their lifecycle.
Pass the values and callbacks a section actually needs; let an appropriate state
selector rebuild only the section whose data changes. Extraction must preserve
navigation, validation, semantics and existing behavior.

Before handing off, check that filenames reveal their purpose, the page can be
understood without reading every section's implementation, and any file above
the guideline has a concrete reason to remain together. Report that reason in
the handoff without adding noisy line-count comments to source files.
