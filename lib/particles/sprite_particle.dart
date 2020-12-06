import 'dart:ui';

import 'package:flutter/foundation.dart';

import '../anchor.dart';
import '../particle.dart';
import '../sprite.dart';
import '../extensions/vector2.dart';

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
    sprite.render(
      canvas,
      size: size,
      anchor: Anchor.center,
      overridePaint: overridePaint,
    );
  }
}
