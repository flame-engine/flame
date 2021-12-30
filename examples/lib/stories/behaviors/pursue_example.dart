// ignore_for_file: implementation_imports
import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/src/ai/steer/behaviors/pursue.dart';
import 'package:flame/src/ai/steer/steerable.dart';
import 'package:flame/src/components/steerable_component.dart';

class PursueExample extends FlameGame {
  static const description = '''
    In this example the red square (Predator) chases after blue circles (Prey)
    using the Pursue behavior. Thin blue line shows the current predator's
    velocity, and yellow line is its acceleration.
  ''';

  late Predator predator;

  @override
  Future<void> onLoad() async {
    super.onLoad();
    // camera.viewport = FixedResolutionViewport(Vector2(400, 800));
    predator = Predator(position: Vector2(200, 400))
      ..behavior = Pursue(maxPredictionTime: 3)
      ..maxLinearSpeed = 100
      ..maxLinearAcceleration = 50;
    add(predator);
    makePrey();
  }

  void makePrey() {
    const tau = 2 * pi;
    final random = Random();

    final preyX = random.nextDouble() * 200 + 100.0;
    final preyY = random.nextDouble() * 300 + 100.0;
    final prey = Prey(
      position: Vector2(preyX, preyY),
      velocity: Vector2(0, 30)..rotate(random.nextDouble() * tau),
    )..maxLinearSpeed = 30;
    add(prey);
    predator.target = prey;
  }
}

class Prey extends SteerableComponent {
  Prey({Vector2? position, Vector2? velocity})
      : super(position: position, velocity: velocity, size: Vector2.all(20));

  final bgPaint = Paint()..color = const Color(0xff74c3ff);

  @override
  void render(Canvas canvas) {
    final radius = width / 2;
    canvas.drawCircle(Offset(radius, radius), radius, bgPaint);
  }
}

class Predator extends SteerableComponent with HasGameRef<PursueExample> {
  Predator({Vector2? position})
      : super(size: Vector2.all(20), position: position);

  final bgPaint = Paint()..color = const Color(0xffe21515);
  final speedPaint = Paint()
    ..color = const Color(0xff52a569)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1;
  final accelerationPaint = Paint()
    ..color = const Color(0xffe8bf28)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2;

  Steerable? get target => (behavior! as Pursue).target;
  set target(Steerable? target) {
    (behavior! as Pursue).target = target;
  }

  @override
  void render(Canvas canvas) {
    // print(linearVelocity);
    canvas.drawRect(Rect.fromLTWH(0, 0, width, height), bgPaint);
    canvas.drawPath(
      Path()
        ..moveTo(width / 2, height / 2)
        ..relativeLineTo(linearVelocity.x, linearVelocity.y),
      speedPaint,
    );
    final acceleration = steering.linearAcceleration;
    canvas.drawPath(
      Path()
        ..moveTo(width / 2, height / 2)
        ..relativeLineTo(acceleration.x, acceleration.y),
      accelerationPaint,
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    final prey = target;
    if (prey != null) {
      if (position.distanceToSquared(prey.position) < 64) {
        (prey as SteerableComponent).removeFromParent();
        target = null;
        gameRef.makePrey();
      }
    }
  }
}
