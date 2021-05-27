import 'dart:ui';

import '../../extensions.dart';
import '../components/mixins/single_child_particle.dart';
import 'curved_particle.dart';
import 'particle.dart';

/// A particle that serves as a container for basic acceleration physics.
///
/// [speed] is logical px per second.
///
/// ```dart
/// AcceleratedParticle(
///   speed: Vector2(0, 100), // is 100 logical px/s down.
///   acceleration: Vector2(-40, 0) // will accelerate to the left at rate of 40 px/s
/// )
/// ```
class AcceleratedParticle extends CurvedParticle with SingleChildParticle {
  @override
  Particle child;

  final Vector2 acceleration;
  Vector2 speed;
  Vector2 position;

  AcceleratedParticle({
    required this.child,
    Vector2? acceleration,
    Vector2? speed,
    Vector2? position,
    double? lifespan,
  })  : acceleration = acceleration ?? Vector2.zero(),
        position = position ?? Vector2.zero(),
        speed = speed ?? Vector2.zero(),
        super(lifespan: lifespan);

  @override
  void render(Canvas canvas) {
    canvas.save();
    canvas.translateVector(position);
    super.render(canvas);
    canvas.restore();
  }

  @override
  void update(double dt) {
    speed += acceleration * dt;
    position += speed * dt - (acceleration * dt * dt) / 2;
    super.update(dt);
  }
}
