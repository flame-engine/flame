import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/text.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter/rendering.dart';
import 'package:test/test.dart';

void main() {
  group('TextComponent', () {
    test('sets the size of the text component', () {
      final t = TextComponent(text: 'foobar');
      expect(t.size, isNot(equals(Vector2.zero())));
    });

    testWithFlameGame(
      'fades the text in its own color and the shadows with it under an '
      'OpacityEffect',
      (game) async {
        const color = Color(0xFF2E9940);
        const shadowColor = Color(0x99FFFFFF);
        final component = TextComponent(
          text: '+1 kr',
          textRenderer: TextPaint(
            style: const TextStyle(
              color: color,
              shadows: [Shadow(color: shadowColor, blurRadius: 4)],
            ),
          ),
        );
        await game.ensureAdd(component);
        component.add(OpacityEffect.fadeOut(EffectController(duration: 1)));

        game.update(0.5);
        var style = component.paintedTextRenderer.style;
        final fill = style.foreground!.color;
        expect(fill.toARGB32() & 0xFFFFFF, color.toARGB32() & 0xFFFFFF);
        expectDouble(fill.a, 0.5, epsilon: 0.05);
        var shadow = style.shadows!.single;
        expect(
          shadow.color.toARGB32() & 0xFFFFFF,
          shadowColor.toARGB32() & 0xFFFFFF,
        );
        expectDouble(shadow.color.a, shadowColor.a * 0.5, epsilon: 0.05);

        game.update(0.5);
        style = component.paintedTextRenderer.style;
        expectDouble(style.foreground!.color.a, 0.0, epsilon: 0.05);
        shadow = style.shadows!.single;
        expectDouble(shadow.color.a, 0.0, epsilon: 0.05);
      },
    );

    test('applies the paint to the renderer the user set, not to a copy', () {
      const color = Color(0xFF2E9940);
      const shadowColor = Color(0x99FFFFFF);
      final component = TextComponent(
        text: '+1 kr',
        textRenderer: TextPaint(
          style: const TextStyle(
            color: color,
            shadows: [Shadow(color: shadowColor, blurRadius: 4)],
          ),
        ),
      );

      component.setOpacity(0.5);
      component.textRenderer = component.textRenderer.copyWith(
        (style) => style.copyWith(fontSize: 30),
      );
      component.setOpacity(0.25);

      expect(component.textRenderer.style.color, color);
      expect(component.textRenderer.style.shadows!.single.color, shadowColor);
      final painted = component.paintedTextRenderer.style;
      expect(painted.fontSize, 30);
      expectDouble(painted.foreground!.color.a, 0.25);
      expectDouble(painted.shadows!.single.color.a, shadowColor.a * 0.25);
    });
  });
}
