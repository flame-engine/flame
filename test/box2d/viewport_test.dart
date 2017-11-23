import 'dart:ui';

import 'package:flame/box2d/viewport.dart';
import 'package:test/test.dart';

void main() {
  var viewport = new Viewport(new Size(100.0, 100.0), 1.0);

  group("getCenterHorizontalScreenPercentage", () {
    test("center starts in the middle", () {
      viewport.setCamera(50.0, viewport.center.y, 1.0);

      expect(viewport.getCenterHorizontalScreenPercentage(), equals(0.5));
      expect(viewport.getCenterHorizontalScreenPercentage(screens: 2.0),
          equals(0.5));
      expect(viewport.getCenterHorizontalScreenPercentage(screens: 3.0),
          equals(0.5));
    });

    test("it increases when it move to right", () {
      var viewport = new Viewport(new Size(100.0, 100.0), 1.0);
      viewport.setCamera(75.0, viewport.center.y, 1.0);
      expect(viewport.getCenterHorizontalScreenPercentage(), equals(0.75));
      expect(viewport.getCenterHorizontalScreenPercentage(screens: 2.0),
          equals(0.75));
      expect(viewport.getCenterHorizontalScreenPercentage(screens: 3.0),
          equals(0.75));
    });

    test("it decreases when it moves to left", () {
      viewport.setCamera(25.0, viewport.center.y, 1.0);
      expect(viewport.getCenterHorizontalScreenPercentage(), equals(0.25));
      expect(viewport.getCenterHorizontalScreenPercentage(screens: 2.0),
          equals(0.25));
      expect(viewport.getCenterHorizontalScreenPercentage(screens: 3.0),
          equals(0.25));
    });

    test("it flips on edges", () {
      viewport.setCamera(110.0, viewport.center.y, 1.0);
      expect(viewport.getCenterHorizontalScreenPercentage(), equals(0.10));
      expect(viewport.getCenterHorizontalScreenPercentage(screens: 2.0),
          equals(0.10));
      expect(viewport.getCenterHorizontalScreenPercentage(screens: 3.0),
          equals(0.10));

      viewport.setCamera(-10.0, viewport.center.y, 1.0);
      expect(viewport.getCenterHorizontalScreenPercentage(), equals(0.90));
      expect(viewport.getCenterHorizontalScreenPercentage(screens: 2.0),
          equals(0.90));
      expect(viewport.getCenterHorizontalScreenPercentage(screens: 3.0),
          equals(0.90));
    });
  });
}
