import 'dart:ui';

import 'package:flame/src/extensions/vector2.dart';
import 'package:flame/src/particles/particle.dart';

/// A [Particle] which renders given [Image] on a [Canvas] image is centered.
/// If any other behavior is needed, consider using ComputedParticle.
class ImageParticle extends Particle {
  /// dart.ui [Image] to draw
  Image image;
  Paint paint;

  late Rect src;
  late Rect dest;

  ImageParticle({
    required this.image,
    Paint? paint,
    Vector2? size,
    super.lifespan,
  }) : paint = paint ?? Paint() {
    final srcWidth = image.width.toDouble();
    final srcHeight = image.height.toDouble();
    final destWidth = size?.x ?? srcWidth;
    final destHeight = size?.y ?? srcHeight;

    src = Rect.fromLTWH(0, 0, srcWidth, srcHeight);
    dest =
        Rect.fromLTWH(-destWidth / 2, -destHeight / 2, destWidth, destHeight);
  }

  @override
  void render(Canvas canvas) {
    canvas.drawImageRect(image, src, dest, paint);
  }
}
