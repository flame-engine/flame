import 'dart:ui';

import 'package:canvas_test/canvas_test.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FixedResolutionViewport', () {
    testWithFlameGame(
      'fixed ratio viewport has perfect ratio',
      (game) async {
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
      },
    );

    testWithFlameGame(
      'fixed ratio viewport maxes width',
      (game) async {
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
      },
    );

    testWithFlameGame(
      'fixed ratio viewport maxes height',
      (game) async {
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
      },
    );
  });
}

class _TestComponent extends PositionComponent {
  _TestComponent(Vector2 position)
      : super(position: position, size: Vector2.all(1.0));

  @override
  void render(Canvas canvas) {
    canvas.drawRect(size.toRect(), Paint());
  }
}
