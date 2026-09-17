// ignore_for_file: avoid_print

import 'dart:math';
import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/geometry.dart';

import 'path_contour_shapes.dart';

/// Measures what it costs to build hitboxes from sampled [Path] contours
/// compared with a hand-written polygon, and how the sampled vertices behave
/// once they reach the ray intersection and collision code.
///
/// This is a report rather than a harness benchmark, so it is not part of
/// `main.dart`. Run it with `flutter test benchmark/path_contour_benchmark.dart`.
const _shapeSize = Size(100, 100);
const _rayCount = 20000;
const _conversionWarmUps = 2000;

final _handWrittenVertices = [
  Vector2(-0.7, -1),
  Vector2(1, -0.4),
  Vector2(0.3, 1),
  Vector2(-1, 0.6),
];

Future<void> main() async {
  _reportSampling();
  _reportScaleSensitivity();
  _reportRayIntersectionCost();
  _reportInsideAgreement();
  _reportSimplification();
  _reportPolygonIntersectionCost();
}

void _reportSampling() {
  print('');
  print('Path to vertices through walkContours at ${_shapeSize.width}px');
  print(
    'shape       granularity  vertices  '
    'convert (microseconds)  max error (px)  path length',
  );
  for (var index = 0; index < pathContourShapeNames.length; index++) {
    final path = pathContourShape(index, _shapeSize);
    final length = path.computeMetrics().fold(
      0.0,
      (sum, metric) => sum + metric.length,
    );
    for (final granularity in [1.0, 2.0]) {
      // The conversion is short enough to be measured before the compiler has
      // optimized it, unless it is warmed up first.
      for (var warmUp = 0; warmUp < _conversionWarmUps; warmUp++) {
        path.walkContours(granularity);
      }
      final microseconds = _medianMicroseconds(
        () => path.walkContours(granularity),
        repetitions: 101,
      );
      final contours = path.walkContours(granularity);
      final polygon = contours.first;
      final error = _maxError(path.contours.first, polygon);
      final suffix = contours.length > 1
          ? '  (${contours.length} contours)'
          : '';
      print(
        '${pathContourShapeNames[index].padRight(11)} '
        '${granularity.toStringAsFixed(1).padLeft(11)}  '
        '${polygon.length.toString().padLeft(8)}  '
        '${microseconds.toStringAsFixed(0).padLeft(22)}  '
        '${error.toStringAsFixed(2).padLeft(14)}  '
        '${length.toStringAsFixed(0).padLeft(11)}$suffix',
      );
    }
  }
}

void _reportScaleSensitivity() {
  print('');
  print('Scale sensitivity of the sampler at granularity 2.0');
  print('shape       size  vertices  max error (px)');
  for (var index = 0; index < pathContourShapeNames.length; index++) {
    for (final side in [20.0, 100.0, 500.0, 2000.0]) {
      final path = pathContourShape(index, Size(side, side));
      final polygon = path.walkContours(2).first;
      final error = _maxError(path.contours.first, polygon);
      print(
        '${pathContourShapeNames[index].padRight(11)} '
        '${side.toStringAsFixed(0).padLeft(4)}  '
        '${polygon.length.toString().padLeft(8)}  '
        '${error.toStringAsFixed(2).padLeft(14)}',
      );
    }
  }
}

