/// [Flutter3dFlameWidget] builds and ticks both layers without throwing.
///
/// **These were skipped as hanging, and do not hang.** A Flame
/// `GameWidget` under `flutter_test` was said to hang in this environment,
/// and the evidence was a test runner that ran for its whole timeout with
/// no output. Run with `flutter test` directly, both finish in seconds: the
/// runner, not Flame, was what stood still. With the skip in place the
/// package's own host widget had no test at all.
library;

import 'package:flame/game.dart';
import 'package:flame_flutter3d/flame_flutter3d.dart';
import 'package:flutter/material.dart' hide Material;
import 'package:flutter3d/flutter3d.dart' hide Material;
import 'package:flutter3d_app/flutter3d_app.dart' show SceneSurface;
import 'package:flutter3d_cpu/flutter3d_cpu.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('an empty game and an empty scene compose and tick', (
    tester,
  ) async {
    final camera = CameraNode(name: 'eye');
    var ticks = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Flutter3dFlameWidget(
          game: FlameGame(),
          camera: camera,
          buildScene: (device) => Scene(),
          onTick: (double dt) => ticks++,
          width: 32,
          height: 24,
        ),
      ),
    );
    await tester.pump();

    expect(find.byType(GameWidget<FlameGame>), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 16));

    expect(ticks, greaterThan(0));
  });

  testWidgets('an existing device and renderer are reused, not reopened', (
    tester,
  ) async {
    final device = CpuDevice(
      width: 32,
      height: 24,
      shaders: CpuShaderLibrary(builtinCpuShaders()),
    );
    final renderer = Renderer.create(device: device);
    final camera = CameraNode(name: 'eye');
    GraphicsDevice? seen;

    await tester.pumpWidget(
      MaterialApp(
        home: Flutter3dFlameWidget(
          game: FlameGame(),
          camera: camera,
          existing: (device: device, renderer: renderer),
          buildScene: (d) {
            seen = d;
            return Scene();
          },
        ),
      ),
    );
    await tester.pump();

    expect(seen, same(device), reason: 'no second device should open');
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('a rebuild with another camera draws through it', (tester) async {
    // A cut to a second camera, or a new sky, handed in from above: both
    // went into the view once and a rebuild changed nothing on screen.
    //
    // Mutation: build the view once, in initState.
    final device = CpuDevice(
      width: 32,
      height: 24,
      shaders: CpuShaderLibrary(builtinCpuShaders()),
    );
    final renderer = Renderer.create(device: device);
    final first = CameraNode(name: 'first');
    final second = CameraNode(name: 'second');
    final game = FlameGame();
    final scene = Scene();

    Widget host(CameraNode camera) => MaterialApp(
      home: Flutter3dFlameWidget(
        game: game,
        camera: camera,
        existing: (device: device, renderer: renderer),
        buildScene: (_) => scene,
      ),
    );

    await tester.pumpWidget(host(first));
    await tester.pumpWidget(host(second));
    await tester.pump();

    final surface = tester.widget<SceneSurface>(find.byType(SceneSurface));
    expect(surface.view.camera, same(second));
    expect(scene.cameras, contains(second));
  });

  testWidgets("Flame's overlays are shown over both layers", (tester) async {
    // A pause menu over the 3D layer needed a second Stack of the host's
    // own; the GameWidget already draws overlays, and was never given them.
    //
    // Mutation: build the GameWidget without the overlay map.
    final device = CpuDevice(
      width: 32,
      height: 24,
      shaders: CpuShaderLibrary(builtinCpuShaders()),
    );
    final renderer = Renderer.create(device: device);
    final camera = CameraNode();
    await tester.pumpWidget(
      MaterialApp(
        home: Flutter3dFlameWidget(
          game: FlameGame(),
          camera: camera,
          existing: (device: device, renderer: renderer),
          buildScene: (_) => Scene(),
          overlayBuilderMap: <String, OverlayWidgetBuilder<FlameGame>>{
            'pause': (context, game) => const Text('PAUSED'),
          },
          initialActiveOverlays: const <String>['pause'],
        ),
      ),
    );
    await tester.pump();
    expect(find.text('PAUSED'), findsOneWidget);
  });

  testWidgets('new overlay builders under the same names reach the screen '
      'without a new GameWidget', (tester) async {
    // A map written inline in a parent's build is new every rebuild, and a
    // new GameWidget for it had Flame update the game again from layout.
    //
    // Mutation: pass the config's map to GameWidget directly and keep it;
    // the overlay goes on saying "score 1".
    final device = CpuDevice(
      width: 32,
      height: 24,
      shaders: CpuShaderLibrary(builtinCpuShaders()),
    );
    final renderer = Renderer.create(device: device);
    final camera = CameraNode();
    final game = FlameGame();
    final scene = Scene();
    Widget host(int score) => MaterialApp(
      home: Flutter3dFlameWidget(
        game: game,
        camera: camera,
        existing: (device: device, renderer: renderer),
        buildScene: (_) => scene,
        overlayBuilderMap: <String, OverlayWidgetBuilder<FlameGame>>{
          'score': (context, game) => Text('score $score'),
        },
        initialActiveOverlays: const <String>['score'],
      ),
    );

    await tester.pumpWidget(host(1));
    await tester.pump();
    final before = tester.widget(find.byType(GameWidget<FlameGame>));
    expect(find.text('score 1'), findsOneWidget);

    await tester.pumpWidget(host(2));
    await tester.pump();
    expect(find.text('score 2'), findsOneWidget);
    expect(
      tester.widget(find.byType(GameWidget<FlameGame>)),
      same(before),
      reason: 'the same names keep the same GameWidget',
    );
  });

  testWidgets('a host that did not start does not tick a game another host '
      'is showing', (tester) async {
    // Its clock went into the game from its first build, and every update
    // then called both hosts' onTick.
    //
    // Mutation: add the clock before the host is ready.
    final device = CpuDevice(
      width: 32,
      height: 24,
      shaders: CpuShaderLibrary(builtinCpuShaders()),
    );
    final renderer = Renderer.create(device: device);
    final game = FlameGame();
    var shown = 0;
    var failed = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Column(
          children: <Widget>[
            Expanded(
              child: Flutter3dFlameWidget(
                game: game,
                camera: CameraNode(),
                existing: (device: device, renderer: renderer),
                buildScene: (_) => Scene(),
                onTick: (double _) => shown++,
              ),
            ),
            Expanded(
              child: Flutter3dFlameWidget(
                game: game,
                camera: CameraNode(),
                existing: (device: device, renderer: renderer),
                buildScene: (_) => throw StateError('no level'),
                onTick: (double _) => failed++,
              ),
            ),
          ],
        ),
      ),
    );
    for (var i = 0; i < 4; i++) {
      await tester.pump(const Duration(milliseconds: 16));
    }
    expect(shown, greaterThan(0));
    expect(failed, 0);
  });

  testWidgets('a host that goes lets go of the game it drew for', (
    tester,
  ) async {
    // Compared by `identical` against a fresh tear-off, which never is, the
    // game kept calling back into, and holding, the disposed host.
    //
    // Mutation: compare `owner.redrawer3d` with `_redraw` again.
    final device = CpuDevice(
      width: 32,
      height: 24,
      shaders: CpuShaderLibrary(builtinCpuShaders()),
    );
    final renderer = Renderer.create(device: device);
    final game = _Owned();
    await tester.pumpWidget(
      MaterialApp(
        home: Flutter3dFlameWidget(
          game: game,
          existing: (device: device, renderer: renderer),
          buildScene: (_) => Scene(),
        ),
      ),
    );
    await tester.pump();
    expect(game.redrawer3d, isNotNull);

    await tester.pumpWidget(const SizedBox());
    expect(game.redrawer3d, isNull);
  });
}

final class _Owned extends FlameGame with HasFlutter3d {}
