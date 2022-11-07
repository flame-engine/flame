import 'package:flame/extensions.dart';
import 'package:flutter/rendering.dart';
import 'package:lottie/lottie.dart';

class LottieRenderer {
  LottieRenderer({
    required LottieComposition? composition,
    LottieDelegates? delegates,
    bool? enableMergePaths,
    double progress = 0.0,
    FrameRate? frameRate,
    this.boxFit,
    this.alignment = Alignment.center,
    FilterQuality? filterQuality,
  })  : assert(progress >= 0.0 && progress <= 1.0),
        _drawable = composition != null
            ? (LottieDrawable(composition)
              ..setProgress(progress, frameRate: frameRate)
              ..delegates = delegates
              ..enableMergePaths = enableMergePaths ?? false
              ..filterQuality = filterQuality)
            : null;

  /// The lottie composition to display.
  LottieComposition? get composition => _drawable?.composition;
  final LottieDrawable? _drawable;

  /// How to inscribe the composition into the space allocated during layout.

  BoxFit? boxFit;

  /// How to align the composition within its bounds.
  ///
  /// If this is set to a text-direction-dependent value, [textDirection] must
  /// not be null.
  AlignmentGeometry alignment;

  void render(Canvas canvas, Size size) {
    _drawable!.draw(
      canvas,
      size.toRect(),
      fit: boxFit,
      alignment: alignment.resolve(TextDirection.ltr),
    );
  }

  void destroy() {}

  void advance(double dt) {
    _drawable?.setProgress(dt);
  }
}
