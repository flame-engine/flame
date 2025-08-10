import 'dart:ui';

import 'package:canvas_test/canvas_test.dart';
import 'package:flame/components.dart';
import 'package:flame/palette.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TextBoxComponent', () {
    test('size is properly computed', () {
      final c = TextBoxComponent(
        text: 'The quick brown fox jumps over the lazy dog.',
        boxConfig: const TextBoxConfig(
          maxWidth: 100.0,
        ),
      );

      expect(c.size.x, 100 + 2 * 8);
      expect(c.size.y, greaterThan(1));
    });

    test('size is properly computed with new line character', () {
      final c = TextBoxComponent(
        text: 'The quick brown fox \n jumps over the lazy dog.',
        boxConfig: const TextBoxConfig(
          maxWidth: 100.0,
        ),
      );

      expect(c.size.x, 100 + 2 * 8);
      expect(c.size.y, 256);
    });

    test('lines are properly computed with new line character', () {
      final c = TextBoxComponent(
        text: 'The quick brown fox \n jumps over the lazy dog.',
        boxConfig: const TextBoxConfig(
          maxWidth: 400.0,
        ),
      );

      expect(
        c.lines,
        ['The quick brown', 'fox ', ' jumps over the', 'lazy dog.'],
      );
    });

    test('boxConfig gets set', () {
      const firstConfig = TextBoxConfig(maxWidth: 400, timePerChar: 0.1);
      const secondConfig = TextBoxConfig(maxWidth: 300, timePerChar: 0.2);
      final c = TextBoxComponent(
        text: 'The quick brown fox jumps over the lazy dog.',
        boxConfig: firstConfig,
      );
      expect(
        c.boxConfig,
        firstConfig,
      );
      c.boxConfig = secondConfig;
      expect(
        c.boxConfig,
        secondConfig,
      );
    });

    test('skip method sets boxConfig timePerChar to 0', () {
      const firstConfig = TextBoxConfig(maxWidth: 400, timePerChar: 0.1);
      final c = TextBoxComponent(
        text: 'The quick brown fox jumps over the lazy dog.',
        boxConfig: firstConfig,
      );
      expect(
        c.boxConfig,
        firstConfig,
      );
      c.skip();
      expect(c.boxConfig.timePerChar, 0);
      // other props are preserved
      expect(c.boxConfig.maxWidth, 400);
    });

    testWithFlameGame(
      'setting dismissDelay removes component when finished',
      (game) async {
        final component = TextBoxComponent(
          text: 'foo bar',
          boxConfig: const TextBoxConfig(
            dismissDelay: 10.0,
            timePerChar: 1.0,
          ),
        );

        await game.ensureAdd(component);
        game.update(8);
        expect(component.isMounted, isTrue);
        game.update(9);
        expect(component.finished, isTrue);
        expect(component.isRemoving, isTrue);
        game.update(0);
        expect(component.isMounted, isFalse);
      },
    );

    testWithFlameGame('onLoad waits for cache to be done', (game) async {
      final c = TextBoxComponent(text: 'foo bar');

      await game.ensureAdd(c);

      final canvas = MockCanvas();
      game.render(canvas); // this should render the cache
      expect(
        canvas,
        MockCanvas(mode: AssertionMode.containsAnyOrder)..drawImage(
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

    testWithFlameGame(
      'TextBoxComponent notifies if a new line is added and requires space',
      (game) async {
        var lineSize = 0.0;
        final textBoxComponent = TextBoxComponent(
          size: Vector2(50, 50),
          text: '''This 
test
has
five
lines.''',
        );
        expect(textBoxComponent.newLinePositionNotifier.value, equals(0));

        textBoxComponent.newLinePositionNotifier.addListener(() {
          lineSize += textBoxComponent.newLinePositionNotifier.value;
        });
        await game.ensureAdd(textBoxComponent);
        expect(lineSize, greaterThan(0));
      },
    );

    testWithFlameGame('TextBoxComponent skips to the end of text', (
      game,
    ) async {
      final textBoxComponent1 = TextBoxComponent(
        text: 'aaa',
        boxConfig: const TextBoxConfig(timePerChar: 1.0),
      );
      await game.ensureAdd(textBoxComponent1);
      // forward time by 2.5 seconds
      game.update(2.5);
      expect(textBoxComponent1.finished, false);
      // flush
      game.update(0.6);
      expect(textBoxComponent1.finished, true);

      // reset
      await game.ensureRemove(textBoxComponent1);

      final textBoxComponent2 = TextBoxComponent(
        text: 'aaa',
        boxConfig: const TextBoxConfig(timePerChar: 1.0),
      );
      await game.ensureAdd(textBoxComponent2);
      expect(textBoxComponent2.finished, false);
      // Simulate running 0.5 seconds before skipping
      game.update(0.5);
      textBoxComponent2.skip();
      expect(textBoxComponent2.finished, true);
    });

    testGolden(
      'Alignment options',
      (game, tester) async {
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
            // cSpell:ignore runn'st (old english)
            text:
                'To move is to stir, and to be valiant is to stand. '
                "Therefore, if thou art moved, thou runn'st away.",
            position: Vector2(10, 370),
            size: Vector2(390, 220),
            align: Anchor.bottomRight,
          ),
          _FramedTextBox(
            text:
                'A dog of that house shall move me to stand. I will take '
                'the wall of any man or maid of Montague‘s.',
            position: Vector2(410, 10),
            size: Vector2(380, 300),
            align: Anchor.center,
          ),
          _FramedTextBox(
            text:
                'That shows thee a weak slave; for the weakest goes to the '
                'wall.',
            position: Vector2(410, 320) + Vector2(380, 270),
            size: Vector2(380, 270),
            align: Anchor.centerRight,
            anchor: Anchor.bottomRight,
          ),
        ]);
      },
      goldenFile: '../_goldens/text_box_component_test_1.png',
    );
  });

  testGolden(
    'Big upscale',
    (game, tester) async {
      game.addAll([
        TextBoxComponent(
          text: 'quickly',
          pixelRatio: 8,
        ),
      ]);
    },
    size: Vector2(512, 64),
    goldenFile: '../_goldens/text_box_component_test_2.png',
  );
}

class _FramedTextBox extends TextBoxComponent {
  _FramedTextBox({
    required String super.text,
    super.align,
    super.position,
    super.size,
    super.anchor,
  }) : super(
         textRenderer: DebugTextRenderer(fontSize: 22),
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