void _reportRayIntersectionCost() {
  print('');
  print('rayIntersection cost per call in nanoseconds over $_rayCount rays');
  print('shape         vertices  nanoseconds  hit percentage');
  final rays = _randomRays(Random(1), 300);
  final hitboxes = <String, PolygonHitbox>{
    'hand-written': _handWrittenHitbox(Vector2.zero()),
    for (var index = 0; index < pathContourShapeNames.length; index++)
      pathContourShapeNames[index]: _contourHitbox(index, Vector2.zero()),
  };
  final result = RaycastResult<ShapeHitbox>();
  for (final entry in hitboxes.entries) {
    final hitbox = entry.value;
    void cast() {
      for (final ray in rays) {
        hitbox.rayIntersection(ray, out: result);
      }
    }

    var hits = 0;
    for (final ray in rays) {
      if (hitbox.rayIntersection(ray, out: result) != null) {
        hits++;
      }
    }
    cast();
    final microseconds = _medianMicroseconds(cast, repetitions: 7);
    print(
      '${entry.key.padRight(13)} '
      '${hitbox.vertices.length.toString().padLeft(8)}  '
      '${(microseconds * 1000 / rays.length).toStringAsFixed(0).padLeft(11)}  '
      '${(100 * hits / rays.length).toStringAsFixed(0).padLeft(14)}',
    );
  }
}

/// Checks the crossing parity that [PolygonRayIntersection.rayIntersection]
/// uses to decide whether the ray origin is inside the polygon against
/// [Path.contains] on the sampled polygon.
void _reportInsideAgreement() {
  print('');
  print('isInsideHitbox agreement with Path.contains over rays that hit');
  print('shape        hits  differs');
  final rays = _randomRays(Random(2), 160);
  for (var index = 0; index < pathContourShapeNames.length; index++) {
    final hitbox = _contourHitbox(index, Vector2.zero());
    final polygon = Path()
      ..addPolygon(
        hitbox.globalVertices().map((vertex) => vertex.toOffset()).toList(),
        true,
      );
    var hits = 0;
    var differs = 0;
    final result = RaycastResult<ShapeHitbox>();
    for (final ray in rays) {
      if (hitbox.rayIntersection(ray, out: result) == null) {
        continue;
      }
      hits++;
      if (result.isInsideHitbox != polygon.contains(ray.origin.toOffset())) {
        differs++;
      }
    }
    print(
      '${pathContourShapeNames[index].padRight(11)} '
      '${hits.toString().padLeft(6)}  '
      '${differs.toString().padLeft(7)}',
    );
  }
}

void _reportSimplification() {
  print('');
  print('Simplification of the granularity 1.0 contour by tolerance');
  print(
    'shape       tolerance  before  after  max error (px)  '
    'ray (nanoseconds)  polygon-polygon (microseconds)',
  );
  final rays = _randomRays(Random(1), 300);
  final result = RaycastResult<ShapeHitbox>();
  final intersections = PolygonPolygonIntersections();
  for (var index = 0; index < pathContourShapeNames.length; index++) {
    final path = pathContourShape(index, _shapeSize);
    final polygon = path.walkContourAt(0, 1, 0);
    for (final tolerance in [0.25, 0.5, 1.0]) {
      final simplified = path.walkContourAt(0, 1, tolerance);
      final vertices = simplified.vertices;
      final first = _hitbox(vertices, Vector2.zero());
      final second = _hitbox(vertices, Vector2(40, 30));
      void cast() {
        for (final ray in rays) {
          first.rayIntersection(ray, out: result);
        }
      }

      cast();
      intersections.intersect(first, second);
      final rayMicroseconds = _medianMicroseconds(cast, repetitions: 7);
      final polygonMicroseconds = _medianMicroseconds(
        () => intersections.intersect(first, second),
        repetitions: 21,
      );
      final rayNanoseconds = rayMicroseconds * 1000 / rays.length;
      final error = _maxError(path.contours.first, simplified);
      print(
        '${pathContourShapeNames[index].padRight(11)} '
        '${tolerance.toStringAsFixed(2).padLeft(9)}  '
        '${polygon.length.toString().padLeft(6)}  '
        '${simplified.length.toString().padLeft(5)}  '
        '${error.toStringAsFixed(2).padLeft(14)}  '
        '${rayNanoseconds.toStringAsFixed(0).padLeft(17)}  '
        '${polygonMicroseconds.toStringAsFixed(0).padLeft(30)}',
      );
    }
  }
}

