import 'package:flame/effects.dart';
import 'package:flame/game.dart';
import 'package:flutter/rendering.dart';
import 'package:lottie/lottie.dart';

class LottieRenderer {
  final LottieDrawable drawable;
  final EffectController _controller;

  final BoxFit? fit;
  final Alignment? alignment;

  late Rect boundingRect;

  LottieRenderer({
    required LottieComposition composition,
    required double progress,
    required NotifyingVector2 size,
    EffectController? controller,
    double? duration,
    bool? repeating,
    this.alignment,
    this.fit,
    LottieDelegates? delegates,
    bool? enableMergePaths,
    FrameRate? frameRate,
  })  : assert(progress >= 0.0 && progress <= 1.0),
        boundingRect = size.toRect(),
        drawable = LottieDrawable(composition)
          ..setProgress(
            progress,
            frameRate: frameRate,
          )
          ..delegates = delegates
          ..enableMergePaths = enableMergePaths ?? false,
        _controller = controller ??
            EffectController(
              duration: duration ?? composition.duration.inSeconds.toDouble(),
              infinite: repeating ?? false,
            ) {
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
