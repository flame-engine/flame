import 'package:canvas_test/canvas_test.dart';
import 'package:flame/extensions.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

void main() {
  group('CanvasExtension', () {
    test('scaleVector calls scale', () {
      final canvas = MocktailCanvas();
      when(() => canvas.scale(1, 2)).thenReturn(null);
      canvas.scaleVector(Vector2(1, 2));
      verify(() => canvas.scale(1, 2)).called(1);
    });

    test('translateVector calls translate', () {
      final canvas = MocktailCanvas();
      when(() => canvas.translate(1, 2)).thenReturn(null);
      canvas.translateVector(Vector2(1, 2));
      verify(() => canvas.translate(1, 2)).called(1);
    });
    test('renderPoint', () {
      final canvas = MockCanvas();
      canvas.renderPoint(Vector2.all(10.0), size: 2);
      expect(
        canvas,
        MockCanvas()..drawRect(const Rect.fromLTWH(9, 9, 2, 2)),
      );
    });

    test('renderAt saves, translates draws and then restores', () {
      final canvas = MocktailCanvas();
      when(canvas.save).thenReturn(null);
      when(() => canvas.translateVector(Vector2(1, 1))).thenReturn(null);
      when(canvas.restore).thenReturn(null);

      final drawFunction = MocktailDrawFunction();
      when(() => drawFunction.call(canvas)).thenReturn(null);
      canvas.renderAt(Vector2(1, 1), drawFunction);
      verify(canvas.save).called(1);
      verify(() => canvas.translateVector(Vector2(1, 1))).called(1);
      verify(() => drawFunction(canvas)).called(1);
      verify(canvas.restore).called(1);
    });

    test(
        'renderRotated saves, translates, rotates, draws, translatesBack'
        ' and then restores', () {
      final canvas = MocktailCanvas();
      when(canvas.save).thenReturn(null);
      when(() => canvas.rotate(.5)).thenReturn(null);
      when(() => canvas.translateVector(Vector2(1, 1))).thenReturn(null);
      when(() => canvas.translateVector(Vector2(-1, -1))).thenReturn(null);
      when(canvas.restore).thenReturn(null);

      final drawFunction = MocktailDrawFunction();
      when(() => drawFunction.call(canvas)).thenReturn(null);
      canvas.renderRotated(0.5, Vector2(1, 1), drawFunction);
      verify(canvas.save).called(1);
      verify(() => canvas.translateVector(Vector2(1, 1))).called(1);
      verify(() => canvas.rotate(.5)).called(1);
      verify(() => drawFunction(canvas)).called(1);
      verify(() => canvas.translateVector(Vector2(-1, -1))).called(1);
      verify(canvas.restore).called(1);
    });
  });
}

class MocktailCanvas extends Mock implements Canvas {}

abstract class DrawerFunction {
  void call(Canvas _);
}

class MocktailDrawFunction extends Mock implements DrawerFunction {}
