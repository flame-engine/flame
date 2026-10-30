<!-- markdownlint-disable MD013 MD060 -->
# Testing


## Coverage target

CI enforces **at least 50% line coverage** (`min_coverage: 50` in
`.github/workflows/flame_studio.yml`). This is intentionally below VGV's usual 100%.
Prioritize:

1. **Repositories and data clients** — pure Dart, cheap to test, high value.
2. **Blocs/Cubits** — every event handler and resulting state.
3. **Widgets** with logic (conditional rendering, dispatching events).

Trivial layout widgets and generated code may go untested.


## Layout

- Tests mirror the source tree: `lib/inspector/bloc/inspector_bloc.dart` →
  `test/inspector/bloc/inspector_bloc_test.dart`.
- Shared helpers live in `test/helpers/` (import `../helpers/helpers.dart`).
  Use `tester.pumpApp(widget)` so widgets get the same providers/theme as in
  the app; extend `pumpApp` as new providers are added.


## Tools (add when first needed)

- `bloc_test` — `blocTest<MyBloc, MyState>(...)` for blocs/cubits.
- `mocktail` — mocks for repositories (`class _MockComponentRepository extends Mock implements ComponentRepository {}`)
  and blocs (`MockBloc`/`MockCubit` from `bloc_test`).


## Style

- Group by the unit under test: `group(MyBloc, () { ... })`.
- Test descriptions read as sentences: `'emits [loading, success] when ...'`.
- Each test sets up its own state; tests run in random order
  (`--test-randomize-ordering-seed random`), so no shared mutable state.
- Mock the layer directly beneath the unit under test — never deeper.


## Running

```sh
flutter test --coverage --test-randomize-ordering-seed random
# optional: view report (requires lcov)
genhtml coverage/lcov.info -o coverage/ && open coverage/index.html
```
