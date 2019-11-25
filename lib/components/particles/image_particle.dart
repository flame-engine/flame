import 'dart:ui';

import 'package:flutter/foundation.dart';

import '../particle_component.dart';

class ImageParticle extends Particle {
  /// dart.ui [Image] to draw
  Image image;

  Rect src;
  Rect dest;

  ImageParticle({
    @required this.image,
    Size size,
    double lifespan,
    Duration duration,
  }) : super(lifespan: lifespan, duration: duration) {
    final srcWidth = image.width.toDouble();
    final srcHeight = image.height.toDouble();
    final destWidth = size?.width ?? srcWidth;
    final destHeight = size?.height ?? srcHeight;

    src = Rect.fromLTWH(0, 0, srcWidth, srcHeight);
    dest = Rect.fromLTWH(-destWidth / 2, -destHeight / 2, destWidth, destHeight);
  }

  @override
  void render(Canvas canvas) {
    canvas.drawImageRect(image, src, dest, Paint());
  }
}