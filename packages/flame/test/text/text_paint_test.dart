import 'dart:ui';

import 'package:flame/text.dart';
import 'package:flutter/rendering.dart' as flutter;
import 'package:test/test.dart';

void main() {
  group('TextPaint', () {
    test('copyWith returns a new instance with the new values', () {
      const style = flutter.TextStyle(fontSize: 12, fontFamily: 'Times');
      final tp = TextPaint(
        style: style,
      ).copyWith((t) => t.copyWith(fontFamily: 'Helvetica'));
      expect(tp.style.fontSize, 12);
      expect(tp.style.fontFamily, 'Helvetica');
    });

    test(
      'can convert back and forth between TextPaint and InlineTextStyle',
      () {
        const flutterStyle = flutter.TextStyle(
          fontSize: 12,
          fontFamily: 'Times',
          fontStyle: flutter.FontStyle.italic,
          fontWeight: flutter.FontWeight.bold,
          color: Color(0xFF00FF00),
          letterSpacing: 1.5,
          wordSpacing: 2.5,
          height: 3.5,
          leadingDistribution: TextLeadingDistribution.even,
          shadows: [
            Shadow(
              color: Color(0xFFFF0000),
              offset: Offset(1, 1),
              blurRadius: 1,
            ),
          ],
          fontFeatures: [
            flutter.FontFeature.alternativeFractions(),
          ],
          fontVariations: [
            flutter.FontVariation.slant(0.3),
          ],
          decoration: TextDecoration.lineThrough,
          decorationColor: Color(0xFF0000FF),
          decorationStyle: TextDecorationStyle.dashed,
          decorationThickness: 1.5,
          backgroundColor: Color(0xFFFF00FF),
        );
        final textPaint = TextPaint(style: flutterStyle);

        final inlineTextStyle = textPaint.asInlineTextStyle();
        expect(inlineTextStyle.fontSize, 12);
        expect(inlineTextStyle.fontFamily, 'Times');
        expect(inlineTextStyle.fontStyle, flutter.FontStyle.italic);
        expect(inlineTextStyle.fontWeight, flutter.FontWeight.bold);
        expect(inlineTextStyle.color, const Color(0xFF00FF00));
        expect(inlineTextStyle.letterSpacing, 1.5);
        expect(inlineTextStyle.wordSpacing, 2.5);
        expect(inlineTextStyle.height, 3.5);
        expect(
          inlineTextStyle.leadingDistribution,
          TextLeadingDistribution.even,
        );
        expect(inlineTextStyle.shadows, [
          const Shadow(
            color: Color(0xFFFF0000),
            offset: Offset(1, 1),
            blurRadius: 1,
          ),
        ]);
        expect(inlineTextStyle.fontFeatures, [
          const flutter.FontFeature.alternativeFractions(),
        ]);
        expect(inlineTextStyle.fontVariations, [
          const FontVariation.slant(0.3),
        ]);
        expect(inlineTextStyle.decoration, TextDecoration.lineThrough);
        expect(inlineTextStyle.decorationColor, const Color(0xFF0000FF));
        expect(inlineTextStyle.decorationStyle, TextDecorationStyle.dashed);
        expect(inlineTextStyle.decorationThickness, 1.5);
        expect(inlineTextStyle.background!.color, const Color(0xFFFF00FF));

        final newTextPaint = inlineTextStyle.asTextRenderer();
        expect(newTextPaint.style.fontSize, 12);
        expect(newTextPaint.style.fontFamily, 'Times');
        expect(newTextPaint.style.fontStyle, flutter.FontStyle.italic);
        expect(newTextPaint.style.fontWeight, flutter.FontWeight.bold);
        expect(newTextPaint.style.color, const Color(0xFF00FF00));
        expect(newTextPaint.style.letterSpacing, 1.5);
        expect(newTextPaint.style.wordSpacing, 2.5);
        expect(newTextPaint.style.height, 3.5);
        expect(
          newTextPaint.style.leadingDistribution,
          TextLeadingDistribution.even,
        );
        expect(newTextPaint.style.shadows, [
          const Shadow(
            color: Color(0xFFFF0000),
            offset: Offset(1, 1),
            blurRadius: 1,
          ),
        ]);
        expect(newTextPaint.style.fontFeatures, [
          const flutter.FontFeature.alternativeFractions(),
        ]);
        expect(newTextPaint.style.fontVariations, [
          const FontVariation.slant(0.3),
        ]);
        expect(newTextPaint.style.decoration, TextDecoration.lineThrough);
        expect(newTextPaint.style.decorationColor, const Color(0xFF0000FF));
        expect(newTextPaint.style.decorationStyle, TextDecorationStyle.dashed);
        expect(newTextPaint.style.decorationThickness, 1.5);
        expect(newTextPaint.style.background!.color, const Color(0xFFFF00FF));
      },
    );
  });

  test(
    'TextPaint and InlineTextStyle can receive Paint instead of Color',
    () {
      final flutterStyle = flutter.TextStyle(
        fontSize: 12,
        fontFamily: 'Times',
        foreground: Paint()..color = const Color(0xFF0000FF),
        background: Paint()..color = const Color(0xFFFF00FF),
      );
      final textPaint = TextPaint(style: flutterStyle);

      final inlineTextStyle = textPaint.asInlineTextStyle();
      expect(inlineTextStyle.fontSize, 12);
      expect(inlineTextStyle.fontFamily, 'Times');
      expect(inlineTextStyle.foreground!.color, const Color(0xFF0000FF));
      expect(inlineTextStyle.background!.color, const Color(0xFFFF00FF));

      final newTextPaint = inlineTextStyle.asTextRenderer();
      expect(newTextPaint.style.fontSize, 12);
      expect(newTextPaint.style.fontFamily, 'Times');
      expect(newTextPaint.style.foreground!.color, const Color(0xFF0000FF));
      expect(newTextPaint.style.background!.color, const Color(0xFFFF00FF));
    },
  );
}
