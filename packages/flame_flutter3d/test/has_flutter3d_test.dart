/// A Flame game that owns its 3D world: opened on a device, built once, and
/// hosted by `Flutter3dFlameWidget` with nothing but the game.
library;

import 'package:flame/game.dart';
import 'package:flame_flutter3d/flame_flutter3d.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter/material.dart' hide Material;
import 'package:flutter3d/flutter3d.dart' hide Material;
import 'package:flutter3d_app/flutter3d_app.dart'
    show DidNotStart, SceneSurface;
import 'package:flutter3d_cpu/flutter3d_cpu.dart';
import 'package:flutter_test/flutter_test.dart';

final class _World extends FlameGame with HasFlutter3d {
  int built = 0;
  Renderer? handed;
  final SceneNode floor = SceneNode(name: 'floor');

  @override
  void onOpen3d() {
    built++;
    scene.add(floor);
  }

  @override
  void onRenderer3d(Renderer renderer) {
    // What the world built is there to be given the renderer.
    expect(built, closed + 1);
    handed = renderer;
  }

  int closed = 0;

  @override
  void onClose3d() {
    closed++;
    floor.removeFromParent();
  }
}

final class _Broken extends FlameGame with HasFlutter3d {
  @override
  void onOpen3d() => throw StateError('no river today');
}

Widget _shown(FlameGame game) =>
    MaterialApp(home: Flutter3dFlameWidget(game: game, width: 32, height: 24));

CpuDevice _device() => CpuDevice(
  width: 32,
  height: 24,
  shaders: CpuShaderLibrary(builtinCpuShaders()),
);

