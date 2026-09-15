// ignore_for_file: avoid_print

import 'dart:math';

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
    'shape       granularity  vertices  tangent calls  '
    'convert (microseconds)  max error (px)  path length',
  );
  for (var index = 0; index < pathContourShapeNames.length; index++) {
    final path = pathContourShape(index, _shapeSize);
    final length = path.computeMetrics().fold(
      0.0,
      (sum, metric) => sum + metric.length,
    );
    for (final granularity in [1.0, 2.0]) {
      path.walkContours(granularity);
      final microseconds = _medianMicroseconds(
        () => path.walkContours(granularity),
      );
      final contours = path.walkContours(granularity);
      final polygon = contours.first;
      final tangentCalls = (length / granularity).ceil() + 1;
      final suffix = contours.length > 1
          ? '  (${contours.length} contours)'
          : '';
      print(
        '${pathContourShapeNames[index].padRight(11)} '
        '${granularity.toStringAsFixed(1).padLeft(11)}  '
        '${polygon.length.toString().padLeft(8)}  '
        '${tangentCalls.toString().padLeft(13)}  '
        '${microseconds.toStringAsFixed(0).padLeft(22)}  '
        '${_maxError(path, polygon).toStringAsFixed(2).padLeft(14)}  '
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
      print(
        '${pathContourShapeNames[index].padRight(11)} '
        '${side.toStringAsFixed(0).padLeft(4)}  '
        '${polygon.length.toString().padLeft(8)}  '
        '${_maxError(path, polygon).toStringAsFixed(2).padLeft(14)}',
      );
    }
  }
}

void _reportRayIntersectionCost() {
  print('');
  print('rayIntersection cost per call in nanoseconds over $_rayCount rays');
  print('shape         vertices  crossings  containment  hit percentage');
  final rays = _randomRays(Random(1), 300);
  final hitboxes = <String, PolygonHitbox>{
    'hand-written': _handWrittenHitbox(Vector2.zero()),
    for (var index = 0; index < pathContourShapeNames.length; index++)
      pathContourShapeNames[index]: _contourHitbox(index, Vector2.zero()),
  };
  final result = RaycastResult<ShapeHitbox>();
  for (final entry in hitboxes.entries) {
    final hitbox = entry.value;
    void castCrossings() {
      for (final ray in rays) {
        hitbox.rayIntersection(ray, out: result);
      }
    }

    void castContainment() {
      for (final ray in rays) {
        hitbox.rayIntersection(ray, out: result, useContainment: true);
      }
    }

    var hits = 0;
    for (final ray in rays) {
      if (hitbox.rayIntersection(ray, out: result) != null) {
        hits++;
      }
    }
    castCrossings();
    castContainment();
    final crossings = _medianMicroseconds(castCrossings, repetitions: 7);
    final containment = _medianMicroseconds(castContainment, repetitions: 7);
    print(
      '${entry.key.padRight(13)} '
      '${hitbox.vertices.length.toString().padLeft(8)}  '
      '${(crossings * 1000 / rays.length).toStringAsFixed(0).padLeft(9)}  '
      '${(containment * 1000 / rays.length).toStringAsFixed(0).padLeft(11)}  '
      '${(100 * hits / rays.length).toStringAsFixed(0).padLeft(14)}',
    );
  }
}

/// Compares three ways of deciding whether the ray origin is inside the
/// polygon: the crossings heuristic used before this branch, the containment
/// test added by this branch, and plain odd crossing parity.
void _reportInsideAgreement() {
  print('');
  print('isInsideHitbox agreement over rays that hit the shape');
  print('shape        hits  heuristic differs  odd parity differs');
  final rays = _randomRays(Random(2), 160);
  for (var index = 0; index < pathContourShapeNames.length; index++) {
    final hitbox = _contourHitbox(index, Vector2.zero());
    var hits = 0;
    var heuristicDiffers = 0;
    var parityDiffers = 0;
    final crossingsResult = RaycastResult<ShapeHitbox>();
    final containmentResult = RaycastResult<ShapeHitbox>();
    for (final ray in rays) {
      if (hitbox.rayIntersection(ray, out: crossingsResult) == null) {
        continue;
      }
      hits++;
      hitbox.rayIntersection(ray, out: containmentResult, useContainment: true);
      final inside = containmentResult.isInsideHitbox;
      if (crossingsResult.isInsideHitbox != inside) {
        heuristicDiffers++;
      }
      if (_countCrossings(hitbox, ray).isOdd != inside) {
        parityDiffers++;
      }
    }
    print(
      '${pathContourShapeNames[index].padRight(11)} '
      '${hits.toString().padLeft(6)}  '
      '${heuristicDiffers.toString().padLeft(17)}  '
      '${parityDiffers.toString().padLeft(18)}',
    );
  }
}

