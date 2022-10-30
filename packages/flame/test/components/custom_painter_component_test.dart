import 'package:canvas_test/canvas_test.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class _MockCustomPainter extends Mock implements CustomPainter {}

void main() {
  group('CustomPainterComponent', () {
    test('correctly calls the paint method of the painter', () {
      final painter = _MockCustomPainter();
      final component = CustomPainterComponent(
        painter: painter,
      )..size = Vector2.all(100);

      final canvas = MockCanvas();
      component.render(canvas);

      verify(() => painter.paint(canvas, const Size(100, 100)));
    });
  });
}
