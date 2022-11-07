import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame_lottie/flame_lottie.dart';
import 'package:flutter/widgets.dart';

class LottieComponent extends PositionComponent {
  late final LottieRenderer renderer;

  LottieComponent({
    required this.renderer,
    required Vector2 super.size,
    EffectController? controller,
    super.position,
  }) : _controller = controller ??
      EffectController(
        duration: 4,
        infinite: true,
      );

  late final EffectController _controller;

  @override
  @mustCallSuper
  void render(Canvas canvas) {
    renderer.render(canvas, size.toSize());
  }

  @override
  @mustCallSuper
  void update(double dt) {
    _controller.advance(dt);
    renderer.advance(_controller.progress);
  }

  @override
  void onRemove() {
    renderer.destroy();
    super.onRemove();
  }
}
