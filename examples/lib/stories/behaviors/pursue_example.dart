import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/steer.dart';

class PursueExample extends FlameGame {
  static const description = '''
  ''';

  late Predator predator;

  @override
  Future<void> onLoad() async {
    super.onLoad();
    // camera.viewport = FixedResolutionViewport(Vector2(400, 800));
    predator = Predator(position: Vector2(200, 400))
      ..behavior = Pursue()
      ..maxLinearSpeed = 100
      ..maxLinearAcceleration = 20;
    add(predator);
    makePrey();
  }

  void makePrey() {
    const tau = 2 * pi;
    final random = Random();

    final preyX = random.nextDouble() * 200 + 100.0;
    final preyY = random.nextDouble() * 300 + 250.0;
    final prey = Prey(
      position: Vector2(preyX, preyY),
      velocity: Vector2(0, 30)..rotate(random.nextDouble() * tau),
    ) ..maxLinearSpeed = 30;
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
      : super(size: Vector2.all(40), position: position);

  final bgPaint = Paint()..color = const Color(0xffcd006a);

  Steerable? get target => (behavior! as Pursue).target;
  set target(Steerable? target) {
    (behavior! as Pursue).target = target;
  }

  @override
  void render(Canvas canvas) {
    canvas.drawRect(Rect.fromLTWH(0, 0, width, height), bgPaint);
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
