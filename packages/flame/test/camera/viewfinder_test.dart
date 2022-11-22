import 'dart:ui';

import 'package:canvas_test/canvas_test.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/experimental.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Viewfinder', () {
    testWithFlameGame(
      'default camera centers the view in canvas',
      (game) async {
        final world = World()..addToParent(game);
        final camera = CameraComponent(world: world)..addToParent(game);
        world.add(_Rect());
        await game.ready();
        expect(game.canvasSize, closeToVector(Vector2(800, 600)));
        expect(camera.viewfinder.position, closeToVector(Vector2(0, 0)));
        expect(camera.viewfinder.zoom, 1);

        // By default, the camera uses anchor=center, and places the world's
        // point (0,0) there. This means the camera applies default translation
        // of (400,300).
        final canvas = MockCanvas();
        game.render(canvas);
        expect(
          canvas,
          MockCanvas()
            ..translate(400, 300)
            ..drawRect(const Rect.fromLTWH(0, 0, 80, 60))
            ..translate(0, 0),
        );
      },
    );

    testWithFlameGame(
      'default camera centers on a given world point',
      (game) async {
        final world = World()..addToParent(game);
        final camera = CameraComponent(world: world)
          ..viewfinder.position = Vector2(100, -50)
          ..addToParent(game);
        world.add(_Rect());
        await game.ready();
        expect(camera.viewfinder.position, closeToVector(Vector2(100, -50)));

        final canvas = MockCanvas();
        game.render(canvas);
        expect(
          canvas,
          MockCanvas()
            ..translate(300, 350) // (800,600)/2 - (100,-50)
            ..drawRect(const Rect.fromLTWH(0, 0, 80, 60))
            ..translate(0, 0),
        );
      },
    );

    testWithFlameGame(
      'default camera apply zoom > 1',
      (game) async {
        final world = World()..addToParent(game);
        final camera = CameraComponent(world: world)
          ..viewfinder.zoom = 2
          ..addToParent(game);
        world.add(_Rect()..position = Vector2(20, 10));
        await game.ready();
        expect(camera.viewfinder.zoom, 2);

        final canvas = MockCanvas();
        game.render(canvas);
        expect(
          canvas,
          MockCanvas()
            ..translate(400, 300) // viewfinder translate
            ..scale(2)
            ..translate(20, 10) // rectangle translate
            ..drawRect(const Rect.fromLTWH(0, 0, 80, 60))
            ..translate(0, 0),
        );
      },
    );

    testWithFlameGame(
      'default camera with zoom > 1 and non-zero position',
      (game) async {
        final world = World()..addToParent(game);
        final camera = CameraComponent(world: world)
          ..viewfinder.zoom = 5
          ..viewfinder.position = Vector2(60, 40)
          ..addToParent(game);
        world.add(_Rect()..position = Vector2(20, 10));
        await game.ready();
        expect(camera.viewfinder.zoom, 5);

        final canvas = MockCanvas();
        game.render(canvas);
        expect(
          canvas,
          MockCanvas()
            ..translate(400, 300) // canvas center
            ..scale(5)
            ..translate(-60, -40) // viewfinder translate
            ..translate(20, 10) // rectangle translate
            ..drawRect(const Rect.fromLTWH(0, 0, 80, 60))
            ..translate(0, 0),
        );
      },
    );

    testWithFlameGame(
      'camera move effect',
      (game) async {
        final world = World()..addToParent(game);
        final camera = CameraComponent(world: world)..addToParent(game);
        camera.viewfinder.add(
          MoveEffect.by(Vector2(5, 13), EffectController(duration: 1)),
        );
        camera.viewport.add(
          MoveEffect.by(Vector2(40, -77), EffectController(duration: 1)),
        );
        await game.ready();

        for (var t = 0.0; t < 1.0; t += 0.1) {
          expect(
            camera.viewfinder.position,
            closeToVector(Vector2(5 * t, 13 * t), 1e-14),
          );
          expect(
            camera.viewport.position,
            closeToVector(Vector2(40 * t, -77 * t), 1e-12),
          );
          game.update(0.1);
        }
      },
    );

    testWithFlameGame(
      'default camera with non-central anchor and zoom',
      (game) async {
        final world = World()
          ..add(_Rect()..position = Vector2(20, 10))
          ..addToParent(game);
        CameraComponent(world: world)
          ..viewfinder.zoom = 2
          ..viewfinder.anchor = const Anchor(0.1, 0.7)
          ..addToParent(game);
        await game.ready();

        final canvas = MockCanvas();
        game.render(canvas);
        expect(
          canvas,
          MockCanvas()
            ..translate(800 * 0.1, 600 * 0.7) // viewfinder logical center
            ..scale(2) // zoom
            ..translate(20, 10) // rectangle translate
            ..drawRect(const Rect.fromLTWH(0, 0, 80, 60))
            ..translate(0, 0),
        );
      },
    );

    testWithFlameGame(
      'camera zoom effect',
      (game) async {
        final world = World()..addToParent(game);
        final camera = CameraComponent(world: world)..addToParent(game);
        camera.viewfinder.add(
          ScaleEffect.to(Vector2.all(2), EffectController(duration: 1)),
        );
        await game.ready();

        for (var t = 0.0; t < 1.0; t += 0.1) {
          expect(camera.viewfinder.zoom, closeTo(1 + t, 1e-14));
          game.update(0.1);
        }
      },
    );

    testWithFlameGame(
      'camera rotate effect',
      (game) async {
        final world = World()..addToParent(game);
        final camera = CameraComponent(world: world)..addToParent(game);
        camera.viewfinder.add(
          RotateEffect.by(1, EffectController(duration: 1)),
        );
        await game.ready();

        for (var t = 0.0; t < 1.0; t += 0.1) {
          expect(camera.viewfinder.angle, closeTo(t, 1e-15));
          game.update(0.1);
        }
      },
    );
  });
}

/// Simple rectangle with default size 80x60.
class _Rect extends PositionComponent {
  _Rect() : super(size: Vector2(80, 60));

  @override
  void render(Canvas canvas) {
    canvas.drawRect(size.toRect(), Paint());
  }
}
