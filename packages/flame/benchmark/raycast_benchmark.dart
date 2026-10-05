import 'package:benchmark_harness/benchmark_harness.dart';
import 'package:flame/collisions.dart';

import 'raycast_scene.dart';

const _raysPerRun = raycastRaysPerRun;

/// The number of different rotations of the scene when it rotates.
const _phases = 8;

/// The rotation in radians that the components are turned by in each phase.
const _phaseAngle = 0.05;

/// Benchmarks [CollisionDetection.raycast] in a scene of [count] hitboxes of
/// the given [kind]. Each run casts the same [_raysPerRun] rays.
///
/// If [rotate] is true, every run starts by turning all of the components to
/// the next of [_phases] rotations, so the bounding boxes and vertices of the
/// hitboxes are computed again, like in a game where things rotate. The cost
/// of that is in the time.
class RaycastBenchmark({
  required final HitboxKind kind,
  required final int count,
  final bool rotate = false,
}) extends AsyncBenchmarkBase {
  this : super('Raycast ${kind.name} x$count');

  late final RaycastScenery _scenery;
  late final List<double> _baseAngles;
  final _result = RaycastResult<ShapeHitbox>();
  var _phase = 0;
  var _hits = 0;

  @override
  Future<void> setup() async {
    _scenery = await RaycastScenery.create(kind: kind, count: count);
    _baseAngles = [
      for (final component in _scenery.components) component.angle,
    ];
  }

  @override
  Future<void> run() async {
    final detection = _scenery.detection;
    if (rotate) {
      _phase = (_phase + 1) % _phases;
      for (var i = 0; i < _scenery.components.length; i++) {
        _scenery.components[i].angle = _baseAngles[i] + _phase * _phaseAngle;
      }
    }
    var hits = 0;
    for (final ray in _scenery.rays) {
      if (detection.raycast(ray, out: _result) != null) {
        hits++;
      }
    }
    _hits = hits;
  }

  /// The number of rays that hit something in the last run, to keep the work
  /// from being optimized away.
  int get hits => _hits;
}

/// Runs the benchmark in all the cases, and prints a table with the time per
/// ray.
Future<void> main() async {
  const counts = [100, 200, 500];
  // ignore: avoid_print
  print('Raycast ($_raysPerRun rays per run)');
  // ignore: avoid_print
  print('kind      hitboxes  rotate  microseconds/ray  hits');
  for (final kind in HitboxKind.shapes) {
    for (final count in counts) {
      for (final rotate in [false, true]) {
        final benchmark = RaycastBenchmark(
          kind: kind,
          count: count,
          rotate: rotate,
        );
        final micros = await benchmark.measure();
        final perRay = micros / _raysPerRun;
        // ignore: avoid_print
        print(
          '${kind.name.padRight(10)}${'$count'.padRight(10)}'
          '${(rotate ? 'yes' : 'no').padRight(8)}'
          '${perRay.toStringAsFixed(2).padRight(18)}'
          '${benchmark.hits}',
        );
      }
    }
  }
}
