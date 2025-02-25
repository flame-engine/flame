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
      testWithFlameGame('crossAlignment = start', (game) async {
        final circle = CircleComponent(radius: 20);
        final rectangle = RectangleComponent(size: Vector2(100, 50));
        final text = TextComponent(text: 'testing');
        final layoutComponentSize = Vector2.all(500);
        final rowComponent = RowComponent(
          children: [circle, rectangle, text],
          size: layoutComponentSize,
        );
        await game.ensureAdd(rowComponent);
        expect(circle.position.y, 0);
        expect(rectangle.position.y, 0);
        expect(text.position.y, 0);
      });
      testWithFlameGame('crossAlignment = center', (game) async {
        final circle = CircleComponent(radius: 20);
        final rectangle = RectangleComponent(size: Vector2(100, 50));
        final text = TextComponent(text: 'testing');
        final layoutComponentSize = Vector2.all(500);
        final rowComponent = RowComponent(
          children: [circle, rectangle, text],
          size: layoutComponentSize,
          crossAxisAlignment: CrossAxisAlignment.center,
        );
        await game.ensureAdd(rowComponent);
        expect(circle.position.y, (layoutComponentSize.y - circle.size.y) / 2);
        expect(
          rectangle.position.y,
          (layoutComponentSize.y - rectangle.size.y) / 2,
        );
        expect(text.position.y, (layoutComponentSize.y - text.size.y) / 2);
      });
      testWithFlameGame('crossAlignment = end', (game) async {
        final circle = CircleComponent(radius: 20);
        final rectangle = RectangleComponent(size: Vector2(100, 50));
        final text = TextComponent(text: 'testing');
        final layoutComponentSize = Vector2.all(500);
        final rowComponent = RowComponent(
          children: [circle, rectangle, text],
          size: layoutComponentSize,
          crossAxisAlignment: CrossAxisAlignment.end,
        );
        await game.ensureAdd(rowComponent);
        expect(circle.position.y, layoutComponentSize.y - circle.size.y);
        expect(rectangle.position.y, layoutComponentSize.y - rectangle.size.y);
        expect(text.position.y, layoutComponentSize.y - text.size.y);
      });
    });
    group('ColumnComponent', () {
      testWithFlameGame('mainAxisAlignment = start', (game) async {
        final circle = CircleComponent(radius: 20);
        final rectangle = RectangleComponent(size: Vector2(100, 50));
        final text = TextComponent(text: 'testing');
        final layoutComponent =
            ColumnComponent(children: [circle, rectangle, text]);
        await game.ensureAdd(layoutComponent);
        expect(circle.position.y, 0);
        expect(rectangle.position.y, circle.size.y);
        expect(text.position.y, rectangle.position.y + rectangle.size.y);
      });
      testWithFlameGame('mainAxisAlignment = end', (game) async {
        final circle = CircleComponent(radius: 20);
        final rectangle = RectangleComponent(size: Vector2(100, 50));
        final text = TextComponent(text: 'testing');
        final layoutComponentSize = Vector2.all(500);
        final layoutComponent = ColumnComponent(
          children: [circle, rectangle, text],
          size: layoutComponentSize,
          mainAxisAlignment: MainAxisAlignment.end,
        );
        await game.ensureAdd(layoutComponent);
        expect(text.position.y, layoutComponentSize.y - text.size.y);
        expect(rectangle.position.y, text.position.y - rectangle.size.y);
        expect(circle.position.y, rectangle.position.y - circle.size.y);
      });
      testWithFlameGame('mainAxisAlignment = center', (game) async {
        final circle = CircleComponent(radius: 20);
        final rectangle = RectangleComponent(size: Vector2(100, 50));
        final text = TextComponent(text: 'testing');
        final layoutComponentSize = Vector2.all(500);
        final layoutComponent = ColumnComponent(
          children: [circle, rectangle, text],
          size: layoutComponentSize,
          mainAxisAlignment: MainAxisAlignment.center,
        );
        await game.ensureAdd(layoutComponent);
        final occupiedSpace = circle.size.y + rectangle.size.y + text.size.y;
        final centerOffset = (layoutComponentSize.y - occupiedSpace) / 2;
        expect(circle.position.y, centerOffset);
        expect(rectangle.position.y, centerOffset + circle.size.y);
        expect(text.position.y, rectangle.position.y + rectangle.size.y);
      });
      testWithFlameGame('mainAxisAlignment = spaceBetween', (game) async {
        final circle = CircleComponent(radius: 20);
        final rectangle = RectangleComponent(size: Vector2(100, 50));
        final text = TextComponent(text: 'testing');
        final layoutComponentSize = Vector2.all(500);
        final layoutComponent = ColumnComponent(
          children: [circle, rectangle, text],
          size: layoutComponentSize,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
        );
        await game.ensureAdd(layoutComponent);
        final occupiedSpace = circle.size.y + rectangle.size.y + text.size.y;
        final expectedGap = (layoutComponentSize.y - occupiedSpace) / 2;
        expect(layoutComponent.gap, expectedGap);
        expect(circle.position.y, 0);
        expect(rectangle.position.y, circle.size.y + expectedGap);
        expect(
          text.position.y,
          rectangle.position.y + rectangle.size.y + expectedGap,
        );
      });
      testWithFlameGame('mainAxisAlignment = spaceAround', (game) async {
        final circle = CircleComponent(radius: 20);
        final rectangle = RectangleComponent(size: Vector2(100, 50));
        final text = TextComponent(text: 'testing');
        final layoutComponentSize = Vector2.all(500);
        final layoutComponent = ColumnComponent(
          children: [circle, rectangle, text],
          size: layoutComponentSize,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
        );
        await game.ensureAdd(layoutComponent);
        final occupiedSpace = circle.size.y + rectangle.size.y + text.size.y;
        final expectedGap = (layoutComponentSize.y - occupiedSpace) / 3;
        expect(layoutComponent.gap, expectedGap);
        expect(circle.position.y, expectedGap / 2);
        expect(
          rectangle.position.y,
          circle.position.y + circle.size.y + expectedGap,
        );
        expect(
          text.position.y,
          rectangle.position.y + rectangle.size.y + expectedGap,
        );
      });
      testWithFlameGame('mainAxisAlignment = spaceEvenly', (game) async {
        final circle = CircleComponent(radius: 20);
        final rectangle = RectangleComponent(size: Vector2(100, 50));
        final text = TextComponent(text: 'testing');
        final layoutComponentSize = Vector2.all(500);
        final layoutComponent = ColumnComponent(
          children: [circle, rectangle, text],
          size: layoutComponentSize,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        );
        await game.ensureAdd(layoutComponent);
        final occupiedSpace = circle.size.y + rectangle.size.y + text.size.y;
        final expectedGap = (layoutComponentSize.y - occupiedSpace) / 4;
        expect(layoutComponent.gap, expectedGap);
        expect(circle.position.y, expectedGap);
        expect(
          rectangle.position.y,
          circle.position.y + circle.size.y + expectedGap,
        );
        expect(
          text.position.y,
          rectangle.position.y + rectangle.size.y + expectedGap,
        );
      });
      testWithFlameGame('crossAlignment = start', (game) async {
        final circle = CircleComponent(radius: 20);
        final rectangle = RectangleComponent(size: Vector2(100, 50));
        final text = TextComponent(text: 'testing');
        final layoutComponentSize = Vector2.all(500);
        final layoutComponent = ColumnComponent(
          children: [circle, rectangle, text],
          size: layoutComponentSize,
        );
        await game.ensureAdd(layoutComponent);
        expect(circle.position.x, 0);
        expect(rectangle.position.x, 0);
        expect(text.position.x, 0);
      });
      testWithFlameGame('crossAlignment = center', (game) async {
        final circle = CircleComponent(radius: 20);
        final rectangle = RectangleComponent(size: Vector2(100, 50));
        final text = TextComponent(text: 'testing');
        final layoutComponentSize = Vector2.all(500);
        final layoutComponent = ColumnComponent(
          children: [circle, rectangle, text],
          size: layoutComponentSize,
          crossAxisAlignment: CrossAxisAlignment.center,
        );
        await game.ensureAdd(layoutComponent);
        expect(circle.position.x, (layoutComponentSize.x - circle.size.x) / 2);
        expect(
          rectangle.position.x,
          (layoutComponentSize.x - rectangle.size.x) / 2,
        );
        expect(text.position.x, (layoutComponentSize.x - text.size.x) / 2);
      });
      testWithFlameGame('crossAlignment = end', (game) async {
        final circle = CircleComponent(radius: 20);
        final rectangle = RectangleComponent(size: Vector2(100, 50));
        final text = TextComponent(text: 'testing');
        final layoutComponentSize = Vector2.all(500);
        final layoutComponent = ColumnComponent(
          children: [circle, rectangle, text],
          size: layoutComponentSize,
          crossAxisAlignment: CrossAxisAlignment.end,
        );
        await game.ensureAdd(layoutComponent);
        expect(circle.position.x, layoutComponentSize.x - circle.size.x);
        expect(rectangle.position.x, layoutComponentSize.x - rectangle.size.x);
        expect(text.position.x, layoutComponentSize.x - text.size.x);
      });
    });
  });
}
