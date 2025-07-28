import 'package:flame/components.dart';
import 'package:flame/experimental.dart';
import 'package:flame/src/image_composition.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter/rendering.dart';
import 'package:test/test.dart';

void main() {
  group('PaddingComponent', () {
    testWithFlameGame('properly shrinkwraps and positions child', (game) async {
      const padding = EdgeInsets.all(16);
      final circle = CircleComponent(radius: 20);
      final paddingComponent = PaddingComponent(
        padding: padding,
        child: circle,
      );
      await game.ensureAdd(paddingComponent);
      expect(
        paddingComponent.size,
        Vector2(
          circle.size.x + padding.horizontal,
          circle.size.y + padding.vertical,
        ),
      );
      expect(
        paddingComponent.child?.topLeftPosition,
        padding.topLeft.toVector2(),
      );
    });
    testWithFlameGame('properly shrinkwraps and positions after child is set',
        (game) async {
      const padding = EdgeInsets.all(16);
      final circle = CircleComponent(radius: 20);
      final paddingComponent = PaddingComponent(
        padding: padding,
      );
      await game.ensureAdd(paddingComponent);
      expect(
        paddingComponent.size,
        Vector2(
          padding.horizontal,
          padding.vertical,
        ),
      );
      paddingComponent.child = circle;
      await game.ready();
      expect(
        paddingComponent.size,
        Vector2(
          circle.size.x + padding.horizontal,
          circle.size.y + padding.vertical,
        ),
      );
      expect(
        paddingComponent.child?.topLeftPosition,
        padding.topLeft.toVector2(),
      );
    });
  });
}
