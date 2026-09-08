import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/text.dart';
import 'package:flame_test/flame_test.dart';
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

    test('draws with the given renderer until the paint changes', () {
      final textPaint = TextPaint(
        style: const TextStyle(color: Color(0xFF2E9940)),
      );
      final component = TextComponent(text: 'foo', textRenderer: textPaint);
      expect(component.textRenderer, same(textPaint));
      expect(component.paintedTextRenderer, same(textPaint));

      component.opacity = 0.5;
      expect(component.textRenderer, same(textPaint));
      expect(component.paintedTextRenderer, isNot(same(textPaint)));
      expect(textPaint.style.color, const Color(0xFF2E9940));
    });

    test('a renderer round trip between opacity changes does not compound', () {
      const shadowColor = Color(0x99FFFFFF);
      final component = TextComponent(
        text: 'foo',
        textRenderer: TextPaint(
          style: const TextStyle(
            color: Color(0xFF2E9940),
            shadows: [Shadow(color: shadowColor, blurRadius: 4)],
          ),
        ),
      );

      component.setOpacity(0.5);
      component.textRenderer = component.textRenderer.copyWith(
        (style) => style.copyWith(fontSize: 30),
      );
      component.setOpacity(0.25);

      expect(component.textRenderer.style.color, const Color(0xFF2E9940));
      expect(component.textRenderer.style.shadows!.single.color, shadowColor);
      final painted = component.paintedTextRenderer.style;
      expect(painted.fontSize, 30);
      expectColor(
        painted.foreground!.color,
        const Color(0xFF2E9940).withValues(alpha: 0.25),
      );
      expectColor(
        painted.shadows!.single.color,
        const Color(0xFFFFFFFF).withValues(alpha: shadowColor.a * 0.25),
      );
    });

    test('applies opacity to the text color and shadows', () {
      final component = TextComponent(
        text: 'foo',
        textRenderer: TextPaint(
          style: const TextStyle(
            color: Color(0xFF2E9940),
            shadows: [Shadow(color: Color(0x99FFFFFF), blurRadius: 4)],
          ),
        ),
      );

      component.opacity = 0.5;

      final style = component.paintedTextRenderer.style;
      expectColor(
        style.foreground!.color,
        const Color(0xFF2E9940).withValues(alpha: 0.5),
      );
      expectColor(
        style.shadows!.single.color,
        const Color(0xFFFFFFFF).withValues(alpha: (153 / 255) * 0.5),
      );
    });

    test('opacity changes do not compound', () {
      final component = TextComponent(
        text: 'foo',
        textRenderer: TextPaint(
          style: const TextStyle(
            color: Color(0xFF2E9940),
            shadows: [Shadow(color: Color(0xFFFFFFFF), blurRadius: 4)],
          ),
        ),
      );

      component.opacity = 0.5;
      component.opacity = 0.5;
      component.opacity = 0.8;

      final style = component.paintedTextRenderer.style;
      expectColor(
        style.foreground!.color,
        const Color(0xFF2E9940).withValues(alpha: 0.8),
      );
      expectColor(
        style.shadows!.single.color,
        const Color(0xFFFFFFFF).withValues(alpha: 0.8),
      );
    });

    test('a new renderer gets the current paint applied', () {
      final component = TextComponent<TextPaint>(text: 'foo');
      component.opacity = 0.25;

      component.textRenderer = TextPaint(
        style: const TextStyle(color: Color(0xFF0000FF)),
      );

      expectColor(
        component.paintedTextRenderer.style.foreground!.color,
        const Color(0xFF0000FF).withValues(alpha: 0.25),
      );
    });

    testWithFlameGame('fades out together with the shadows', (game) async {
      final component = TextComponent(
        text: 'foo',
        textRenderer: TextPaint(
          style: const TextStyle(
            color: Color(0xFF2E9940),
            shadows: [Shadow(color: Color(0xFFFFFFFF), blurRadius: 4)],
          ),
        ),
      )..add(OpacityEffect.fadeOut(EffectController(duration: 1)));
      await game.ensureAdd(component);

      game.update(0.5);
      var style = component.paintedTextRenderer.style;
      expectColor(
        style.foreground!.color,
        const Color(0xFF2E9940).withValues(alpha: 0.5),
      );
      expectColor(
        style.shadows!.single.color,
        const Color(0xFFFFFFFF).withValues(alpha: 0.5),
      );

      game.update(0.5);
      style = component.paintedTextRenderer.style;
      expectColor(
        style.foreground!.color,
        const Color(0xFF2E9940).withValues(alpha: 0),
      );
      expectColor(
        style.shadows!.single.color,
        const Color(0xFFFFFFFF).withValues(alpha: 0),
      );
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
