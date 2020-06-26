import 'dart:ui';

import 'package:flutter/foundation.dart';

import '../particle.dart';
import '../vector2d.dart';
import '../sprite.dart';

class SpriteParticle extends Particle {
  final Sprite sprite;
  final Vector2d size;
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
      Vector2d.zero(),
      overridePaint: overridePaint,
      size: size,
    );
  }
}
