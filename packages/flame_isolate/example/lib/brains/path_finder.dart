import 'dart:io';

import 'package:collection/collection.dart';
import 'package:flutter_isolates_example/objects/colonists_object.dart';
import 'package:flutter_isolates_example/standard/int_vector2.dart';
import 'package:flutter_isolates_example/standard/pair.dart';
import 'package:flutter_isolates_example/terrain/terrain.dart';

/// Synchronous implementation of finding a path between start and destination.
Iterable<IntVector2>? findPath({
  required IntVector2 start,
  required IntVector2 destination,
  required PathFinderData pathFinderData,
}) {
  // I know, I know, this is a thread sleep... But it's emulating an expensive
  // path finding calculation
  sleep(const Duration(milliseconds: 20));
  return _findPathAStar(
    start: start,
    destination: destination,
    pathFinderData: pathFinderData,
  );
}

class PathFinderData {
  final Map<IntVector2, double> terrain;
  final Set<IntVector2> unWalkableTiles;

  const PathFinderData._({
    required this.terrain,
    required this.unWalkableTiles,
  });

  factory PathFinderData.fromWorld({
    required Map<IntVector2, Terrain> terrain,
    required List<ColonistsObject> worldObjects,
  }) {
    return PathFinderData._(
      terrain: terrain.map((key, value) => MapEntry(key, value.difficulty)),
      unWalkableTiles: worldObjects.map((e) => e.tilePosition).toSet(),
    );
  }

  bool _complies(IntVector2 position, IntVector2 destination) {
    return position == destination ||
        terrain.containsKey(position) && !unWalkableTiles.contains(position);
  }

  /// Returns an iterable of the possible neighbors to move to
  /// Unreachable terrain will not be sent here
  Iterable<IntVector2> neighbors(
    IntVector2 current,
    IntVector2 destination,
  ) sync* {
    // + shape
    final upOne = current.add(y: -1);
    if (_complies(upOne, destination)) {
      yield upOne;
    }
    final leftOne = current.add(x: -1);
    if (_complies(leftOne, destination)) {
      yield leftOne;
    }
    final downOne = current.add(y: 1);
    if (_complies(downOne, destination)) {
      yield downOne;
    }
    final rightOne = current.add(x: 1);
    if (_complies(rightOne, destination)) {
      yield rightOne;
    }

    // Diagonal
    final upLeft = current.add(x: -1, y: -1);
    if (_complies(upLeft, destination)) {
      yield upLeft;
    }
    final downLeft = current.add(x: -1, y: 1);
    if (_complies(downLeft, destination)) {
      yield downLeft;
    }
    final upRight = current.add(x: 1, y: -1);
    if (_complies(upRight, destination)) {
      yield upRight;
    }
    final downRight = current.add(x: 1, y: 1);
    if (_complies(downRight, destination)) {
      yield downRight;
    }
  }

  double cost(IntVector2 current, IntVector2 next) {
    return terrain[next]! * current.distanceTo(next);
  }
}

/// A* pathfinding algorithm, inspired by
/// https://www.redblobgames.com/pathfinding/a-star/introduction.html
/// https://www.redblobgames.com/pathfinding/a-star/implementation.html
Iterable<IntVector2>? _findPathAStar({
  required IntVector2 start,
  required IntVector2 destination,
  required PathFinderData pathFinderData,
}) {
  final frontier = PriorityQueue<Pair<IntVector2, double>>(
    (first, second) => first.second.compareTo(second.second),
  );
  frontier.add(Pair(start, 0));

  final cameFrom = <IntVector2, IntVector2>{
    start: start,
  };
  final costSoFar = <IntVector2, double>{
    start: 0,
  };

  while (frontier.isNotEmpty) {
    final current = frontier.removeFirst().first;

    if (current == destination) {
      break;
    }

    for (final next in pathFinderData.neighbors(current, destination)) {
      final newCost = costSoFar[current]! + pathFinderData.cost(current, next);
      if (!costSoFar.containsKey(next) || newCost < costSoFar[next]!) {
        costSoFar[next] = newCost;
        final distanceTo = destination.distanceTo(next);
        final priority = newCost + distanceTo;
        frontier.add(Pair(next, priority));
        cameFrom[next] = current;
      }
    }
  }

  var current = destination;
  final path = <IntVector2>[];
  while (current != start) {
    path.add(current);
    final innerCurrent = cameFrom[current];
    if (innerCurrent == null) {
      return null;
    }
    current = innerCurrent;
  }
  path.add(start);

  return path.reversed;
}
