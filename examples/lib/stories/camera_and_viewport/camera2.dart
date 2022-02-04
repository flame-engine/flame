import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/src/experimental/camera.dart'; // ignore: implementation_imports
import 'package:flame/src/experimental/world.dart'; // ignore: implementation_imports
import 'package:flutter/widgets.dart';

Future<void> main() async {
  runApp(GameWidget(game: Camera2Example()));
}

class Camera2Example extends FlameGame {
  @override
  Color backgroundColor() => const Color(0xFFffffff);

  @override
  Future<void> onLoad() async {
    final world = AntWorld();
    await add(world);
    final camera = Camera2(world: world);
    await add(camera);
    final center = world.curve.boundingRect().center;
    camera.viewfinder.position = Vector2(center.dx, center.dy);
  }
}

class AntWorld extends World {
  late final DragonCurve curve;

  @override
  Future<void> onLoad() async {
    final random = Random();
    curve = DragonCurve();
    await add(curve);

    const baseColor = HSVColor.fromAHSV(1, 38.5, 0.63, 0.68);
    for (var i = 0; i < 20; i++) {
      add(
        Ant()
          ..color = baseColor.withHue(random.nextDouble() * 360).toColor()
          ..scale = Vector2.all(.4)
          ..setTravelPath(curve.path),
      );
    }
  }
}

class DragonCurve extends PositionComponent {
  DragonCurve() {
    initPath();
  }

  late final Paint borderPaint;
  late final Paint mainPaint;
  late final Path dragon;
  late List<Vector2> path;
  static const cellSize = 20.0;
  static const notchSize = 4.0;

  void initPath() {
    path = [
      Vector2(0, cellSize - notchSize),
      Vector2(0, notchSize),
    ];
    final endPoint = Vector2(0, cellSize);
    final transform = Transform2D()..angleDegrees = -90;
    for (var i = 0; i < 8; i++) {
      path += List.from(path.reversed.map<Vector2>(transform.localToGlobal));
      final pivot = transform.localToGlobal(endPoint);
      transform
        ..position = pivot
        ..offset = -pivot;
    }
  }

  Rect boundingRect() {
    var minX = double.infinity;
    var minY = double.infinity;
    var maxX = -double.infinity;
    var maxY = -double.infinity;
    for (final point in path) {
      minX = min(minX, point.x);
      minY = min(minY, point.y);
      maxX = max(maxX, point.x);
      maxY = max(maxY, point.y);
    }
    return Rect.fromLTRB(minX, minY, maxX, maxY);
  }

  @override
  Future<void> onLoad() async {
    borderPaint = Paint()
      ..color = const Color(0xFF041D1F)
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 0.3)
      ..strokeWidth = 4;
    mainPaint = Paint()
      ..color = const Color(0xffefe79c)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.6;

    dragon = Path()..moveTo(path[0].x, path[0].y);
    for (final p in path) {
      dragon.lineTo(p.x, p.y);
    }
  }

  @override
  void render(Canvas canvas) {
    canvas.drawPath(dragon, borderPaint);
    canvas.drawPath(dragon, mainPaint);
  }
}

class Ant extends PositionComponent {
  Ant() : random = Random() {
    size = Vector2(2, 5);
    anchor = const Anchor(0.5, 0.4);
  }

  late final Color color;
  final Random random;
  static const black = Color(0xFF000000);
  static const tau = Transform2D.tau;
  late final Paint bodyPaint;
  late final Paint eyesPaint;
  late final Paint legsPaint;
  late final Paint facePaint;
  late final Paint borderPaint;
  late final Path head;
  late final Path body;
  late final Path pincers;
  late final Path eyes;
  late final Path antennae;
  late final List<InsectLeg> legs;
  Vector2 destinationPosition = Vector2.zero();
  double destinationAngle = 0;
  double movementTime = 0;
  double rotationTime = 0;
  double stepTime = 0;
  double movementSpeed = 3; // mm/s
  double rotationSpeed = 3; // angle/s
  double probabilityToChangeDirection = 0.02;
  bool moveLeftSide = false;
  List<Vector2> targetLegsPositions = List.generate(6, (_) => Vector2.zero());
  List<Vector2> travelPath = [];
  int travelPathNodeIndex = 0;
  int travelDirection = 1; // +1 or -1

  bool legIsMoving(int i) => moveLeftSide == (i < 3);

  void setTravelPath(List<Vector2> path) {
    travelPath = path;
    travelPathNodeIndex = random.nextInt(path.length - 1);
    travelDirection = 1;
    position = travelPath[travelPathNodeIndex];
    destinationPosition = travelPath[travelPathNodeIndex + travelDirection];
    angle = -(destinationPosition - position).angleToSigned(Vector2(0, -1));
    destinationAngle = angle;
  }

