import 'dart:ui';

import 'package:box2d_flame/box2d.dart' hide Timer;
import 'viewport.dart';
import '../components/component.dart';
import 'package:ordered_set/comparing.dart';
import 'package:ordered_set/ordered_set.dart';

abstract class Box2DComponent extends Component {
  static const int DEFAULT_WORLD_POOL_SIZE = 100;
  static const int DEFAULT_WORLD_POOL_CONTAINER_SIZE = 10;
  static const double DEFAULT_GRAVITY = -10.0;
  static const int DEFAULT_VELOCITY_ITERATIONS = 10;
  static const int DEFAULT_POSITION_ITERATIONS = 10;
  static const double DEFAULT_SCALE = 1.0;

  Size dimensions;
  int velocityIterations;
  int positionIterations;

  /// The list of components to be updated and rendered by the Box2DComponent.
  OrderedSet<BodyComponent> components =
      OrderedSet(Comparing.on((c) => c.priority()));
  Viewport viewport;
  World world;

  Box2DComponent({
    this.dimensions,
    int worldPoolSize = DEFAULT_WORLD_POOL_SIZE,
    int worldPoolContainerSize = DEFAULT_WORLD_POOL_CONTAINER_SIZE,
    double gravity = DEFAULT_GRAVITY,
    this.velocityIterations = DEFAULT_VELOCITY_ITERATIONS,
    this.positionIterations = DEFAULT_POSITION_ITERATIONS,
    double scale = DEFAULT_SCALE,
  }) {
    dimensions ??= window.physicalSize;
    final pool = DefaultWorldPool(worldPoolSize, worldPoolContainerSize);
    world = World.withPool(Vector2(0.0, gravity), pool);
    viewport = Viewport(dimensions, scale);
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
    if (viewport.size == Size.zero) {
      return;
    }
    components.forEach((c) {
      if (c.body.isActive()) {
        c.render(canvas);
      }
    });
  }

  @override
  void resize(Size size) {
    viewport.resize(size);
    components.forEach((c) {
      c.resize(size);
    });
  }

  void add(BodyComponent component) {
    components.add(component);
  }

  void addAll(List<BodyComponent> component) {
    components.addAll(component);
  }

  void remove(BodyComponent component) {
    components.remove(component);
    world.destroyBody(component.body);
  }

  void initializeWorld();

  void cameraFollow(
    BodyComponent component, {
    double horizontal,
    double vertical,
  }) {
    viewport.cameraFollow(
      component,
      horizontal: horizontal,
      vertical: vertical,
    );
  }
}

abstract class BodyComponent extends Component {
  static const MAX_POLYGON_VERTICES = 10;

  Box2DComponent box;

  Body body;

  BodyComponent(this.box);

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
          _renderChain(canvas, fixture);
          break;
        case ShapeType.CIRCLE:
          _renderCircle(canvas, fixture);
          break;
        case ShapeType.EDGE:
          throw Exception('not implemented');
          break;
        case ShapeType.POLYGON:
          _renderPolygon(canvas, fixture);
          break;
      }
    }
  }

  Vector2 get center => body.worldCenter;

  void _renderChain(Canvas canvas, Fixture fixture) {
    final ChainShape chainShape = fixture.getShape();
    final List<Vector2> vertices = Vec2Array().get(chainShape.getVertexCount());

    for (int i = 0; i < chainShape.getVertexCount(); ++i) {
      body.getWorldPointToOut(chainShape.getVertex(i), vertices[i]);
      vertices[i] = viewport.getWorldToScreen(vertices[i]);
    }

    final List<Offset> points = [];
    for (int i = 0; i < chainShape.getVertexCount(); i++) {
      points.add(Offset(vertices[i].x, vertices[i].y));
    }

    renderChain(canvas, points);
  }

  void renderChain(Canvas canvas, List<Offset> points) {
    final Paint paint = Paint()
      ..color = const Color.fromARGB(255, 255, 255, 255);
    final path = Path()..addPolygon(points, true);
    canvas.drawPath(path, paint);
  }

  void _renderCircle(Canvas canvas, Fixture fixture) {
    var center = Vector2.zero();
    final CircleShape circle = fixture.getShape();
    body.getWorldPointToOut(circle.p, center);
    center = viewport.getWorldToScreen(center);
    renderCircle(
        canvas, Offset(center.x, center.y), circle.radius * viewport.scale);
  }

  void renderCircle(Canvas canvas, Offset center, double radius) {
    final Paint paint = Paint()
      ..color = const Color.fromARGB(255, 255, 255, 255);
    canvas.drawCircle(center, radius, paint);
  }

  void _renderPolygon(Canvas canvas, Fixture fixture) {
    final PolygonShape polygon = fixture.getShape();
    assert(polygon.count <= MAX_POLYGON_VERTICES);
    final List<Vector2> vertices = Vec2Array().get(polygon.count);

    for (int i = 0; i < polygon.count; ++i) {
      body.getWorldPointToOut(polygon.vertices[i], vertices[i]);
      vertices[i] = viewport.getWorldToScreen(vertices[i]);
    }

    final List<Offset> points = [];
    for (int i = 0; i < polygon.count; i++) {
      points.add(Offset(vertices[i].x, vertices[i].y));
    }

    renderPolygon(canvas, points);
  }

  void renderPolygon(Canvas canvas, List<Offset> points) {
    final path = Path()..addPolygon(points, true);
    final Paint paint = Paint()
      ..color = const Color.fromARGB(255, 255, 255, 255);
    canvas.drawPath(path, paint);
  }
}
