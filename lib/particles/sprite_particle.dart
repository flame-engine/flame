import 'dart:ui';

import 'package:flutter/foundation.dart';

import '../particle.dart';
import '../sprite.dart';
import '../vector2f.dart';

class SpriteParticle extends Particle {
  final Sprite sprite;
  final Vector2F size;
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
      Vector2F.zero(),
      overridePaint: overridePaint,
      size: size,
    );
  }
}
