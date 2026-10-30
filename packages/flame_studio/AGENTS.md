<!-- markdownlint-disable MD013 MD060 -->
# Flame Studio — Agent Guide

This guide applies only to `packages/flame_studio/`, not to the rest of the Flame monorepo.

A **Flutter desktop app** (macOS, Windows, Linux) for visually creating
[Flame](https://flame-engine.org) components: users compose and tweak
components on a canvas and the editor produces reusable Flame component
definitions/code.

Read this file first, then the doc relevant to your task:

| Doc | When to read it |
| --- | --- |
| [docs/architecture.md](docs/architecture.md) | Before adding any feature, bloc, client or repository |
| [docs/conventions.md](docs/conventions.md) | Before writing Dart code (naming, barrels, style, lints) |
| [docs/testing.md](docs/testing.md) | Before writing or changing tests |
| [docs/ci.md](docs/ci.md) | When touching `.github/` or when CI fails |


## Golden rules

1. **Follow VGV layered architecture** (data → repository → business logic →
   presentation). A layer only talks to the layer directly beneath it. See
   [docs/architecture.md](docs/architecture.md).
2. **Everything lives in `lib/`, with no internal packages.** Feature folders
   have `bloc/` and `view/`, data clients live in `lib/clients/` and repositories
   in `lib/repositories/`. This differs from VGV on purpose, see
   [docs/architecture.md](docs/architecture.md).
3. **State management is `bloc`/`flutter_bloc`.** No `setState` for anything
   beyond purely ephemeral widget state (hover, focus, animation controllers).
4. **Lints are `flame_lint` (with DCM), `very_good_analysis` and `bloc_lint`.** Code must pass `flutter analyze` with
   zero issues — never silence a lint project-wide to make it pass.
5. **Every change ships with tests.** Aim for **≥ 50% line coverage**
   (deliberately lower than VGV's usual 100%). Don't chase 100%, but test
   blocs, repositories and non-trivial widgets.
6. **Desktop only.** Do not add `android/`, `ios/` or `web/` targets unless
   explicitly asked.


## Commands

```sh
melos bootstrap                                   # install deps, from the monorepo root
flutter analyze                                   # must report "No issues found!"
dart format lib test                              # format (CI fails on unformatted code)
flutter test --coverage --test-randomize-ordering-seed random
flutter run -d macos                              # or -d windows / -d linux
```

Before finishing a task, run **analyze, format and test** and make sure all
three pass.


## Current state

- Features: `home` (open project + recent projects), `project` (dashboard:
  list/add/edit/delete components; adding asks for a name and a component
  type), `project_settings` (settings dialog: generated code output path,
  stored in `<project>/.flame_studio/settings.json`), `palette` (dialog to
  manage the project's named colors, stored in
  `<project>/.flame_studio/palette.json` and generated as `GamePalette` in
  `palette.generated.dart`; paint colors can be picked from it and their
  generated code references `GamePalette.<name>`; colors in use can't be
  renamed or removed — see "Palette" in
  [docs/architecture.md](docs/architecture.md)) and `component_editor`
  (a top bar below the app bar for project-wide actions — the palette
  button —, component tree on the left to add/remove/select/rename nested children,
  live Flame preview in the center, with a toolbar above it whose toggle
  highlights the selected node with a magenta border, another toggle
  shows/hides the hitbox outlines, and whose zoom
  controls (also Cmd/Ctrl + `=`/`-`/`0`) zoom the preview — the zoom is an
  app-wide preference per component, in `editor_preferences_repository`,
  never in the component's JSON —, properties of the selected node on the
  right, explicit save with button or Cmd/Ctrl+S, unsaved-changes prompt when
  leaving). **Saving also generates the component's Dart code** in the
  settings' output path, with a getter for every child — see "Code
  generation" in [docs/architecture.md](docs/architecture.md). Clients and repositories: `key_value_storage_client`,
  `file_system_client`, `project_repository`, `editor_preferences_repository`, `component_repository`
  (components stored in `<project>/.flame_studio/components/<name>.json`) —
  see "Existing modules" in [docs/architecture.md](docs/architecture.md).
- Component types: `polygon` (a Flame `PolygonComponent`: position, anchor
  and angle — children only —, vertices and paint; no size, which is the
  vertices' bounding box; it starts as a triangle or a square, and its
  vertices are edited in the vertices editor dialog, `lib/vertices_editor/`,
  by dragging, adding from edge midpoints and deleting, with its own zoom
  (not remembered) — see "Polygons" in
  [docs/architecture.md](docs/architecture.md)), `rectangle` (position, anchor and angle — edited only on
  children —, size, and paint with color and fill style), `position` (a plain Flame
  `PositionComponent`: position, anchor and angle — children only — and size; draws nothing
  itself, useful as a container) and `circle` (a Flame `CircleComponent`:
  position, anchor and angle — children only —, radius, and paint; the radius is its own
  `ComponentRadius` property, since Flame circles take a radius, not a
  size) and the hitboxes `rectangleHitbox`, `circleHitbox` and
  `polygonHitbox` (Flame's `RectangleHitbox`, `CircleHitbox` and
  `PolygonHitbox`: their shape's geometry plus a `ComponentCollision` —
  collision type and solid —, no paint; children only, never roots, and
  with no children of their own; outlined in orange dashes in the preview,
  shown/hidden by a toolbar toggle — see "Hitboxes" in
  [docs/architecture.md](docs/architecture.md)). Components can have children
  (see "Component tree" in [docs/architecture.md](docs/architecture.md)). Properties are shared between types through capability interfaces —
  see "Component types & shared properties" in
  [docs/architecture.md](docs/architecture.md) before adding a type or
  property.
- `bloc`, `flutter_bloc`, `equatable`, `flame` (**2.0.0-dev** — the
  generated code targets Flame 2; `flame_test` is on the matching 3.0.0-dev),
  `dart_style` (formats the
  generated code, in `component_repository`), `flex_color_picker`
  (pinned to 3.x: 4.x depends on the standalone `material_ui` package, whose
  `MaterialLocalizations` don't match `flutter/material`), `bloc_test`,
  `flame_test`, `mocktail`, `flame_lint` and `bloc_lint` are dependencies.
- Toolchain: Flutter stable 3.47 / Dart 3.13. Dart 3.13 lints prefer primary
  constructors (`class const Foo({super.key}) extends Bar {`) — `dart fix --apply`
  handles it.


## Commits & PRs

- PR titles (and commits) follow [Conventional Commits](https://www.conventionalcommits.org):
  `feat:`, `fix:`, `docs:`, `refactor:`, `test:`, `chore:`, `ci:`. CI checks this.
- Keep docs in `docs/` up to date when you change architecture or conventions.