void _reportSimplification() {
  print('');
  print('Ramer-Douglas-Peucker simplification of the granularity 1.0 contour');
  print(
    'shape       tolerance  before  after  max error (px)  '
    'ray (nanoseconds)  polygon-polygon (microseconds)',
  );
  final rays = _randomRays(Random(1), 300);
  final result = RaycastResult<ShapeHitbox>();
  final intersections = PolygonPolygonIntersections();
  for (var index = 0; index < pathContourShapeNames.length; index++) {
    final path = pathContourShape(index, _shapeSize);
    final polygon = path.walkContours().first;
    for (final tolerance in [0.25, 0.5, 1.0]) {
      final simplified = _simplifyClosed(polygon, tolerance);
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
      print(
        '${pathContourShapeNames[index].padRight(11)} '
        '${tolerance.toStringAsFixed(2).padLeft(9)}  '
        '${polygon.length.toString().padLeft(6)}  '
        '${simplified.length.toString().padLeft(5)}  '
        '${_maxError(path, simplified).toStringAsFixed(2).padLeft(14)}  '
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

/// The same crossing count that [PolygonRayIntersection.rayIntersection]
/// computes internally.
int _countCrossings(PolygonHitbox hitbox, Ray2 ray) {
  final vertices = hitbox.globalVertices();
  final epsilon = max(1.0, max(ray.origin.x.abs(), ray.origin.y.abs())) * 1e-4;
  var crossings = 0;
  for (var index = 0; index < vertices.length; index++) {
    final edge = hitbox.getEdge(index, vertices: vertices);
    final distance = ray.lineSegmentIntersection(edge);
    if (distance != null && distance > epsilon) {
      crossings++;
    }
  }
  return crossings;
}

/// The largest distance from any point on [path] to the closest edge of
/// [polygon], sampled every quarter unit along the path.
double _maxError(Path path, List<Offset> polygon) {
  var worst = 0.0;
  for (final metric in path.computeMetrics()) {
    for (var distance = 0.0; distance < metric.length; distance += 0.25) {
      final position = metric.getTangentForOffset(distance)!.position;
      worst = max(worst, _distanceToPolygon(position, polygon));
    }
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

List<Offset> _ramerDouglasPeucker(List<Offset> points, double tolerance) {
  if (points.length < 3) {
    return List.of(points);
  }
  var worst = 0.0;
  var worstIndex = 0;
  for (var index = 1; index < points.length - 1; index++) {
    final distance = _distanceToSegment(
      points[index],
      points.first,
      points.last,
    );
    if (distance > worst) {
      worst = distance;
      worstIndex = index;
    }
  }
  if (worst <= tolerance) {
    return [points.first, points.last];
  }
  final left = _ramerDouglasPeucker(
    points.sublist(0, worstIndex + 1),
    tolerance,
  );
  final right = _ramerDouglasPeucker(points.sublist(worstIndex), tolerance);
  return [...left.sublist(0, left.length - 1), ...right];
}

/// Splits the closed [polygon] at the vertex farthest from the first one and
/// simplifies both halves, so that the closing edge is treated like any other.
List<Offset> _simplifyClosed(List<Offset> polygon, double tolerance) {
  var farthestIndex = 0;
  var farthestDistance = 0.0;
  for (var index = 1; index < polygon.length; index++) {
    final distance = (polygon[index] - polygon.first).distance;
    if (distance > farthestDistance) {
      farthestDistance = distance;
      farthestIndex = index;
    }
  }
  final first = _ramerDouglasPeucker(
    polygon.sublist(0, farthestIndex + 1),
    tolerance,
  );
  final second = _ramerDouglasPeucker(
    [...polygon.sublist(farthestIndex), polygon.first],
    tolerance,
  );
  return [
    ...first.sublist(0, first.length - 1),
    ...second.sublist(0, second.length - 1),
  ];
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
