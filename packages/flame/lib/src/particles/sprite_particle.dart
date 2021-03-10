import 'dart:ui';

import '../anchor.dart';
import '../extensions/vector2.dart';
import '../sprite.dart';
import 'particle.dart';

export '../sprite.dart';

export '../sprite.dart';

class SpriteParticle extends Particle {
  final Sprite sprite;
  final Vector2? size;
  final Paint? overridePaint;

  SpriteParticle({
    required this.sprite,
    this.size,
    this.overridePaint,
    double? lifespan,
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
