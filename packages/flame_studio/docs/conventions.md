# Code Conventions


## Lints

- `flame_lint` (with its DCM rules) is the base of `analysis_options.yaml`, with
  `very_good_analysis` and `bloc_lint` on top. Zero analyzer issues is required.
- Fix lints rather than ignore them. A line-level
  `// ignore: <rule>` is acceptable only with a short comment explaining why.
- Run `dart fix --apply` for mechanical fixes.
- Public APIs need doc comments (`public_member_api_docs`). Use the
  `{@template}` / `{@macro}` pattern for widgets and classes:

  ```dart
  /// {@template my_widget}
  /// Short description.
  /// {@endtemplate}
  class const MyWidget({super.key}) extends StatelessWidget {
    /// {@macro my_widget}
    this;
  }
  ```


## Naming & files

- Files and folders: `snake_case`. One public class per file, file named after it.
- Feature folders are named after the feature (`inspector/`, not `screens/inspector/`).
- Blocs: `<feature>_bloc.dart` with `<feature>_event.dart` and
  `<feature>_state.dart` as `part` files. Cubits: `<feature>_cubit.dart` +
  `<feature>_state.dart`.
- Events are past tense, describing what happened: `ComponentSelected`,
  `PropertyChanged`. Prefix with the feature if ambiguous.
- Widgets: `<Feature>Page` provides dependencies, `<Feature>View` renders.


## Barrel files

- Every folder with public members has a barrel (`view/view.dart`,
  `widgets/widgets.dart`, `models/models.dart`) and every feature has
  `<feature>/<feature>.dart` exporting `bloc/` and `view/`.
- Import other features through their barrel, never deep paths.
- Clients and repositories are imported through `clients/clients.dart` and
  `repositories/repositories.dart`.


## Imports

- Use `package:` imports (enforced by `always_use_package_imports`).
- The bloc layer must not import `package:flutter/...`.


## State

- States and events are immutable and value-comparable (`equatable` or
  sealed classes with `==`). Prefer a single state class with a `status` enum
  plus `copyWith` for features with loading/error states.
- Keep the component model immutable; edits produce new instances (this
  keeps undo/redo straightforward).


## Desktop specifics

- Design for mouse + keyboard: hover states, right-click context menus,
  keyboard shortcuts (`Shortcuts`/`Actions`), resizable panels.
- No platform-specific code in blocs/repositories; isolate it in data
  clients.