  @override
  Future<void> onLoad() async {
    bodyPaint = Paint()..color = color;
    eyesPaint = Paint()..color = black;
    borderPaint = Paint()
      ..color = Color.lerp(color, black, 0.6)!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.06;
    legsPaint = Paint()
      ..color = Color.lerp(color, black, 0.4)!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.2;
    facePaint = Paint()
      ..color = Color.lerp(color, black, 0.5)!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.05;
    head = Path()
      ..moveTo(0, -0.3)
      ..cubicTo(-0.5, -0.3, -0.7, -0.6, -0.7, -1)
      ..cubicTo(-0.7, -1.3, -0.3, -2, 0, -2)
      ..cubicTo(0.3, -2, 0.7, -1.3, 0.7, -1)
      ..cubicTo(0.7, -0.6, 0.5, -0.3, 0, -0.3)
      ..close();
    body = Path()
      ..moveTo(0, -0.3)
      ..cubicTo(0.2, -0.3, 0.4, -0.2, 0.4, 0.2)
      ..cubicTo(0.4, 0.4, 0.25, 1, 0, 1)
      ..cubicTo(0.6, 1, 0.9, 1.4, 0.9, 1.8)
      ..cubicTo(0.9, 2.6, 0.35, 3.1, 0, 3.1)
      ..cubicTo(-0.35, 3.1, -0.9, 2.6, -0.9, 1.8)
      ..cubicTo(-0.9, 1.4, -0.6, 1, 0, 1)
      ..cubicTo(-0.25, 1, -0.4, 0.4, -0.4, 0.2)
      ..cubicTo(-0.4, -0.2, -0.2, -0.3, 0, -0.3)
      ..close();
    pincers = Path()
      ..moveTo(0.15, -2.15)
      ..cubicTo(0.5, -1.5, -0.5, -1.5, -0.15, -2.15)
      ..cubicTo(-0.3, -1.8, 0.3, -1.8, 0.15, -2.15)
      ..close();
    antennae = Path()
      ..moveTo(0, -1.7)
      ..lineTo(-0.7, -1.9)
      ..lineTo(-1, -2.5)
      ..lineTo(-1.5, -2.6)
      ..moveTo(0, -1.7)
      ..lineTo(0.7, -1.9)
      ..lineTo(1, -2.5)
      ..lineTo(1.5, -2.6);
    eyes = Path()
      ..moveTo(-0.5, -1.1)
      ..cubicTo(-0.95, -1.1, -0.6, -1.8, -0.3, -1.8)
      ..cubicTo(0, -1.8, 0, -1.1, -0.5, -1.1)
      ..moveTo(0.5, -1.1)
      ..cubicTo(0.95, -1.1, 0.6, -1.8, 0.3, -1.8)
      ..cubicTo(0, -1.8, 0, -1.1, 0.5, -1.1)
      ..close();
    legs = [
      InsectLeg(-0.3, 0.4, -2.6, 0.6, 1.1, 1.1, 0.5, true),
      InsectLeg(-0.2, 0.7, -2.3, 2.6, 1.5, 1.5, 0.6, true),
      InsectLeg(0.3, 0, 1.7, -2.3, 1.5, 1.3, 0.6, true),
      InsectLeg(0.3, 0.4, 2.6, 0.6, 1.1, 1.1, 0.5, false),
      InsectLeg(0.2, 0.7, 2.3, 2.6, 1.5, 1.5, 0.6, false),
      InsectLeg(-0.3, 0, -1.7, -2.3, 1.5, 1.3, 0.6, false),
    ];
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (movementTime <= 0 && rotationTime <= 0) {
      planNextMove();
    }
    if (stepTime <= 0) {
      planNextStep();
    }
    final feetPositions = [for (final leg in legs) positionOf(leg.foot)];
    final fMove = movementTime > 0 ? min(dt / movementTime, 1) : 0;
    final fRot = rotationTime > 0 ? min(dt / rotationTime, 1) : 0;
    final deltaX = (destinationPosition.x - position.x) * fMove;
    final deltaY = (destinationPosition.y - position.y) * fMove;
    final deltaA = (destinationAngle - angle) * fRot;
    position += Vector2(deltaX, deltaY);
    angle += deltaA;
    movementTime -= dt;
    rotationTime -= dt;
    for (var i = 0; i < 6; i++) {
      var newFootPosition = feetPositions[i];
      if (legIsMoving(i)) {
        final fStep = min(dt / stepTime, 1.0);
        final targetPosition = targetLegsPositions[i];
        newFootPosition += (targetPosition - newFootPosition) * fStep;
      }
      legs[i].placeFoot(toLocal(newFootPosition));
    }
    stepTime -= dt;
  }

