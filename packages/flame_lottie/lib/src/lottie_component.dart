import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame_lottie/src/lottie_renderer.dart';
import 'package:flutter/widgets.dart';
import 'package:lottie/lottie.dart';

/// A Flame [Component] which renders a [Lottie] animation using
/// the already existing Flutter library [lottie](https://pub.dev/packages/lottie)
///
/// @param controller The controller which drives the animation. In case none is
///   specified it will be created implicitly in the [LottieRenderer]
///
class LottieComponent extends PositionComponent with HasPaint {
  final LottieRenderer _renderer;

  LottieComponent({
    required LottieComposition composition,
    EffectController? controller,
    double? progress,
    // Lottie configuration
    LottieDelegates? delegates,
    bool? enableMergePaths,
    FrameRate? frameRate,
    double? duration,
    bool? repeating,
    Alignment alignment = Alignment.center,
    BoxFit? fit = BoxFit.contain,
    // position component arguments
    super.position,
    super.size,
    super.scale,
    double super.angle = 0.0,
    Anchor super.anchor = Anchor.topLeft,
    super.children,
    super.priority,
  }) : _renderer = LottieRenderer(
          composition: composition,
          progress: progress ?? 0.0,
          controller: controller,
          duration: duration,
          repeating: repeating,
          alignment: alignment,
          fit: fit,
          delegates: delegates,
          enableMergePaths: enableMergePaths,
          frameRate: frameRate,
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

/// Loads the Lottie animation from the specified Lottie file.
Future<LottieComposition> loadLottie(
  FutureOr<LottieBuilder> file,
) async {
  final loaded = await file;
  final composition = await loaded.lottie.load();

  return composition;
}
