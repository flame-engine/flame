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

  late Size _size;

  @override
  void onMount() {
    _size = size.toSize();
    super.onMount();
  }

  @override
  set size(Vector2 size) {
    _size = size.toSize();
    super.size = size;
  }

  @override
  @mustCallSuper
  void render(Canvas canvas) {
    renderer.render(canvas, _size);
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
