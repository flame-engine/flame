# Flame benchmarks

Micro-benchmarks for the hot paths of the Flame Component System. Use them to
detect regressions and to measure the effect of optimizations to the engine
internals (children containers, lifecycle processing, traversal, hit testing,
collision detection).


## Running

Run the whole suite:

```console
flutter test benchmark/main.dart
```

Each file also has its own `main`, so a single suite can be run in isolation:

```console
flutter test benchmark/priority_change_benchmark.dart
```

The `flutter test` runner executes in JIT mode with asserts enabled, which is
fine for comparing before/after numbers on the same machine. For
release-representative numbers, run on a device instead:

```console
flutter run --release -t benchmark/main.dart -d <device>
```

Note that `flutter test` prints `No tests ran` at the end; that is expected,
the benchmark results are printed above it.


## Suites

- `children_traversal_benchmark.dart`: pure update-pass and render-pass
  overhead (container iteration, recursion) over wide, nested, and deep trees
  of no-op components, plus a barrier-dense tree where a fraction of the
  parents override `updateTree`.
- `component_churn_benchmark.dart`: steady-state add/remove churn
  (bullets/particles) at 1k and 10k populations, and bulk add/remove cycles
  (level loads) through the lifecycle queue.
- `priority_change_benchmark.dart`: reordering costs: single-child priority
  changes across many parents, and the y-sort pattern where a whole container
  reorders every tick.
- `type_query_benchmark.dart`: maintenance and read cost of the
  `register<T>()`/`query<T>()` type-query caches under mixed-type churn.
- `update_components_benchmark.dart`: end-to-end update pass with game-like
  logic and inputs on a two-level tree.
- `render_components_benchmark.dart`: render pass over a randomized tree onto
  a mock canvas.
- `components_at_point_benchmark.dart`: pointer hit testing
  (`componentsAtPoint`) with and without the hit-test cache.
- `collision_detection_benchmark.dart`: the collision detection system with
  flat and nested hitbox hierarchies.


## Writing benchmarks

- Mount the game with `mountGame` from `common.dart`. A `FlameGame` that is
  never resized, loaded, and mounted skips `onLoad` and bypasses the lifecycle
  queue entirely, silently benchmarking the wrong code path.
- Seed every `Random`, and precompute random sequences in `setup` when `run`
  needs them, so that each `run` invocation performs identical work.
- Keep per-run work small enough that the harness gets many samples within its
  measurement window (aim for well under ~100ms per `run`).
