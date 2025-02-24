import 'package:flame/components.dart';
import 'package:flame/experimental.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter/rendering.dart';
import 'package:test/test.dart';

void main() {
  group('LayoutComponent', () {
    group('RowComponent', () {
      testWithFlameGame('mainAxisAlignment = start', (game) async {
        final circle = CircleComponent(radius: 20);
        final rectangle = RectangleComponent(size: Vector2(100, 50));
        final text = TextComponent(text: 'testing');
        final layoutComponentSize = Vector2.all(500);
        await game.ensureAdd(RowComponent(children: [circle, rectangle, text]));
        expect(circle.position.x, 0);
        expect(rectangle.position.x, circle.size.x);
        expect(text.position.x, rectangle.position.x + rectangle.size.x);
      });
      testWithFlameGame('mainAxisAlignment = end', (game) async {
        final circle = CircleComponent(radius: 20);
        final rectangle = RectangleComponent(size: Vector2(100, 50));
        final text = TextComponent(text: 'testing');
        final layoutComponentSize = Vector2.all(500);
        await game.ensureAdd(
          RowComponent(
            children: [circle, rectangle, text],
            size: layoutComponentSize,
            mainAxisAlignment: MainAxisAlignment.end,
          ),
        );
        expect(text.position.x, layoutComponentSize.x - text.size.x);
        expect(rectangle.position.x, text.position.x - rectangle.size.x);
        expect(circle.position.x, rectangle.position.x - circle.size.x);
      });
      testWithFlameGame('mainAxisAlignment = center', (game) async {
        final circle = CircleComponent(radius: 20);
        final rectangle = RectangleComponent(size: Vector2(100, 50));
        final text = TextComponent(text: 'testing');
        final layoutComponentSize = Vector2.all(500);
        final rowComponent = RowComponent(
          children: [circle, rectangle, text],
          size: layoutComponentSize,
          mainAxisAlignment: MainAxisAlignment.center,
        );
        await game.ensureAdd(rowComponent);
        final occupiedSpace = circle.size.x + rectangle.size.x + text.size.x;
        final centerOffset = (layoutComponentSize.x - occupiedSpace) / 2;
        expect(circle.position.x, centerOffset);
        expect(rectangle.position.x, centerOffset + circle.size.x);
        expect(text.position.x, rectangle.position.x + rectangle.size.x);
      });
      testWithFlameGame('mainAxisAlignment = spaceBetween', (game) async {
        final circle = CircleComponent(radius: 20);
        final rectangle = RectangleComponent(size: Vector2(100, 50));
        final text = TextComponent(text: 'testing');
        final layoutComponentSize = Vector2.all(500);
        final rowComponent = RowComponent(
          children: [circle, rectangle, text],
          size: layoutComponentSize,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
        );
        await game.ensureAdd(rowComponent);
        final occupiedSpace = circle.size.x + rectangle.size.x + text.size.x;
        final expectedGap = (layoutComponentSize.x - occupiedSpace) / 2;
        expect(rowComponent.gap, expectedGap);
        expect(circle.position.x, 0);
        expect(rectangle.position.x, circle.size.x + expectedGap);
        expect(
          text.position.x,
          rectangle.position.x + rectangle.size.x + expectedGap,
        );
      });
      testWithFlameGame('mainAxisAlignment = spaceAround', (game) async {
        final circle = CircleComponent(radius: 20);
        final rectangle = RectangleComponent(size: Vector2(100, 50));
        final text = TextComponent(text: 'testing');
        final layoutComponentSize = Vector2.all(500);
        final rowComponent = RowComponent(
          children: [circle, rectangle, text],
          size: layoutComponentSize,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
        );
        await game.ensureAdd(rowComponent);
        final occupiedSpace = circle.size.x + rectangle.size.x + text.size.x;
        final expectedGap = (layoutComponentSize.x - occupiedSpace) / 3;
        expect(rowComponent.gap, expectedGap);
        expect(circle.position.x, expectedGap / 2);
        expect(
          rectangle.position.x,
          circle.position.x + circle.size.x + expectedGap,
        );
        expect(
          text.position.x,
          rectangle.position.x + rectangle.size.x + expectedGap,
        );
      });
      testWithFlameGame('mainAxisAlignment = spaceEvenly', (game) async {
        final circle = CircleComponent(radius: 20);
        final rectangle = RectangleComponent(size: Vector2(100, 50));
        final text = TextComponent(text: 'testing');
        final layoutComponentSize = Vector2.all(500);
        final rowComponent = RowComponent(
          children: [circle, rectangle, text],
          size: layoutComponentSize,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        );
        await game.ensureAdd(rowComponent);
        final occupiedSpace = circle.size.x + rectangle.size.x + text.size.x;
        final expectedGap = (layoutComponentSize.x - occupiedSpace) / 4;
        expect(rowComponent.gap, expectedGap);
        expect(circle.position.x, expectedGap);
        expect(
          rectangle.position.x,
          circle.position.x + circle.size.x + expectedGap,
        );
        expect(
          text.position.x,
          rectangle.position.x + rectangle.size.x + expectedGap,
        );
      });
    });
  });
}
