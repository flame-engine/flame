import 'package:flame/effects.dart';
import 'package:flutter/rendering.dart';
import 'package:lottie/lottie.dart';

// TODO(Tobias): add tests

class LottieRenderer extends CustomPainter {
  final LottieDrawable drawable;
  final EffectController _controller;

  final BoxFit? fit;

  LottieRenderer({
    required LottieComposition composition,
    EffectController? controller,
    double? duration,
    double progress = 0.0,
    bool? repeating,
    this.fit,
    // TODO(Tobias): expose parameters
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

  /// Size is not used but still kept as an argument to conform to CustomPainter
  @override
  void paint(Canvas canvas, Size size) {
    drawable.draw(canvas, boundingRect, fit: fit);
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
