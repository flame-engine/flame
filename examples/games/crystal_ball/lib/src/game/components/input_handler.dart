import 'package:crystal_ball/src/game/constants.dart';
import 'package:crystal_ball/src/game/game.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/services.dart';

class InputHandler extends PositionComponent
    with TapCallbacks, HasGameReference<CrystalBallGame> {
  InputHandler()
      : super(
          anchor: Anchor.center,
          size: kCameraSize,
        );

  @override
  Future<void> onLoad() async {
    await add(
      KeyboardListenerComponent(
        keyDown: {
          LogicalKeyboardKey.arrowLeft: onLeftStart,
          LogicalKeyboardKey.arrowRight: onRightStart,
        },
        keyUp: {
          LogicalKeyboardKey.arrowLeft: onLeftEnd,
          LogicalKeyboardKey.arrowRight: onRightEnd,
        },
      ),
    );

    return super.onLoad();
  }

  @override
  void update(double dt) {
    super.update(dt);
    position = game.world.cameraTarget.position;
  }

  @override
  void onTapDown(TapDownEvent event) {
    super.onTapDown(event);

    if (event.localPosition.x < game.size.x * 1 / 3) {
      onLeftStart({});
    } else if (event.localPosition.x > game.size.x * 2 / 3) {
      onRightStart({});
      
    } else {
      final pos = CameraComponent.currentCamera!.globalToLocal(
        event.canvasPosition,
      );
      game.world.cameraTarget.go(
        to: Vector2(0, pos.y),
        duration: 5,
      );
    }
  }

  @override
  void onTapUp(TapUpEvent event) {
    super.onTapUp(event);

    if (event.localPosition.x < game.size.x * 1 / 3) {
      onLeftEnd({});
    }
    if (event.localPosition.x > game.size.x * 2 / 3) {
      onRightEnd({});
    }
  }


  double _directionalCoefficient = 0;

  double get directionalCoefficient => _directionalCoefficient;

  bool onLeftStart(Set<LogicalKeyboardKey> logicalKeys) {
    _directionalCoefficient = -1;
    return false;
  }

  bool onRightStart(Set<LogicalKeyboardKey> logicalKeys) {
    _directionalCoefficient = 1;
    return false;
  }

  bool onLeftEnd(Set<LogicalKeyboardKey> logicalKeys) {
    if (_directionalCoefficient < 0) {
      _directionalCoefficient = 0;
    }
    return false;
  }

  bool onRightEnd(Set<LogicalKeyboardKey> logicalKeys) {
    if (_directionalCoefficient > 0) {
      _directionalCoefficient = 0;
    }
    return false;
  }
}
