import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart' hide World;
import 'package:flame/effects.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/foundation.dart';

/// A pairing of a [ShapeGeometry] with an optional [ShapeDef], used by
/// [BodyComponent.shapeSpecs] to describe the shapes that should be created
/// on the body.
class ShapeSpec {
  const ShapeSpec(this.geometry, [this.definition]);

  /// The geometry of the shape, for example a [Circle] or a [Polygon].
  final ShapeGeometry geometry;

  /// The definition that the shape is created with, or the Forge2D defaults
  /// when null.
  final ShapeDef? definition;
}

/// Since a pure BodyComponent doesn't have anything drawn on top of it,
/// it is a good idea to turn on [debugMode] for it so that the bodies can be
/// seen
///
/// You can use the optional [bodyDef] and [shapeSpecs] arguments to create
/// the [BodyComponent]'s body without having to create the definitions within
/// the component.
class BodyComponent<T extends Forge2DGame> extends Component
    with HasGameRef<T>, HasPaint
    implements
        CoordinateTransform,
        ReadOnlyPositionProvider,
        ReadOnlyAngleProvider {
  BodyComponent({
    Paint? paint,
    super.children,
    super.priority,
    this.renderBody = true,
    this.bodyDef,
    this.shapeSpecs,
    super.key,
  }) {
    this.paint = paint ?? (Paint()..color = defaultColor);
  }

  static const defaultColor = Color.fromARGB(255, 255, 255, 255);
  late Body body;

  /// Whether the debug-mode warning about a body being too small for
  /// Forge2D's tolerances has already been reported.
  ///
  /// A world that is laid out at the wrong scale has that problem everywhere,
  /// so the warning is only worth printing once. Reset it to warn again.
  @visibleForTesting
  static bool debugWarnedAboutBodyScale = false;

  /// The default implementation of [createBody] will use this value to create
  /// the [Body], if it is provided.
  ///
  /// If you do not provide a [BodyDef] here, you must override [createBody].
  BodyDef? bodyDef;

  /// The default implementation of [createBody] will create these shapes on
  /// the [Body] that it creates from [bodyDef].
  List<ShapeSpec>? shapeSpecs;

  @override
  Vector2 get position => body.position;

  /// Specifies if the body's shapes should be rendered.
  ///
  /// [renderBody] is true by default for [BodyComponent], if set to false
  /// the body's shapes wont be rendered.
  ///
  /// If you render something on top of the [BodyComponent], or doesn't want it
  /// to be seen, you probably want to set it to false.
  bool renderBody;

  /// You should create the Forge2D [Body] in this method when you extend
  /// the BodyComponent.
  ///
  /// The default implementation creates the body from [bodyDef] and the
  /// shapes from [shapeSpecs]. When the userData of [bodyDef] or of a shape's
  /// [ShapeDef] is a [ContactCallbacks], contact and sensor events are
  /// automatically enabled for that shape, since Forge2D only generates
  /// events for shapes that have opted in to them. If you override this
  /// method you have to enable the event flags yourself.
  ///
  /// Note that the event flags are set on the [ShapeDef] of the [ShapeSpec]
  /// itself, since Forge2D snapshots them when the shape is created. Don't
  /// share a single [ShapeDef] instance between components if you don't want
  /// them to share those flags.
  Body createBody() {
    assert(
      bodyDef != null,
      'Ensure this.bodyDef is not null or override createBody',
    );
    final body = world.createBody(bodyDef);
    final bodyHasCallbacks = bodyDef!.userData is ContactCallbacks;
    for (final spec in shapeSpecs ?? const <ShapeSpec>[]) {
      final definition = spec.definition ?? ShapeDef();
      if (bodyHasCallbacks || definition.userData is ContactCallbacks) {
        definition.enableContactEvents = true;
        definition.enableSensorEvents = true;
      }
      body.createShape(spec.geometry, definition);
    }
    return body;
  }

  @mustCallSuper
  @override
  Future<void> onLoad() async {
    await super.onLoad();
    world = gameRef.world;
    body = createBody();
    assert(() {
      _debugCheckBodyScale(this, body);
      return true;
    }());
  }

  @override
  void onMount() {
    super.onMount();
    world = gameRef.world;
    if (!body.isValid) {
      // The body was destroyed when the component was removed, and since
      // onLoad only runs once it has to be recreated here for the component
      // to be usable again. Reading a destroyed body is not just stale, it
      // reads freed native memory.
      body = createBody();
    }
  }

  late Forge2DWorld world;
  CameraComponent get camera => gameRef.camera;
  Vector2 get center => body.worldCenterOfMass;

  @override
  double get angle => body.angle;

  /// The matrix used for preparing the canvas
  final Transform2D _transform = Transform2D();
  Matrix4 get _transformMatrix => _transform.transformMatrix;
  double? _lastAngle;

  @mustCallSuper
  @override
  void renderTree(Canvas canvas) {
    final matrix = _transformMatrix;
    if (matrix.m41 != body.position.x ||
        matrix.m42 != body.position.y ||
        _lastAngle != angle) {
      matrix.setIdentity();
      matrix.translateByDouble(body.position.x, body.position.y, 0.0, 1.0);
      matrix.rotateZ(angle);
      _lastAngle = angle;
    }
    canvas.save();
    canvas.transform32(matrix.storage);
    super.renderTree(canvas);
    canvas.restore();
  }

  @override
  void render(Canvas canvas) {
    if (renderBody) {
      for (final shape in body.shapes) {
        renderShape(canvas, shape);
      }
    }
  }

  @override
  void renderDebugMode(Canvas canvas) {
    for (final shape in body.shapes) {
      renderShape(canvas, shape);
    }
  }

  /// Renders a [Shape] in a [Canvas].
  ///
  /// Called for each shape in [body] when [render]ing. Override this method
  /// to customize how shapes are rendered. For example, you can filter out
  /// shapes that you don't want to render.
  ///
  /// **NOTE**: If [renderBody] is false, no shapes will be rendered. Hence,
  /// [renderShape] is not called when [render]ing.
  void renderShape(Canvas canvas, Shape shape) {
    canvas.save();
    switch (shape.geometry) {
      case Circle(:final center, :final radius):
        renderCircle(canvas, center.toOffset(), radius);
      case Capsule(:final center1, :final center2, :final radius):
        renderCapsule(canvas, center1.toOffset(), center2.toOffset(), radius);
      case Segment(:final point1, :final point2):
        renderSegment(canvas, point1.toOffset(), point2.toOffset());
      case Polygon(:final points):
        renderPolygon(
          canvas,
          points!.map((v) => v.toOffset()).toList(growable: false),
        );
    }
    canvas.restore();
  }

  void renderCircle(Canvas canvas, Offset center, double radius) {
    canvas.drawCircle(center, radius, paint);
  }

  late final Path _path = Path();

  void renderPolygon(Canvas canvas, List<Offset> points) {
    final path = _path
      ..reset()
      ..addPolygon(points, true);
    // TODO(Spydon): Use drawVertices instead.
    canvas.drawPath(path, paint);
  }

  void renderSegment(Canvas canvas, Offset p1, Offset p2) {
    canvas.drawLine(p1, p2, paint);
  }

  void renderCapsule(Canvas canvas, Offset p1, Offset p2, double radius) {
    final delta = p2 - p1;
    final angle = math.atan2(delta.dy, delta.dx);
    final path = _path
      ..reset()
      ..addArc(
        Rect.fromCircle(center: p1, radius: radius),
        angle + math.pi / 2,
        math.pi,
      )
      ..arcTo(
        Rect.fromCircle(center: p2, radius: radius),
        angle - math.pi / 2,
        math.pi,
        false,
      )
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  Vector2 parentToLocal(Vector2 point) => _transform.globalToLocal(point);

  @override
  Vector2 localToParent(Vector2 point) => _transform.localToGlobal(point);

  late final Vector2 _hitTestPoint = Vector2.zero();

  @override
  bool containsLocalPoint(Vector2 point) {
    _transform.localToGlobal(point, output: _hitTestPoint);
    return body.shapes.any((shape) => shape.testPoint(_hitTestPoint));
  }

  @override
  bool containsPoint(Vector2 point) {
    return body.shapes.any((shape) => shape.testPoint(point));
  }

  @override
  void onRemove() {
    if (!world.isRemoving || world.destroyBodiesOnRemove) {
      world.destroyBody(body);
    }
    super.onRemove();
  }
}

/// Warns when a moving body is small enough that Forge2D's absolute
/// tolerances dominate it.
///
/// Forge2D reports a contact as soon as two shapes are within
/// [Tolerances.speculativeDistance] of each other, which is what stops fast
/// bodies from passing through things. It also means that a body which is not
/// comfortably larger than that distance is permanently in contact with its
/// neighbors, which usually shows up as `beginContact` firing across a
/// visible gap.
///
/// Only non-static bodies are checked, since Forge2D's guidance is about
/// moving objects and thin static geometry is a normal thing to have. The
/// largest side of the shape is used rather than the smallest, so that thin
/// but long shapes are not reported.
void _debugCheckBodyScale(BodyComponent component, Body body) {
  if (BodyComponent.debugWarnedAboutBodyScale || body.type == BodyType.static) {
    return;
  }
  // Forge2D is tuned for moving bodies between 0.1 and 10 meters, and 0.1
  // meters is five speculative distances.
  final speculativeDistance = Tolerances.speculativeDistance;
  final smallestUsefulSize = 5 * speculativeDistance;
  for (final shape in body.shapes) {
    final largestSide = _debugLargestSide(shape.geometry);
    if (largestSide >= smallestUsefulSize || largestSide == 0) {
      continue;
    }
    BodyComponent.debugWarnedAboutBodyScale = true;
    debugPrint(
      'flame_forge2d: $component has a shape that is only '
      '${_debugMeters(largestSide)} meters across, while Forge2D '
      'reports contacts across gaps of up to '
      '${_debugMeters(speculativeDistance)} meters '
      '(Tolerances.speculativeDistance). Bodies this small collide with '
      'things they do not visibly touch, never bounce, and fall asleep while '
      'still moving.\n'
      'Forge2D is tuned for moving bodies between 0.1 and 10 meters. Lay the '
      'world out at that scale and raise Forge2DGame.metersToPixels to keep '
      'it the same size on screen, remembering to scale gravity by the same '
      'factor so that the timing stays the same. If the layout cannot change, '
      'pass lengthUnitsPerMeter to the Forge2DGame constructor to move the '
      'tolerances instead.\n'
      'This is a debug-mode warning and is only reported once.',
    );
    return;
  }
}

/// The longest side of [geometry], used to tell a body that is small in every
/// direction from one that is merely thin.
///
/// Measured on the geometry rather than on `Shape.aabb`, because Forge2D
/// stores the bounds already grown by the speculative distance, which is the
/// very thing being compared against here.
double _debugLargestSide(ShapeGeometry geometry) {
  switch (geometry) {
    case Circle(:final radius):
      return 2 * radius;
    case Capsule(:final center1, :final center2, :final radius):
      return center1.distanceTo(center2) + 2 * radius;
    case Segment(:final point1, :final point2):
      return point1.distanceTo(point2);
    case Polygon(
      :final points,
      :final radius,
      :final halfWidth,
      :final halfHeight,
    ):
      if (points == null || points.isEmpty) {
        // A box that has not been read back from Forge2D yet.
        return 2 * (math.max(halfWidth ?? 0, halfHeight ?? 0) + radius);
      }
      var minimum = points.first.clone();
      var maximum = points.first.clone();
      for (final point in points) {
        minimum = Vector2(
          math.min(minimum.x, point.x),
          math.min(minimum.y, point.y),
        );
        maximum = Vector2(
          math.max(maximum.x, point.x),
          math.max(maximum.y, point.y),
        );
      }
      return math.max(maximum.x - minimum.x, maximum.y - minimum.y) +
          2 * radius;
  }
}

/// Formats a length without the trailing zeros that [num.toStringAsPrecision]
/// leaves behind.
String _debugMeters(double value) =>
    double.parse(value.toStringAsPrecision(3)).toString();
