import 'dart:math' as math;
import 'dart:ui';
import 'package:flame/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('HueDecorator', () {
    test('can be instantiated', () {
      final decorator = HueDecorator();
      expect(decorator.hue, 0.0);
    });

    test('hue property updates correctly', () {
      final decorator = HueDecorator();
      decorator.hue = math.pi;
      expect(decorator.hue, math.pi);
    });

    test('apply with hue 0 does not use saveLayer', () {
      final decorator = HueDecorator();
      var drawCalled = false;
      final canvas = _MockCanvas();

      decorator.apply((c) => drawCalled = true, canvas);

      expect(drawCalled, isTrue);
      expect(canvas.saveLayerCalled, isFalse);
    });

    test('apply with non-zero hue uses saveLayer', () {
      final decorator = HueDecorator(hue: math.pi / 2);
      var drawCalled = false;
      final canvas = _MockCanvas();

      decorator.apply((c) => drawCalled = true, canvas);

      expect(drawCalled, isTrue);
      expect(canvas.saveLayerCalled, isTrue);
    });
  });
}

class _MockCanvas extends Fake implements Canvas {
  bool saveLayerCalled = false;
  bool restoreCalled = false;

  @override
  void saveLayer(Rect? bounds, Paint paint) {
    saveLayerCalled = true;
  }

  @override
  void restore() {
    restoreCalled = true;
  }
}
