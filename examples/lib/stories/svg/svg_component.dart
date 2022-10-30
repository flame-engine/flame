import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame_svg/flame_svg.dart';

class Player extends SvgComponent with HasGameRef<SvgComponentExample> {
  Player() : super(priority: 3, size: Vector2(106, 146), anchor: Anchor.center);

  Vector2? destination;

  @override
  Future<void>? onLoad() async {
    await super.onLoad();

    svg = await gameRef.loadSvg('svgs/happy_player.svg');
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (destination != null) {
      final difference = destination! - position;
      if (difference.length < 2) {
        destination = null;
      } else {
        final direction = difference.normalized();
        position += direction * 200 * dt;
      }
    }
  }
}

class Background extends SvgComponent with HasGameRef<SvgComponentExample> {
  Background()
      : super(
          priority: 1,
          size: Vector2(745, 415),
          anchor: Anchor.center,
        );

  @override
  Future<void>? onLoad() async {
    await super.onLoad();

    svg = await gameRef.loadSvg('svgs/checkboard.svg');
  }
}

class Ballons extends SvgComponent with HasGameRef<SvgComponentExample> {
  Ballons()
      : super(
          priority: 2,
          size: Vector2(75, 125),
          anchor: Anchor.center,
        );

  @override
  Future<void>? onLoad() async {
    await super.onLoad();

    final color = Random().nextBool() ? 'red' : 'green';

    svg = await gameRef.loadSvg('svgs/${color}_ballons.svg');
  }
}

class SvgComponentExample extends FlameGame
    with TapDetector, DoubleTapDetector {
  static const description = '''
      Simple game showcasing how to use SVGs inside a flame game. This game uses several svgs
      for its graphics. Click or touch the screen to make the player move, and double click/tap
      to add a new set of ballons on the clicked position.
''';

  late Player player;

  @override
  Future<void>? onLoad() async {
    await super.onLoad();
    camera.followVector2(Vector2.zero());

    add(player = Player());
    add(Background());

    add(
      Ballons()
        ..x = -10
        ..y = -20,
    );

    add(
      Ballons()
        ..x = -100
        ..y = -150,
    );

    add(
      Ballons()
        ..x = -200
        ..y = -140,
    );

    add(
      Ballons()
        ..x = 100
        ..y = 130,
    );

    add(
      Ballons()
        ..x = 50
        ..y = -130,
    );
  }

  @override
  void onTapUp(TapUpInfo info) {
    player.destination = info.eventPosition.game;
  }

  @override
  void onDoubleTapDown(TapDownInfo info) {
    add(Ballons()..position = info.eventPosition.game);
  }
}
