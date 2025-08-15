import 'dart:ui';

import 'package:flame/components.dart' hide World;
import 'package:flame/effects.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/foundation.dart';

/// Since a pure BodyComponent doesn't have anything drawn on top of it,
/// it is a good idea to turn on [debugMode] for it so that the bodies can be
/// seen
///
/// You can use the optional [bodyDef] and [fixtureDefs] arguments to create
/// the [BodyComponent]'s body without having to create the definitions within
/// the component.
class BodyComponent<T extends Forge2DGame> extends Component
    with HasGameReference<T>, HasPaint
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
    this.fixtureDefs,
    super.key,
  }) {
    this.paint = paint ?? (Paint()..color = defaultColor);
  }

  static const defaultColor = Color.fromARGB(255, 255, 255, 255);
  late Body body;

  /// The default implementation of [createBody] will use this value to create
  /// the [Body], if it is provided.
  ///
  /// If you do not provide a [BodyDef] here, you must override [createBody].
  BodyDef? bodyDef;

  /// The default implementation of [createBody] will add these fixtures to the
  /// [Body] that it creates from [bodyDef].
  List<FixtureDef>? fixtureDefs;

  @override
  Vector2 get position => body.position;

  /// Specifies if the body's fixtures should be rendered.
  ///
  /// [renderBody] is true by default for [BodyComponent], if set to false
  /// the body's fixtures wont be rendered.
  ///
  /// If you render something on top of the [BodyComponent], or doesn't want it
  /// to be seen, you probably want to set it to false.
  bool renderBody;

  /// You should create the Forge2D [Body] in this method when you extend
  /// the BodyComponent.
  Body createBody() {
    assert(
      bodyDef != null,
      'Ensure this.bodyDef is not null or override createBody',
    );
    final body = world.createBody(bodyDef!);
    fixtureDefs?.forEach(body.createFixture);
    return body;
  }

  @mustCallSuper
  @override
  Future<void> onLoad() async {
    await super.onLoad();
    body = createBody();
  }

  Forge2DWorld get world => game.world;
  CameraComponent get camera => game.camera;
  Vector2 get center => body.worldCenter;

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
      for (final fixture in body.fixtures) {
        renderFixture(canvas, fixture);
      }
    }
  }

  @override
  void renderDebugMode(Canvas canvas) {
    body.fixtures.forEach(
      (fixture) => renderFixture(canvas, fixture),
    );
  }

  /// Renders a [Fixture] in a [Canvas].
  ///
  /// Called for each fixture in [body] when [render]ing. Override this method
  /// to customize how fixtures are rendered. For example, you can filter out
  /// fixtures that you don't want to render.
  ///
  /// **NOTE**: If [renderBody] is false, no fixtures will be rendered. Hence,
  /// [renderFixture] is not called when [render]ing.
  void renderFixture(Canvas canvas, Fixture fixture) {
    canvas.save();
    switch (fixture.type) {
      case ShapeType.chain:
        _renderChain(canvas, fixture);
      case ShapeType.circle:
        _renderCircle(canvas, fixture);
      case ShapeType.edge:
        _renderEdge(canvas, fixture);
      case ShapeType.polygon:
        _renderPolygon(canvas, fixture);
    }
    canvas.restore();
  }

  void _renderChain(Canvas canvas, Fixture fixture) {
    final chainShape = fixture.shape as ChainShape;
    renderChain(
      canvas,
      chainShape.vertices.map((v) => v.toOffset()).toList(growable: false),
    );
  }

  void renderChain(Canvas canvas, List<Offset> points) {
    canvas.drawPoints(PointMode.polygon, points, paint);
  }

  void _renderCircle(Canvas canvas, Fixture fixture) {
    final circle = fixture.shape as CircleShape;
    renderCircle(canvas, circle.position.toOffset(), circle.radius);
  }

  void renderCircle(Canvas canvas, Offset center, double radius) {
    canvas.drawCircle(center, radius, paint);
  }

  void _renderPolygon(Canvas canvas, Fixture fixture) {
    final polygon = fixture.shape as PolygonShape;
    renderPolygon(
      canvas,
      polygon.vertices.map((v) => v.toOffset()).toList(growable: false),
    );
  }

  late final Path _path = Path();

  void renderPolygon(Canvas canvas, List<Offset> points) {
    final path = _path
      ..reset()
      ..addPolygon(points, true);
    // TODO(Spydon): Use drawVertices instead.
    canvas.drawPath(path, paint);
  }

  void _renderEdge(Canvas canvas, Fixture fixture) {
    final edge = fixture.shape as EdgeShape;
    renderEdge(canvas, edge.vertex1.toOffset(), edge.vertex2.toOffset());
  }

  void renderEdge(Canvas canvas, Offset p1, Offset p2) {
    canvas.drawLine(p1, p2, paint);
  }

  @override
  Vector2 parentToLocal(Vector2 point) => _transform.globalToLocal(point);

  @override
  Vector2 localToParent(Vector2 point) => _transform.localToGlobal(point);

  late final Vector2 _hitTestPoint = Vector2.zero();

  @override
  bool containsLocalPoint(Vector2 point) {
    _transform.localToGlobal(point, output: _hitTestPoint);
    return body.fixtures.any((fixture) => fixture.testPoint(_hitTestPoint));
  }

  @override
  bool containsPoint(Vector2 point) {
    return body.fixtures.any((fixture) => fixture.testPoint(point));
  }

  @override
  void onRemove() {
    world.destroyBody(body);
    super.onRemove();
  }
}
