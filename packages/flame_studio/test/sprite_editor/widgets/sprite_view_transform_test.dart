import 'dart:ui';

import 'package:flame_studio/sprite_editor/widgets/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group(SpriteViewTransform, () {
    test('fit scales small images up to fill the canvas', () {
      final transform = SpriteViewTransform.fit(
        const Size(10, 20),
        const Size(248, 448),
      );

      expect(transform.scale, equals(20));
      expect(transform.offset, equals(const Offset(24, 24)));
    });

    test('fit centers the image on the axis with room to spare', () {
      final transform = SpriteViewTransform.fit(
        const Size(200, 100),
        const Size(248, 448),
      );

      expect(transform.scale, equals(1));
      expect(transform.offset, equals(const Offset(24, 174)));
    });

    test('maps points to the canvas and back', () {
      const transform = SpriteViewTransform(scale: 2, offset: Offset(10, 20));

      expect(transform.toCanvas(const Offset(3, 4)), const Offset(16, 28));
      expect(transform.toImage(const Offset(16, 28)), const Offset(3, 4));
      expect(
        transform.rectToCanvas(const Rect.fromLTWH(1, 1, 2, 3)),
        const Rect.fromLTWH(12, 22, 4, 6),
      );
    });

    test('zoomed keeps its center in place, and panned moves it', () {
      const center = Offset(50, 50);
      final zoomed = const SpriteViewTransform().zoomed(2, center);

      expect(zoomed.toImage(center), equals(center));
      expect(zoomed.scale, equals(2));
      expect(
        zoomed.panned(const Offset(1, 2)).offset,
        equals(zoomed.offset + const Offset(1, 2)),
      );
    });

    test('supports value equality', () {
      expect(
        const SpriteViewTransform(scale: 2),
        equals(const SpriteViewTransform(scale: 2)),
      );
      expect(
        const SpriteViewTransform(scale: 2).hashCode,
        equals(const SpriteViewTransform(scale: 2).hashCode),
      );
    });

    test('handleAt finds the closest handle within the hit radius', () {
      const transform = SpriteViewTransform();
      const region = Rect.fromLTWH(100, 100, 100, 50);

      expect(
        transform.handleAt(region, const Offset(103, 98)),
        equals(SpriteRegionHandle.topLeft),
      );
      expect(
        transform.handleAt(region, const Offset(150, 150)),
        equals(SpriteRegionHandle.bottom),
      );
      expect(
        transform.handleAt(region, const Offset(200, 125)),
        equals(SpriteRegionHandle.right),
      );
      expect(transform.handleAt(region, const Offset(130, 120)), isNull);
    });
  });

  group(SpriteRegionHandle, () {
    const region = Rect.fromLTRB(10, 10, 20, 20);

    test('corners move two sides', () {
      expect(
        SpriteRegionHandle.bottomRight.dragged(region, const Offset(30, 40)),
        equals(const Rect.fromLTRB(10, 10, 30, 40)),
      );
      expect(
        SpriteRegionHandle.topLeft.dragged(region, const Offset(5, 6)),
        equals(const Rect.fromLTRB(5, 6, 20, 20)),
      );
    });

    test('edges move one side', () {
      expect(
        SpriteRegionHandle.top.dragged(region, const Offset(100, 5)),
        equals(const Rect.fromLTRB(10, 5, 20, 20)),
      );
      expect(
        SpriteRegionHandle.right.dragged(region, const Offset(25, 100)),
        equals(const Rect.fromLTRB(10, 10, 25, 20)),
      );
    });

    test('dragging past the opposite side flips the region', () {
      expect(
        SpriteRegionHandle.left.dragged(region, const Offset(30, 0)),
        equals(const Rect.fromLTRB(20, 10, 30, 20)),
      );
    });
  });
}
