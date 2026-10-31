<!-- markdownlint-disable MD013 MD060 -->
# Architecture

This project follows the layers of the
[Very Good Ventures layered architecture](https://engineering.verygood.ventures/architecture/architecture/),
with one deliberate difference: the data and repository layers live in `lib/`, not in internal
packages. This is a standalone app, so each layer is a folder and there are no packages under
`packages/flame_studio`. Nothing enforces the boundaries between layers, so keep to the rules below.


## Layers

Data flows **bottom up**. Each layer has a single responsibility and may only
depend on the layer **directly beneath it**.

```text
┌─────────────────────────────────────┬──────────────────────────────────────┐
│ Presentation (lib/<feature>/view)   │ Flutter widgets, no business logic   │
├─────────────────────────────────────┼──────────────────────────────────────┤
│ Business logic (lib/<feature>/bloc) │ Blocs/Cubits, no Flutter imports     │
├─────────────────────────────────────┼──────────────────────────────────────┤
│ Repository (lib/repositories)       │ Domain rules, composes data clients  │
├─────────────────────────────────────┼──────────────────────────────────────┤
│ Data (lib/clients)                  │ Raw I/O: file system, serialization  │
└─────────────────────────────────────┴──────────────────────────────────────┘
```


### Data layer — `lib/clients/`

- Talks to the outside world: file system, JSON/YAML (de)serialization of
  project files, clipboard, OS dialogs, asset loading, process execution.
- No domain or business logic. Should be reusable in an unrelated project.
- Returns raw/DTO models specific to that source.


### Repository layer — `lib/repositories/<domain>_repository/`

- One repository per domain. Composes one or more data clients and exposes
  **domain models**.
- Pure Dart: **no Flutter imports**, and **no dependency on other
  repositories**.
- Hides *how* data is fetched/stored. If a data client changes, only its
  repository should change.


### Business logic layer — `lib/<feature>/bloc/`

- Blocs/Cubits that compose repositories and turn user intents into states.
- **No Flutter SDK imports** (no `package:flutter/...`) and **no direct
  dependency on other blocs**. If two blocs need to coordinate, do it through
  a shared repository (e.g. a stream) or from the presentation layer.
- Repositories are injected via the constructor.


### Presentation layer — `lib/<feature>/view/` (+ `widgets/`)

- Widgets only. Reads bloc state and dispatches events — nothing else.
- Never touches a data client or repository method directly (repositories are
  only *provided* via `RepositoryProvider` and passed into blocs).


### Leakage examples (don't)

- A widget reading a file from disk or calling a `*Client`.
- A bloc knowing file paths/formats — that belongs in the repository/client.
- A repository importing `package:flutter/...` or another repository.


## Project structure

```text
flame_studio/
├── lib/
│   ├── main.dart                     # entry point: builds repositories, runApp(App)
│   ├── app/
│   │   ├── app.dart                  # barrel
│   │   └── view/
│   │       └── app.dart              # MaterialApp, providers, theme
│   ├── widgets/                      # widgets shared by several features (e.g. ZoomControls)
│   ├── clients/
│   │   ├── clients.dart              # barrel
│   │   └── <source>_client.dart
│   ├── repositories/
│   │   ├── repositories.dart         # barrel
│   │   └── <domain>_repository/
│   │       ├── models/
│   │       │   └── models.dart       # barrel
│   │       └── <domain>_repository.dart
│   └── <feature>/                    # e.g. canvas, component_tree, inspector
│       ├── <feature>.dart            # barrel: exports bloc/ and view/
│       ├── bloc/
│       │   ├── <feature>_bloc.dart
│       │   ├── <feature>_event.dart  # part of <feature>_bloc.dart
│       │   └── <feature>_state.dart  # part of <feature>_bloc.dart
│       ├── view/
│       │   ├── <feature>_page.dart   # provides the bloc
│       │   ├── <feature>_view.dart   # consumes the bloc
│       │   └── view.dart             # barrel
│       └── widgets/                  # feature-private widgets (optional)
│           └── widgets.dart          # barrel
└── test/                             # mirrors lib/
    ├── helpers/                      # pumpApp and shared test utilities
    ├── app/view/app_test.dart
    └── <feature>/
        ├── bloc/<feature>_bloc_test.dart
        └── view/<feature>_page_test.dart
```


### Page / View split

Each feature's `view/` has a `<Feature>Page` that creates and provides the bloc
(`BlocProvider(create: (context) => FeatureBloc(repository: context.read()))`)
and a `<Feature>View` that only consumes it. Tests of the view can then inject
a mock bloc without touching repositories.


## Existing modules

| Layer | Module | Responsibility |
| --- | --- | --- |
| Data | `lib/clients/key_value_storage_client.dart` | Generic string key-value storage (`shared_preferences`) |
| Data | `lib/clients/file_system_client.dart` | Native directory picker (`file_selector`), directory/file existence, list (optionally recursively)/read (as text or bytes)/write/delete files |
| Repository | `lib/repositories/editor_preferences_repository/` | App-wide editor preferences (`shared_preferences`, through `key_value_storage_client`), not stored in the project: the preview zoom of each component, keyed by project path + component name (`component_zoom:<projectPath>:<componentName>`), clamped to `minZoom`–`maxZoom`; the `ZoomLevels` the editor canvases step through |
| Repository | `lib/repositories/project_repository/` | `Project` and `ProjectSettings` models; pick/open projects; last 10 recent projects; read/write project settings (`<project>/.flame_studio/settings.json`) and pick a project-relative output folder |
| Repository | `lib/repositories/component_repository/` | Sealed `Component` model (one subclass per `ComponentType`), shared property models (`ComponentPosition`, `ComponentSize`, `ComponentPaint`, `ComponentVertices`…), the `PolygonShape` presets new polygons start with, the hitbox types and their `ComponentCollision`, capability interfaces and the `ComponentTree` extension for nested children (including child name validation); list/create/save/delete a project's components (one JSON file each in `<project>/.flame_studio/components/`); `ComponentCodeGenerator` and writing/deleting the generated Dart code (see "Code generation"); the project's `Palette` (`<project>/.flame_studio/palette.json`) and its `PaletteCodeGenerator` (see "Palette"); the images sprites can use (`getImages`, `readImage`, see "Sprites") |
| Bloc + view | `lib/home/` | Landing screen: "Open project" button and recent projects list |
| Bloc + view | `lib/project/` | Project dashboard: lists components, add (name + type dialog → editor), edit, delete (with confirmation; also deletes the generated code), settings icon (opens the settings dialog). Pushed from home with `ProjectPage.route` |
| Bloc + view | `lib/component_editor/` | Component editor, `ComponentEditorPage.route(project, component)`: a top bar (`EditorTopBar`, below the app bar, above the three panels) for project-wide actions (the palette button), component tree (left, add/remove children — not under hitboxes —, root selected by default), Flame preview (center, magenta border around the selected node; a toolbar above it toggles that highlight and the hitbox outlines, and has the zoom controls; it scrolls horizontally when the preview is narrow), properties panel for the selected node (right; children also get a Name field), save button + Cmd/Ctrl+S (also generates the Dart code), unsaved-changes marker in the title, `PopScope` prompt (cancel / discard / save) when leaving with unsaved changes |
| Bloc + view | `lib/vertices_editor/` | Vertices editor dialog, `VerticesEditorDialog.show(context, vertices:, paint:)`: a `CustomPaint` canvas (`VerticesCanvas`, `VerticesPainter`) where the user drags vertices, adds one from the "+" handle in the middle of an edge, and deletes the selected one (Delete/Backspace, context menu or button; at least 3 are kept). A side bar (`VerticesList`) has X/Y fields per vertex to type exact coordinates, and a delete button per row; selecting a row or focusing its fields selects the vertex. `VerticesEditorCubit` edits a working copy; Apply returns it normalized, Cancel/Esc returns `null`. `VerticesViewTransform` maps local coordinates to the canvas (fitted once when the dialog opens) and does the hit testing. The canvas zooms (`ZoomControls` next to the title, Cmd/Ctrl + `=`/`-`/`0`) relative to that fit, around its center (`VerticesViewTransform.zoomed`); the zoom is held by the cubit and not remembered |
| Bloc + view | `lib/sprite_editor/` | Sprite editor dialog, `SpriteEditorDialog.show(context, project:, sprite:)`: the project's images in a side bar, and a `CustomPaint` canvas (`SpriteCanvas`, `SpritePainter`) showing the picked one, where the user drags on the image to select a region, drags the selection to move it and drags its 8 handles to resize it. X/Y/Width/Height fields (`SpriteRegionFields`) type exact values. `SpriteEditorCubit` edits a working copy and keeps the region in whole pixels inside the image; Apply returns it, Cancel/Esc returns `null`. `SpriteViewTransform` maps image pixels to the canvas (fitted to it, also scaling small images up) and does the hit testing; `ZoomControls` and Cmd/Ctrl + `=`/`-`/`0` zoom it, scrolling pans it, and neither is remembered |
| Bloc + view | `lib/palette/` | Palette dialog, `PaletteDialog.show(context, project:, component:)` (opened from the editor's top bar; returns the saved `Palette` or `null`): add, rename, change and remove named colors; colors used by a component (including the unsaved edits of the open one) can't be renamed or removed. `PaletteBloc` saves the palette and generates its code |
| Bloc + view | `lib/project_settings/` | Project settings dialog, `ProjectSettingsDialog.show(context, project)`: output path for generated Dart code (default `lib/components`, text field + Browse) |

The macOS app sandbox is **disabled** (both entitlements files) so that plain
folder paths in the recent projects list can be reopened after a restart.


## Component types & shared properties

Many Flame components share properties (every `PositionComponent` has a size,
many components have a paint). Each property is therefore built **once** and
component types only declare which ones they have:

| Piece | Where | Example |
| --- | --- | --- |
| Value object (Equatable, JSON, defaults) | `lib/repositories/component_repository/models/` | `ComponentPosition`, `ComponentAnchor`, `ComponentAngle`, `ComponentSize`, `ComponentRadius`, `ComponentVertices`, `ComponentPaint`, `ComponentSprite`, `ComponentCollision` |
| Capability interface | `lib/repositories/component_repository/models/component_capabilities.dart` | `PositionedComponent`, `AnchoredComponent`, `RotatedComponent`, `SizedComponent`, `RadiusComponent`, `VerticesComponent`, `PaintedComponent`, `SpriteBackedComponent`, `HitboxComponent` |
| Component type | `ComponentType` enum + a subclass in `component.dart`'s library (`part` file) | `RectangleComponent implements PositionedComponent, AnchoredComponent, RotatedComponent, SizedComponent, PaintedComponent`, `PositionComponent implements PositionedComponent, AnchoredComponent, RotatedComponent, SizedComponent`, `CircleComponent implements PositionedComponent, AnchoredComponent, RotatedComponent, RadiusComponent, PaintedComponent`, `PolygonComponent implements PositionedComponent, AnchoredComponent, RotatedComponent, VerticesComponent, PaintedComponent`, `SpriteComponent implements PositionedComponent, AnchoredComponent, RotatedComponent, SizedComponent, SpriteBackedComponent`, and the hitboxes, which swap the paint for a `HitboxComponent`: `RectangleHitboxComponent`, `CircleHitboxComponent`, `PolygonHitboxComponent` |
| Bloc event | `lib/component_editor/bloc/` | `ComponentEditorSizeChanged` (edits the selected node if it is a `SizedComponent`) |
| Editor widget (`value` + `onChanged`, bloc-agnostic) | `lib/component_editor/widgets/property_editors/` | `PositionEditor`, `AnchorEditor`, `AngleEditor`, `SizeEditor`, `RadiusEditor`, `VerticesEditor` (a button that opens the vertices editor dialog), `SpriteEditor` (a button that opens the sprite editor dialog), `PaintEditor`, `CollisionEditor`, built from `NumberField`, `ColorField`, `EnumField` |
| Panel wiring | `lib/component_editor/widgets/properties_panel.dart` | `if (component case SizedComponent c) SizeEditor(...)` |
| Flame mapping | `lib/component_editor/widgets/preview/flame_mapping.dart` | `applyPosition`, `applyAnchor`, `applyAngle`, `applySize`, `applyRadius`, `applyPaint`, `applySprite`, `applyCollision`, `buildFlameComponent` |
| Code generation | `lib/repositories/component_repository/code_generation/` | `ComponentCodeGenerator._flameClass` / `_arguments`, `flameMemberNames` in `dart_names.dart` |

**Adding a component type:** add a `ComponentType` value, a `Component`
subclass implementing the right capabilities (reuse the value objects' JSON;
its private `_fromJson` reads only its own properties, `Component.fromJson`
reads the children for every type), and cases in
`Component.create`/`Component.fromJson`,
`buildFlameComponent`, `ComponentCodeGenerator._flameClass` and
`flameMemberNames` (the public members of its Flame class, which child
getters must not override), and an icon in `ComponentTreePanel.iconFor`. The panel, bloc, preview and generated code
pick up its properties automatically.

**Adding a property:** add the value object and capability interface, a bloc
event, an editor widget, a branch in `PropertiesPanel`, in
`applyProperties` and in `ComponentCodeGenerator._arguments` (the generated
code must match the preview), then implement the capability on the types
that have it.


### Polygons

A `PolygonComponent` is shaped by its `ComponentVertices`: points in the
component's local coordinates, in order, at least 3 (Flame asserts it).
Its Flame size is the bounding box of the vertices (Flame's
`shrinkToBounds`), so polygons have **no size property**. New polygons
start as a triangle or a square (`PolygonShape`, picked in the add
component dialog and in the tree's add-child menu); concave and
self-intersecting shapes are allowed.

Flame moves the vertices so that the top left of their bounding box is
at the origin, so the vertices editor stores them normalized
(`ComponentVertices.normalized`) and the stored data matches what Flame
renders. A Flame polygon can't change its number of vertices and can't be
given new ones from outside (`refreshVertices` is protected), so
`haveSameShape` is false when a polygon's vertices change and the preview
rebuilds it. Flame also changes the list it is given, so the preview and
the generated code always pass a new, non-const list, as the first
(positional) constructor argument.


### Sprites

A `SpriteComponent` is a position component (position, anchor, angle and
size) that draws a `ComponentSprite`: the `image`, and the region of it in
`srcPosition` and `srcSize`, in whole pixels. `image` is `null` until one
is picked.

- **Images** are the image files anywhere under `<project>/assets/`
  (`ComponentRepository.getImages`). They are identified by their **asset
  path** (`assets/images/player.png`, always with `/`), which is what
  Flame 2 loads: unlike older versions it adds no `assets/images/` prefix.
  The editor doesn't touch `pubspec.yaml`: the game must declare its assets.
- **Size.** `size` is what the sprite is drawn with, so the region is
  stretched to fit, like in Flame. The first image picked also sets the size
  to the one of the region (`ComponentEditorSpriteChanged`), like Flame sizes
  a sprite without a size; after that it is only edited by hand.
- **Decoding** needs `dart:ui`, so it only happens in the view. Repositories
  and blocs handle bytes: `ComponentEditorState.spriteImages` has the bytes of
  the images of the tree (`ComponentTree.usedImages`), loaded on
  `ComponentEditorStarted` and when a sprite changes; `ComponentPreview`
  decodes them for `ComponentPreviewGame.spriteImages`. The dialog's cubit
  reads the bytes and `SpriteCanvas` decodes them and reports the size with
  `imageDecoded`. An image changed on disk is read again when the editor or
  the dialog opens.
- **Preview.** Flame's `SpriteComponent` asserts on mount that it has a
  sprite, but the preview shows it before the image is picked or decoded, and
  when it is missing. So it builds `PreviewSpriteComponent`, a
  `PositionComponent` that draws the sprite, or a dashed outline without one.
- **Code.** Flame loads sprites asynchronously, so a node with an image gets
  a generated class, even as a leaf child, whose `onLoad` does
  `sprite = await Sprite.load(path, srcPosition:, srcSize:, images: findGame()?.images)`.
  `findGame` rather than `HasGameReference`, since a game subclass mixing in
  its own `HasGameReference<MyGame>` wouldn't compile. Subclasses overriding
  `onLoad` must call `super.onLoad()`.
- **Without an image** the generated code is a plain `SpriteComponent`, which
  **asserts when mounted in debug mode** unless something sets its `sprite`,
  such as a subclass of the root.


### Hitboxes

`RectangleHitboxComponent`, `CircleHitboxComponent` and
`PolygonHitboxComponent` are Flame's `RectangleHitbox`, `CircleHitbox` and
`PolygonHitbox`: the geometry of their shape (size, radius or vertices, so
the shared editors, highlight and polygon rules apply) without a paint,
plus a `ComponentCollision` (`HitboxComponent`): the collision type
(`HitboxCollisionType`, mirroring Flame's `CollisionType`) and `isSolid`.
The generated code imports `package:flame/collisions.dart` when the tree has
a hitbox, and omits `collisionType`/`isSolid` at Flame's defaults (active,
not solid).

- **Children only, and leaves.** Flame throws when a hitbox has no
  `PositionComponent` ancestor, so `createComponent` rejects hitbox roots
  (`ArgumentError`) and the add component dialog doesn't offer them;
  `addChildAt` throws under a hitbox, the editor bloc ignores
  `ComponentEditorChildAdded` while one is selected and the tree's add
  button is disabled.
- **Preview.** Hitboxes draw nothing, so the preview builds
  `PreviewRectangleHitbox`, `PreviewCircleHitbox` and `PreviewPolygonHitbox`
  (`preview_hitboxes.dart`, sharing the `PreviewHitbox` mixin): the real
  Flame hitboxes with an **orange dashed outline**. The preview game has no
  collision detection, so they never collide. The toolbar's "Show
  hitboxes" toggle (`ComponentEditorState.areHitboxesVisible`, on by
  default, not persisted) hides them through Flame's `HasVisibility`
  (`ComponentPreviewGame.areHitboxesVisible`). The vertices editor draws
  polygon hitboxes with the same orange stroke.
- **Fill-parent gotcha.** Flame's `RectangleHitbox`/`CircleHitbox` fill
  their parent when built without a size/radius and without a position.
  The preview hitboxes are built with a zero size/radius, and the
  generated children always pass a position and a size/radius.


### Component tree

Like in Flame, every `Component` has `children` (stored nested in the same
JSON file). A node is addressed by its **path**, the list of child indices
from the root (`[]` is the root); `ComponentTree` (`nodeAt`, `updateNodeAt`,
`addChildAt`, `removeNodeAt`, `uniqueChildName`) does all the immutable tree
edits. The editor state holds `selectedPath`, and every property event edits
`selectedNode`. New children get a unique default name such as `rectangle1`.

The position, the anchor and the angle are only edited on children
(`PropertiesPanel` hides them for the root, which is placed by whoever uses
it). In the preview the root is centered with a center anchor and no
rotation (its stored position, anchor and angle are ignored); children use
their own anchor (`ComponentAnchor`, Flame's default top left unless
edited: one of Flame's nine named anchors or a custom `x`/`y`) and angle
(`ComponentAngle`, stored in radians like Flame, edited in degrees by
`AngleEditor`) and are positioned relative to their parent. The selection
highlight is rotated with the selected node. `ComponentPreviewGame.show`
updates the Flame components in place while the tree shape is unchanged
(`haveSameShape`) and rebuilds them otherwise.

Position components draw nothing in Flame, so the preview builds them as
`PreviewPositionComponent`, a `PositionComponent` with a faint dashed
outline, to keep them visible while unselected. The outline is preview
only: the generated code uses a plain `PositionComponent`. The dashes are
drawn by the shared helpers in `dashed_outline.dart`, also used by the
hitboxes.

The preview highlights the selected node with a magenta border while
`isSelectionHighlighted` is on (the toolbar toggle; on by default, not
persisted). Only nodes with a size (`SizedComponent`, which sprites are) or a radius
(`RadiusComponent`, whose Flame size is the circle's bounding box) or
vertices (`VerticesComponent`, highlighted around their bounding box) are
highlighted. The
border is drawn by `SelectionHighlight`, a world-level overlay that targets
the Flame component found with `flameNodeAt`, rather than a child of it:
that keeps it above overlapping siblings and keeps the Flame children
matching the component tree.

The preview can be zoomed (`ComponentEditorState.zoom`) with the zoom
out / percentage (reset to 100%) / zoom in controls on the right of the
toolbar, or with Cmd/Ctrl + `=`, `-` and `0`. Zooming in and out steps
through `ZoomLevels` (10% to 800%, in `editor_preferences_repository`).
The controls and shortcuts are the shared `ZoomControls` and
`zoomShortcuts` in `lib/widgets/`, also used by the vertices editor. The zoom is an
**editor preference, not component data**: it is remembered per component
in `EditorPreferencesRepository` (loaded on `ComponentEditorStarted`,
stored on every change) and never written to the component's JSON, so it
doesn't mark unsaved changes. `ComponentPreviewGame.zoom` sets the
camera's `viewfinder.zoom`, which zooms around the root at the center of
the screen; `SelectionHighlight` divides its stroke width by the zoom so
the border keeps the same width on screen.

Domain models avoid `dart:ui`: colors are ARGB `int`s and `PaintStyle` mirrors
`PaintingStyle`. Conversion to Flame/Flutter types happens only in
`flame_mapping.dart`. Flame's own `Component`/`RectangleComponent` clash with
the domain names, so import Flame with a prefix
(`import 'package:flame/components.dart' as flame;`).

The preview `GameWidget` is created with `autofocus: false`: a focused
`GameWidget` marks every key event as handled, which would swallow the editor
shortcuts. Widget tests that show the preview can't use `pumpAndSettle` (the
game loop never settles), so use `tester.pumpRouteTransition()` from
`test/helpers`.


### Palette

A project has one `Palette`: an ordered list of named colors
(`PaletteColor`), stored in `<project>/.flame_studio/palette.json` and read
and written by `ComponentRepository` (`getPalette`, `savePalette`,
`writePaletteCode`). It lives in `component_repository` because component
code references it, components can't take its file name, and "in use" is
computed from the components; a separate repository would have to depend on
this one.

- **Names** are their generated member names, so they are validated like
  child names (`Palette.validateColorName`, `PaletteColorNameError`): a valid
  identifier, not a keyword, unique after camelCase normalization.
- **Paints reference colors by name**: `ComponentPaint.paletteColor`. Its
  `color` keeps the value the palette color had when it was picked, as a
  fallback when the palette doesn't have it (`resolvedColor(palette)`).
  `withColor` (picked by hand) clears the reference; `withPaletteColor`
  sets it. `paletteColor` is only written to JSON when set.
- **Editing**: `ColorField` gets a palette button (a menu of the colors)
  when it is given a palette and `onPaletteColorSelected`; `PaintEditor`
  wires it. The editor bloc loads the palette on `ComponentEditorStarted`
  and gets the saved one from the dialog with
  `ComponentEditorPaletteChanged`; the preview draws
  `component.withPaletteColorsResolved(palette)`. Palette changes are not
  component changes (`hasChanges` is unaffected).
- **Colors in use can't be renamed or removed** (`PaletteState.usersOf`,
  `ComponentTree.usedPaletteColors`); their value can change. That keeps
  every reference in saved components and generated code valid.
- **Code**: `PaletteCodeGenerator` writes
  `<outputPath>/palette.generated.dart` with
  `abstract final class GamePalette { static const primary = Color(…); }`
  (no `$` prefix: generated component classes all have one, so they never
  clash). Component code uses `Paint()..color = GamePalette.primary` and
  imports `palette.generated.dart` for colors the palette has; missing ones
  fall back to the inline value. `writeComponentCode` also rewrites the
  palette file when the component uses it, so the import always resolves
  (e.g. after the output path changed), and `isComponentCodeUpToDate`
  compares against code generated with the current palette. Components named
  `palette` (any name whose file is `palette`) are rejected on creation, and
  an older one's code is never written over the palette's
  (`GeneratedFileConflictException`).


### Code generation

Saving a component in the editor also writes its Dart code to
`<project>/<outputPath>/<snake_case name>.generated.dart` (`outputPath` comes from
the project settings, default `lib/components`). There is no separate
"generate" action. `ComponentEditorBloc` composes both repositories: it
saves the JSON with `ComponentRepository.saveComponent`, reads the settings
with `ProjectRepository.getSettings` and calls
`ComponentRepository.writeComponentCode`. If only the code fails, the
component still counts as saved (`codeConflict` / `codeFailure` statuses,
shown as a snackbar). `ProjectBloc` deletes the generated file along with
the component.

`ComponentCodeGenerator` (pure, formatted with `dart_style` at language
version 3.8) generates code for **Flame 2.0.0-dev** (the version the app
itself uses, so the preview matches). When upgrading Flame, refresh the
member lists in `dart_names.dart` (`flameMemberNames`). It generates:

- the root as a public class named in PascalCase after the component,
  with the `$` prefix of generated code (`player_ship` → `$PlayerShip`),
  extending its Flame class (games subclass it:
  `class PlayerShip extends $PlayerShip`), with a
  `{super.position, super.angle, super.anchor, super.priority}` constructor
  (the root's stored position, angle and anchor are ignored, like in the
  preview);
- the children's anchor as an `anchor:` argument, `Anchor.<name>` for
  Flame's named anchors (`ComponentAnchor.presetName`) and `Anchor(x, y)`
  otherwise, omitted for the default top left (so files generated before
  anchors existed stay up to date);
- the children's angle as an `angle:` argument in radians, omitted when it
  is `0`;
- **a `final` field (a getter) for every child on the component it is
  inside**, named in camelCase after the child (`left_arm` → `leftArm`),
  added in the constructor body;
- a class `$<Root><Child>` (e.g. `$PlayerShipHead`) for every child that
  has children of its own, so the nested children get getters too
  (`player.head.eye`), and for every child that loads a sprite (see
  "Sprites"); other leaf children are plain Flame components.

Every generated file starts with `ComponentCodeGenerator.header`.
`dart:ui` is only imported when a node of the tree has a paint (an unused
import is a warning that `ignore_for_file: type=lint` doesn't hide). The
repository never overwrites or deletes a file without it
(`GeneratedFileConflictException`), so hand-written code in the output
folder is safe.

Child names are the getter names, so the Name field validates them with
`ComponentTree.validateChildName` (`ChildNameError`): a valid identifier
that isn't a keyword, not a member of the parent's Flame class (`size`,
`position`, `paint`, …), and unique in the tree after camelCase
normalization. Root names are validated on creation: the class name must
be a valid identifier, and no other component may generate the same file.
Thanks to the `$` prefix, generated classes never shadow Flame types.

Generated classes are public, so **class names must also be unique across
the project** (a library importing two files that declare `$PlayerShipHead`
won't compile). `ComponentTree.generatedClassNames` lists the classes a
component reserves: its root class and `$<Root><Child>` for **every** child,
even leaves (which only get a class once they have children), so adding a
grandchild never causes a clash. The class names live in `dart_names.dart`
(`dartRootClassName`, `dartChildClassName`), shared by the generator and
the validation. `createComponent` throws `ComponentClassConflictException`
when the new root class is reserved by another component (e.g. `AB` vs
`a_b`, or `player_ship_head` vs the `head` child of `player_ship`). The
editor loads the other components' classes on `ComponentEditorStarted`
(`ComponentEditorState.takenClassNames`), and both `validateChildName`
(`ChildNameError.conflict`) and `uniqueChildName` take them into account.
Saving reloads the other components and checks the whole tree again
(catching names typed before they loaded). **A component whose classes
clash is not saved at all** (`classConflict` status; the changes stay
pending): its code wouldn't compile, and its JSON would reserve classes
that other components own. Clashes that already existed (e.g. `AB` and
`a_b` created before this check) are reported when the editor opens.
`takenClassNames` maps every class to the component that generates it, so
the snackbar says how to fix each clash: rename the clashing children; or,
when the root class clashes (`ComponentEditorState.rootClassOwner`), rename
the child of the other component that generates it, or delete one of the
two components if both roots generate it (components can't be renamed).

`isCodeOutdated` is true when the generated code doesn't match the saved
component: `ComponentEditorStarted` checks it with
`ComponentRepository.isComponentCodeUpToDate` (missing, stale or
hand-written file), and saves that don't generate the code (`codeConflict`,
`codeFailure`) set it. `canSave` then lets the user save without changes,
e.g. after deleting the other component or moving a hand-written file out
of the way. Save states are built from the current state, so edits made
while saving are kept; edits keep the `saving` status, so no second save
starts meanwhile, and `ComponentEditorStarted` drops its results if a save
started while it was loading (the save's are newer). The leave prompt's
"save" only leaves once nothing is unsaved.


## Domain sketch (expected, not yet built)

These are **likely** candidates as the editor grows; confirm with the user
before creating them.

| Layer | Candidate | Responsibility |
| --- | --- | --- |
| Repository | `component_repository` (exists) | More component types and properties (scale…), undo/redo-friendly immutable models |
| Bloc | `component_tree/`, `canvas/` | Selection, canvas interactions |
| Presentation | same features | Desktop layout: tree panel, Flame canvas preview (`GameWidget`), inspector panel |

The live Flame preview is presentation: the `GameWidget`/`FlameGame` used to
render the component being edited lives in the view layer and is driven by
bloc state; it must not own the source of truth for the component.
