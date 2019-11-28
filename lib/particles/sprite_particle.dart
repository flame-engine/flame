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
    Duration duration,
  }) : super(
          lifespan: lifespan,
          duration: duration,
        );

  @override
  void render(Canvas canvas) {
    sprite.renderCentered(canvas, Position.empty(), 
      overridePaint: overridePaint,
      size: size
    );
  }
}