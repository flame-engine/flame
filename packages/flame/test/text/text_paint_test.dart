import 'dart:ui' show Color;

import 'package:flame/text.dart';
import 'package:flutter/rendering.dart' as flutter;
import 'package:test/test.dart';

void main() {
  group('TextPaint', () {
    test('copyWith returns a new instance with the new values', () {
      const style = flutter.TextStyle(fontSize: 12, fontFamily: 'Times');
      final tp = TextPaint(style: style)
          .copyWith((t) => t.copyWith(fontFamily: 'Helvetica'));
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
        );
        final textPaint = TextPaint(style: flutterStyle);

        final inlineTextStyle = textPaint.asInlineTextStyle();
        expect(inlineTextStyle.fontSize, 12);
        expect(inlineTextStyle.fontFamily, 'Times');
        expect(inlineTextStyle.fontStyle, flutter.FontStyle.italic);
        expect(inlineTextStyle.fontWeight, flutter.FontWeight.bold);
        expect(inlineTextStyle.color, const Color(0xFF00FF00));

        final newTextPaint = inlineTextStyle.asTextRenderer();
        expect(newTextPaint.style.fontSize, 12);
        expect(newTextPaint.style.fontFamily, 'Times');
        expect(newTextPaint.style.fontStyle, flutter.FontStyle.italic);
        expect(newTextPaint.style.fontWeight, flutter.FontWeight.bold);
        expect(newTextPaint.style.color, const Color(0xFF00FF00));
      },
    );
  });
}
