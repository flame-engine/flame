import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame_svg/flame_svg.dart';

class Player extends SvgComponent with HasGameReference<SvgComponentExample> {
  Player() : super(priority: 3, size: Vector2(106, 146), anchor: Anchor.center);

  Vector2? destination;

  @override
  Future<void>? onLoad() async {
    await super.onLoad();

    svg = await game.loadSvg('svgs/happy_player.svg');
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

class Background extends SvgComponent
    with HasGameReference<SvgComponentExample> {
  Background()
      : super(
          priority: 1,
          size: Vector2(745, 415),
          anchor: Anchor.center,
        );

  @override
  Future<void>? onLoad() async {
    await super.onLoad();

    svg = await game.loadSvg('svgs/checkerboard.svg');
  }
}

class Balloons extends SvgComponent with HasGameReference<SvgComponentExample> {
  Balloons({super.position})
      : super(
          priority: 2,
          size: Vector2(75, 125),
          anchor: Anchor.center,
        );

  @override
  Future<void>? onLoad() async {
    await super.onLoad();

    final color = Random().nextBool() ? 'red' : 'green';

    svg = await game.loadSvg('svgs/${color}_balloons.svg');
  }
}

class SvgComponentExample extends FlameGame {
  static const description = '''
      Simple game showcasing how to use SVGs inside a flame game. This game 
      uses several SVGs for its graphics. Click or touch the screen to make the 
      player move, and double click/tap to add a new set of balloons at the 
      clicked position.
  ''';

  SvgComponentExample()
      : super(
          camera: CameraComponent.withFixedResolution(
            width: 400,
            height: 600,
          ),
          world: _SvgComponentWorld(),
        );
}

class _SvgComponentWorld extends World with TapCallbacks, DoubleTapCallbacks {
  late Player player;

  @override
  Future<void>? onLoad() async {
    await super.onLoad();

    add(player = Player());
    add(Background());

    addAll([
      Balloons(position: Vector2(-10, -20)),
      Balloons(position: Vector2(-100, -150)),
      Balloons(position: Vector2(-200, -140)),
      Balloons(position: Vector2(100, 130)),
      Balloons(position: Vector2(50, -130)),
    ]);
  }

  @override
  void onTapUp(TapUpEvent info) {
    player.destination = info.localPosition;
  }

  @override
  void onDoubleTapDown(DoubleTapDownEvent info) {
    add(Balloons()..position = info.localPosition);
  }
}
