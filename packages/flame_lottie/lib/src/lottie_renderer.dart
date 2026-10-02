import 'package:flame/effects.dart';
import 'package:flame/game.dart';
import 'package:flutter/rendering.dart';
import 'package:lottie/lottie.dart';

class LottieRenderer({
  required LottieComposition composition,
  required double progress,
  required NotifyingVector2 size,
  EffectController? controller,
  double? duration,
  bool? repeating,
  final Alignment? alignment,
  final BoxFit? fit,
  LottieDelegates? delegates,
  bool? enableMergePaths,
  FrameRate? frameRate,
}) {
  final LottieDrawable drawable =
      LottieDrawable(composition, frameRate: frameRate)
        ..setProgress(progress)
        ..delegates = delegates
        ..enableMergePaths = enableMergePaths ?? false;
  final EffectController _controller =
      controller ??
      EffectController(
        duration: duration ?? composition.duration.inMilliseconds / 1000,
        infinite: repeating ?? false,
      );

  Rect boundingRect = size.toRect();

  this : assert(progress >= 0.0 && progress <= 1.0) {
    size.addListener(() {
      boundingRect = size.toRect();
    });
  }

  /// Renders the current frame of the Lottie animation onto the canvas.
  void render(Canvas canvas) {
    drawable.draw(canvas, boundingRect, fit: fit, alignment: alignment);
  }

  void update(double dt) {
    _controller.advance(dt);
    drawable.setProgress(_controller.progress);
  }
}
