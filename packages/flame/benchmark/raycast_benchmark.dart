// ignore_for_file: use_primary_constructors

import 'package:benchmark_harness/benchmark_harness.dart';
import 'package:flame/collisions.dart';

import 'raycast_scene.dart';

const _raysPerRun = raycastRaysPerRun;

/// The number of different rotations of the scene when it rotates.
const _phases = 8;

/// The rotation in radians that the components are turned by in each phase.
const _phaseAngle = 0.05;

/// Benchmarks [CollisionDetection.raycast] in a scene of [count] hitboxes of
/// the given [kind], with the old code path or the one that visits the
/// hitboxes from the nearest to the farthest, depending on [nearestFirst].
/// Each run casts the same [_raysPerRun] rays.
///
/// If [rotate] is true, every run starts by turning all of the components to
/// the next of [_phases] rotations, so the bounding boxes and vertices of the
/// hitboxes are computed again, like in a game where things rotate. The cost
/// of that is in the time of both code paths. The rotations repeat, so that
/// both code paths find the same hits in the same phase of the scene.
class RaycastBenchmark extends AsyncBenchmarkBase {
  RaycastBenchmark({
    required this.kind,
    required this.count,
    required this.nearestFirst,
    this.rotate = false,
  }) : super('Raycast ${kind.name} x$count');

  final HitboxKind kind;
  final int count;
  final bool nearestFirst;
  final bool rotate;

  late final RaycastScenery _scenery;
  late final List<double> _baseAngles;
  final _result = RaycastResult<ShapeHitbox>();
  var _phase = 0;
  final _hitsByPhase = List<int?>.filled(_phases, null);

  @override
  Future<void> setup() async {
    // The same scene and rays for both code paths.
    _scenery = await RaycastScenery.create(kind: kind, count: count);
    _baseAngles = [
      for (final component in _scenery.components) component.angle,
    ];
    _scenery.detection.nearestFirstRaycast = nearestFirst;
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
    _hitsByPhase[_phase] = hits;
  }

  /// The number of rays that hit something in each phase of the scene, to keep
  /// the work from being optimized away and to check that both code paths
  /// agree. It is null for the phases that did not run.
  List<int?> get hitsByPhase => _hitsByPhase;
}

/// Runs the benchmark for the old and the new code path in all the cases, and
/// prints a table with the time per ray and the speedup.
Future<void> main() async {
  const counts = [100, 200, 500];
  // ignore: avoid_print
  print('Raycast: old code path vs nearest first ($_raysPerRun rays per run)');
  // ignore: avoid_print
  print(
    'kind      hitboxes  rotate  old [us/ray]  new [us/ray]  speedup  hits',
  );
  for (final kind in HitboxKind.shapes) {
    for (final count in counts) {
      for (final rotate in [false, true]) {
        final old = RaycastBenchmark(
          kind: kind,
          count: count,
          nearestFirst: false,
          rotate: rotate,
        );
        final oldMicros = await old.measure();
        final nearest = RaycastBenchmark(
          kind: kind,
          count: count,
          nearestFirst: true,
          rotate: rotate,
        );
        final newMicros = await nearest.measure();
        final oldPerRay = oldMicros / _raysPerRun;
        final newPerRay = newMicros / _raysPerRun;
        // Compare the phases that both code paths ran.
        var phasesCompared = 0;
        var same = true;
        for (var phase = 0; phase < _phases; phase++) {
          final a = old.hitsByPhase[phase];
          final b = nearest.hitsByPhase[phase];
          if (a != null && b != null) {
            phasesCompared++;
            same &= a == b;
          }
        }
        // ignore: avoid_print
        print(
          '${kind.name.padRight(10)}${'$count'.padRight(10)}'
          '${(rotate ? 'yes' : 'no').padRight(8)}'
          '${oldPerRay.toStringAsFixed(2).padRight(14)}'
          '${newPerRay.toStringAsFixed(2).padRight(14)}'
          '${'${(oldPerRay / newPerRay).toStringAsFixed(2)}x'.padRight(9)}'
          '${same && phasesCompared > 0 ? 'same' : 'DIFFERENT'} '
          '($phasesCompared phases)',
        );
      }
    }
  }
}
