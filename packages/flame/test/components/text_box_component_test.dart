import 'dart:ui' hide TextStyle;

import 'package:canvas_test/canvas_test.dart';
import 'package:flame/components.dart';
import 'package:flame/palette.dart';
import 'package:flame/src/text/formatter_text_renderer.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

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

    testWithFlameGame('onLoad waits for cache to be done', (game) async {
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

    testGolden(
      'Alignment options',
      (game) async {
        game.addAll([
          _FramedTextBox(
            text: 'I strike quickly, being moved.',
            position: Vector2(10.5, 10),
            size: Vector2(390, 100),
            align: Anchor.topLeft,
          ),
          _FramedTextBox(
            text: 'But thou art not quickly moved to strike.',
            position: Vector2(10, 120),
            size: Vector2(390, 115),
            align: Anchor.topCenter,
          ),
          _FramedTextBox(
            text: 'A dog of the house of Montague moves me.',
            position: Vector2(10, 245),
            size: Vector2(390, 115),
            align: Anchor.topRight,
          ),
          _FramedTextBox(
            text: 'To move is to stir, and to be valiant is to stand. '
                'Therefore, if thou art moved, thou runn‘st away.',
            position: Vector2(10, 370),
            size: Vector2(390, 220),
            align: Anchor.bottomRight,
          ),
          _FramedTextBox(
            text: 'A dog of that house shall move me to stand. I will take '
                'the wall of any man or maid of Montague‘s.',
            position: Vector2(410, 10),
            size: Vector2(380, 300),
            align: Anchor.center,
          ),
          _FramedTextBox(
            text: 'That shows thee a weak slave; for the weakest goes to the '
                'wall.',
            position: Vector2(410, 320),
            size: Vector2(380, 270),
            align: Anchor.centerRight,
          ),
        ]);
      },
      goldenFile: '../_goldens/text_box_component_test_1.png',
    );
  });
}

class _FramedTextBox extends TextBoxComponent {
  _FramedTextBox({
    required String super.text,
    super.align,
    super.position,
    super.size,
  }) : super(
          textRenderer: FormatterTextRenderer(DebugTextFormatter(fontSize: 22)),
        );

  final Paint _borderPaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2
    ..color = const Color(0xff00ff00);

  @override
  void render(Canvas canvas) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(size.toRect(), const Radius.circular(5)),
      _borderPaint,
    );
    super.render(canvas);
  }
}
