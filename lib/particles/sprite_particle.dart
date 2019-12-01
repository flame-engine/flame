import 'dart:ui';

import 'package:flutter/foundation.dart';

import '../particle.dart';
import '../position.dart';
import '../sprite.dart';

class SpriteParticle extends Particle {
  final Sprite sprite;
  final Position size;
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
      Position.empty(),
      overridePaint: overridePaint,
      size: size,
    );
  }
}
