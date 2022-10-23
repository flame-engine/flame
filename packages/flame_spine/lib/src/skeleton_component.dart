import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame_spine/flame_spine.dart';
import 'package:flutter/foundation.dart';

class SpineComponent extends PositionComponent {
  final SkeletonRender renderer;

  SpineComponent({
    required this.renderer,
    required Vector2 super.size,
    super.position,
  });

  @override
  void onMount() {
    super.onMount();
    renderer.init();
  }

  @override
  @mustCallSuper
  void render(Canvas canvas) {
    renderer.render(canvas, size.toSize());
  }

  @override
  @mustCallSuper
  void update(double dt) {
    renderer.advance(dt);
  }

  @override
  void onRemove() {
    renderer.destroy();
    super.onRemove();
  }
}
