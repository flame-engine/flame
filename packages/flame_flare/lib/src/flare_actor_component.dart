import 'package:flame/components.dart';
import 'package:flutter/widgets.dart';

import '../flame_flare.dart';

/// A [PositionComponent] that renders a [FlareActorAnimation]
class FlareActorComponent extends PositionComponent {
  final FlareActorAnimation flareAnimation;

  FlareActorComponent(
    this.flareAnimation, {
    required Vector2 size,
    Vector2? position,
  }) : super(position: position, size: size);

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
    super.update(dt);
    flareAnimation.advance(dt);
  }

  @override
  void onRemove() {
    flareAnimation.destroy();
    super.onRemove();
  }
}
