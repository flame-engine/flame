import 'package:flame/extensions.dart';
import 'package:flame/src/components/mixins/single_child_particle.dart';
import 'package:flame/src/particles/curved_particle.dart';
import 'package:flame/src/particles/particle.dart';

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
    speed.addScaled(acceleration, dt);
    position
      ..addScaled(speed, dt)
      ..addScaled(acceleration, -dt * dt * 0.5);
    super.update(dt);
  }
}
