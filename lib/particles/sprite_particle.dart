import 'dart:ui';

import 'package:flutter/foundation.dart';

import '../particle.dart';
import '../sprite.dart';
import '../vector2_extension.dart';

class SpriteParticle extends Particle {
  final Sprite sprite;
  final Vector2 size;
  final Paint overridePaint;

  SpriteParticle({
    @required this.sprite,
    this.size,
    this.overridePaint,
    double lifespan,
  }) : super(
          lifespan: lifespan,
        );

  @override
  void render(Canvas canvas) {
    sprite.renderCentered(
      canvas,
      Vector2.zero(),
      overridePaint: overridePaint,
      size: size,
    );
  }
}
