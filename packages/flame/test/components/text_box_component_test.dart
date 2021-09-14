import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/palette.dart';
import 'package:flame/test.dart';
import 'package:test/test.dart';

void main() {
  group('text box component test', () {
    test('size is properly computed', () async {
      final c = TextBoxComponent(
        'The quick brown fox jumps over the lazy dog.',
        boxConfig: TextBoxConfig(
          maxWidth: 100.0,
        ),
      );

      expect(c.size.x, 100 + 2 * 8);
      expect(c.size.y, greaterThan(1));
    });
    test('onLoad waits for cache to be done', () async {
      final c = TextBoxComponent('foo bar');

      final game = FlameGame();
      game.onGameResize(Vector2.all(100));

      await game.add(c);
      game.update(0);

      final canvas = MockCanvas();
      game.render(canvas); // this should render the cache
      expect(
        canvas,
        MockCanvas(mode: AssertionMode.containsAnyOrder)
          ..drawImage(
            null,
            Offset.zero,
            BasicPalette.white.paint(),
          ),
      );
    });
  });
}
