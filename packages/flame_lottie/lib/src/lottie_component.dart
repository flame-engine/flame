import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame_lottie/src/lottie_renderer.dart';
import 'package:flutter/widgets.dart';
import 'package:lottie/lottie.dart';

/// A Flame [Component] which renders a [Lottie] animation using the already
/// existing Flutter library [lottie](https://pub.dev/packages/lottie).
class LottieComponent extends PositionComponent with HasPaint {
  late final LottieRenderer _renderer;

  /// The [controller] drives the [Lottie] animation. In case none is specified
  /// it will be created implicitly in the [LottieRenderer].
  LottieComponent(
    LottieComposition composition, {
    EffectController? controller,
    double? progress,
    LottieDelegates? delegates,
    bool? enableMergePaths,
    FrameRate? frameRate,
    double? duration,
    bool? repeating,
    Alignment alignment = Alignment.center,
    BoxFit? fit = BoxFit.contain,
    super.position,
    super.size,
    super.scale,
    super.angle,
    super.anchor,
    super.children,
    super.priority,
  }) {
    _renderer = LottieRenderer(
      composition: composition,
      progress: progress ?? 0.0,
      size: size,
      controller: controller,
      duration: duration,
      repeating: repeating,
      alignment: alignment,
      fit: fit,
      delegates: delegates,
      enableMergePaths: enableMergePaths,
      frameRate: frameRate,
    );
  }

  @mustCallSuper
  @override
  void render(Canvas canvas) {
    _renderer.render(canvas);
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
