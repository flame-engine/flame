import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:benchmark_harness/benchmark_harness.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flame/geometry.dart';

const _amountHitboxes = 200;
const _amountTicks = 100;
const _dt = 1.0 / 60;
const _worldWidth = 800.0;
const _worldHeight = 600.0;
final _half = Vector2(0.5, 0.5);

abstract class RayIntersectionBenchmark extends AsyncBenchmarkBase {
  RayIntersectionBenchmark(super.name, {required this.random});

  final Random random;
  late final RayIntersectionGame game;

  @override
  Future<void> run() async {
    for (var i = 0; i < _amountTicks; i++) {
      game.update(_dt);
    }
  }
}

class ConcaveRayIntersectionBenchmark extends RayIntersectionBenchmark {
  final RayInputs inputs;

  ConcaveRayIntersectionBenchmark(this.inputs, {required super.random})
    : super('Concave polygon ray intersection');

  static Future<void> main() async {
    final r = Random(69420);
    final inputsConcave = _createRayInputs(r, _flamePath());
    await ConcaveRayIntersectionBenchmark(inputsConcave, random: r).report();
  }

  @override
  Future<void> setup() async {
    game = RayIntersectionGame(
      _createBatch(_pathVertices(_flamePath()), inputs),
    );
    await game.prepare();
  }
}

class ConvexRayIntersectionBenchmark extends RayIntersectionBenchmark {
  final RayInputs inputs;

  ConvexRayIntersectionBenchmark(this.inputs, {required super.random})
    : super('Convex polygon ray intersection');

  static Future<void> main() async {
    final r = Random(69420);
    final inputsConvex = _createRayInputs(
      r,
      _roundRectPath(const Size(64, 48)),
    );
    await ConvexRayIntersectionBenchmark(inputsConvex, random: r).report();
  }

  @override
  Future<void> setup() async {
    game = RayIntersectionGame(
      _createBatch(
        _pathVertices(_roundRectPath(const Size(64, 48))),
        inputs,
      ),
    );
    await game.prepare();
  }
}

class RayIntersectionGame extends FlameGame {
  late final RayIntersectionComponent rayIntersectionComponent;
  late final RayBatch batch;

  RayIntersectionGame(this.batch);

  FutureOr<void> prepare() async {
    onGameResize(Vector2(_worldWidth, _worldHeight));
    await load();
    await ready();
  }

  @override
  FutureOr<void> onLoad() async {
    await super.onLoad();
    addComponents();
  }

  void addComponents() {
    addAll(batch.hitboxes);
    rayIntersectionComponent = RayIntersectionComponent(batch);
    add(rayIntersectionComponent);
  }
}

class RayIntersectionComponent extends Component {
  RayIntersectionComponent(this.batch);

  final RayBatch batch;

  @override
  void update(double dt) {
    super.update(dt);
    for (var index = 0; index < batch.hitboxes.length; index++) {
      batch.hitboxes[index].rayIntersection(batch.rays[index]);
    }
  }
}

class RayInputs {
  RayInputs(this.positions, this.rays);

  final List<Vector2> positions;
  final List<Ray2> rays;
}

class RayBatch {
  RayBatch(this.hitboxes, this.rays);

  final List<PolygonHitbox> hitboxes;
  final List<Ray2> rays;
}

RayBatch _createBatch(List<Vector2> vertices, RayInputs inputs) {
  final hitboxes = [
    for (var index = 0; index < _amountHitboxes; index++)
      PolygonHitbox(
        vertices.map((vertex) => vertex.clone()).toList(growable: false),
        position: inputs.positions[index].clone(),
        collisionType: .inactive,
      ),
  ];
  return RayBatch(hitboxes, inputs.rays);
}

Map<Path, List<Vector2>> _vertices = {};
List<Vector2> _pathVertices(Path path) {
  final existing = _vertices[path];
  if (existing != null) {
    return existing;
  }
  final vertices = path.centered.walkContourAt(0, 2).vertices;
  _vertices[path] = vertices;
  return vertices;
}

RayInputs _createRayInputs(Random random, Path path) {
  final positions = [
    for (var index = 0; index < _amountHitboxes; index++)
      Vector2(
        random.nextDouble() * _worldWidth,
        random.nextDouble() * _worldHeight,
      ),
  ];
  final rays = randomRays(random, _amountHitboxes);
  return RayInputs(positions, rays);
}

Vector2 _randomWorldPoint(Random rnd) {
  final v = Vector2.random(rnd);
  v.setValues(v.x * _worldWidth, v.y * _worldHeight);
  return v;
}

List<Ray2> randomRays(Random rnd, int count) => List<Ray2>.generate(
  count,
  (index) => Ray2(
    origin: _randomWorldPoint(rnd),
    direction: (Vector2.random(rnd) - _half).normalized(),
  ),
);

Path? _roundRect;
Path _roundRectPath(Size size) {
  return _roundRect ??= Path()
    ..addRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        Radius.circular(size.shortestSide * 0.25),
      ),
    );
}

Path? _flame;
Path _flamePath() {
  return _flame ??= Path()
    ..moveTo(62.0, 42.8)
    ..cubicTo(62.0, 58.9, 49.0, 65.0, 33.0, 65.0)
    ..cubicTo(17.0, 65.0, 4.0, 58.9, 4.0, 42.8)
    ..cubicTo(4.0, 38.6, 4.9, 35.9, 6.5, 32.2)
    ..cubicTo(7.6, 29.8, 10.1, 40.7, 11.9, 38.8)
    ..cubicTo(16.2, 34.1, 7.2, 23.3, 23.8, 15.2)
    ..cubicTo(20.8, 23.5, 23.2, 26.8, 26.4, 26.8)
    ..cubicTo(33.4, 26.8, 33.5, 16.3, 32.7, 3.0)
    ..cubicTo(54.1, 19.6, 42.3, 26.0, 44.7, 28.1)
    ..cubicTo(56.6, 29.4, 48.7, 3.1, 59.3, 28.3)
    ..cubicTo(61.3, 32.8, 62.0, 37.5, 62.0, 42.8)
    ..close();
}

Future<void> main() async {
  final rConcave = Random(69420);
  final inputsConcave = _createRayInputs(rConcave, _flamePath());
  await ConcaveRayIntersectionBenchmark(
    inputsConcave,
    random: rConcave,
  ).report();
  final rConvex = Random(69420);
  final inputsConvex = _createRayInputs(
    rConvex,
    _roundRectPath(const Size(64, 48)),
  );
  await ConvexRayIntersectionBenchmark(inputsConvex, random: rConvex).report();
}
