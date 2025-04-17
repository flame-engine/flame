import 'package:crystal_ball/src/game/game.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/animation.dart';

class CameraTarget extends PositionComponent
    with HasGameReference<CrystalBallGame> {
  final effectController = CurvedEffectController(
    0.1,
    Curves.easeOut,
  )..setToEnd();

  late final moveEffect = MoveCameraTarget(position, effectController);

  @override
  Future<void> onLoad() async {
    await add(moveEffect);
  }

  void go({
    required Vector2 to,
    double duration = 0.25,
    double scale = 1,
  }) {
    effectController.duration = duration * 4;
    moveEffect.go(to: to);
  }
}

class MoveCameraTarget extends Effect with EffectTarget<CameraTarget> {
  MoveCameraTarget(this._to, super.controller);

  @override
  void onMount() {
    super.onMount();
    _from = target.position;
  }

  Vector2 _to;
  late Vector2 _from;

  @override
  bool get removeOnFinish => false;

  @override
  void apply(double progress) {
    target.position.setValues(
      _from.x + (_to.x - _from.x) * progress,
      _from.y + (_to.y - _from.y) * progress,
    );
  }

  void go({required Vector2 to}) {
    reset();
    _to = to;
    _from = target.position;
  }
}
