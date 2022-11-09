import 'package:flame/effects.dart';
import 'package:flutter/rendering.dart';
import 'package:lottie/lottie.dart';

class LottieRenderer extends CustomPainter {
  final LottieDrawable drawable;
  final EffectController _controller;

  final BoxFit? fit;
  final Alignment? alignment;

  LottieRenderer({
    required LottieComposition composition,
    required double progress,
    EffectController? controller,
    double? duration,
    bool? repeating,
    this.alignment,
    this.fit,
    LottieDelegates? delegates,
    bool? enableMergePaths,
    FrameRate? frameRate,
  })  : assert(progress >= 0.0 && progress <= 1.0),
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
            );

  late Rect boundingRect = () {
    final bounds = drawable.composition.bounds;
    return Rect.fromLTRB(
      bounds.left.toDouble(),
      bounds.top.toDouble(),
      bounds.right.toDouble(),
      bounds.bottom.toDouble(),
    );
  }();

  /// Paints the current frame of the Lottie animation onto the canvas
  ///
  /// The [size] is not used ([Size.zero] is getting forwarded)
  /// and the method argument is kept to conform to [CustomPainter] declaration.
  @override
  void paint(Canvas canvas, Size size) {
    drawable.draw(canvas, boundingRect, fit: fit, alignment: alignment);
  }

  void update(double dt) {
    _controller.advance(dt);
    drawable.setProgress(_controller.progress);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