void _reportPolygonIntersectionCost() {
  print('');
  print('PolygonPolygonIntersections.intersect cost per call in microseconds');
  print('shape         vertices  overlapping  separated');
  final intersections = PolygonPolygonIntersections();
  for (var index = -1; index < pathContourShapeNames.length; index++) {
    PolygonHitbox make(Vector2 position) => index < 0
        ? _handWrittenHitbox(position)
        : _contourHitbox(index, position);
    final first = make(Vector2.zero());
    final overlapping = make(Vector2(40, 30));
    final separated = make(Vector2(400, 0));
    intersections.intersect(first, overlapping);
    intersections.intersect(first, separated);
    final overlappingMicroseconds = _medianMicroseconds(
      () => intersections.intersect(first, overlapping),
      repetitions: 21,
    );
    final separatedMicroseconds = _medianMicroseconds(
      () => intersections.intersect(first, separated),
      repetitions: 21,
    );
    final name = index < 0 ? 'hand-written' : pathContourShapeNames[index];
    print(
      '${name.padRight(13)} '
      '${first.vertices.length.toString().padLeft(8)}  '
      '${overlappingMicroseconds.toStringAsFixed(0).padLeft(11)}  '
      '${separatedMicroseconds.toStringAsFixed(0).padLeft(9)}',
    );
  }
}

PolygonHitbox _handWrittenHitbox(Vector2 position) => PolygonHitbox.relative(
  _handWrittenVertices,
  parentSize: Vector2.all(_shapeSize.width),
  anchor: Anchor.center,
  position: position,
);

PolygonHitbox _contourHitbox(int index, Vector2 position) =>
    PolygonHitbox.contour(
      pathContourShape(index, _shapeSize),
      anchor: Anchor.center,
      position: position,
    );

PolygonHitbox _hitbox(List<Vector2> vertices, Vector2 position) =>
    PolygonHitbox(
      vertices.map((vertex) => vertex.clone()).toList(growable: false),
      anchor: Anchor.center,
      position: position,
    );

List<Ray2> _randomRays(Random random, double spread) => List.generate(
  _rayCount,
  (_) => Ray2(
    origin: (Vector2.random(random) - Vector2.all(0.5)) * spread,
    direction: (Vector2.random(random) - Vector2.all(0.5)).normalized(),
  ),
);

/// The largest distance from any point on [contour] to the closest edge of
/// [polygon], sampled every quarter unit along the contour.
///
/// The [polygon] has to be sampled from that same [contour], since points on
/// any other contour of the path are unrelated to it.
double _maxError(PathMetric contour, List<Offset> polygon) {
  var worst = 0.0;
  for (var distance = 0.0; distance < contour.length; distance += 0.25) {
    final position = contour.getTangentForOffset(distance)!.position;
    worst = max(worst, _distanceToPolygon(position, polygon));
  }
  return worst;
}

double _distanceToPolygon(Offset point, List<Offset> polygon) {
  var best = double.infinity;
  for (var index = 0; index < polygon.length; index++) {
    final distance = _distanceToSegment(
      point,
      polygon[index],
      polygon[(index + 1) % polygon.length],
    );
    if (distance < best) {
      best = distance;
    }
  }
  return best;
}

double _distanceToSegment(Offset point, Offset from, Offset to) {
  final delta = to - from;
  final lengthSquared = delta.dx * delta.dx + delta.dy * delta.dy;
  if (lengthSquared == 0) {
    return (point - from).distance;
  }
  final toPoint = point - from;
  final projection =
      (toPoint.dx * delta.dx + toPoint.dy * delta.dy) / lengthSquared;
  return (point - (from + delta * projection.clamp(0.0, 1.0))).distance;
}

double _medianMicroseconds(void Function() body, {int repetitions = 15}) {
  final samples = <double>[];
  for (var index = 0; index < repetitions; index++) {
    final stopwatch = Stopwatch()..start();
    body();
    stopwatch.stop();
    samples.add(stopwatch.elapsedMicroseconds.toDouble());
  }
  samples.sort();
  return samples[samples.length ~/ 2];
}
