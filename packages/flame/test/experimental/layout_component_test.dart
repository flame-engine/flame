import 'package:flame/components.dart';
import 'package:flame/experimental.dart';
import 'package:flame/game.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Component component;
  late Vector2 gameSize;

  late PositionComponent firstComponent;
  late PositionComponent secondComponent;
  late PositionComponent thirdComponent;
  late double totalSizeOfComponents;

  void _initChildren() {
    firstComponent = PositionComponent(
      size: Vector2.all(50),
    );

    secondComponent = PositionComponent(
      size: Vector2.all(100),
    );

    thirdComponent = PositionComponent(
      size: Vector2.all(150),
    );
  }

  for (var k = 0; k <= 1; k++) {
    group(k == 0 ? 'RowComponent' : 'ColumnComponent', () {
      late PositionComponent layoutComponent;
      setUp(() async {
        component = Component();
        gameSize = Vector2(1000, 768);
        component.onGameResize(gameSize);
        _initChildren();
        totalSizeOfComponents = firstComponent.size[k] +
            secondComponent.size[k] +
            thirdComponent.size[k];
      });

      Future<void> _initScene(
        FlameGame game,
        LayoutComponentAlignment alignment,
        Vector2 position, [
        double gap = 0.0,
      ]) async {
        await game.add(component);
        game.onGameResize(gameSize);
        await component.add(
          k == 0
              ? layoutComponent = RowComponent(
                  alignment: alignment,
                  gap: gap,
                )
              : layoutComponent = ColumnComponent(
                  alignment: alignment,
                  gap: gap,
                ),
        );
        layoutComponent.position = position;
        await layoutComponent
            .ensureAddAll([firstComponent, secondComponent, thirdComponent]);
        await game.ready();
      }

      testWithFlameGame('layoutComponentAlignment.start with position',
          (game) async {
        await _initScene(game, LayoutComponentAlignment.start, Vector2.all(50));
        expect(firstComponent.absolutePosition[k], 50);

        /// these positions refer to inside rowComponent
        expect(firstComponent.position[k], 0);
        expect(secondComponent.position[k], 50);
        expect(thirdComponent.position[k], 150);
      });

      testWithFlameGame('layoutComponentAlignment.start with position and gap',
          (game) async {
        await _initScene(
          game,
          LayoutComponentAlignment.start,
          Vector2.all(50),
          10,
        );
        expect(firstComponent.absolutePosition[k], 50);
        expect(firstComponent.position[k], 0);
        expect(secondComponent.position[k], 60);
        expect(thirdComponent.position[k], 170);
      });

      testWithFlameGame('layoutComponentAlignment.end with position',
          (game) async {
        await _initScene(game, LayoutComponentAlignment.end, Vector2.all(500));
        expect(firstComponent.absolutePosition[k], 200);
        expect(firstComponent.position[k], -300);
        expect(secondComponent.position[k], -250);
        expect(thirdComponent.position[k], -150);
      });

      testWithFlameGame('layoutComponentAlignment.end with position and gap',
          (game) async {
        await _initScene(
          game,
          LayoutComponentAlignment.end,
          Vector2.all(500),
          20,
        );
        expect(firstComponent.absolutePosition[k], 160);
        expect(firstComponent.position[k], -340);
        expect(secondComponent.position[k], -270);
        expect(thirdComponent.position[k], -150);
      });

      testWithFlameGame('layoutComponentAlignment.center with position',
          (game) async {
        await _initScene(
          game,
          LayoutComponentAlignment.center,
          Vector2.all(50),
        );
        final startPosition =
            (layoutComponent.size[k] - totalSizeOfComponents) / 2;
        expect(firstComponent.position[k], startPosition);
        expect(secondComponent.position[k], startPosition + 50);
        expect(thirdComponent.position[k], startPosition + 150);
      });

      testWithFlameGame('layoutComponentAlignment.center with position and gap',
          (game) async {
        await _initScene(
          game,
          LayoutComponentAlignment.center,
          Vector2.all(50),
          10,
        );
        final startPosition =
            (layoutComponent.size[k] - totalSizeOfComponents - 20) / 2;
        expect(firstComponent.absolutePosition[k], startPosition + 50);
        expect(firstComponent.position[k], startPosition);
        expect(secondComponent.position[k], startPosition + 60);
        expect(thirdComponent.position[k], startPosition + 170);
      });
    });
  }
}
