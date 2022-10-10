import 'package:flame/components.dart';
import 'package:flame/experimental.dart';
import 'package:flame/game.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter/material.dart';
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
      size: Vector2(50, 50),
    );

    secondComponent = PositionComponent(
      size: Vector2(100, 100),
    );

    thirdComponent = PositionComponent(
      size: Vector2(150, 150),
    );
  }

  for (var k = 0; k <= 1; k++) {
    group(k == 0 ? 'RowComponent' : 'ColumnComponent', () {
      late LayoutComponent layoutComponent;
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
        MainAxisAlignment alignment,
        Vector2 position, [
        double gap = 0.0,
      ]) async {
        await game.add(component);
        game.onGameResize(gameSize);
        await component.add(
          k == 0
              ? layoutComponent = RowComponent(
                  mainAxisAlignment: alignment,
                  gap: gap,
                  size: Vector2(1000, 768),
                )
              : layoutComponent = ColumnComponent(
                  mainAxisAlignment: alignment,
                  gap: gap,
                  size: Vector2(1000, 768),
                ),
        );
        layoutComponent.position = position;
        await layoutComponent
            .ensureAddAll([firstComponent, secondComponent, thirdComponent]);
        await game.ready();
      }

      testWithFlameGame('mainAxisAlignment.start with position and size',
          (game) async {
        await _initScene(game, MainAxisAlignment.start, Vector2(50, 50));
        expect(firstComponent.absolutePosition[k], 50);

        /// these positions refer to inside rowComponent
        expect(firstComponent.position[k], 0);
        expect(secondComponent.position[k], 50);
        expect(thirdComponent.position[k], 150);
      });

      testWithFlameGame('mainAxisAlignment.start with position, size and gap',
          (game) async {
        await _initScene(game, MainAxisAlignment.start, Vector2(50, 50), 10);
        expect(firstComponent.absolutePosition[k], 50);
        expect(firstComponent.position[k], 0);
        expect(secondComponent.position[k], 60);
        expect(thirdComponent.position[k], 170);
      });

      testWithFlameGame('mainAxisAlignment.end with position and size',
          (game) async {
        await _initScene(game, MainAxisAlignment.end, Vector2(500, 500));
        expect(firstComponent.absolutePosition[k], 200);
        expect(firstComponent.position[k], -300);
        expect(secondComponent.position[k], -250);
        expect(thirdComponent.position[k], -150);
      });

      testWithFlameGame('mainAxisAlignment.end with position, size and gap',
          (game) async {
        await _initScene(game, MainAxisAlignment.end, Vector2(500, 500), 20);
        expect(firstComponent.absolutePosition[k], 160);
        expect(firstComponent.position[k], -340);
        expect(secondComponent.position[k], -270);
        expect(thirdComponent.position[k], -150);
      });

      testWithFlameGame('mainAxisAlignment.spaceBetween with position and size',
          (game) async {
        await _initScene(game, MainAxisAlignment.spaceBetween, Vector2(50, 50));
        final gap = (layoutComponent.size[k] - totalSizeOfComponents) / 2;
        expect(secondComponent.position[k], gap + 50);
        expect(thirdComponent.position[k], 2 * gap + 150);
      });

      testWithFlameGame('mainAxisAlignment.spaceEvenly with position and size',
          (game) async {
        await _initScene(game, MainAxisAlignment.spaceEvenly, Vector2(50, 50));
        final gap = (layoutComponent.size[k] - totalSizeOfComponents) / 4;
        expect(firstComponent.position[k], gap);
        expect(secondComponent.position[k], 2 * gap + 50);
        expect(thirdComponent.position[k], 3 * gap + 150);
      });

      testWithFlameGame('mainAxisAlignment.spaceAround with position and size',
          (game) async {
        await _initScene(game, MainAxisAlignment.spaceAround, Vector2(50, 50));
        final gap = (layoutComponent.size[k] - totalSizeOfComponents) / 3;
        expect(
          double.parse((firstComponent.position[k]).toStringAsFixed(1)),
          double.parse((gap / 2).toStringAsFixed(1)),
        );
        expect(
          double.parse((secondComponent.position[k]).toStringAsFixed(1)),
          double.parse((1.5 * gap + 50).toStringAsFixed(1)),
        );
        expect(
          double.parse((thirdComponent.position[k]).toStringAsFixed(1)),
          double.parse((2.5 * gap + 150).toStringAsFixed(1)),
        );
      });

      testWithFlameGame('mainAxisAlignment.center with position and size',
          (game) async {
        await _initScene(game, MainAxisAlignment.center, Vector2(50, 50));
        final startPosition =
            (layoutComponent.size[k] - totalSizeOfComponents) / 2;
        expect(firstComponent.position[k], startPosition);
        expect(secondComponent.position[k], startPosition + 50);
        expect(thirdComponent.position[k], startPosition + 150);
      });

      testWithFlameGame('mainAxisAlignment.center with position, size and gap',
          (game) async {
        await _initScene(game, MainAxisAlignment.center, Vector2(50, 50), 10);
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
