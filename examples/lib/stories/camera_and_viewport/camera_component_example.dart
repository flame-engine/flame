import 'dart:math';

import 'package:flame/camera.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/extensions.dart' show OffsetExtension;
import 'package:flame/game.dart';
import 'package:flame/geometry.dart';
import 'package:flame/input.dart';
import 'package:flutter/painting.dart';

class CameraComponentExample extends FlameGame with PanDetector {
  static const description = '''
    This example shows how a camera can be dynamically added into a game using
    a CameraComponent.
    
    Click and hold the mouse to bring up a magnifying glass, then have a better
    look at the world underneath! 
  ''';

  late final CameraComponent magnifyingGlass;
  late final Vector2 center;
  static const zoom = 10.0;
  static const radius = 130.0;

  @override
  Color backgroundColor() => const Color(0xFFeeeeee);

  @override
  Future<void> onLoad() async {
    final world = AntWorld();
    await add(world);
    final camera = CameraComponent(world: world);
    await add(camera);
    final offset = world.curve.boundingRect().center;
    center = offset.toVector2();
    camera.viewfinder.position = Vector2(center.x, center.y);

    magnifyingGlass =
        CameraComponent(world: world, viewport: CircularViewport(radius));
    magnifyingGlass.viewport.add(Bezel(radius));
    magnifyingGlass.viewfinder.zoom = zoom;
  }

  @override
  bool onPanStart(DragStartInfo info) {
    _updateMagnifyingGlassPosition(info.eventPosition.widget);
    add(magnifyingGlass);
    return false;
  }

  @override
  bool onPanUpdate(DragUpdateInfo info) {
    _updateMagnifyingGlassPosition(info.eventPosition.widget);
    return false;
  }

  @override
  bool onPanEnd(DragEndInfo info) {
    onPanCancel();
    return false;
  }

  @override
  bool onPanCancel() {
    remove(magnifyingGlass);
    return false;
  }

  void _updateMagnifyingGlassPosition(Vector2 point) {
    // [point] is in the canvas coordinate system.
    magnifyingGlass
      ..viewport.position = point - Vector2.all(radius)
      ..viewfinder.position = point - canvasSize / 2 + center;
  }
}

class Bezel extends PositionComponent {
  Bezel(this.radius)
      : super(
          size: Vector2.all(2 * radius),
          position: Vector2.all(radius),
        );

  final double radius;
  late final Path rim;
  late final Path rimBorder;
  late final Path handle;
  late final Path connector;
  late final Path specularHighlight;
  static const rimWidth = 20.0;
  static const handleWidth = 40.0;
  static const handleLength = 100.0;
  late final Paint glassPaint;
  late final Paint rimPaint;
  late final Paint rimBorderPaint;
  late final Paint handlePaint;
  late final Paint connectorPaint;
  late final Paint specularPaint;

  @override
  void onLoad() {
    rim = Path()..addOval(Rect.fromLTRB(-radius, -radius, radius, radius));
    final outer = radius + rimWidth / 2;
    final inner = radius - rimWidth / 2;
    rimBorder = Path()
      ..addOval(Rect.fromLTRB(-outer, -outer, outer, outer))
      ..addOval(Rect.fromLTRB(-inner, -inner, inner, inner));
    handle = (Path()
          ..addRRect(
            RRect.fromLTRBR(
              radius,
              -handleWidth / 2,
              handleLength + radius,
              handleWidth / 2,
              const Radius.circular(5.0),
            ),
          ))
        .transform((Matrix4.identity()..rotateZ(pi / 4)).storage);
    connector = (Path()
          ..addArc(Rect.fromLTRB(-outer, -outer, outer, outer), -0.22, 0.44))
        .transform((Matrix4.identity()..rotateZ(pi / 4)).storage);
    specularHighlight = (Path()
          ..addOval(Rect.fromLTWH(-radius * 0.8, -8, 16, radius * 0.3)))
        .transform((Matrix4.identity()..rotateZ(pi / 4)).storage);

    glassPaint = Paint()..color = const Color(0x1400ffae);
    rimBorderPaint = Paint()
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke
      ..color = const Color(0xff61382a);
    rimPaint = Paint()
      ..strokeWidth = rimWidth
      ..style = PaintingStyle.stroke
      ..color = const Color(0xffffdf70);
    connectorPaint = Paint()
      ..strokeWidth = 20.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..color = const Color(0xff654510);
    handlePaint = Paint()..color = const Color(0xffdbbf9f);
    specularPaint = Paint()
      ..color = const Color(0xccffffff)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
  }

  @override
  void render(Canvas canvas) {
    canvas.drawPath(rim, glassPaint);
    canvas.drawPath(specularHighlight, specularPaint);
    canvas.drawPath(handle, handlePaint);
    canvas.drawPath(handle, rimBorderPaint);
    canvas.drawPath(connector, connectorPaint);
    canvas.drawPath(rim, rimPaint);
    canvas.drawPath(rimBorder, rimBorderPaint);
  }
}

class AntWorld extends World {
  late final DragonCurve curve;
  late final Rect bgRect;
  final Paint bgPaint = Paint()..color = const Color(0xffeeeeee);

  @override
  Future<void> onLoad() async {
    final random = Random();
    curve = DragonCurve();
    await add(curve);
    bgRect = curve.boundingRect().inflate(100);

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

  @override
  void render(Canvas canvas) {
    // Render white backdrop, to prevent the world in the magnifying glass from
    // being "see-through"
    canvas.drawRect(bgRect, bgPaint);
  }
}

class DragonCurve extends PositionComponent {
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
    initPath();
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
      InsectLeg(-0.3, 0.4, -2.6, 0.6, 1.1, 1.1, 0.5, mirrorBendDirection: true),
      InsectLeg(-0.2, 0.7, -2.3, 2.6, 1.5, 1.5, 0.6, mirrorBendDirection: true),
      InsectLeg(0.3, 0, 1.7, -2.3, 1.5, 1.3, 0.6, mirrorBendDirection: true),
      InsectLeg(0.3, 0.4, 2.6, 0.6, 1.1, 1.1, 0.5, mirrorBendDirection: false),
      InsectLeg(0.2, 0.7, 2.3, 2.6, 1.5, 1.5, 0.6, mirrorBendDirection: false),
      InsectLeg(-0.3, 0, -1.7, -2.3, 1.5, 1.3, 0.6, mirrorBendDirection: false),
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
    assert(
      nextIndex >= 0 && nextIndex < travelPath.length,
      'nextIndex is outside of the bounds of travelPath',
    );
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
    this.l3, {
    required bool mirrorBendDirection,
  })  : dir = mirrorBendDirection ? -1 : 1,
        path = Path(),
        foot = Vector2.zero() {
    final ok = placeFoot(Vector2(x1, y1));
    assert(ok, 'The foot was not properly placed');
  }

  /// Place where the leg is attached to the body
  final double x0;
  final double y0;

  /// Place on the ground where the ant needs to place its foot
  final double x1;
  final double y1;

  /// Lengths of the 3 segments of the leg: [l1] is nearest to the body, [l2]
  /// is the middle part, and [l3] is the "foot".
  final double l1;
  final double l2;
  final double l3;

  /// +1 if the leg bends "forward", or -1 if backwards
  final double dir;

  /// The leg is drawn as a simple [path] polyline consisting of 3 segments.
  final Path path;

  /// This vector stores the position of the foot; it's equal to (x1, y1).
  final Vector2 foot;

  bool placeFoot(Vector2 pos) {
    final r = l3 / 2;
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
