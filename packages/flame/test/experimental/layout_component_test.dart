import 'package:collection/collection.dart';
import 'package:flame/components.dart';
import 'package:flame/experimental.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter/rendering.dart';
import 'package:test/test.dart';
import 'layout_component_test_helpers.dart';

void main() {
  group('LayoutComponent', () {
    group('mainAxisAlignment', () {
      runLayoutComponentTestRegistry(
        {
          'mainAxisAlignment = start': (game, direction) async {
            final circle = CircleComponent(radius: 20);
            final rectangle = RectangleComponent(size: Vector2(100, 50));
            final text = TextComponent(text: 'testing');
            await game.ensureAdd(
              LayoutComponent.fromDirection(
                direction,
                children: [circle, rectangle, text],
              ),
            );
            expect(direction.mainAxis(circle.position), 0);
            expect(
              direction.mainAxis(rectangle.position),
              direction.mainAxis(circle.size),
            );
            expect(
              direction.mainAxis(text.position),
              direction.mainAxis(rectangle.position) +
                  direction.mainAxis(rectangle.size),
            );
          },
          'mainAxisAlignment = end': (game, direction) async {
            final circle = CircleComponent(radius: 20);
            final rectangle = RectangleComponent(size: Vector2(100, 50));
            final text = TextComponent(text: 'testing');
            final layoutComponentSize = Vector2.all(500);
            await game.ensureAdd(
              LayoutComponent.fromDirection(
                direction,
                children: [circle, rectangle, text],
                size: layoutComponentSize,
                mainAxisAlignment: MainAxisAlignment.end,
              ),
            );
            final mainAxis = direction.mainAxis;
            expect(
              mainAxis(text.position),
              mainAxis(layoutComponentSize) - mainAxis(text.size),
            );
            expect(
              mainAxis(rectangle.position),
              mainAxis(text.position) - mainAxis(rectangle.size),
            );
            expect(
              mainAxis(circle.position),
              mainAxis(rectangle.position) - mainAxis(circle.size),
            );
          },
          'mainAxisAlignment = center, gap = 20': (game, direction) async {
            final circle = CircleComponent(radius: 20);
            final rectangle = RectangleComponent(size: Vector2(100, 50));
            final text = TextComponent(text: 'testing');
            final layoutComponentSize = Vector2.all(500);
            const gap = 20.0;
            final layoutComponent = LayoutComponent.fromDirection(
              direction,
              children: [circle, rectangle, text],
              size: layoutComponentSize,
              mainAxisAlignment: MainAxisAlignment.center,
              gap: gap,
            );
            await game.ensureAdd(layoutComponent);
            final mainAxis = direction.mainAxis;
            final occupiedSpace =
                [circle.size, rectangle.size, text.size].map(mainAxis).sum;
            const gapSpace = gap * 2;
            final centerOffset =
                (mainAxis(layoutComponentSize) - occupiedSpace - gapSpace) / 2;
            expect(mainAxis(circle.position), centerOffset);
            expect(
              mainAxis(rectangle.position),
              mainAxis(circle.position) + mainAxis(circle.size) + gap,
            );
            expect(
              mainAxis(text.position),
              mainAxis(rectangle.position) + mainAxis(rectangle.size) + gap,
            );
          },
          'mainAxisAlignment = spaceBetween': (game, direction) async {
            final circle = CircleComponent(radius: 20);
            final rectangle = RectangleComponent(size: Vector2(100, 50));
            final text = TextComponent(text: 'testing');
            final layoutComponentSize = Vector2.all(500);
            final layoutComponent = LayoutComponent.fromDirection(
              direction,
              children: [circle, rectangle, text],
              size: layoutComponentSize,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
            );
            await game.ensureAdd(layoutComponent);
            final mainAxis = direction.mainAxis;
            final occupiedSpace =
                [circle.size, rectangle.size, text.size].map(mainAxis).sum;
            final expectedGap =
                (mainAxis(layoutComponentSize) - occupiedSpace) / 2;
            expect(layoutComponent.gap, expectedGap);
            expect(mainAxis(circle.position), 0);
            expect(
              mainAxis(rectangle.position),
              mainAxis(circle.size) + expectedGap,
            );
            expect(
              mainAxis(text.position),
              mainAxis(rectangle.position) +
                  mainAxis(rectangle.size) +
                  expectedGap,
            );
          },
          'mainAxisAlignment = spaceAround': (game, direction) async {
            final circle = CircleComponent(radius: 20);
            final rectangle = RectangleComponent(size: Vector2(100, 50));
            final text = TextComponent(text: 'testing');
            final layoutComponentSize = Vector2.all(500);
            final layoutComponent = LayoutComponent.fromDirection(
              direction,
              children: [circle, rectangle, text],
              size: layoutComponentSize,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
            );
            await game.ensureAdd(layoutComponent);
            final mainAxis = direction.mainAxis;
            final occupiedSpace =
                [circle.size, rectangle.size, text.size].map(mainAxis).sum;
            final expectedGap =
                (mainAxis(layoutComponentSize) - occupiedSpace) / 3;
            expect(layoutComponent.gap, expectedGap);
            expect(mainAxis(circle.position), closeTo(expectedGap / 2, 1e-4));
            expect(
              mainAxis(rectangle.position),
              closeTo(
                mainAxis(circle.position) + mainAxis(circle.size) + expectedGap,
                1e-4,
              ),
            );
            expect(
              mainAxis(text.position),
              closeTo(
                mainAxis(rectangle.position) +
                    mainAxis(rectangle.size) +
                    expectedGap,
                1e-4,
              ),
            );
          },
          'mainAxisAlignment = spaceEvenly': (game, direction) async {
            final circle = CircleComponent(radius: 20);
            final rectangle = RectangleComponent(size: Vector2(100, 50));
            final text = TextComponent(text: 'testing');
            final layoutComponentSize = Vector2.all(500);
            final layoutComponent = LayoutComponent.fromDirection(
              direction,
              children: [circle, rectangle, text],
              size: layoutComponentSize,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            );
            await game.ensureAdd(layoutComponent);
            final mainAxis = direction.mainAxis;
            final occupiedSpace =
                [circle.size, rectangle.size, text.size].map(mainAxis).sum;
            final expectedGap =
                (mainAxis(layoutComponentSize) - occupiedSpace) / 4;
            expect(layoutComponent.gap, expectedGap);
            expect(mainAxis(circle.position), expectedGap);
            expect(
              mainAxis(rectangle.position),
              mainAxis(circle.position) + mainAxis(circle.size) + expectedGap,
            );
            expect(
              mainAxis(text.position),
              mainAxis(rectangle.position) +
                  mainAxis(rectangle.size) +
                  expectedGap,
            );
          },
        },
      );
    });

    group('crossAxisAlignment', () {
      runLayoutComponentTestRegistry({
        'crossAlignment = start': (game, direction) async {
          final circle = CircleComponent(radius: 20);
          final rectangle = RectangleComponent(size: Vector2(100, 50));
          final text = TextComponent(text: 'testing');
          final layoutComponentSize = Vector2.all(500);
          final layoutComponent = LayoutComponent.fromDirection(
            direction,
            children: [circle, rectangle, text],
            size: layoutComponentSize,
          );
          await game.ensureAdd(layoutComponent);
          final crossAxis = direction.crossAxis;
          expect(crossAxis(circle.position), 0);
          expect(crossAxis(rectangle.position), 0);
          expect(crossAxis(text.position), 0);
        },
        'crossAlignment = center': (game, direction) async {
          final circle = CircleComponent(radius: 20);
          final rectangle = RectangleComponent(size: Vector2(100, 50));
          final text = TextComponent(text: 'testing');
          final layoutComponentSize = Vector2.all(500);
          final layoutComponent = LayoutComponent.fromDirection(
            direction,
            children: [circle, rectangle, text],
            size: layoutComponentSize,
            crossAxisAlignment: CrossAxisAlignment.center,
          );
          await game.ensureAdd(layoutComponent);
          final crossAxis = direction.crossAxis;
          expect(
            crossAxis(circle.position),
            (crossAxis(layoutComponentSize) - crossAxis(circle.size)) / 2,
          );
          expect(
            crossAxis(rectangle.position),
            (crossAxis(layoutComponentSize) - crossAxis(rectangle.size)) / 2,
          );
          expect(
            crossAxis(text.position),
            (crossAxis(layoutComponentSize) - crossAxis(text.size)) / 2,
          );
        },
        'crossAlignment = end': (game, direction) async {
          final circle = CircleComponent(radius: 20);
          final rectangle = RectangleComponent(size: Vector2(100, 50));
          final text = TextComponent(text: 'testing');
          final layoutComponentSize = Vector2.all(500);
          final layoutComponent = LayoutComponent.fromDirection(
            direction,
            children: [circle, rectangle, text],
            size: layoutComponentSize,
            crossAxisAlignment: CrossAxisAlignment.end,
          );
          await game.ensureAdd(layoutComponent);
          final crossAxis = direction.crossAxis;
          expect(
            crossAxis(circle.position),
            crossAxis(layoutComponentSize) - crossAxis(circle.size),
          );
          expect(
            crossAxis(rectangle.position),
            crossAxis(layoutComponentSize) - crossAxis(rectangle.size),
          );
          expect(
            crossAxis(text.position),
            crossAxis(layoutComponentSize) - crossAxis(text.size),
          );
        },
      });
    });

    group('shrinkWrap', () {
      runLayoutComponentTestRegistry({
        'shrinkWrap=true ignores size': (game, direction) async {
          final circle = CircleComponent(radius: 20);
          final rectangle = RectangleComponent(size: Vector2(100, 50));
          final text = TextComponent(text: 'testing');
          final layoutComponentSize = Vector2.all(500);
          final layoutComponent = LayoutComponent.fromDirection(
            direction,
            shrinkWrap: true,
            children: [circle, rectangle, text],
            size: layoutComponentSize,
          );
          await game.ensureAdd(layoutComponent);
          expect(layoutComponent.size, layoutComponent.inherentSize);
        },
        'shrinkWrap=true ignores mainAxisAlignment': (game, direction) async {
          final circle = CircleComponent(radius: 20);
          final rectangle = RectangleComponent(size: Vector2(100, 50));
          final text = TextComponent(text: 'testing');
          final layoutComponent = LayoutComponent.fromDirection(
            direction,
            shrinkWrap: true,
            children: [circle, rectangle, text],
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
          );
          await game.ensureAdd(layoutComponent);
          expect(layoutComponent.mainAxisAlignment, MainAxisAlignment.start);
        },
        'shrinkWrap=true respects supported crossAxisAlignments':
            (game, direction) async {
          final circle = CircleComponent(radius: 20);
          final rectangle = RectangleComponent(size: Vector2(100, 50));
          final text = TextComponent(text: 'testing');
          final layoutComponent = LayoutComponent.fromDirection(
            direction,
            shrinkWrap: true,
            children: [circle, rectangle, text],
            crossAxisAlignment: CrossAxisAlignment.center,
          );
          await game.ensureAdd(layoutComponent);
          expect(layoutComponent.crossAxisAlignment, CrossAxisAlignment.center);
          layoutComponent.crossAxisAlignment = CrossAxisAlignment.end;
          expect(layoutComponent.crossAxisAlignment, CrossAxisAlignment.end);
          layoutComponent.crossAxisAlignment = CrossAxisAlignment.start;
          expect(layoutComponent.crossAxisAlignment, CrossAxisAlignment.start);
        },
        "shrinkWrap=true doesn't respect CrossAxisAlignment.stretch":
            (game, direction) async {
          final circle = CircleComponent(radius: 20);
          final rectangle = RectangleComponent(size: Vector2(100, 50));
          final text = TextComponent(text: 'testing');
          final layoutComponent = LayoutComponent.fromDirection(
            direction,
            shrinkWrap: true,
            children: [circle, rectangle, text],
            crossAxisAlignment: CrossAxisAlignment.stretch,
          );
          await game.ensureAdd(layoutComponent);
          expect(layoutComponent.crossAxisAlignment, CrossAxisAlignment.start);
        },
      });
    });
  });
}
