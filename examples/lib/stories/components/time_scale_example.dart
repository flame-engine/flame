import 'dart:async';
import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/image_composition.dart';
import 'package:flame/palette.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/rendering.dart';

class TimeScaleExample extends FlameGame
    with HasTimeScale, HasCollisionDetection {
  static const description =
      'This example shows how time scale can be used to control game speed.';

  TimeScaleExample()
      : super(
          camera: CameraComponent.withFixedResolution(
            width: 640,
            height: 360,
          ),
        );

  final gameSpeedText = TextComponent(
    text: 'Time Scale: 1',
    textRenderer: TextPaint(
      style: TextStyle(
        color: BasicPalette.white.color,
        fontSize: 20.0,
        shadows: const [
          Shadow(offset: Offset(1, 1), blurRadius: 1),
        ],
      ),
    ),
    anchor: Anchor.center,
  );

  @override
  Color backgroundColor() => const Color.fromARGB(255, 88, 114, 97);

  @override
  Future<void> onLoad() async {
    final spriteSheet = SpriteSheet(
      image: await images.load('animations/chopper.png'),
      srcSize: Vector2.all(48),
    );
    gameSpeedText.position = Vector2(size.x * 0.5, size.y * 0.8);

    await world.addAll([
      _Chopper(
        position: Vector2(-100, -10),
        size: Vector2.all(64),
        anchor: Anchor.center,
        angle: -pi / 2,
        animation: spriteSheet.createAnimation(row: 0, stepTime: 0.05),
      ),
      _Chopper(
        position: Vector2(100, 10),
        size: Vector2.all(64),
        anchor: Anchor.center,
        angle: pi / 2,
        animation: spriteSheet.createAnimation(row: 0, stepTime: 0.05),
      ),
      gameSpeedText,
    ]);
    return super.onLoad();
  }

  @override
  void update(double dt) {
    gameSpeedText.text = 'Time Scale : $timeScale';
    super.update(dt);
  }
}

class _Chopper extends SpriteAnimationComponent
    with HasGameReference<TimeScaleExample>, CollisionCallbacks {
  _Chopper({
    super.animation,
    super.position,
    super.size,
    super.angle,
    super.anchor,
  })  : _moveDirection = Vector2(0, 1)..rotate(angle ?? 0),
        _initialPosition = position?.clone() ?? Vector2.zero();

  final Vector2 _moveDirection;
  final _speed = 80.0;
  final Vector2 _initialPosition;
  late final _timer = TimerComponent(
    period: 2,
    onTick: _reset,
    autoStart: false,
  );

  @override
  Future<void> onLoad() async {
    await add(CircleHitbox());
    await add(_timer);
    return super.onLoad();
  }

  @override
  void updateTree(double dt) {
    position.setFrom(position + _moveDirection * _speed * dt);
    super.updateTree(dt);
  }

  @override
  void onCollisionStart(Set<Vector2> _, PositionComponent other) {
    if (other is _Chopper) {
      game.timeScale = 0.25;
    }
    super.onCollisionStart(_, other);
  }

  @override
  void onCollisionEnd(PositionComponent other) {
    if (other is _Chopper) {
      game.timeScale = 1.0;
      _timer.timer.start();
    }
    super.onCollisionEnd(other);
  }

  void _reset() {
    position.setFrom(_initialPosition);
  }
}
