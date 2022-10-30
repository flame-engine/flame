import 'package:flame/components.dart';
import 'package:flame_flare/flame_flare.dart';
import 'package:flutter/widgets.dart';

/// A [PositionComponent] that renders a [FlareActorAnimation]
class FlareActorComponent extends PositionComponent {
  final FlareActorAnimation flareAnimation;

  FlareActorComponent(
    this.flareAnimation, {
    required Vector2 super.size,
    super.position,
  });

  @override
  void onMount() {
    super.onMount();
    flareAnimation.init();
  }

  @override
  @mustCallSuper
  void render(Canvas canvas) {
    flareAnimation.render(canvas, size);
  }

  @override
  @mustCallSuper
  void update(double dt) {
    flareAnimation.advance(dt);
  }

  @override
  void onRemove() {
    flareAnimation.destroy();
    super.onRemove();
  }
}