  void planNextStep() {
    moveLeftSide = !moveLeftSide;
    stepTime = 0.1;
    final f = min(stepTime * 1.6 / movementTime, 1.0);
    final deltaX = (destinationPosition.x - position.x) * f;
    final deltaY = (destinationPosition.y - position.y) * f;
    final deltaA = (destinationAngle - angle) * f;
    position += Vector2(deltaX, deltaY);
    angle += deltaA;
    for (var i = 0; i < 6; i++) {
      if (legIsMoving(i)) {
        targetLegsPositions[i].setFrom(
          positionOf(Vector2(legs[i].x1, legs[i].y1)),
        );
      }
    }
    position -= Vector2(deltaX, deltaY);
    angle -= deltaA;
  }

  void planNextMove() {
    if (travelPathNodeIndex == 0) {
      travelDirection = 1;
    } else if (travelPathNodeIndex == travelPath.length - 1) {
      travelDirection = -1;
    } else if (random.nextDouble() < probabilityToChangeDirection) {
      travelDirection = -travelDirection;
    }
    final nextIndex = travelPathNodeIndex + travelDirection;
    assert(nextIndex >= 0 && nextIndex < travelPath.length);
    final nextPosition = travelPath[nextIndex];
    var nextAngle =
        angle = -(nextPosition - position).angleToSigned(Vector2(0, -1));
    if (nextAngle - angle > tau / 2) {
      nextAngle -= tau;
    }
    if (nextAngle - angle < -tau / 2) {
      nextAngle += tau;
    }
    if ((nextAngle - angle).abs() > 1) {
      destinationPosition = position;
      destinationAngle = nextAngle;
    } else {
      destinationPosition = nextPosition;
      destinationAngle = nextAngle;
      travelPathNodeIndex = nextIndex;
    }
    rotationTime = (destinationAngle - angle) / rotationSpeed;
    movementTime = (destinationPosition - position).length / movementSpeed;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    canvas
      ..save()
      ..translate(1, 2)
      ..drawPath(pincers, facePaint)
      ..drawPath(antennae, facePaint)
      ..drawPath(head, bodyPaint)
      ..drawPath(head, borderPaint)
      ..drawPath(eyes, eyesPaint)
      ..drawPath(legs[0].path, legsPaint)
      ..drawPath(legs[1].path, legsPaint)
      ..drawPath(legs[2].path, legsPaint)
      ..drawPath(legs[3].path, legsPaint)
      ..drawPath(legs[4].path, legsPaint)
      ..drawPath(legs[5].path, legsPaint)
      ..drawPath(body, bodyPaint)
      ..drawPath(body, borderPaint)
      ..restore();
  }
}

class InsectLeg {
  InsectLeg(
    this.x0,
    this.y0,
    this.x1,
    this.y1,
    this.l1,
    this.l2,
    this.l3,
    this.bendDirection,
  )   : r = l3 / 2,
        dir = bendDirection ? -1 : 1,
        path = Path(),
        foot = Vector2.zero() {
    final ok = placeFoot(Vector2(x1, y1));
    assert(ok);
  }

  final double x0, y0;
  final double x1, y1;
  final double l1, l2, l3, r;
  final bool bendDirection;
  final double dir;
  final Path path;
  final Vector2 foot;

  bool placeFoot(Vector2 pos) {
    final rr = distance(pos.x, pos.y, x0, y0);
    if (rr < r) {
      return false;
    }
    final d = rr - r;
    final z = (d * d + l1 * l1 - l2 * l2) / (2 * d);
    if (z > l1) {
      return false;
    }
    final h = sqrt(l1 * l1 - z * z);
    final xv = (pos.x - x0) / rr;
    final yv = (pos.y - y0) / rr;
    path
      ..reset()
      ..moveTo(x0, y0)
      ..lineTo(x0 + xv * z + dir * yv * h, y0 + yv * z - dir * xv * h)
      ..lineTo(x0 + xv * (rr - r), y0 + yv * (rr - r))
      ..lineTo(x0 + xv * (rr + r), y0 + yv * (rr + r));
    foot.setFrom(pos);
    return true;
  }
}

double distance(num x0, num y0, num x1, num y1) {
  final dx = x1 - x0;
  final dy = y1 - y0;
  return sqrt(dx * dx + dy * dy);
}
