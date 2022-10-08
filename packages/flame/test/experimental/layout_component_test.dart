import 'package:flame/components.dart';
import 'package:flame/experimental.dart';
import 'package:flame/game.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Component component;
  late Vector2 gameSize;

  late TextComponent firstText;
  late TextComponent secondText;
  late TextComponent thirdText;
  late double componentsWidth;
  late double componentsHeight;

  void _initChildren() {
    firstText = TextComponent(
      text: 'First',
    )
      ..textRenderer = TextPaint(
        style: const TextStyle(
          fontSize: 22,
        ),
      )
      ..size = Vector2(50, 50);

    secondText = TextComponent(
      text: 'Second',
    )
      ..textRenderer = TextPaint(
        style: const TextStyle(
          fontSize: 20,
        ),
      )
      ..size = Vector2(100, 100);

    thirdText = TextComponent(
      text: 'Third',
    )
      ..textRenderer = TextPaint(
        style: const TextStyle(
          fontSize: 15,
        ),
      )
      ..size = Vector2(150, 150);
  }

  group('RowComponent', () {
    late RowComponent rowComponent;
    setUp(() async {});

    setUp(() async {
      component = Component();
      gameSize = Vector2(1000, 768);
      component.onGameResize(gameSize);
      _initChildren();
      componentsWidth = firstText.size.x + secondText.size.x + thirdText.size.x;
    });

    Future<void> _initScene(
      FlameGame game,
      MainAxisAlignment alignment,
      Vector2 position, [
      double gap = 0.0,
    ]) async {
      await game.add(component);
      game.onGameResize(gameSize);
      rowComponent = RowComponent(
        mainAxisAlignment: alignment,
        gap: gap,
        size: Vector2(1000, 768),
      )..position = position;
      await component.add(rowComponent);
      await rowComponent.ensureAddAll([firstText, secondText, thirdText]);
      await game.ready();
    }

    testWithFlameGame('mainAxisAlignment.start with position and size',
        (game) async {
      await _initScene(game, MainAxisAlignment.start, Vector2(50, 50));
      expect(firstText.absolutePosition.x, 50);

      /// these positions refer to inside rowComponent
      expect(firstText.position.x, 0);
      expect(secondText.position.x, 50);
      expect(thirdText.position.x, 150);
    });

    testWithFlameGame('mainAxisAlignment.start with position, size and gap',
        (game) async {
      await _initScene(game, MainAxisAlignment.start, Vector2(50, 50), 10);
      expect(firstText.absolutePosition.x, 50);
      expect(firstText.position.x, 0);
      expect(secondText.position.x, 60);
      expect(thirdText.position.x, 170);
    });

    testWithFlameGame('mainAxisAlignment.end with position and size',
        (game) async {
      await _initScene(game, MainAxisAlignment.end, Vector2(500, 50));
      expect(firstText.absolutePosition.x, 200);
      expect(firstText.position.x, -300);
      expect(secondText.position.x, -250);
      expect(thirdText.position.x, -150);
    });

    testWithFlameGame('mainAxisAlignment.end with position, size and gap',
        (game) async {
      await _initScene(game, MainAxisAlignment.end, Vector2(500, 50), 20);
      expect(firstText.absolutePosition.x, 160);
      expect(firstText.position.x, -340);
      expect(secondText.position.x, -270);
      expect(thirdText.position.x, -150);
    });

    testWithFlameGame('mainAxisAlignment.spaceBetween with position and size',
        (game) async {
      await _initScene(game, MainAxisAlignment.spaceBetween, Vector2(50, 50));
      final gap = (rowComponent.size.x - componentsWidth) / 2;
      expect(secondText.position.x, gap + 50);
      expect(thirdText.position.x, 2 * gap + 150);
    });

    testWithFlameGame('mainAxisAlignment.spaceEvenly with position and size',
        (game) async {
      await _initScene(game, MainAxisAlignment.spaceEvenly, Vector2(50, 50));
      final gap = (rowComponent.size.x - componentsWidth) / 4;
      expect(firstText.position.x, gap);
      expect(secondText.position.x, 2 * gap + 50);
      expect(thirdText.position.x, 3 * gap + 150);
    });

    testWithFlameGame('mainAxisAlignment.spaceAround with position and size',
        (game) async {
      await _initScene(game, MainAxisAlignment.spaceAround, Vector2(50, 50));
      final gap = (rowComponent.size.x - componentsWidth) / 3;
      expect(double.parse((firstText.position.x).toStringAsFixed(1)),
          double.parse((gap / 2).toStringAsFixed(1)),);
      expect(double.parse((secondText.position.x).toStringAsFixed(1)),
          double.parse((1.5 * gap + 50).toStringAsFixed(1)),);
      expect(double.parse((thirdText.position.x).toStringAsFixed(1)),
          double.parse((2.5 * gap + 150).toStringAsFixed(1)),);
    });

    testWithFlameGame('mainAxisAlignment.center with position and size',
        (game) async {
      await _initScene(game, MainAxisAlignment.center, Vector2(50, 50));
      final startPosition = (rowComponent.size.x - componentsWidth) / 2;
      expect(firstText.position.x, startPosition);
      expect(secondText.position.x, startPosition + 50);
      expect(thirdText.position.x, startPosition + 150);
    });

    testWithFlameGame('mainAxisAlignment.center with position, size and gap',
        (game) async {
      await _initScene(game, MainAxisAlignment.center, Vector2(50, 50), 10);
      final startPosition = (rowComponent.size.x - componentsWidth - 20) / 2;
      expect(firstText.absolutePosition.x, startPosition + 50);
      expect(firstText.position.x, startPosition);
      expect(secondText.position.x, startPosition + 60);
      expect(thirdText.position.x, startPosition + 170);
    });
  });

  group('ColumnComponent', () {
    late ColumnComponent columnComponent;
    setUp(() async {});

    setUp(() async {
      component = Component();
      gameSize = Vector2(1030, 768);
      component.onGameResize(gameSize);
      _initChildren();
      componentsHeight =
          firstText.size.y + secondText.size.y + thirdText.size.y;
    });

    Future<void> _initScene(
      FlameGame game,
      MainAxisAlignment alignment,
      Vector2 position, [
      double gap = 0.0,
    ]) async {
      await game.add(component);
      game.onGameResize(gameSize);
      columnComponent = ColumnComponent(
        mainAxisAlignment: alignment,
        gap: gap,
        size: Vector2(1000, 768),
      )..position = position;
      await component.add(columnComponent);
      await columnComponent.ensureAddAll([firstText, secondText, thirdText]);
      await game.ready();
    }

    testWithFlameGame('mainAxisAlignment.start with position and size',
        (game) async {
      await _initScene(game, MainAxisAlignment.start, Vector2(50, 50));
      expect(firstText.absolutePosition.y, 50);

      /// these positions refer to inside rowComponent
      expect(firstText.position.y, 0);
      expect(secondText.position.y, 50);
      expect(thirdText.position.y, 150);
    });

    testWithFlameGame('mainAxisAlignment.start with position, size and gap',
        (game) async {
      await _initScene(game, MainAxisAlignment.start, Vector2(50, 50), 10);
      expect(firstText.absolutePosition.y, 50);
      expect(firstText.position.y, 0);
      expect(secondText.position.y, 60);
      expect(thirdText.position.y, 170);
    });

    testWithFlameGame('mainAxisAlignment.end with position and size',
        (game) async {
      await _initScene(game, MainAxisAlignment.end, Vector2(500, 500));
      expect(firstText.absolutePosition.y, 200);
      expect(firstText.position.y, -300);
      expect(secondText.position.y, -250);
      expect(thirdText.position.y, -150);
    });

    testWithFlameGame('mainAxisAlignment.end with position, size and gap',
        (game) async {
      await _initScene(game, MainAxisAlignment.end, Vector2(500, 500), 20);
      expect(firstText.absolutePosition.y, 160);
      expect(firstText.position.y, -340);
      expect(secondText.position.y, -270);
      expect(thirdText.position.y, -150);
    });

    testWithFlameGame('mainAxisAlignment.spaceBetween with position and size',
        (game) async {
      await _initScene(game, MainAxisAlignment.spaceBetween, Vector2(50, 50));
      final gap = (columnComponent.size.y - componentsHeight) / 2;
      expect(secondText.position.y, gap + 50);
      expect(thirdText.position.y, 2 * gap + 150);
    });

    testWithFlameGame('mainAxisAlignment.spaceEvenly with position and size',
        (game) async {
      await _initScene(game, MainAxisAlignment.spaceEvenly, Vector2(50, 50));
      final gap = (columnComponent.size.y - componentsHeight) / 4;
      expect(firstText.position.y, gap);
      expect(secondText.position.y, 2 * gap + 50);
      expect(thirdText.position.y, 3 * gap + 150);
    });

    testWithFlameGame('mainAxisAlignment.spaceAround with position and size',
        (game) async {
      await _initScene(game, MainAxisAlignment.spaceAround, Vector2(50, 50));
      final gap = (columnComponent.size.y - componentsHeight) / 3;
      expect(firstText.position.y, gap / 2);
      expect(secondText.position.y, 1.5 * gap + 50);
      expect(thirdText.position.y, 2.5 * gap + 150);
    });

    testWithFlameGame('mainAxisAlignment.center with position and size',
        (game) async {
      await _initScene(game, MainAxisAlignment.center, Vector2(50, 50));
      final startPosition = (columnComponent.size.y - componentsHeight) / 2;
      expect(firstText.position.y, startPosition);
      expect(secondText.position.y, startPosition + 50);
      expect(thirdText.position.y, startPosition + 150);
    });

    testWithFlameGame('mainAxisAlignment.center with position, size and gap',
        (game) async {
      await _initScene(game, MainAxisAlignment.center, Vector2(50, 50), 10);
      final startPosition =
          (columnComponent.size.y - componentsHeight - 20) / 2;
      expect(firstText.position.y, startPosition);
      expect(secondText.position.y, startPosition + 60);
      expect(thirdText.position.y, startPosition + 170);
    });
  });
}
