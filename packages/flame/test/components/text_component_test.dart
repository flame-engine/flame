import 'package:flame/components.dart';
import 'package:flame/text.dart';
import 'package:flutter/painting.dart';
import 'package:test/test.dart';

void main() {
  group('TextComponent', () {
    test('sets the size of the text component', () {
      final t = TextComponent(text: 'foobar');
      expect(t.size, isNot(equals(Vector2.zero())));
    });

    test('keeps the glyphs translated by the ascent after a paint change', () {
      final elements = <_RecordingTextElement>[];
      final component = TextComponent(
        text: 'foo',
        textRenderer: _RecordingTextRenderer(elements),
      );
      expect(elements.single.translations, [const Offset(0, _ascent)]);

      component.setOpacity(0.5);

      expect(elements, hasLength(2));
      expect(elements.last.translations, [const Offset(0, _ascent)]);
    });
  });
}

const _ascent = 10.0;

class _RecordingTextRenderer extends TextRenderer {
  _RecordingTextRenderer(this.elements);

  final List<_RecordingTextElement> elements;

  @override
  InlineTextElement format(String text) {
    final element = _RecordingTextElement();
    elements.add(element);
    return element;
  }

  @override
  TextRenderer copyWithPaint(Paint paint) => _RecordingTextRenderer(elements);
}

class _RecordingTextElement extends InlineTextElement {
  final translations = <Offset>[];

  @override
  LineMetrics get metrics => LineMetrics(ascent: _ascent, width: 30);

  @override
  void draw(Canvas canvas) {}

  @override
  void translate(double dx, double dy) {
    translations.add(Offset(dx, dy));
  }
}
