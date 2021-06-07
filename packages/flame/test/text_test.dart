import 'dart:ui';

import 'package:flame/components.dart';
import 'package:test/test.dart';

class _CustomTextRenderer extends TextRenderer<TextPaintConfig> {
  _CustomTextRenderer() : super(config: const TextPaintConfig());
  @override
  TextRenderer<TextPaintConfig> copyWith(
    BaseTextConfig Function(TextPaintConfig) transform,
  ) {
    return this;
  }

  @override
  double measureTextHeight(String text) {
    return 0;
  }

  @override
  double measureTextWidth(String text) {
    return 0;
  }

  @override
  void render(
    Canvas canvas,
    String text,
    Vector2 position, {
    Anchor anchor = Anchor.topLeft,
  }) {}
}

void main() {
  group('Text', () {
    test('copyWith', () {
      const config = TextPaintConfig(fontSize: 12, fontFamily: 'Times');
      final tp = TextPaint(config: config)
          .copyWith((t) => t.withFontFamily('Helvetica'));
      expect(tp.config.fontSize, 12);
      expect(tp.config.fontFamily, 'Helvetica');
    });
    test('createDefault', () {
      final tp = TextRenderer.createDefault<TextPaint>();
      expect(tp, isNotNull);
      expect(tp, isA<TextPaint>());

      final tr = TextRenderer.createDefault();
      expect(tr, isNotNull);
      expect(tr, isA<TextRenderer>());
    });
    test('change parameters of text component', () {
      final tc = TextComponent<TextPaint>('foo');
      tc.textRenderer = tc.textRenderer.copyWith((c) => c.withFontSize(200));
      expect(tc.textRenderer.config.fontSize, 200);
    });
    test('custom renderer', () {
      TextRenderer.defaultCreatorsRegistry[_CustomTextRenderer] =
          () => _CustomTextRenderer();
      final tc = TextComponent<_CustomTextRenderer>('foo');
      expect(tc.textRenderer, isA<_CustomTextRenderer>());
    });
    test('text component size is set', () {
      final t = TextComponent('foobar');
      expect(t.size, isNot(equals(Vector2.zero())));
    });
  });
}
