import 'dart:ui';

import 'package:flame/src/anchor.dart';
import 'package:flame/src/extensions/vector2.dart';
import 'package:flame/src/particles/particle.dart';
import 'package:flame/src/sprite.dart';

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
    super.lifespan,
  });

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
