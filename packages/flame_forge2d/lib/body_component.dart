import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flame_forge2d/forge2d_game.dart';
import 'package:flutter/foundation.dart';
import 'package:forge2d/forge2d.dart' hide Timer, Vector2;

/// Since a pure BodyComponent doesn't have anything drawn on top of it,
/// it is a good idea to turn on [debugMode] for it so that the bodies can be
/// seen
abstract class BodyComponent<T extends Forge2DGame> extends Component
    with HasGameRef<T>, HasPaint {
  BodyComponent({
    Paint? paint,
    super.children,
    super.priority,
    this.renderBody = true,
  }) {
    this.paint = paint ?? (Paint()..color = defaultColor);
  }

  static const defaultColor = Color.fromARGB(255, 255, 255, 255);
  late Body body;

  /// Specifies if the body's fixtures should be rendered.
  ///
  /// [renderBody] is true by default for [BodyComponent], if set to false
  /// the body's fixtures wont be rendered.
  ///
  /// If you render something on top of the [BodyComponent], or doesn't want it
  /// to be seen, you probably want to set it to false.
  bool renderBody;

  /// You should create the Forge2D [Body] in this method when you extend
  /// the BodyComponent
  Body createBody();

  @mustCallSuper
  @override
  Future<void> onLoad() async {
    await super.onLoad();
    body = createBody();
  }

  World get world => gameRef.world;
  Camera get camera => gameRef.camera;
  Vector2 get center => body.worldCenter;
  double get angle => body.angle;

  /// The matrix used for preparing the canvas
  final Matrix4 _transform = Matrix4.identity();
  double? _lastAngle;

  @mustCallSuper
  @override
  void renderTree(Canvas canvas) {
    if (_transform.m14 != body.position.x ||
        _transform.m24 != body.position.y ||
        _lastAngle != angle) {
      _transform.setIdentity();
      _transform.translate(body.position.x, body.position.y);
      _transform.rotateZ(angle);
      _lastAngle = angle;
    }
    canvas.save();
    canvas.transform(_transform.storage);
    super.renderTree(canvas);
    canvas.restore();
  }

  @override
  void render(Canvas canvas) {
    if (renderBody) {
      body.fixtures.forEach(
        (fixture) => renderFixture(canvas, fixture),
      );
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
  void renderFixture(
    Canvas canvas,
    Fixture fixture,
  ) {
    canvas.save();
    switch (fixture.type) {
      case ShapeType.chain:
        _renderChain(canvas, fixture);
        break;
      case ShapeType.circle:
        _renderCircle(canvas, fixture);
        break;
      case ShapeType.edge:
        _renderEdge(canvas, fixture);
        break;
      case ShapeType.polygon:
        _renderPolygon(canvas, fixture);
        break;
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
    final path = Path()..addPolygon(points, true);
    canvas.drawPath(path, paint);
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

  void renderPolygon(Canvas canvas, List<Offset> points) {
    final path = Path()..addPolygon(points, true);
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
  bool containsPoint(Vector2 point) {
    return body.fixtures.any((fixture) => fixture.testPoint(point));
  }

  @override
  void onRemove() {
    world.destroyBody(body);
    super.onRemove();
  }
}
