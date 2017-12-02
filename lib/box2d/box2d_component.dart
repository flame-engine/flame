import 'dart:ui';

import 'package:box2d/box2d.dart' hide Timer;
import 'package:flame/box2d/viewport.dart';
import 'package:flame/components/component.dart';

abstract class Box2DComponent extends Component {
  static const int DEFAULT_WORLD_POOL_SIZE = 100;
  static const int DEFAULT_WORLD_POOL_CONTAINER_SIZE = 10;
  static const double DEFAULT_GRAVITY = -10.0;
  static const int DEFAULT_VELOCITY_ITERATIONS = 10;
  static const int DEFAULT_POSITION_ITERATIONS = 10;
  static const double DEFAULT_SCALE = 8.0;

  Size dimensions;
  int velocityIterations;
  int positionIterations;

  World world;
  List<Component> components = new List();

  Viewport viewport;

  Box2DComponent(this.dimensions,
      {int worldPoolSize: DEFAULT_WORLD_POOL_SIZE,
      int worldPoolContainerSize: DEFAULT_WORLD_POOL_CONTAINER_SIZE,
      double gravity: DEFAULT_GRAVITY,
      this.velocityIterations: DEFAULT_VELOCITY_ITERATIONS,
      this.positionIterations: DEFAULT_POSITION_ITERATIONS,
      double scale: DEFAULT_SCALE}) {
    this.world = new World.withPool(new Vector2(0.0, gravity),
        new DefaultWorldPool(worldPoolSize, worldPoolContainerSize));
    this.viewport = new Viewport(dimensions, scale);
  }

  @override
  void update(t) {
    world.stepDt(t, velocityIterations, positionIterations);
    components.forEach((c) {
      c.update(t);
    });
  }

  @override
  void render(canvas) {
    components.forEach((c) {
      c.render(canvas);
    });
  }

  void add(Component component) {
    components.add(component);
  }

  void initializeWorld();

  void cameraFollow(BodyComponent component,
      {double horizontal, double vertical}) {
    viewport.cameraFollow(component,
        horizontal: horizontal, vertical: vertical);
  }
}

abstract class BodyComponent extends Component {
  static const MAX_POLYGON_VERTICES = 10;

  Box2DComponent box;

  Body body;

  BodyComponent(this.box) {}

  World get world => box.world;

  Viewport get viewport => box.viewport;

  @override
  void update(double t) {
    // usually all update will be handled by the world physics
  }

  @override
  void render(Canvas canvas) {
    body.getFixtureList();
    for (Fixture fixture = body.getFixtureList();
        fixture != null;
        fixture = fixture.getNext()) {
      switch (fixture.getType()) {
        case ShapeType.CHAIN:
          throw new Exception("not implemented");
          break;
        case ShapeType.CIRCLE:
          _renderCircle(canvas, fixture);
          break;
        case ShapeType.EDGE:
          throw new Exception("not implemented");
          break;
        case ShapeType.POLYGON:
          _renderPolygon(canvas, fixture);
          break;
      }
    }
  }

  Vector2 get center => this.body.worldCenter;

  void _renderCircle(Canvas canvas, Fixture fixture) {
    Vector2 center = new Vector2.zero();
    CircleShape circle = fixture.getShape();
    body.getWorldPointToOut(circle.p, center);
    viewport.getWorldToScreen(center, center);
    renderCircle(
        canvas, new Offset(center.x, center.y), circle.radius * viewport.scale);
  }

  void renderCircle(Canvas canvas, Offset center, double radius) {
    final Paint paint = new Paint()
      ..color = new Color.fromARGB(255, 255, 255, 255);
    canvas.drawCircle(center, radius, paint);
  }

  void _renderPolygon(Canvas canvas, Fixture fixture) {
    PolygonShape polygon = fixture.getShape();
    assert(polygon.count <= MAX_POLYGON_VERTICES);
    List<Vector2> vertices = new Vec2Array().get(polygon.count);

    for (int i = 0; i < polygon.count; ++i) {
      body.getWorldPointToOut(polygon.vertices[i], vertices[i]);
      viewport.getWorldToScreen(vertices[i], vertices[i]);
    }

    List<Offset> points = new List();
    for (int i = 0; i < polygon.count; i++) {
      points.add(new Offset(vertices[i].x, vertices[i].y));
    }

    renderPolygon(canvas, points);
  }

  void renderPolygon(Canvas canvas, List<Offset> points) {
    final path = new Path()..addPolygon(points, true);
    final Paint paint = new Paint()
      ..color = new Color.fromARGB(255, 255, 255, 255);
//      ..style = PaintingStyle.stroke;
    canvas.drawPath(path, paint);
  }
}
