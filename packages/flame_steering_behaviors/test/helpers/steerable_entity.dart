import 'package:flame/extensions.dart';
import 'package:flame_behaviors/flame_behaviors.dart';
import 'package:flame_steering_behaviors/flame_steering_behaviors.dart';

class SteerableEntity extends PositionedEntity with Steerable {
  SteerableEntity({
    super.position,
    super.behaviors,
    super.size,
  });

  @override
  double get maxVelocity => 100;

  @override
  void renderDebugMode(Canvas canvas) {
    // Custom debug render mode so that the PositionComponent text doesn't get
    // rendered.
    canvas.drawRect(Vector2.zero() & size, debugPaint);
  }
}
