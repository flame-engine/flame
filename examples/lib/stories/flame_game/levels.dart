import 'package:examples/commons/ember.dart';
import 'package:flame/components.dart';
import 'package:flame/experimental.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';

class LevelsExample extends FlameGame {
  static const String description = '''
    In this example we showcase how you can utilize World components as levels.
    Press the different buttons in the bottom to change levels.
  ''';

  LevelsExample() : super(world: Level1());

  late final TextComponent header;

  @override
  Future<void> onLoad() async {
    header = TextComponent(
      text: 'test',
      position: Vector2(size.x / 2, 50),
      anchor: Anchor.center,
    );
    // If you have a lot of HUDs you could also create separate viewports for
    // each level and then just change them from within the world's onLoad with:
    // game.cameraComponent.viewport = Level1Viewport();
    final viewport = cameraComponent.viewport;
    viewport.add(header);
    viewport.addAll(
      [
        LevelButton(
          'Level 1',
          onPressed: () => world = Level1(),
          position: Vector2(size.x / 2 - 120, size.y - 50),
        ),
        LevelButton(
          'Level 2',
          onPressed: () => world = Level2(),
          position: Vector2(size.x / 2, size.y - 50),
        ),
        LevelButton(
          'Level 3',
          onPressed: () => world = Level3(),
          position: Vector2(size.x / 2 + 120, size.y - 50),
        ),
      ],
    );
  }
}

class Level1 extends World with HasGameReference<LevelsExample> {
  @override
  Future<void> onLoad() async {
    add(Ember());
    game.header.text = 'Level 1';
  }
}

class Level2 extends World with HasGameReference<LevelsExample> {
  @override
  Future<void> onLoad() async {
    add(Ember(position: Vector2(-100, 0)));
    add(Ember(position: Vector2(100, 0)));
    game.header.text = 'Level 2';
  }
}

class Level3 extends World with HasGameReference<LevelsExample> {
  @override
  Future<void> onLoad() async {
    add(Ember(position: Vector2(-100, -50)));
    add(Ember(position: Vector2(100, -50)));
    add(Ember(position: Vector2(0, 50)));
    game.header.text = 'Level 3';
  }
}

class LevelButton extends ButtonComponent {
  LevelButton(String text, {super.onPressed, super.position})
      : super(
          button: ButtonBackground(Colors.white),
          buttonDown: ButtonBackground(Colors.orangeAccent),
          children: [
            TextComponent(
              text: text,
              position: Vector2(50, 20),
              anchor: Anchor.center,
            ),
          ],
          size: Vector2(100, 40),
          anchor: Anchor.center,
        );
}

class ButtonBackground extends PositionComponent {
  ButtonBackground(Color color) : super(size: Vector2(100, 40)) {
    _paint.color = color;
  }

  late final _background = RRect.fromRectAndRadius(
    size.toRect(),
    const Radius.circular(5),
  );
  final _paint = Paint()..style = PaintingStyle.stroke;

  @override
  void render(Canvas canvas) {
    canvas.drawRRect(_background, _paint);
  }
}
