import 'package:flame/components.dart';
import 'package:flame/text.dart';
import 'package:flutter/material.dart';
import 'package:test/test.dart';

void main() {
  group('TextRenderer', () {
    test('createDefault', () {
      final tp = TextRendererFactory.createDefault<TextPaint>();
      expect(tp, isNotNull);
      expect(tp, isA<TextPaint>());

      final tr = TextRendererFactory.createDefault();
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
      TextRendererFactory.defaultRegistry[_CustomTextRenderer] =
          _CustomTextRenderer.new;
      final tc = TextComponent<_CustomTextRenderer>(text: 'foo');
      expect(tc.textRenderer, isA<_CustomTextRenderer>());
    });
  });
}

class _CustomTextRenderer extends TextRenderer {
  @override
  TextElement format(String text) {
    return CustomTextElement();
  }
}

class CustomTextElement extends TextElement {
  @override
  LineMetrics get metrics => LineMetrics();

  @override
  void draw(Canvas canvas) {}

  @override
  void translate(double dx, double dy) {}
}
