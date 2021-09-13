import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:forge2d/forge2d.dart' hide Timer, Vector2;

import 'forge2d_game.dart';
import 'position_body_component.dart';
import 'sprite_body_component.dart';

/// Since a pure BodyComponent doesn't have anything drawn on top of it,
/// it is a good idea to turn on [debugMode] for it so that the bodies can be
/// seen
abstract class BodyComponent<T extends Forge2DGame> extends Component
    with HasGameRef<T> {
  static const defaultColor = Color.fromARGB(255, 255, 255, 255);
  late Body body;
  late Paint paint;

  /// [debugMode] is true by default for body component since otherwise
  /// nothing is rendered for it, if you render something on top of the
  /// [BodyComponent], or doesn't want it to be seen, just set it to false.
  /// [SpriteBodyComponent] and [PositionBodyComponent] has it set to false by
  /// default.
  @override
  bool debugMode = true;

  BodyComponent({Paint? paint}) {
    this.paint = paint ?? (Paint()..color = defaultColor);
  }

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
  final Matrix4 _flipYTransform = Matrix4.identity()..scale(1.0, -1.0);
  double? _lastAngle;

  @override
  void preRender(Canvas canvas) {
    if (_transform.m14 != body.position.x ||
        _transform.m24 != body.position.y ||
        _lastAngle != angle) {
      _transform.setIdentity();
      _transform.translate(body.position.x, -body.position.y);
      _transform.rotateZ(-angle);
      _lastAngle = angle;
    }

    canvas.transform(_transform.storage);
  }

  @override
  void renderDebugMode(Canvas canvas) {
    canvas.transform(_flipYTransform.storage);

    for (final fixture in body.fixtures) {
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
    }
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
    super.onRemove();
    world.destroyBody(body);
  }
}
