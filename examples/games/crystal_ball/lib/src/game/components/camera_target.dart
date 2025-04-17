import 'package:crystal_ball/src/game/game.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/animation.dart';

class CameraTarget extends PositionComponent
    with HasGameReference<CrystalBallGame> {
  CameraTarget()
      : super(
          position: Vector2(0, 0),
          size: Vector2.all(0),
          anchor: Anchor.center,
          priority: 0x7fffffff,
        );

  final effectController = CurvedEffectController(
    0.1,
    Curves.easeOut,
  )..setToEnd();

  late final moveEffect = MoveCameraTarget(position, effectController);

  @override
  Color get debugColor => const Color(0xFFFFFF00);

  @override
  Future<void> onLoad() async {
    await add(moveEffect);
  }

  void go({
    required Vector2 to,
    double duration = 0.25,
    double scale = 1,
  }) {
    effectController
      .duration = duration * 4;

    moveEffect.go(to: to);
  }
  

  

  @override
  void update(double dt) {
    super.update(dt);
    game.camera.viewfinder.zoom = scale.x;
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
