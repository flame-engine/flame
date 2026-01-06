import 'package:collection/collection.dart';
import 'package:flame/components.dart';
import 'package:flame/experimental.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter/rendering.dart';
import 'package:test/test.dart';
import 'linear_layout_component_test_helpers.dart';

void main() {
  group('LinearLayoutComponent', () {
    group('mainAxisAlignment', () {
      runLinearLayoutComponentTestRegistry(
        {
          'mainAxisAlignment = start': (game, direction) async {
            final circle = CircleComponent(radius: 20);
            final rectangle = RectangleComponent(size: Vector2(100, 50));
            final text = TextComponent(text: 'testing');
            await game.ensureAdd(
              LinearLayoutComponent.fromDirection(
                direction,
                children: [circle, rectangle, text],
              ),
            );
            expect(direction.mainAxisValue(circle.position), 0);
            expect(
              direction.mainAxisValue(rectangle.position),
              direction.mainAxisValue(circle.size),
            );
            expect(
              direction.mainAxisValue(text.position),
              direction.mainAxisValue(rectangle.position) +
                  direction.mainAxisValue(rectangle.size),
            );
          },
          'mainAxisAlignment = end': (game, direction) async {
            final circle = CircleComponent(radius: 20);
            final rectangle = RectangleComponent(size: Vector2(100, 50));
            final text = TextComponent(text: 'testing');
            final layoutComponentSize = Vector2.all(500);
            await game.ensureAdd(
              LinearLayoutComponent.fromDirection(
                direction,
                children: [circle, rectangle, text],
                size: layoutComponentSize,
                mainAxisAlignment: MainAxisAlignment.end,
              ),
            );
            final mainAxisValue = direction.mainAxisValue;
            expect(
              mainAxisValue(text.position),
              mainAxisValue(layoutComponentSize) - mainAxisValue(text.size),
            );
            expect(
              mainAxisValue(rectangle.position),
              mainAxisValue(text.position) - mainAxisValue(rectangle.size),
            );
            expect(
              mainAxisValue(circle.position),
              mainAxisValue(rectangle.position) - mainAxisValue(circle.size),
            );
          },
          'mainAxisAlignment = center, gap = 20': (game, direction) async {
            final circle = CircleComponent(radius: 20);
            final rectangle = RectangleComponent(size: Vector2(100, 50));
            final text = TextComponent(text: 'testing');
            final layoutComponentSize = Vector2.all(500);
            const gap = 20.0;
            final layoutComponent = LinearLayoutComponent.fromDirection(
              direction,
              children: [circle, rectangle, text],
              size: layoutComponentSize,
              mainAxisAlignment: MainAxisAlignment.center,
              gap: gap,
            );
            await game.ensureAdd(layoutComponent);
            final mainAxisValue = direction.mainAxisValue;
            final occupiedSpace = [
              circle.size,
              rectangle.size,
              text.size,
            ].map(mainAxisValue).sum;
            const gapSpace = gap * 2;
            final centerOffset =
                (mainAxisValue(layoutComponentSize) -
                    occupiedSpace -
                    gapSpace) /
                2;
            expect(mainAxisValue(circle.position), centerOffset);
            expect(
              mainAxisValue(rectangle.position),
              mainAxisValue(circle.position) + mainAxisValue(circle.size) + gap,
            );
            expect(
              mainAxisValue(text.position),
              mainAxisValue(rectangle.position) +
                  mainAxisValue(rectangle.size) +
                  gap,
            );
          },
          'mainAxisAlignment = spaceBetween': (game, direction) async {
            final circle = CircleComponent(radius: 20);
            final rectangle = RectangleComponent(size: Vector2(100, 50));
            final text = TextComponent(text: 'testing');
            final layoutComponentSize = Vector2.all(500);
            final layoutComponent = LinearLayoutComponent.fromDirection(
              direction,
              children: [circle, rectangle, text],
              size: layoutComponentSize,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
            );
            await game.ensureAdd(layoutComponent);
            final mainAxisValue = direction.mainAxisValue;
            final occupiedSpace = [
              circle.size,
              rectangle.size,
              text.size,
            ].map(mainAxisValue).sum;
            final expectedGap =
                (mainAxisValue(layoutComponentSize) - occupiedSpace) / 2;
            expect(layoutComponent.gap, expectedGap);
            expect(mainAxisValue(circle.position), 0);
            expect(
              mainAxisValue(rectangle.position),
              mainAxisValue(circle.size) + expectedGap,
            );
            expect(
              mainAxisValue(text.position),
              mainAxisValue(rectangle.position) +
                  mainAxisValue(rectangle.size) +
                  expectedGap,
            );
          },
          'mainAxisAlignment = spaceAround': (game, direction) async {
            final circle = CircleComponent(radius: 20);
            final rectangle = RectangleComponent(size: Vector2(100, 50));
            final text = TextComponent(text: 'testing');
            final layoutComponentSize = Vector2.all(500);
            final layoutComponent = LinearLayoutComponent.fromDirection(
              direction,
              children: [circle, rectangle, text],
              size: layoutComponentSize,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
            );
            await game.ensureAdd(layoutComponent);
            final mainAxisValue = direction.mainAxisValue;
            final occupiedSpace = [
              circle.size,
              rectangle.size,
              text.size,
            ].map(mainAxisValue).sum;
            final expectedGap =
                (mainAxisValue(layoutComponentSize) - occupiedSpace) / 3;
            expect(layoutComponent.gap, expectedGap);
            expect(
              mainAxisValue(circle.position),
              closeTo(expectedGap / 2, 1e-4),
            );
            expect(
              mainAxisValue(rectangle.position),
              closeTo(
                mainAxisValue(circle.position) +
                    mainAxisValue(circle.size) +
                    expectedGap,
                1e-4,
              ),
            );
            expect(
              mainAxisValue(text.position),
              closeTo(
                mainAxisValue(rectangle.position) +
                    mainAxisValue(rectangle.size) +
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
            final layoutComponent = LinearLayoutComponent.fromDirection(
              direction,
              children: [circle, rectangle, text],
              size: layoutComponentSize,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            );
            await game.ensureAdd(layoutComponent);
            final mainAxisValue = direction.mainAxisValue;
            final occupiedSpace = [
              circle.size,
              rectangle.size,
              text.size,
            ].map(mainAxisValue).sum;
            final expectedGap =
                (mainAxisValue(layoutComponentSize) - occupiedSpace) / 4;
            expect(layoutComponent.gap, expectedGap);
            expect(mainAxisValue(circle.position), expectedGap);
            expect(
              mainAxisValue(rectangle.position),
              mainAxisValue(circle.position) +
                  mainAxisValue(circle.size) +
                  expectedGap,
            );
            expect(
              mainAxisValue(text.position),
              mainAxisValue(rectangle.position) +
                  mainAxisValue(rectangle.size) +
                  expectedGap,
            );
          },
          'set mainAxisAlignment to spaceEvenly then end':
              (game, direction) async {
                final circle = CircleComponent(radius: 20);
                final rectangle = RectangleComponent(size: Vector2(100, 50));
                final text = TextComponent(text: 'testing');
                final layoutComponentSize = Vector2.all(500);
                final layoutComponent = LinearLayoutComponent.fromDirection(
                  direction,
                  children: [circle, rectangle, text],
                  size: layoutComponentSize,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                );
                await game.ensureAdd(layoutComponent);
                final mainAxisValue = direction.mainAxisValue;
                final occupiedSpace = [
                  circle.size,
                  rectangle.size,
                  text.size,
                ].map(mainAxisValue).sum;
                final expectedGap =
                    (mainAxisValue(layoutComponentSize) - occupiedSpace) / 4;
                expect(layoutComponent.gap, expectedGap);
                expect(mainAxisValue(circle.position), expectedGap);
                expect(
                  mainAxisValue(rectangle.position),
                  mainAxisValue(circle.position) +
                      mainAxisValue(circle.size) +
                      expectedGap,
                );
                expect(
                  mainAxisValue(text.position),
                  mainAxisValue(rectangle.position) +
                      mainAxisValue(rectangle.size) +
                      expectedGap,
                );
                layoutComponent.mainAxisAlignment = MainAxisAlignment.end;
                expect(
                  mainAxisValue(text.positionOfAnchor(Anchor.bottomRight)),
                  mainAxisValue(layoutComponentSize),
                );
              },
        },
      );
    });

    group('crossAxisAlignment', () {
      runLinearLayoutComponentTestRegistry({
        'crossAxisAlignment = start': (game, direction) async {
          final circle = CircleComponent(radius: 20);
          final rectangle = RectangleComponent(size: Vector2(100, 50));
          final text = TextComponent(text: 'testing');
          final layoutComponentSize = Vector2.all(500);
          final layoutComponent = LinearLayoutComponent.fromDirection(
            direction,
            children: [circle, rectangle, text],
            size: layoutComponentSize,
          );
          await game.ensureAdd(layoutComponent);
          final crossAxisValue = direction.crossAxisValue;
          expect(crossAxisValue(circle.position), 0);
          expect(crossAxisValue(rectangle.position), 0);
          expect(crossAxisValue(text.position), 0);
        },
        'crossAxisAlignment = center': (game, direction) async {
          final circle = CircleComponent(radius: 20);
          final rectangle = RectangleComponent(size: Vector2(100, 50));
          final text = TextComponent(text: 'testing');
          final layoutComponentSize = Vector2.all(500);
          final layoutComponent = LinearLayoutComponent.fromDirection(
            direction,
            children: [circle, rectangle, text],
            size: layoutComponentSize,
            crossAxisAlignment: CrossAxisAlignment.center,
          );
          await game.ensureAdd(layoutComponent);
          final crossAxisValue = direction.crossAxisValue;
          expect(
            crossAxisValue(circle.position),
            (crossAxisValue(layoutComponentSize) -
                    crossAxisValue(circle.size)) /
                2,
          );
          expect(
            crossAxisValue(rectangle.position),
            (crossAxisValue(layoutComponentSize) -
                    crossAxisValue(rectangle.size)) /
                2,
          );
          expect(
            crossAxisValue(text.position),
            (crossAxisValue(layoutComponentSize) - crossAxisValue(text.size)) /
                2,
          );
        },
        'crossAxisAlignment = end': (game, direction) async {
          final circle = CircleComponent(radius: 20);
          final rectangle = RectangleComponent(size: Vector2(100, 50));
          final text = TextComponent(text: 'testing');
          final layoutComponentSize = Vector2.all(500);
          final layoutComponent = LinearLayoutComponent.fromDirection(
            direction,
            children: [circle, rectangle, text],
            size: layoutComponentSize,
            crossAxisAlignment: CrossAxisAlignment.end,
          );
          await game.ensureAdd(layoutComponent);
          final crossAxisValue = direction.crossAxisValue;
          expect(
            crossAxisValue(circle.position),
            crossAxisValue(layoutComponentSize) - crossAxisValue(circle.size),
          );
          expect(
            crossAxisValue(rectangle.position),
            crossAxisValue(layoutComponentSize) -
                crossAxisValue(rectangle.size),
          );
          expect(
            crossAxisValue(text.position),
            crossAxisValue(layoutComponentSize) - crossAxisValue(text.size),
          );
        },
      });
    });

    group('size', () {
      runLinearLayoutComponentTestRegistry({
        'size=null sets size to intrinsicSize': (game, direction) async {
          final circle = CircleComponent(radius: 20);
          final rectangle = RectangleComponent(size: Vector2(100, 50));
          final text = TextComponent(text: 'testing');
          final layoutComponentSize = Vector2.all(500);
          final layoutComponent = LinearLayoutComponent.fromDirection(
            direction,
            children: [circle, rectangle, text],
            size: layoutComponentSize,
          );
          await game.ensureAdd(layoutComponent);
          expect(layoutComponent.size, layoutComponentSize);
          layoutComponent.setLayoutSize(null, null);
          expect(layoutComponent.size, layoutComponent.intrinsicSize);
        },
        'size=null ignores mainAxisAlignment': (game, direction) async {
          final circle = CircleComponent(radius: 20);
          final rectangle = RectangleComponent(size: Vector2(100, 50));
          final text = TextComponent(text: 'testing');
          final layoutComponent = LinearLayoutComponent.fromDirection(
            direction,
            children: [circle, rectangle, text],
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
          );
          await game.ensureAdd(layoutComponent);
          expect(layoutComponent.mainAxisAlignment, MainAxisAlignment.start);
        },
        'size=null respects supported crossAxisAlignments':
            (game, direction) async {
              final circle = CircleComponent(radius: 20);
              final rectangle = RectangleComponent(size: Vector2(100, 50));
              final text = TextComponent(text: 'testing');
              final layoutComponent = LinearLayoutComponent.fromDirection(
                direction,
                children: [circle, rectangle, text],
                crossAxisAlignment: CrossAxisAlignment.center,
              );
              await game.ensureAdd(layoutComponent);
              expect(
                layoutComponent.crossAxisAlignment,
                CrossAxisAlignment.center,
              );
              layoutComponent.crossAxisAlignment = CrossAxisAlignment.end;
              expect(
                layoutComponent.crossAxisAlignment,
                CrossAxisAlignment.end,
              );
              layoutComponent.crossAxisAlignment = CrossAxisAlignment.start;
              expect(
                layoutComponent.crossAxisAlignment,
                CrossAxisAlignment.start,
              );
            },
        'size=null with CrossAxisAlignment.stretch expands children as usual':
            (game, direction) async {
              final circle = CircleComponent(radius: 20);
              final rectangle = RectangleComponent(size: Vector2(100, 50));
              final text = TextComponent(text: 'testing');
              final layoutComponent = LinearLayoutComponent.fromDirection(
                direction,
                children: [circle, rectangle, text],
                crossAxisAlignment: CrossAxisAlignment.stretch,
              );
              await game.ensureAdd(layoutComponent);
              final crossAxisLengths = layoutComponent.positionChildren.map(
                (component) => component.size[direction.crossAxis.axisIndex],
              );
              // All the cross axis lengths are the same
              expect(
                crossAxisLengths.every(
                  (length) => length == crossAxisLengths.first,
                ),
                true,
              );
              expect(
                crossAxisLengths.first,
                layoutComponent.size[direction.crossAxis.axisIndex],
              );
            },
      });
    });
    group('children', () {
      runLinearLayoutComponentTestRegistry(
        {
          'size responds when children are added and then resized':
              (game, direction) async {
                final circle = CircleComponent(radius: 20);
                final rectangle2 = RectangleComponent(size: Vector2(100, 50));
                final layoutComponent = LinearLayoutComponent.fromDirection(
                  direction,
                );
                await game.ensureAdd(layoutComponent);
                expect(layoutComponent.size, Vector2.zero());
                await layoutComponent.ensureAddAll([
                  circle,
                  rectangle2,
                ]);
                rectangle2.size = Vector2(200, 70);
                expect(
                  layoutComponent.size,
                  switch (direction) {
                    Direction.horizontal => Vector2(40 + 200, 70),
                    Direction.vertical => Vector2(200, 70 + 40),
                  },
                );
              },
          'ExpandedComponent among children are sized correctly':
              (game, direction) async {
                final circle = CircleComponent(radius: 20);
                final rectangle = RectangleComponent(size: Vector2(100, 50));
                final expandedComponent = ExpandedComponent(child: rectangle);
                final layoutComponent = LinearLayoutComponent.fromDirection(
                  direction,
                  size: Vector2(200, 100),
                  children: [circle, expandedComponent],
                );
                await game.ensureAdd(layoutComponent);
                expect(
                  expandedComponent.size,
                  switch (direction) {
                    Direction.horizontal => Vector2(200 - 40, 50),
                    Direction.vertical => Vector2(100, 100 - 40),
                  },
                );
                expect(expandedComponent.child?.size, expandedComponent.size);
              },
        },
      );
    });

    group('special behaviors', () {
      testWithFlameGame(
        'ColumnComponent with crossAxisAlignment = stretch, will set '
        'TextBoxComponent child maxWidth',
        (game) async {
          final textBoxComponent = TextBoxComponent(
            text: 'The quick brown fox jumps over the lazy dog.',
          );
          final layoutComponentSize = Vector2.all(500);
          final layoutComponent = ColumnComponent(
            size: layoutComponentSize,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [textBoxComponent],
          );
          await game.ensureAdd(layoutComponent);
          expect(textBoxComponent.boxConfig.maxWidth, layoutComponent.width);
        },
      );
      testWithFlameGame(
        'setLayoutSize and setLayoutAxisLength each notify once',
        (game) async {
          final layoutComponent = ColumnComponent();
          await game.ensureAdd(layoutComponent);
          var setLayoutSizeCallCount = 0;
          var setLayoutAxisLengthCallCount = 0;
          void firstListener() {
            setLayoutSizeCallCount += 1;
          }

          void secondListener() {
            setLayoutAxisLengthCallCount += 1;
          }

          layoutComponent.size.addListener(firstListener);
          layoutComponent.setLayoutSize(100, 100);
          await game.lifecycleEventsProcessed;
          layoutComponent.size.removeListener(firstListener);
          expect(setLayoutSizeCallCount, 1);
          expect(layoutComponent.size, Vector2(100, 100));

          layoutComponent.size.addListener(secondListener);
          layoutComponent.setLayoutAxisLength(LayoutAxis.x, 200);
          await game.lifecycleEventsProcessed;
          layoutComponent.size.removeListener(secondListener);
          expect(setLayoutAxisLengthCallCount, 1);
          expect(layoutComponent.size, Vector2(200, 100));
        },
      );
    });
  });
}
