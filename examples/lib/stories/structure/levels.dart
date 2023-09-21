import 'package:examples/commons/ember.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';

class LevelsExample extends FlameGame {
  static const String description = '''
    In this example we showcase how you can utilize World components as levels.
    Press the different buttons in the bottom to change levels and press in the
    center to add new Ember's. You can see how level 1-3 keeps their state,
    meanwhile the one called Resettable always resets.
  ''';

  LevelsExample() : super(world: ResettableLevel());

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
    final viewport = camera.viewport;
    viewport.add(header);
    final levels = [Level1(), Level2(), Level3()];
    viewport.addAll(
      [
        LevelButton(
          'Level 1',
          onPressed: () => world = levels[0],
          position: Vector2(size.x / 2 - 210, size.y - 50),
        ),
        LevelButton(
          'Level 2',
          onPressed: () => world = levels[1],
          position: Vector2(size.x / 2 - 70, size.y - 50),
        ),
        LevelButton(
          'Level 3',
          onPressed: () => world = levels[2],
          position: Vector2(size.x / 2 + 70, size.y - 50),
        ),
        LevelButton(
          'Resettable',
          onPressed: () => world = ResettableLevel(),
          position: Vector2(size.x / 2 + 210, size.y - 50),
        ),
      ],
    );
  }
}

class ResettableLevel extends Level {
  @override
  Future<void> onLoad() async {
    add(
      Ember()
        ..add(
          ScaleEffect.by(
            Vector2.all(3),
            EffectController(duration: 1, alternate: true, infinite: true),
          ),
        ),
    );
    game.header.text = 'Resettable';
  }
}

class Level1 extends Level {
  @override
  Future<void> onLoad() async {
    add(Ember());
    game.header.text = 'Level 1';
  }
}

class Level2 extends Level {
  @override
  Future<void> onLoad() async {
    add(Ember(position: Vector2(-100, 0)));
    add(Ember(position: Vector2(100, 0)));
    game.header.text = 'Level 2';
  }
}

class Level3 extends Level {
  @override
  Future<void> onLoad() async {
    add(Ember(position: Vector2(-100, -50)));
    add(Ember(position: Vector2(100, -50)));
    add(Ember(position: Vector2(0, 50)));
    game.header.text = 'Level 3';
  }
}

class Level extends World with HasGameReference<LevelsExample>, TapCallbacks {
  @override
  void onTapDown(TapDownEvent event) {
    add(Ember(position: event.localPosition));
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
              position: Vector2(60, 20),
              anchor: Anchor.center,
            ),
          ],
          size: Vector2(120, 40),
          anchor: Anchor.center,
        );
}

class ButtonBackground extends PositionComponent with HasAncestor<LevelButton> {
  ButtonBackground(Color color) {
    _paint.color = color;
  }

  @override
  void onMount() {
    super.onMount();
    size = ancestor.size;
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
