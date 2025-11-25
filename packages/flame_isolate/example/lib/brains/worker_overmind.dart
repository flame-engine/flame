import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame_isolate/flame_isolate.dart';
import 'package:flame_isolate_example/brains/path_finder.dart';
import 'package:flame_isolate_example/brains/worker_overmind_hud.dart';
import 'package:flame_isolate_example/colonists_game.dart';
import 'package:flame_isolate_example/objects/bread.dart';
import 'package:flame_isolate_example/objects/colonists_object.dart';
import 'package:flame_isolate_example/standard/int_vector2.dart';
import 'package:flame_isolate_example/standard/pair.dart';
import 'package:flame_isolate_example/units/worker.dart';
import 'package:flutter/foundation.dart';

class WorkerOvermind extends Component
    with HasGameReference<ColonistsGame>, FlameIsolate {
  final List<Pair<StaticColonistsObject, Vector2>> _queuedTasks = [];
  late Timer _assignTaskInterval;
  late WorkerOvermindHud isolateHud;

  @override
  Future<void> onLoad() async {
    game.camera.viewport.add(isolateHud = WorkerOvermindHud());
    super.onLoad();
  }

  @override
  Future<void> onMount() {
    calculateTasks();
    _assignTaskInterval = Timer(0.2, repeat: true, onTick: _assignTasks)
      ..start();
    return super.onMount();
  }

  // Note: This would, in reality, also be moved to isolate
  void calculateTasks() {
    game.worldObjects.whereType<Bread>().forEach((bread) {
      moveObject(bread, Vector2(8, 2));
    });
  }

  void moveObject(StaticColonistsObject objectToMove, Vector2 destination) =>
      _queuedTasks.add(Pair(objectToMove, destination));

  @override
  void update(double dt) {
    _assignTaskInterval.update(dt);
    super.update(dt);
  }

  /// Set that keeps track of what workers are currently in queue to get a job.
  ///
  /// As long as a worker is in this queue it should be prevented to be
  /// calculated for a job.
  final _workersBeingCalculated = <Worker>{};

  /// Function that pairs a job and a worker.
  ///
  /// Using an isolate for the actual calculation.
  Future<void> _assignTasks() async {
    if (_queuedTasks.isEmpty) {
      return;
    }

    final idleWorkers = game.workers
        .where(
          (worker) =>
              worker.isIdle && !_workersBeingCalculated.contains(worker),
        )
        .take(10)
        .toList(growable: false);

    _workersBeingCalculated.addAll(idleWorkers);

    final shortestQueue = min(idleWorkers.length, _queuedTasks.length);

    // I know this is not proper handling of lists, but this is just for demo
    final localQueue =
        _queuedTasks
            .map((task) => task.first.tilePosition)
            .toList(growable: false)
          ..shuffle();
    final subQueue = localQueue
        .getRange(0, shortestQueue)
        .toList(growable: false);

    // Commented out since I want to keep jobs in queue for demo
    // _queuedTasks.removeRange(0, shortestQueue);

    try {
      if (idleWorkers.isNotEmpty && _queuedTasks.isNotEmpty) {
        final calculateWorkData = _CalculateWorkData(
          idleWorkerPositions: idleWorkers
              .map((worker) => worker.tilePosition)
              .toList(growable: false),
          destinations: subQueue,
          pathFinderData: game.pathFinderData,
        );

        final paths = switch (isolateHud.computeType) {
          ComputeType.isolate => await isolateCompute(
            _calculateWork,
            calculateWorkData,
          ),
          ComputeType.synchronous => _calculateWork(
            calculateWorkData,
          ),
          ComputeType.compute => await compute(
            _calculateWork,
            calculateWorkData,
          ),
        };

        for (var i = 0; i < paths.length; i++) {
          idleWorkers[i].issueWork(
            _queuedTasks[i].first,
            paths[i],
          );
        }
      }
    } on DropException catch (_) {
      debugPrint('Dropped');
    } finally {
      idleWorkers.forEach(_workersBeingCalculated.remove);
    }
  }

  static List<List<IntVector2>> _calculateWork(_CalculateWorkData data) {
    final workers = data.idleWorkerPositions.iterator;
    final destinations = data.destinations.iterator;

    final workerPaths = <List<IntVector2>>[];

    while (workers.moveNext() && destinations.moveNext()) {
      final path = findPath(
        start: workers.current,
        destination: destinations.current,
        pathFinderData: data.pathFinderData,
      );
      if (path != null) {
        workerPaths.add(path.toList());
      }
    }

    return workerPaths;
  }

  @override
  BackpressureStrategy get backpressureStrategy =>
      ReplaceBackpressureStrategy();
}

@immutable
class _CalculateWorkData {
  final List<IntVector2> idleWorkerPositions;
  final List<IntVector2> destinations;
  final PathFinderData pathFinderData;

  const _CalculateWorkData({
    required this.idleWorkerPositions,
    required this.destinations,
    required this.pathFinderData,
  });
}
