import 'dart:ui' show Paint;

import 'package:flame/extensions.dart';
import 'package:flame/src/anchor.dart';
import 'package:flame/src/components/position_component.dart';
import 'package:flame/src/game/base_game.dart';
import 'package:flame/src/game/viewport.dart';
import 'package:test/test.dart';

import '../util/mock_canvas.dart';

class TestComponent extends PositionComponent {
  static final Paint _paint = Paint();

  TestComponent(Vector2 position)
      : super(
          position: position,
          size: Vector2.all(1.0),
        );

  @override
  void render(Canvas c) {
    super.render(c);
    c.drawRect(size.toRect(), _paint);
  }
}

void main() {
  group('viewport', () {
    test('default viewport does not change size', () {
      final game = BaseGame(); // default viewport
      game.onResize(Vector2(100.0, 200.0));
      expect(game.canvasSize, Vector2(100.0, 200.00));
      expect(game.size, Vector2(100.0, 200.00));
    });
    test('fixed ratio viewport has perfect ratio', () {
      final game = BaseGame()
        ..viewport = FixedResolutionViewport(Vector2.all(50));
      game.onResize(Vector2.all(200.0));
      expect(game.canvasSize, Vector2.all(200.00));
      expect(game.size, Vector2.all(50.00));

      final viewport = game.viewport as FixedResolutionViewport;
      expect(viewport.resizeOffset, Vector2.zero());
      expect(viewport.scaledSize, Vector2(200.0, 200.0));
      expect(viewport.scale, 4.0);

      final canvas = MockCanvas();
      game.render(canvas);
      expect(
        canvas.methodCalls.singleWhere((e) => e.startsWith('clipRect')),
        'clipRect(0.0, 0.0, 200.0, 200.0)',
      );
      expect(
        canvas.methodCalls,
        contains(
          'transform(4.0, 0.0, 0.0, 0.0, 0.0, 4.0, 0.0, 0.0, 0.0, 0.0, 4.0, 0.0, 0.0, 0.0, 0.0, 1.0)',
        ),
      );
    });
    test('fixed ratio viewport maxes width', () {
      final game = BaseGame()
        ..viewport = FixedResolutionViewport(Vector2.all(50));
      game.onResize(Vector2(100.0, 200.0));
      expect(game.canvasSize, Vector2(100.0, 200.00));
      expect(game.size, Vector2.all(50.00));

      final viewport = game.viewport as FixedResolutionViewport;
      expect(viewport.resizeOffset, Vector2(0, 50.0));
      expect(viewport.scaledSize, Vector2(100.0, 100.0));
      expect(viewport.scale, 2.0);

      final canvas = MockCanvas();
      game.render(canvas);
      expect(
        canvas.methodCalls.singleWhere((e) => e.startsWith('clipRect')),
        'clipRect(0.0, 50.0, 100.0, 100.0)',
      );
      expect(
        canvas.methodCalls,
        contains(
          'transform(2.0, 0.0, 0.0, 0.0, 0.0, 2.0, 0.0, 0.0, 0.0, 0.0, 2.0, 0.0, 0.0, 50.0, 0.0, 1.0)',
        ),
      );
    });
    test('fixed ratio viewport maxes height', () {
      final game = BaseGame()
        ..viewport = FixedResolutionViewport(Vector2(100.0, 400.0));
      game.onResize(Vector2(100.0, 200.0));
      expect(game.canvasSize, Vector2(100.0, 200.00));
      expect(game.size, Vector2(100.00, 400.0));

      final viewport = game.viewport as FixedResolutionViewport;
      expect(viewport.resizeOffset, Vector2(25.0, 0));
      expect(viewport.scaledSize, Vector2(50.0, 200.0));
      expect(viewport.scale, 0.5);

      final canvas = MockCanvas();
      game.render(canvas);
      expect(
        canvas.methodCalls.singleWhere((e) => e.startsWith('clipRect')),
        'clipRect(25.0, 0.0, 50.0, 200.0)',
      );
      expect(
        canvas.methodCalls,
        contains(
          'transform(0.5, 0.0, 0.0, 0.0, 0.0, 0.5, 0.0, 0.0, 0.0, 0.0, 0.5, 0.0, 25.0, 0.0, 0.0, 1.0)',
        ),
      );
    });
  });
  group('camera', () {
    test('default camera applies no translation', () {
      final game = BaseGame(); // no camera changes
      game.onResize(Vector2.all(100.0));
      expect(game.camera.position, Vector2.zero());

      final p = TestComponent(Vector2.all(10.0));
      game.add(p);
      game.update(0);

      final canvas = MockCanvas();
      game.render(canvas);
      expect(
        canvas.methodCalls.where(
          (e) => e.startsWith(RegExp('translate|transform')),
        ),
        [
          'transform(1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 1.0)', // camera translation
          'translate(10.0, 10.0)', // position component translation
          'translate(0.0, 0.0)', // position component anchor
        ],
      );
    });
    test('camera snap movement', () {
      final game = BaseGame(); // no camera changes
      game.onResize(Vector2.all(100.0));
      expect(game.camera.position, Vector2.zero());

      final p = TestComponent(Vector2.all(10.0));
      game.add(p);
      game.update(0);

      // this puts the top left of the screen on (4,4)
      game.camera.moveTo(Vector2.all(4.0));
      game.camera.snap();
      // the component will now be at 10 - 4 = (6, 6)
      expect(game.camera.position, Vector2.all(4.0));

      final canvas = MockCanvas();
      game.render(canvas);
      expect(
        canvas.methodCalls.where(
          (e) => e.startsWith(RegExp('translate|transform')),
        ),
        [
          'transform(1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, -4.0, -4.0, 0.0, 1.0)', // camera translation
          'translate(10.0, 10.0)', // position component translation
          'translate(0.0, 0.0)', // position component anchor
        ],
      );
    });
    test('camera smooth movement', () {
      final game = BaseGame(); // no camera changes
      game.onResize(Vector2.all(100.0));

      game.camera.cameraSpeed = 1; // 1 pixel per second
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
    test('camera follow', () {
      final game = BaseGame(); // no camera changes
      game.onResize(Vector2.all(100.0));

      final p = TestComponent(Vector2.all(10.0))..anchor = Anchor.center;
      game.add(p);
      game.update(0);
      game.camera.followComponent(p);

      expect(game.camera.position, Vector2.all(0.0));
      p.position.setValues(10.0, 20.0);
      // follow happens immediately because the object's movement is assumed to be smooth
      game.update(0);
      // (10,20) - half screen (50,50)
      expect(game.camera.position, Vector2(-40, -30));

      final canvas = MockCanvas();
      game.render(canvas);
      expect(
        canvas.methodCalls.where(
          (e) => e.startsWith(RegExp('translate|transform')),
        ),
        [
          'transform(1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 40.0, 30.0, 0.0, 1.0)', // camera translation
          'translate(10.0, 20.0)', // position component translation
          'translate(-0.5, -0.5)', // position component anchor
        ],
        // result: 50 - w/2, 50 - h/2 (perfectly centered)
      );
    });
    test('camera follow with relative position', () {
      final game = BaseGame(); // no camera changes
      game.onResize(Vector2.all(100.0));

      final p = TestComponent(Vector2.all(10.0))..anchor = Anchor.center;
      game.add(p);
      game.update(0);
      // this would be a typical vertical shoot-em-up
      game.camera.followComponent(p, relativeOffset: const Anchor(0.5, 0.8));

      expect(game.camera.position, Vector2.all(0.0));
      p.position.setValues(600.0, 2000.0);
      // follow happens immediately because the object's movement is assumed to be smooth
      game.update(0);
      // (600,2000) - fractional screen (50,80)
      expect(game.camera.position, Vector2(550, 1920));

      final canvas = MockCanvas();
      game.render(canvas);
      expect(
        canvas.methodCalls.where(
          (e) => e.startsWith(RegExp('translate|transform')),
        ),
        [
          'transform(1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, -550.0, -1920.0, 0.0, 1.0)', // camera translation
          'translate(600.0, 2000.0)', // position component translation
          'translate(-0.5, -0.5)', // position component anchor
        ],
        // result: 50 - w/2, 80 - h/2 (respects fractional relative offset)
      );
    });
    test('camera follow with world boundaries', () {
      final game = BaseGame(); // no camera changes
      game.onResize(Vector2.all(100.0));

      final p = TestComponent(Vector2.all(10.0))..anchor = Anchor.center;
      game.add(p);
      game.update(0);
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
    test('camera follow with world boundaries smaller than the screen', () {
      final game = BaseGame(); // no camera changes
      game.onResize(Vector2.all(200.0));

      final p = TestComponent(Vector2.all(10.0))..anchor = Anchor.center;
      game.add(p);
      game.update(0);
      game.camera.followComponent(
        p,
        worldBounds: const Rect.fromLTWH(0, 0, 100, 100),
      );

      // in this case the camera will just center the world, no matter the player position
      game.update(0);
      expect(game.camera.position, Vector2(50, 50));

      p.position.setValues(60.0, 50.0);
      game.update(0);
      expect(game.camera.position, Vector2(50, 50));

      p.position.setValues(-10.0, -20.0);
      game.update(0);
      expect(game.camera.position, Vector2(50, 50));
    });
    test('camera relative offset without follow', () {
      final game = BaseGame();
      game.onResize(Vector2.all(200.0));

      game.camera.setRelativeOffset(Anchor.center);

      game.update(0);
      expect(game.camera.position, Vector2.zero());

      game.update(10000);
      expect(game.camera.position, Vector2.all(-100.0));
    });
    test('camera zoom', () {
      final game = BaseGame();
      game.onResize(Vector2.all(200.0));
      game.camera.zoom = 2;

      final p = TestComponent(Vector2.all(100.0))..anchor = Anchor.center;
      game.add(p);
      game.update(0);

      final canvas = MockCanvas();
      game.render(canvas);
      expect(
        canvas.methodCalls.where(
          (e) => e.startsWith(RegExp('translate|transform|scale')),
        ),
        [
          'transform(2.0, 0.0, 0.0, 0.0, 0.0, 2.0, 0.0, 0.0, 0.0, 0.0, 2.0, 0.0, 0.0, 0.0, 0.0, 1.0)', // camera translation and zoom
          'translate(100.0, 100.0)', // position component
          'translate(-0.5, -0.5)', // anchor
        ],
      );
    });
    test('camera zoom with setRelativeOffset', () {
      final game = BaseGame();
      game.onResize(Vector2.all(200.0));
      game.camera.zoom = 2;
      game.camera.setRelativeOffset(Anchor.center);

      final p = TestComponent(Vector2.all(100.0))..anchor = Anchor.center;
      game.add(p);
      game.update(10000);

      final canvas = MockCanvas();
      game.render(canvas);
      expect(
        canvas.methodCalls.where(
          (e) => e.startsWith(RegExp('translate|transform|scale')),
        ),
        [
          'transform(2.0, 0.0, 0.0, 0.0, 0.0, 2.0, 0.0, 0.0, 0.0, 0.0, 2.0, 0.0, 100.0, 100.0, 0.0, 1.0)', // camera translation and zoom
          'translate(100.0, 100.0)', // position component
          'translate(-0.5, -0.5)', // anchor
        ],
      );
      expect(game.camera.position, Vector2.all(-50.0));
    });
    test('camera shake should return to where it started', () {
      final game = BaseGame();
      final camera = game.camera;
      game.onResize(Vector2.all(200.0));
      expect(camera.position, Vector2.zero());
      camera.shake(duration: 9000);
      game.update(5000);
      game.update(5000);
      game.update(5000);
      expect(camera.position, Vector2.zero());
    });
  });
  group('viewport & camera', () {
    test('default ratio viewport + camera with world boundaries', () {
      final game = BaseGame()
        ..viewport = FixedResolutionViewport(Vector2.all(100));
      game.onResize(Vector2.all(200.0));
      expect(game.canvasSize, Vector2.all(200.00));
      expect(game.size, Vector2.all(100.00));

      final p = TestComponent(Vector2.all(10.0))..anchor = Anchor.center;
      game.add(p);
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
    });
  });
}
