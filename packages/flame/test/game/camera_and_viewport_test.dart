import 'dart:ui' show Paint;

import 'package:canvas_test/canvas_test.dart';
import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flame_test/flame_test.dart';
import 'package:test/test.dart';

class _TestComponent extends PositionComponent {
  static final Paint _paint = Paint();

  _TestComponent(Vector2 position)
      : super(
          position: position,
          size: Vector2.all(1.0),
        );

  @override
  void render(Canvas c) {
    c.drawRect(size.toRect(), _paint);
  }
}

void main() {
  group('widget', () {
    flameGame.test(
      'viewport does not affect component with PositionType.widget',
      (game) async {
        game.camera.viewport = FixedResolutionViewport(Vector2.all(50));
        game.onGameResize(Vector2.all(200.0));
        await game.ensureAdd(
          _TestComponent(Vector2.zero())..positionType = PositionType.widget,
        );

        final canvas = MockCanvas();
        game.render(canvas);
        expect(
          canvas,
          MockCanvas()
            ..translate(0, 0) // transform in PositionComponent.renderTree
            ..drawRect(const Rect.fromLTWH(0, 0, 1, 1)),
        );
      },
    );

    flameGame.test(
      'camera does not affect component with PositionType.widget',
      (game) async {
        await game.ensureAdd(
          _TestComponent(Vector2.zero())..positionType = PositionType.widget,
        );
        game.camera.snapTo(Vector2(100, 100));

        final canvas = MockCanvas();
        game.render(canvas);
        expect(
          canvas,
          MockCanvas()
            ..translate(0, 0) // transform in PositionComponent.renderTree
            ..drawRect(const Rect.fromLTWH(0, 0, 1, 1)),
        );
      },
    );
  });

  group('viewport', () {
    flameGame.test('default viewport does not change size', (game) {
      game.onGameResize(Vector2(100.0, 200.0));
      expect(game.canvasSize, Vector2(100.0, 200.00));
      expect(game.size, Vector2(100.0, 200.00));
    });

    flameGame.test('fixed ratio viewport has perfect ratio', (game) async {
      game.camera.viewport = FixedResolutionViewport(Vector2.all(50));
      game.onGameResize(Vector2.all(200.0));
      expect(game.canvasSize, Vector2.all(200.00));
      expect(game.size, Vector2.all(50.00));

      final viewport = game.camera.viewport as FixedResolutionViewport;
      expect(viewport.resizeOffset, Vector2.zero());
      expect(viewport.scaledSize, Vector2(200.0, 200.0));
      expect(viewport.scale, 4.0);

      await game.ensureAdd(_TestComponent(Vector2.zero()));

      final canvas = MockCanvas();
      game.render(canvas);
      expect(
        canvas,
        MockCanvas()
          ..clipRect(const Rect.fromLTWH(0, 0, 200, 200))
          ..scale(4)
          ..drawRect(const Rect.fromLTWH(0, 0, 1, 1))
          ..translate(0, 0), // reset camera
      );
    });

    flameGame.test('fixed ratio viewport maxes width', (game) async {
      game.camera.viewport = FixedResolutionViewport(Vector2.all(50));
      game.onGameResize(Vector2(100.0, 200.0));
      expect(game.canvasSize, Vector2(100.0, 200.00));
      expect(game.size, Vector2.all(50.00));

      final viewport = game.camera.viewport as FixedResolutionViewport;
      expect(viewport.resizeOffset, Vector2(0, 50.0));
      expect(viewport.scaledSize, Vector2(100.0, 100.0));
      expect(viewport.scale, 2.0);

      await game.ensureAdd(_TestComponent(Vector2.zero()));

      final canvas = MockCanvas();
      game.render(canvas);
      expect(
        canvas,
        MockCanvas()
          ..clipRect(const Rect.fromLTWH(0, 50, 100, 100))
          ..translate(0, 50)
          ..scale(2)
          ..drawRect(const Rect.fromLTWH(0, 0, 1, 1))
          ..translate(0, 0), // reset camera
      );
    });

    flameGame.test('fixed ratio viewport maxes height', (game) async {
      game.camera.viewport = FixedResolutionViewport(Vector2(100.0, 400.0));
      game.onGameResize(Vector2(100.0, 200.0));
      expect(game.canvasSize, Vector2(100.0, 200.00));
      expect(game.size, Vector2(100.00, 400.0));

      final viewport = game.camera.viewport as FixedResolutionViewport;
      expect(viewport.resizeOffset, Vector2(25.0, 0));
      expect(viewport.scaledSize, Vector2(50.0, 200.0));
      expect(viewport.scale, 0.5);

      await game.ensureAdd(_TestComponent(Vector2.zero()));

      final canvas = MockCanvas();
      game.render(canvas);
      expect(
        canvas,
        MockCanvas()
          ..clipRect(const Rect.fromLTWH(25, 0, 50, 200))
          ..translate(25, 0)
          ..scale(0.5)
          ..drawRect(const Rect.fromLTWH(0, 0, 1, 1))
          ..translate(0, 0), // reset camera
      );
    });
  });

  group('camera', () {
    flameGame.test('default camera applies no translation', (game) async {
      game.onGameResize(Vector2.all(100.0));
      expect(game.camera.position, Vector2.zero());

      await game.ensureAdd(_TestComponent(Vector2.all(10.0)));

      final canvas = MockCanvas();
      game.render(canvas);
      expect(
        canvas,
        MockCanvas()
          ..translate(10, 10)
          ..drawRect(const Rect.fromLTWH(0, 0, 1, 1))
          ..translate(0, 0), // reset camera
      );
    });

    flameGame.test('camera snap movement', (game) async {
      game.onGameResize(Vector2.all(100.0));
      expect(game.camera.position, Vector2.zero());

      await game.ensureAdd(_TestComponent(Vector2.all(10.0)));

      // this puts the top left of the screen on (4,4)
      game.camera.moveTo(Vector2.all(4.0));
      game.camera.snap();
      // the component will now be at 10 - 4 = (6, 6)
      expect(game.camera.position, Vector2.all(4.0));

      final canvas = MockCanvas();
      game.render(canvas);
      expect(
        canvas,
        MockCanvas()
          ..translate(-4, -4) // Camera translation
          ..translate(10, 10) // PositionComponent translation
          ..drawRect(const Rect.fromLTWH(0, 0, 1, 1))
          ..translate(0, 0), // reset camera
      );
    });

    flameGame.test('camera smooth movement', (game) {
      game.onGameResize(Vector2.all(100.0));

      game.camera.speed = 1; // 1 pixel per second
      game.camera.moveTo(Vector2(0.0, 10.0));

      // nothing should change yet
      expect(game.camera.position, Vector2.all(0.0));
      game.update(2.0); // 2s
      expect(game.camera.position, Vector2(0.0, 2.0));
      game.update(5.0); // 5s
      expect(game.camera.position, Vector2(0.0, 7.0));
      game.update(100.0); // more than needed at once
      expect(game.camera.position, Vector2(0.0, 10.0));
    });

    flameGame.test('camera follow', (game) async {
      game.onGameResize(Vector2.all(100.0));

      final p = _TestComponent(Vector2.all(10.0))..anchor = Anchor.center;
      await game.ensureAdd(p);
      game.camera.followComponent(p);

      expect(game.camera.position, Vector2.all(0.0));
      p.position.setValues(10.0, 20.0);
      // follow happens immediately because the object's movement is assumed to
      // be smooth.
      game.update(0);
      // (10,20) - half screen (50,50).
      expect(game.camera.position, Vector2(-40, -30));

      final canvas = MockCanvas();
      game.render(canvas);
      expect(
        canvas,
        MockCanvas()
          ..translate(40, 30) // Camera translation
          ..translate(9.5, 19.5) // PositionComponent translation
          ..drawRect(const Rect.fromLTWH(0, 0, 1, 1))
          ..translate(0, 0), // reset camera
        // result: 50 - w/2, 50 - h/2 (perfectly centered)
      );
    });

    flameGame.test('camera follow with relative position', (game) async {
      game.onGameResize(Vector2.all(100.0));

      final p = _TestComponent(Vector2.all(10.0))..anchor = Anchor.center;
      await game.ensureAdd(p);
      // this would be a typical vertical shoot-em-up
      game.camera.followComponent(p, relativeOffset: const Anchor(0.5, 0.8));

      expect(game.camera.position, Vector2.all(0.0));
      p.position.setValues(600.0, 2000.0);
      // follow happens immediately because the object's movement is assumed to
      // be smooth.
      game.update(0);
      // (600,2000) - fractional screen (50,80)
      expect(game.camera.position, Vector2(550, 1920));

      final canvas = MockCanvas();
      game.render(canvas);
      expect(
        canvas,
        MockCanvas()
          ..translate(-550, -1920) // Camera translation
          ..translate(599.5, 1999.5) // PositionComponent translation
          ..drawRect(const Rect.fromLTWH(0, 0, 1, 1))
          ..translate(0, 0), // reset camera
      );
    });
    flameGame.test('camera follow with world boundaries', (game) async {
      game.onGameResize(Vector2.all(100.0));

      final p = _TestComponent(Vector2.all(10.0))..anchor = Anchor.center;
      await game.ensureAdd(p);
      game.camera.followComponent(
        p,
        worldBounds: const Rect.fromLTWH(-1000, -1000, 2000, 2000),
      );

      p.position.setValues(600.0, 700.0); // well within bounds
      game.update(0);
      expect(game.camera.position, Vector2(550, 650));

      // x ok, y starts to get to bounds
      p.position.setValues(600.0, 950.0); // right on the edge
      game.update(0);
      expect(game.camera.position, Vector2(550, 900));

      p.position.setValues(600.0, 950.0); // stop advancing
      game.update(0);
      expect(game.camera.position, Vector2(550, 900));

      p.position.setValues(-1100.0, 950.0);
      game.update(0);
      expect(game.camera.position, Vector2(-1000, 900));

      p.position.setValues(1000.0, 1000.0);
      game.update(0);
      expect(game.camera.position, Vector2(900, 900));
    });

    flameGame.test(
      'camera follow with world boundaries smaller than the screen',
      (game) async {
        game.onGameResize(Vector2.all(200.0));

        final p = _TestComponent(Vector2.all(10.0))..anchor = Anchor.center;
        await game.ensureAdd(p);
        game.camera.followComponent(
          p,
          worldBounds: const Rect.fromLTWH(0, 0, 100, 100),
        );

        // In this case the camera will just center the world, no matter the
        // player position.
        game.update(0);
        expect(game.camera.position, Vector2(50, 50));

        p.position.setValues(60.0, 50.0);
        game.update(0);
        expect(game.camera.position, Vector2(50, 50));

        p.position.setValues(-10.0, -20.0);
        game.update(0);
        expect(game.camera.position, Vector2(50, 50));
      },
    );

    flameGame.test('camera relative offset without follow', (game) {
      game.onGameResize(Vector2.all(200.0));

      game.camera.setRelativeOffset(Anchor.center);

      game.update(0);
      expect(game.camera.position, Vector2.zero());

      game.update(10000);
      expect(game.camera.position, Vector2.all(-100.0));
    });

    flameGame.test('camera zoom', (game) async {
      game.onGameResize(Vector2.all(200.0));
      game.camera.zoom = 2;

      final p = _TestComponent(Vector2.all(100.0))..anchor = Anchor.center;
      await game.ensureAdd(p);

      final canvas = MockCanvas();
      game.render(canvas);
      expect(
        canvas,
        MockCanvas()
          ..scale(2) // Camera zoom
          ..translate(99.5, 99.5) // PositionComponent translation
          ..drawRect(const Rect.fromLTWH(0, 0, 1, 1))
          ..translate(0, 0), // reset camera
      );
    });

    flameGame.test('camera zoom with setRelativeOffset', (game) {
      game.onGameResize(Vector2.all(200.0));
      game.camera.zoom = 2;
      game.camera.setRelativeOffset(Anchor.center);

      final p = _TestComponent(Vector2.all(100.0))..anchor = Anchor.center;
      game.add(p);
      game.update(10000);

      final canvas = MockCanvas();
      game.render(canvas);
      expect(
        canvas,
        MockCanvas()
          ..translate(100, 100) // camera translation
          ..scale(2) // camera zoom
          ..translate(99.5, 99.5) // position component
          ..drawRect(const Rect.fromLTWH(0, 0, 1, 1))
          ..translate(0, 0), // reset camera
      );
      expect(game.camera.position, Vector2.all(-50.0));
    });

    flameGame.test('camera shake should return to where it started', (game) {
      final camera = game.camera;
      game.onGameResize(Vector2.all(200.0));
      expect(camera.position, Vector2.zero());
      camera.shake(duration: 9000);
      game.update(5000);
      game.update(5000);
      game.update(5000);
      expect(camera.position, Vector2.zero());
    });
  });

  group('viewport & camera', () {
    flameGame.test(
      'default ratio viewport + camera with world boundaries',
      (game) async {
        final game = FlameGame()
          ..camera.viewport = FixedResolutionViewport(Vector2.all(100));
        game.onGameResize(Vector2.all(200.0));
        expect(game.canvasSize, Vector2.all(200.00));
        expect(game.size, Vector2.all(100.00));

        final p = _TestComponent(Vector2.all(10.0))..anchor = Anchor.center;
        await game.ensureAdd(p);
        game.camera.followComponent(
          p,
          // this could be a typical mario-like platformer, where the player is
          // more on the bottom left to allow the scenario to be seem
          relativeOffset: const Anchor(0.25, 0.25),
          worldBounds: const Rect.fromLTWH(0, 0, 1000, 1000),
        );

        game.update(0);
        expect(game.camera.position, Vector2(0, 0));

        p.position.setValues(30.0, 0.0);
        game.update(0);
        expect(game.camera.position, Vector2(5, 0));

        p.position.setValues(30.0, 100.0);
        game.update(0);
        expect(game.camera.position, Vector2(5, 75));

        p.position.setValues(30.0, 1000.0);
        game.update(0);
        expect(game.camera.position, Vector2(5, 900));

        p.position.setValues(950.0, 20.0);
        game.update(0);
        expect(game.camera.position, Vector2(900, 0));
      },
    );
  });
}
