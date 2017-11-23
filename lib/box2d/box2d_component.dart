import 'dart:ui';

import 'package:box2d/box2d.dart' hide Timer;
import 'package:flame/component.dart';

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
  List<BodyComponent> components = new List();

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

  void add(BodyComponent component) {
    components.add(component);
  }

  /**
   * Follow the body component using sliding a focus window defined as a
   * percentage of the total viewport.
   *
   * @param component to follow.
   * @param horizontal percentage of the horizontal viewport. Null means no horizontal following.
   * @param vertical percentage of the vertical viewport. Null means no vertical following.
   */
  void cameraFollow(BodyComponent component,
      {double horizontal, double vertical}) {
    Vector2 position = component.center;

    double x = viewport.center.x;
    double y = viewport.center.y;

    if (horizontal != null) {
      Vector2 temp = new Vector2.zero();
      viewport.getWorldToScreen(position, temp);

      var margin = horizontal / 2 * dimensions.width / 2;
      var focus = dimensions.width / 2 - temp.x;

      if (focus.abs() > margin) {
        x = dimensions.width / 2 +
            (position.x * viewport.scale) +
            (focus > 0 ? margin : -margin);
      }
    }

    if (vertical != null) {
      Vector2 temp = new Vector2.zero();
      viewport.getWorldToScreen(position, temp);

      var margin = vertical / 2 * dimensions.height / 2;
      var focus = dimensions.height / 2 - temp.y;

      if (focus.abs() > margin) {
        y = dimensions.height / 2 +
            (position.y * viewport.scale) +
            (focus < 0 ? margin : -margin);
      }
    }

    if (x != viewport.center.x || y != viewport.center.y) {
      viewport.setCamera(x, y, viewport.scale);
    }
  }

  void initializeWorld();
}

class Viewport extends ViewportTransform {
  Size dimensions;

  double scale;

  Viewport(this.dimensions, this.scale)
      : super(new Vector2(dimensions.width / 2, dimensions.height / 2),
      new Vector2(dimensions.width / 2, dimensions.height / 2), scale);

  double worldAlignBottom(double height) =>
      -(dimensions.height / 2 / scale) + height;

  /**
   * Computes the number of horizontal world meters of this viewport considering a
   * percentage of its width.
   *
   * @param percent percetage of the width in [0, 1] range
   */
  double worldWidth(double percent) {
    return percent * (dimensions.width / scale);
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

    drawPolygon(canvas, points);
  }

  void drawPolygon(Canvas canvas, List<Offset> points) {
    final path = new Path()
      ..addPolygon(points, true);
    final Paint paint = new Paint()
      ..color = new Color.fromARGB(255, 255, 255, 255);
//      ..style = PaintingStyle.stroke;
    canvas.drawPath(path, paint);
  }
}
