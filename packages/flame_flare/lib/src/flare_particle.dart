import 'package:flame/extensions.dart';
import 'package:flame/particles.dart';

import 'package:flame_flare/flame_flare.dart';

/// A [Particle] that renders a [FlareActorAnimation].
class FlareParticle extends Particle {
  final FlareActorAnimation flareAnimation;

  /// The animation size base.
  Vector2 size;

  FlareParticle({
    required this.flareAnimation,
    super.lifespan,
    required this.size,
  }) {
    flareAnimation.init();
  }

  @override
  void render(Canvas canvas) {
    canvas.save();
    flareAnimation.render(canvas, size);
    canvas.restore();
  }

  @override
  void update(double dt) {
    flareAnimation.advance(dt);
  }
}
