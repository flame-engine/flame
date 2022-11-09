import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame_lottie/src/lottie_renderer.dart';
import 'package:flutter/widgets.dart';
import 'package:lottie/lottie.dart';

class LottieComponent extends PositionComponent with HasPaint {
  final LottieRenderer _renderer;

  LottieComponent({
    required LottieComposition composition,
    required Vector2 super.size,
    bool? repeating,
    EffectController? controller,
    BoxFit? fit,
    // TODO(Tobias) position component arguments
    super.position,
  }) : _renderer = LottieRenderer(
          composition: composition,
          controller: controller,
          fit: fit,
          repeating: repeating,
        );

  @mustCallSuper
  @override
  void render(Canvas canvas) {
    _renderer.paint(canvas, Size.zero);
  }

  @mustCallSuper
  @override
  void update(double dt) {
    _renderer.update(dt);
  }
}

Future<LottieComposition> loadLottie(
  FutureOr<LottieBuilder> file,
) async {
  final loaded = await file;
  final composition = await loaded.lottie.load();

  return composition;
}
