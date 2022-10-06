import 'package:flame/components.dart';
import 'package:flame/experimental.dart';
import 'package:flame/game.dart';
import 'package:flame/src/components/input/button_component.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Component component;
  late Vector2 gameSize;

  late TextComponent firstText;
  late TextComponent secondText;
  late TextComponent thirdText;
  late ButtonComponent button;

  late double componentsWidth;

  group('RowComponent', () {
    RowComponent rowComponent;
    setUp(() async {});

    setUp(() async {
      component = Component();
      gameSize = Vector2(1025, 768);
      component.onGameResize(gameSize);

      firstText = TextComponent(
        text: 'First',
      )
        ..textRenderer = TextPaint(
          style: const TextStyle(
            fontSize: 22,
          ),
        )
        ..size = Vector2(50, 20);

      secondText = TextComponent(
        text: 'Second',
      )
        ..textRenderer = TextPaint(
          style: const TextStyle(
            fontSize: 20,
          ),
        )
        ..size = Vector2(100, 20);

      thirdText = TextComponent(
        text: 'Third',
      )
        ..textRenderer = TextPaint(
          style: const TextStyle(
            fontSize: 15,
          ),
        )
        ..size = Vector2(150, 20);

      componentsWidth = firstText.size.x + secondText.size.x + thirdText.size.x;
    });

    testWithFlameGame('mainAxisAlignment.start with position', (game) async {
      await game.add(component);
      game.onGameResize(gameSize);
      rowComponent = RowComponent()..position = Vector2(50, 50);
      await component.add(rowComponent);
      await rowComponent.ensureAddAll([firstText, secondText, thirdText]);
      await game.ready();
      expect(firstText.absolutePosition.x, 50);

      /// these positions refer to inside rowComponent
      expect(firstText.position.x, 0);
      expect(secondText.position.x, 50);
      expect(thirdText.position.x, 150);
    });

    testWithFlameGame('mainAxisAlignment.end with position', (game) async {
      await game.add(component);
      game.onGameResize(gameSize);
      rowComponent = RowComponent(mainAxisAlignment: MainAxisAlignment.end)
        ..position = Vector2(500, 50);
      await component.add(rowComponent);
      await rowComponent.ensureAddAll([firstText, secondText, thirdText]);
      await game.ready();
      expect(firstText.absolutePosition.x, 200);
      expect(firstText.position.x, -300);
      expect(secondText.position.x, -250);
      expect(thirdText.position.x, -150);
    });

    testWithFlameGame('mainAxisAlignment.spaceBetween with position',
        (game) async {
      await game.add(component);
      game.onGameResize(gameSize);
      rowComponent =
          RowComponent(mainAxisAlignment: MainAxisAlignment.spaceBetween)
            ..position = Vector2(50, 50);
      await component.add(rowComponent);
      await rowComponent.ensureAddAll([firstText, secondText, thirdText]);
      await game.ready();
      final gap = (gameSize.x - rowComponent.position.x - componentsWidth) / 2;
      expect(secondText.position.x, gap + 50);
      expect(thirdText.position.x, 2 * gap + 150);
    });

    testWithFlameGame('mainAxisAlignment.spaceEvenly with position',
        (game) async {
      await game.add(component);
      game.onGameResize(gameSize);
      rowComponent =
          RowComponent(mainAxisAlignment: MainAxisAlignment.spaceEvenly)
            ..position = Vector2(50, 50);
      await component.add(rowComponent);
      await rowComponent.ensureAddAll([firstText, secondText, thirdText]);
      await game.ready();
      final gap = (gameSize.x - rowComponent.position.x - componentsWidth) / 4;
      expect(firstText.position.x, gap);
      expect(secondText.position.x, 2 * gap + 50);
      expect(thirdText.position.x, 3 * gap + 150);
    });

    testWithFlameGame('mainAxisAlignment.spaceAround with position',
        (game) async {
      await game.add(component);
      game.onGameResize(gameSize);
      rowComponent =
          RowComponent(mainAxisAlignment: MainAxisAlignment.spaceAround)
            ..position = Vector2(50, 50);
      await component.add(rowComponent);
      await rowComponent.ensureAddAll([firstText, secondText, thirdText]);
      await game.ready();
      final gap = (gameSize.x - rowComponent.position.x - componentsWidth) / 3;
      expect(firstText.position.x, gap / 2);
      expect(secondText.position.x, 1.5 * gap + 50);
      expect(thirdText.position.x, 2.5 * gap + 150);
    });

    testWithFlameGame('mainAxisAlignment.center with position', (game) async {
      await game.add(component);
      game.onGameResize(gameSize);
      rowComponent = RowComponent(mainAxisAlignment: MainAxisAlignment.center)
        ..position = Vector2(50, 50);
      await component.add(rowComponent);
      await rowComponent.ensureAddAll([firstText, secondText, thirdText]);
      await game.ready();
      final startPosition =
          (gameSize.x - rowComponent.position.x - componentsWidth) / 2;
      expect(firstText.position.x, startPosition);
      expect(secondText.position.x, startPosition + 50);
      expect(thirdText.position.x, startPosition + 150);
    });
  });
}
