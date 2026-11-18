# flame_3d scene benchmark

A benchmark of what rendering a `Scene3DComponent` costs, in a scene shaped
like a board game's 3D layer over a 2D world:

- about 200 instanced objects of twelve kinds, four or five surfaces each,
  drawn with ten `StylizedMaterial`s (MatCap tiers, a metallic MatCap,
  model-space wind, emission, accents, a color grade);
- unique translucent parts and additive glows, each with a mesh of its own;
- 8 skinned characters with 16 joints, animated every frame;
- a sun that casts soft shadows onto the objects and onto a
  `ShadowCatcherMaterial` ground;
- 3 particle systems (smoke, sparks, dust), a few hundred particles;
- a hemisphere light and 8 point lights, 3 of which shine;
- 4x MSAA, and a 2D camera that pans and zooms, so that the layer renders
  every frame.

`scene_benchmark.dart` builds the scene (`BenchmarkGame`),
`benchmark_runner.dart` measures it, and `scene_benchmark_test.dart` runs it
under `flutter test`.


## Running it under `flutter test`

From `packages/flame_3d`:

```sh
flutter test --enable-impeller --enable-flutter-gpu --enable-vmservice \
  --dart-define=FLAME_3D_PROFILE=true \
  benchmark/scene_benchmark_test.dart
```

It prints, per frame:

- the CPU time of the update and of the layer's render (median, mean, p90,
  min), each frame waiting for the GPU to finish the previous one as a frame
  paced by the display would;
- with `--dart-define=FLAME_3D_PROFILE=true`, the time of each phase of the
  render (`RenderPhase`: traversal, culling, recording, particles, sort,
  batching, state, `Material.apply`, pass uniforms, uploads, bindings,
  instance gathering, draw calls, pass begin and end, the shadow pass apart).
  Timing costs a little; compare totals with a run without the define;
- with `--enable-vmservice`, the objects the layer's render allocates per
  frame, by class (the frames rendered with the layer off are subtracted).
  The VM's allocation counters are approximate (a class allocated twice per
  frame can show anywhere from a fraction to more than that): read them as
  which classes allocate, not as exact counts;
- the `RenderStats` of the last frame;
- whole frames at a phone's resolution (390x844 at a pixel ratio of 3),
  waiting for the GPU: on the software Vulkan of `flutter test`, a rough
  proxy of the GPU's work.

`flutter test` runs the Dart code in JIT, with assertions, on a software
GPU: compare its numbers with each other, not with a device.

| Define               | Default | Meaning                                               |
| -------------------- | ------- | ----------------------------------------------------- |
| `BENCH_MODE`         | `all`   | `cpu`, `alloc` (CPU and allocations), `gpu`, or `all` |
| `BENCH_FRAMES`       | `600`   | measured frames                                       |
| `BENCH_WARMUP`       | `400`   | frames rendered before measuring                      |
| `BENCH_GPU_FRAMES`   | `24`    | whole frames timed at a phone's resolution            |
| `BENCH_RENDER_SCALE` | `1`     | the layer's render scale for those frames             |
| `BENCH_OBJECTS`      | `200`   | instanced objects                                     |
| `BENCH_TRIANGLES`    | `1`     | triangles per object, times about 600                 |
| `BENCH_SHADOWS`      | `true`  | whether the sun casts shadows                         |
| `BENCH_OUT`          |         | a file to write the results to, as JSON               |
| `FLAME_3D_PROFILE`   | `false` | time the renderer's phases (`RenderProfile`)          |


## Running it in an AOT build

The numbers that matter come from an AOT (profile) build on a real GPU. On
macOS, make an app outside of the repository that depends on this checkout:

```sh
flutter create --platforms=macos --project-name flame3d_profile profile_app
cd profile_app
ln -s <path to>/packages/flame_3d/benchmark lib/bench
```

- `pubspec.yaml`: path dependencies on `packages/flame` and
  `packages/flame_3d` (and a `dependency_overrides` entry for `flame`).
- `macos/Runner/Info.plist`: `FLTEnableImpeller` and `FLTEnableFlutterGPU`
  set to `true`; `LSUIElement` set to `true` keeps the app out of the Dock.
- `macos/Runner/MainFlutterWindow.swift`: a 390 by 844 window with an
  `alphaValue` of `0` and `ignoresMouseEvents`, so that nothing shows.
- `macos/Runner/*.entitlements`: `com.apple.security.app-sandbox` set to
  `false`, for the allocation counts (the VM service) and `BENCH_OUT`.
- `lib/main.dart`:

  ```dart
  Future<void> main() async {
    WidgetsFlutterBinding.ensureInitialized();
    await GpuBackend.initialize();
    final game = BenchmarkGame(BenchmarkRun.config);
    runApp(GameWidget(game: game));
    while (!game.isLoaded || !game.layer.isMounted) {
      await Future<void>.delayed(const Duration(milliseconds: 50));
    }
    game.pauseEngine();
    final run = BenchmarkRun();
    await run.cpu(game);
    await run.allocations(game);
    await run.gpu(game);
    run.save();
    exit(0);
  }
  ```

Then build and run it, with the same defines:

```sh
flutter build macos --profile --dart-define=FLAME_3D_PROFILE=true
app=build/macos/Build/Products/Profile/flame3d_profile.app
$app/Contents/MacOS/flame3d_profile
```
