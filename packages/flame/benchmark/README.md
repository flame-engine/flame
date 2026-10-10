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
release-representative numbers, a suite needs to run as an app in a profile or
release build. This package has no platform runner, so the app runs from the
`examples` directory, which has a macOS one. `raycast_benchmark_app.dart` does
this for `raycast_benchmark.dart`, printing the same table and exiting:

```console
cd examples
flutter build macos --release -t ../packages/flame/benchmark/raycast_benchmark_app.dart
build/macos/Build/Products/Release/examples.app/Contents/MacOS/examples
```

Running the binary prints the table straight to the terminal, and the app exits
when it is done. Use `--profile` instead of `--release` for a profile build.

Note that `flutter test` prints `No tests ran` at the end; that is expected,
the benchmark results are printed above it.


## Measuring allocations

The time per ray does not tell how much is allocated, and the allocations of
AOT code differ from the ones of `flutter test`. The tool
`tool/measure_raycast_allocations.dart` measures what `raycast` allocates, in a
profile build, with no manual steps:

```console
dart run benchmark/tool/measure_raycast_allocations.dart
```

It runs `raycast_allocation_app.dart` from the `examples` directory with
`flutter run --machine`, connects to the VM service of the app, and for each
case asks the app, through the service extension `ext.flame.raycast` that it
registers, to build a scene and cast rays against it. The objects per ray are
counted by tracing the allocations of the classes that a raycast allocates,
and the time per ray is measured by the app without tracing. The options of
the tool, like the device, the number of timings and a filter on the cases,
are documented at the top of the file. The first run makes a profile build,
which takes minutes. To compare a change, run it on both branches.


## Suites

- `children_traversal_benchmark.dart`: pure update-pass and render-pass
  overhead (container iteration, recursion) over wide, nested, and deep trees
  of no-op components, plus a barrier-dense tree where a fraction of the
  parents override `updateTree`.
- `update_workload_benchmark.dart`: the wide and nested trees from the
  traversal suite, but with every component running a realistic `update`
  body (light: bullet-style movement, heavy: seek-nearest-target steering),
  to put the framework overhead in proportion to actual game logic.
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
- `path_collision_benchmark.dart`: the collision detection system with a
  hitbox sampled from a `Path` contour against circles, rectangles, polygons,
  and itself, next to the same scenes with a hand-written polygon of the same
  shape. The polygon scenes also run on main, so a branch that adds `Path`
  hitboxes can be compared against it.
- `path_contour_benchmark.dart`: a standalone report, not part of `main.dart`,
  that compares hitboxes built from sampled `Path` contours with a
  hand-written polygon: vertex counts and sampling error, per-ray intersection
  cost, agreement of the inside-hitbox test with `Path.contains` on concave
  shapes, the effect of the simplification tolerance of `walkContours` next to
  the samples before they are simplified, and polygon-polygon intersection
  cost.
- `image_contour_benchmark.dart`: a standalone suite, not part of
  `main.dart`, that measures tracing the outlines of images with
  `ImageExtension.contourFromPixels`, including a transparent image for the
  scan of the pixels alone, splitting stars of growing size with
  `convexPieces`, and the whole way from the pixels to the convex pieces.
- `ray_intersection_benchmark.dart`: `rayIntersection` on polygon hitboxes
  that are sampled from a concave and from a convex `Path` contour, with one
  precomputed ray for each hitbox in every tick.
- `raycast_benchmark.dart`: `raycast` in a static and in a rotating scene of
  simple, polygon, path and mixed hitboxes, printing the time per ray.
  `raycast_benchmark_app.dart` runs it in a profile or release build.
- `raycast_allocation_app.dart`: not a suite, but the app that
  `tool/measure_raycast_allocations.dart` runs in a profile build to count
  the allocations of `raycast`, see "Measuring allocations" above. It only
  registers a service extension that casts rays against a scene from
  `raycast_scene.dart`.
- `tool/measure_raycast_allocations.dart`: the tool that drives that app and
  prints the objects and the time per ray for each case, and can also show
  which stacks allocate the objects of a class.
- `transform2d_benchmark.dart`: the `Transform2D` hot paths: matrix
  recalculation after position and angle changes, point conversion, matrix
  assignment, and copying transforms.


## Writing benchmarks

- Mount the game with `mountGame` from `common.dart`. A `FlameGame` that is
  never resized, loaded, and mounted skips `onLoad` and bypasses the lifecycle
  queue entirely, silently benchmarking the wrong code path.
- Seed every `Random`, and precompute random sequences in `setup` when `run`
  needs them, so that each `run` invocation performs identical work.
- Keep per-run work small enough that the harness gets many samples within its
  measurement window (aim for well under ~100ms per `run`).
