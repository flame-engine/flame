import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:test/test.dart';

class _CustomTextRenderer extends TextRenderer {
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
      const style = TextStyle(fontSize: 12, fontFamily: 'Times');
      final tp = TextPaint(style: style)
          .copyWith((t) => t.copyWith(fontFamily: 'Helvetica'));
      expect(tp.style.fontSize, 12);
      expect(tp.style.fontFamily, 'Helvetica');
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
      final tc = TextComponent<TextPaint>(text: 'foo');
      tc.textRenderer = tc.textRenderer.copyWith(
        (c) => c.copyWith(fontSize: 200),
      );
      expect(tc.textRenderer.style.fontSize, 200);
    });

    test('custom renderer', () {
      TextRenderer.defaultRenderersRegistry[_CustomTextRenderer] =
          () => _CustomTextRenderer();
      final tc = TextComponent<_CustomTextRenderer>(text: 'foo');
      expect(tc.textRenderer, isA<_CustomTextRenderer>());
    });

    test('text component size is set', () {
      final t = TextComponent(text: 'foobar');
      expect(t.size, isNot(equals(Vector2.zero())));
    });
  });
}
