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

    testWithFlameGame(
      'internal image is disposed when component is removed',
      (game) async {
        final c = TextBoxComponent(text: 'foo bar');

        await game.ensureAdd(c);
        final imageCache = c.cache;

        final canvas = MockCanvas();
        game.render(canvas);
        game.remove(c);
        game.update(0);
        expect(imageCache, isNotNull);
        expect(imageCache!.debugDisposed, isTrue);
        expect(c.cache, null);
      },
    );

    testWithFlameGame(
      'internal image is redrawn when component is re-added',
      (game) async {
        final c = TextBoxComponent(text: 'foo bar');

        await game.ensureAdd(c);
        game.remove(c);
        game.update(0);
        await game.ensureAdd(c);
        expect(c.isMounted, true);

        await null;
        expect(c.cache, isNotNull);
        expect(c.cache!.debugDisposed, isFalse);
      },
    );
  });
}
