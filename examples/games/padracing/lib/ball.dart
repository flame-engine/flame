import 'dart:math';
import 'dart:ui';

import 'package:flame/extensions.dart';
import 'package:flame/palette.dart';
import 'package:flame_forge2d/flame_forge2d.dart' hide Particle, World;
import 'package:padracing/car.dart';
import 'package:padracing/game_colors.dart';
import 'package:padracing/padracing_game.dart';
import 'package:padracing/wall.dart';

class Ball extends BodyComponent<PadRacingGame> with ContactCallbacks {
  final double radius;
  final Vector2 initialPosition;
  final double rotation;
  final bool isMovable;
  final rng = Random();
  late final Paint _shaderPaint;

  Ball({
    required this.initialPosition,
    this.radius = 80.0,
    this.rotation = 1.0,
    this.isMovable = true,
  }) : super(priority: 3);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    renderBody = false;
    _shaderPaint = GameColors.green.paint
      ..shader = Gradient.radial(
        Offset.zero,
        radius,
        [
          GameColors.green.color,
          BasicPalette.black.color,
        ],
        null,
        TileMode.clamp,
        null,
        Offset(radius / 2, radius / 2),
      );
  }

  @override
  Body createBody() {
    final def = BodyDef()
      ..userData = this
      ..type = isMovable ? BodyType.dynamic : BodyType.kinematic
      ..position = initialPosition;
    final body = world.createBody(def)..angularVelocity = rotation;

    final shape = CircleShape()..radius = radius;
    final fixtureDef = FixtureDef(shape)
      ..restitution = 0.5
      ..friction = 0.5;
    return body..createFixture(fixtureDef);
  }

  @override
  void render(Canvas canvas) {
    canvas.drawCircle(Offset.zero, radius, _shaderPaint);
  }

  @override
  void beginContact(Object other, Contact contact) {
    if (isMovable && other is Car) {
      final carBody = other.body;
      carBody.applyAngularImpulse(3 * carBody.mass * 100);
    }
  }

  late Rect asRect = Rect.fromCircle(
    center: initialPosition.toOffset(),
    radius: radius,
  );
}

List<Ball> createBalls(Vector2 trackSize, List<Wall> walls, Ball bigBall) {
  final balls = <Ball>[];
  final rng = Random();
  while (balls.length < 20) {
    final ball = Ball(
      initialPosition: Vector2.random(rng)..multiply(trackSize),
      radius: 3.0 + rng.nextInt(5),
      rotation: (rng.nextBool() ? 1 : -1) * rng.nextInt(5).toDouble(),
    );
    final touchesBall =
        ball.initialPosition.distanceTo(bigBall.initialPosition) <
            ball.radius + bigBall.radius;
    if (!touchesBall) {
      final touchesWall =
          walls.any((wall) => wall.asRect.overlaps(ball.asRect));
      if (!touchesWall) {
        balls.add(ball);
      }
    }
  }
  return balls;
}
