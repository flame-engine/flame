import 'dart:ui';

import 'package:flame/src/anchor.dart';
import 'package:flame/src/extensions/vector2.dart';
import 'package:flame/src/particles/particle.dart';
import 'package:flame/src/sprite.dart';

export '../sprite.dart';

/// A [Particle] which applies certain [Sprite].
class SpriteParticle extends Particle {
  final Sprite sprite;
  final Vector2? position;
  final Vector2? size;
  final Anchor anchor;
  final Paint? overridePaint;

  SpriteParticle({
    required this.sprite,
    this.position,
    this.size,
    this.anchor = Anchor.center,
    this.overridePaint,
    super.lifespan,
  });

  @override
  void render(Canvas canvas) {
    sprite.render(
      canvas,
      position: position,
      size: size,
      anchor: anchor,
      overridePaint: overridePaint,
    );
  }
}
