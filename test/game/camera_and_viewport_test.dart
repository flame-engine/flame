import 'package:flame/src/game/base_game.dart';
import 'package:flame/extensions.dart';
import 'package:flame/src/game/viewport.dart';

import 'package:test/test.dart';

import '../util/mock_canvas.dart';

void main() {
  group('viewport', () {
    test('default viewport does not change size', () {
      final game = BaseGame(); // default viewport
      game.onResize(Vector2(100.0, 200.0));
      expect(game.rawSize, Vector2(100.0, 200.00));
      expect(game.size, Vector2(100.0, 200.00));
    });
    test('fixed ratio viewport has perfect ratio', () {
      final game = BaseGame()..viewport = FixedRatioViewport(Vector2.all(50));
      game.onResize(Vector2.all(200.0));
      expect(game.rawSize, Vector2.all(200.00));
      expect(game.size, Vector2.all(50.00));

      final viewport = game.viewport as FixedRatioViewport;
      expect(viewport.resizeOffset, Vector2(0, 0));
      expect(viewport.scaledSize, Vector2(200.0, 200.0));
      expect(viewport.scale, 4.0);

      final canvas = MockCanvas();
      final expected = [
        'drawRect(Offset(0.0, 0.0), 200.0, 0.0)',
        'drawRect(Offset(0.0, 200.0), 200.0, 0.0)',
        'drawRect(Offset(200.0, 0.0), 0.0, 200.0)',
        'drawRect(Offset(0.0, 0.0), 0.0, 200.0)',
      ];
      game.render(canvas);
      expect(
        canvas.methodCalls.where((e) => e.startsWith('drawRect')),
        unorderedEquals(expected),
      );
      expect(
        canvas.methodCalls,
        contains('scale(4.0, 4.0)'),
      );
      expect(
        canvas.methodCalls,
        contains('translate(0.0, 0.0)'),
      );
    });
    test('fixed ratio viewport maxes width', () {
      final game = BaseGame()..viewport = FixedRatioViewport(Vector2.all(50));
      game.onResize(Vector2(100.0, 200.0));
      expect(game.rawSize, Vector2(100.0, 200.00));
      expect(game.size, Vector2.all(50.00));

      final viewport = game.viewport as FixedRatioViewport;
      expect(viewport.resizeOffset, Vector2(0, 50.0));
      expect(viewport.scaledSize, Vector2(100.0, 100.0));
      expect(viewport.scale, 2.0);

      final canvas = MockCanvas();
      final expected = [
        'drawRect(Offset(0.0, 0.0), 100.0, 50.0)',
        'drawRect(Offset(0.0, 150.0), 100.0, 50.0)',
        'drawRect(Offset(0.0, 0.0), 0.0, 200.0)',
        'drawRect(Offset(100.0, 0.0), 0.0, 200.0)',
      ];
      game.render(canvas);
      expect(
        canvas.methodCalls.where((e) => e.startsWith('drawRect')),
        unorderedEquals(expected),
      );
      expect(
        canvas.methodCalls,
        contains('scale(2.0, 2.0)'),
      );
      expect(
        canvas.methodCalls,
        contains('translate(0.0, 50.0)'),
      );
    });
    test('fixed ratio viewport maxes height', () {
      final game = BaseGame()
        ..viewport = FixedRatioViewport(Vector2(100.0, 400.0));
      game.onResize(Vector2(100.0, 200.0));
      expect(game.rawSize, Vector2(100.0, 200.00));
      expect(game.size, Vector2(100.00, 400.0));

      final viewport = game.viewport as FixedRatioViewport;
      expect(viewport.resizeOffset, Vector2(25.0, 0));
      expect(viewport.scaledSize, Vector2(50.0, 200.0));
      expect(viewport.scale, 0.5);

      final canvas = MockCanvas();
      final expected = [
        'drawRect(Offset(0.0, 0.0), 100.0, 0.0)',
        'drawRect(Offset(0.0, 200.0), 100.0, 0.0)',
        'drawRect(Offset(0.0, 0.0), 25.0, 200.0)',
        'drawRect(Offset(75.0, 0.0), 25.0, 200.0)',
      ];
      game.render(canvas);
      expect(
        canvas.methodCalls.where((e) => e.startsWith('drawRect')),
        unorderedEquals(expected),
      );
      expect(
        canvas.methodCalls,
        contains('scale(0.5, 0.5)'),
      );
      expect(
        canvas.methodCalls,
        contains('translate(25.0, 0.0)'),
      );
    });
  });
}
