import 'dart:ui';

import 'package:flame/box2d/viewport.dart';
import 'package:test/test.dart';

void main() {
  final viewport = Viewport(const Size(100.0, 100.0), 1.0);

  group('getCenterHorizontalScreenPercentage', () {
    test('center starts in the middle', () {
      viewport.setCamera(50.0, viewport.center.y, 1.0);
      expect(viewport.getCenterHorizontalScreenPercentage(), equals(0.5));
    });

    test('it increases when it move to right', () {
      viewport.setCamera(75.0, viewport.center.y, 1.0);
      expect(viewport.getCenterHorizontalScreenPercentage(), equals(0.75));
    });

    test('it decreases when it moves to left', () {
      viewport.setCamera(25.0, viewport.center.y, 1.0);
      expect(viewport.getCenterHorizontalScreenPercentage(), equals(0.25));
    });

    test('it flips on edges', () {
      viewport.setCamera(110.0, viewport.center.y, 1.0);
      expect(viewport.getCenterHorizontalScreenPercentage(), equals(0.10));

      viewport.setCamera(-10.0, viewport.center.y, 1.0);
      expect(viewport.getCenterHorizontalScreenPercentage(), equals(0.90));
    });

    test('it increases slower with more screens', () {
      viewport.setCamera(50.0, viewport.center.y, 1.0);
      expect(viewport.getCenterHorizontalScreenPercentage(screens: 2.0),
          equals(0.5));
      expect(viewport.getCenterHorizontalScreenPercentage(screens: 4.0),
          equals(0.5));

      viewport.setCamera(75.0, viewport.center.y, 1.0);
      expect(viewport.getCenterHorizontalScreenPercentage(screens: 2.0),
          equals(0.625));
      expect(viewport.getCenterHorizontalScreenPercentage(screens: 5.0),
          equals(0.55));
    });

    test('it flips on edges also with more screens', () {
      viewport.setCamera(170.0, viewport.center.y, 1.0);
      expect(viewport.getCenterHorizontalScreenPercentage(screens: 2.0),
          equals(0.10));

      viewport.setCamera(-70.0, viewport.center.y, 1.0);
      expect(viewport.getCenterHorizontalScreenPercentage(screens: 2.0),
          equals(0.90));
    });
  });
}