void main() {
  test('opened before it is loaded, it builds once it has loaded', () async {
    final game = _World()..open3d(_device());
    expect(game.built, 0, reason: 'nothing to build a game on yet');
    await initializeGame(() => game);
    expect(game.built, 1);
    expect(game.scene.cameras, contains(game.camera3d));
    expect(game.floor.parent, isNotNull);
  });

  test('opened after it is loaded, it builds at once, and only once', () async {
    final game = await initializeGame(_World.new);
    expect(game.has3d, isFalse);
    expect(() => game.scene, throwsStateError);

    game.open3d(_device());
    expect(game.built, 1);
    expect(() => game.open3d(_device()), throwsStateError);
    expect(game.built, 1);
  });

  test('its background lets the 3D layer through', () {
    expect(_World().backgroundColor().a, 0.0);
  });

  testWidgets('the widget hosts it with nothing but the game', (tester) async {
    final device = _device();
    final renderer = Renderer.create(device: device);
    final game = _World();

    await tester.pumpWidget(
      MaterialApp(
        home: Flutter3dFlameWidget(
          game: game,
          existing: (device: device, renderer: renderer),
        ),
      ),
    );
    await tester.pump();

    expect(game.device, same(device));
    expect(game.handed, same(renderer));
    expect(game.built, 1);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  test(
    'a renderer handed over before it is loaded waits for the world',
    () async {
      // The widget's order: the device opens, the renderer is made, and only
      // then does Flame load the game.
      final device = _device();
      final renderer = Renderer.create(device: device);
      final game = _World()
        ..open3d(device)
        ..attachRenderer(renderer);
      expect(game.handed, isNull);
      await initializeGame(() => game);
      expect(game.handed, same(renderer));
    },
  );

  testWidgets('shown again, it draws the world it kept', (tester) async {
    // A tab that comes back: Flame keeps the game's components, and the
    // world built on the device has to stay with them.
    //
    // Mutation: close the device the widget opened when the widget goes.
    final game = _World();
    await tester.pumpWidget(_shown(game));
    await tester.pump();
    final device = game.device;
    final scene = game.scene;
    final renderer = game.handed;
    expect(renderer, isNotNull);

    await tester.pumpWidget(const SizedBox());
    expect(game.has3d, isTrue, reason: 'the world goes with the game');

    await tester.pumpWidget(_shown(game));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 16));
    expect(game.built, 1, reason: 'built once, shown twice');
    expect(game.device, same(device));
    expect(game.scene, same(scene));
    expect(game.handed, same(renderer));
    final surface = tester.widget<SceneSurface>(find.byType(SceneSurface));
    expect(
      surface.renderer,
      same(renderer),
      reason: 'drawn by the renderer its world was handed',
    );
    expect(tester.takeException(), isNull);
    game.close3d();
  });

  testWidgets('closed, it builds its world afresh the next time it is '
      'shown', (tester) async {
    final game = _World();
    await tester.pumpWidget(_shown(game));
    await tester.pump();
    await tester.pumpWidget(const SizedBox());
    game.close3d();
    expect(game.has3d, isFalse);
    expect(game.closed, 1);
    expect(game.floor.parent, isNull);

    await tester.pumpWidget(_shown(game));
    await tester.pump();
    expect(game.built, 2);
    expect(game.scene.cameras, contains(game.camera3d));
    game.close3d();
  });

  testWidgets('another game handed in gets a world of its own', (tester) async {
    // Mutation: keep the state across a change of game.
    final first = _World();
    final second = _World();
    await tester.pumpWidget(_shown(first));
    await tester.pump();
    await tester.pumpWidget(_shown(second));
    await tester.pump();

    expect(second.built, 1);
    final surface = tester.widget<SceneSurface>(find.byType(SceneSurface));
    expect(surface.scene, same(second.scene));
    expect(surface.scene, isNot(same(first.scene)));
    first.close3d();
    second.close3d();
  });

  testWidgets('a world that throws while it is built says why', (tester) async {
    // Mutation: build the GameWidget without an error builder.
    final game = _Broken();
    await tester.pumpWidget(_shown(game));
    await tester.pump();
    await tester.pump();
    expect(find.byType(DidNotStart), findsOneWidget);
    expect(find.textContaining('no river today'), findsWidgets);
    game.close3d();
  });

  testWidgets('a split screen draws its second view beside the first', (
    tester,
  ) async {
    // The renderer drew several views and the surface was handed one.
    //
    // Mutation: hand the surface the game's camera alone.
    final game = _World();
    await tester.pumpWidget(_shown(game));
    await tester.pump();
    final second = CameraNode(name: 'player two');
    game.scene.add(second);
    game
      ..viewport3d = const ViewportRect(0.0, 0.0, 0.5, 1.0)
      ..moreViews3d.add(
        RenderView(
          camera: second,
          viewportFraction: const ViewportRect(0.5, 0.0, 0.5, 1.0),
        ),
      );
    game.update(1 / 60);
    await tester.pump();
    await tester.pump();

    final surface = tester.widget<SceneSurface>(find.byType(SceneSurface));
    expect(surface.moreViews.single.camera, same(second));
    expect(surface.view.viewportFraction.width, 0.5);
    expect(tester.takeException(), isNull);
    game.close3d();
  });

  testWidgets('paused, it is drawn again when asked', (tester) async {
    // A pause menu that changes the sky: nothing ticks, so nothing drew it.
    //
    // Mutation: leave redraw3d unconnected.
    final game = _World();
    await tester.pumpWidget(_shown(game));
    await tester.pump();
    game.pauseEngine();
    // The last tick's redraw lands a frame or two after it.
    for (var i = 0; i < 3; i++) {
      await tester.pump(const Duration(milliseconds: 16));
    }
    final before = tester.widget<SceneSurface>(find.byType(SceneSurface));
    await tester.pump(const Duration(milliseconds: 16));
    expect(
      tester.widget<SceneSurface>(find.byType(SceneSurface)),
      same(before),
      reason: 'a paused game is not redrawn by itself',
    );

    game.redraw3d();
    await tester.pump();
    await tester.pump();
    expect(
      tester.widget<SceneSurface>(find.byType(SceneSurface)),
      isNot(same(before)),
    );
    game.close3d();
  });
}
