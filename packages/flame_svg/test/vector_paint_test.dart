import 'dart:ui';

import 'package:flame_svg/vector_paint.dart';
import 'package:flutter_test/flutter_test.dart';

Paint _fill(int color) => Paint()
  ..style = PaintingStyle.fill
  ..color = Color(color);

Paint _stroke(int color) => Paint()
  ..style = PaintingStyle.stroke
  ..color = Color(color);

void main() {
  group('VectorPaint', () {
    test('has a fill and a stroke', () {
      final fill = _fill(0xffff0000);
      final stroke = _stroke(0xff00ff00);
      final paint = VectorPaint(fill: fill, stroke: stroke);
      expect(paint.fill, fill);
      expect(paint.stroke, stroke);
      expect(paint.isFilled, isTrue);
      expect(paint.isStroked, isTrue);
    });

    test('has nothing by default', () {
      const paint = VectorPaint();
      expect(paint.isFilled, isFalse);
      expect(paint.isStroked, isFalse);
      expect(paint.paint, isNull);
      expect(paint.paintLayers, isNull);
    });

    group('VectorPaint.paint', () {
      test('creates a fill from a fill paint', () {
        final fill = _fill(0xffff0000);
        final paint = VectorPaint.paint(fill);
        expect(paint.fill, fill);
        expect(paint.isStroked, isFalse);
      });

      test('creates a stroke from a stroke paint', () {
        final stroke = _stroke(0xff00ff00);
        final paint = VectorPaint.paint(stroke);
        expect(paint.stroke, stroke);
        expect(paint.isFilled, isFalse);
      });
    });

    group('paint', () {
      test('is the fill if there is one', () {
        final fill = _fill(0xffff0000);
        final stroke = _stroke(0xff00ff00);
        expect(VectorPaint(fill: fill, stroke: stroke).paint, fill);
      });

      test('is the stroke if there is no fill', () {
        final stroke = _stroke(0xff00ff00);
        expect(VectorPaint(stroke: stroke).paint, stroke);
      });
    });

    group('paintLayers', () {
      test('has the fill first and then the stroke', () {
        final fill = _fill(0xffff0000);
        final stroke = _stroke(0xff00ff00);
        expect(VectorPaint(fill: fill, stroke: stroke).paintLayers, [
          fill,
          stroke,
        ]);
      });

      test('has only the paints that are present', () {
        final fill = _fill(0xffff0000);
        final stroke = _stroke(0xff00ff00);
        expect(VectorPaint(fill: fill).paintLayers, [fill]);
        expect(VectorPaint(stroke: stroke).paintLayers, [stroke]);
      });
    });

    group('equality', () {
      test('is by fill and stroke', () {
        final fill = _fill(0xffff0000);
        final stroke = _stroke(0xff00ff00);
        final a = VectorPaint(fill: fill, stroke: stroke);
        final b = VectorPaint(fill: fill, stroke: stroke);
        expect(a, b);
        expect(a.hashCode, b.hashCode);
        expect(a, isNot(VectorPaint(fill: fill)));
        expect(a, isNot(VectorPaint(fill: _fill(0xffff0000), stroke: stroke)));
      });
    });

    test('toString lists the fill and the stroke', () {
      final paint = VectorPaint(
        fill: _fill(0xffff0000),
        stroke: _stroke(0xff00ff00),
      );
      expect(paint.toString(), allOf(contains('fill:'), contains('stroke:')));
      expect(const VectorPaint().toString(), 'VectorPaint()');
    });
  });
}
