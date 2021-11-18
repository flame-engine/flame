import 'dart:ui';

import 'package:canvas_test/canvas_test.dart';
import 'package:flame/components.dart';
import 'package:flame/palette.dart';
import 'package:flame_test/flame_test.dart';
import 'package:test/test.dart';

void main() {
  group('TextBoxComponent', () {
    test('size is properly computed', () async {
      final c = TextBoxComponent(
        text: 'The quick brown fox jumps over the lazy dog.',
        boxConfig: TextBoxConfig(
          maxWidth: 100.0,
        ),
      );

      expect(c.size.x, 100 + 2 * 8);
      expect(c.size.y, greaterThan(1));
    });

    flameGame.test('onLoad waits for cache to be done', (game) async {
      final c = TextBoxComponent(text: 'foo bar');

      await game.ensureAdd(c);

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
