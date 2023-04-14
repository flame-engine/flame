import 'package:flame/extensions.dart';
import 'package:flame/src/components/mixins/single_child_particle.dart';
import 'package:flame/src/particles/curved_particle.dart';
import 'package:flame/src/particles/particle.dart';

/// Statically move given child [Particle] by given [Vector2].
///
/// If you're looking to move the child, consider the [MovingParticle].
class MovingParticle extends CurvedParticle with SingleChildParticle {
  @override
  Particle child;

  final Vector2 from;
  final Vector2 to;

  MovingParticle({
    required this.child,
    required this.to,
    Vector2? from,
    super.lifespan,
    super.curve,
  }) : from = from ?? Vector2.zero();

  /// Used to avoid creating new [Vector2] objects in [update].
  static final _tmpVector = Vector2.zero();

  @override
  void render(Canvas canvas) {
    canvas.save();
    final current = _tmpVector
      ..setFrom(from)
      ..lerp(to, progress);
    canvas.translateVector(current);
    super.render(canvas);
    canvas.restore();
  }
}
