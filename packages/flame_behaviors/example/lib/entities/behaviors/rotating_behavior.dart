import 'dart:async';
import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame_behaviors/flame_behaviors.dart';

class RotatingBehavior({required final double rotationSpeed})
    extends Behavior<PositionedEntity>
    with HasGameRef {
  late final ScreenHitbox screenHitbox;

  @override
  FutureOr<void> onLoad() {
    screenHitbox = gameRef.children.whereType<ScreenHitbox>().first;
  }

  @override
  void update(double dt) {
    final angleDelta = dt * rotationSpeed;
    parent.angle = (parent.angle + angleDelta) % (2 * pi);
  }
}
