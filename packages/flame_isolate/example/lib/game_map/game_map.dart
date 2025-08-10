import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame_isolate_example/brains/path_finder.dart';
import 'package:flame_isolate_example/colonists_game.dart';
import 'package:flame_isolate_example/constants.dart';
import 'package:flame_isolate_example/extensions/range_extensions.dart';
import 'package:flame_isolate_example/objects/bread.dart';
import 'package:flame_isolate_example/objects/cheese.dart';
import 'package:flame_isolate_example/objects/colonists_object.dart';
import 'package:flame_isolate_example/standard/int_vector2.dart';
import 'package:flame_isolate_example/terrain/grass.dart';
import 'package:flame_isolate_example/terrain/terrain.dart';
import 'package:flame_isolate_example/units/worker.dart';

class GameMap extends Component with HasGameReference<ColonistsGame> {
  static const mapSizeX = 50;
  static const mapSizeY = 50;
  static const totalPositions = mapSizeX * mapSizeY;

  static final int cheeseSpread = (0.03 * totalPositions).toInt();
  static final int breadSpread = (0.05 * totalPositions).toInt();
  static final int workerSpread = (0.1 * totalPositions).toInt();

  static const double workerMinSpeed = 25;
  static const double workerMaxSpeed = 75;

  @override
  Future<void> onLoad() async {
    for (var x = 0; x < mapSizeX; x++) {
      for (var y = 0; y < mapSizeY; y++) {
        addTerrain(IntVector2(x, y), Grass());
      }
    }

    final mapPositions = List.generate(totalPositions, (index) => index)
      ..shuffle();

    worldObjects = [
      for (final _ in 0.to(cheeseSpread))
        Cheese(
          mapPositions[0] ~/ mapSizeX,
          mapPositions.removeAt(0) % mapSizeY,
        ),
      for (final _ in 0.to(breadSpread))
        Bread(
          mapPositions[0] ~/ mapSizeX,
          mapPositions.removeAt(0) % mapSizeY,
        ),
      for (final _ in 0.to(workerSpread))
        Worker(
          mapPositions[0] ~/ mapSizeX,
          mapPositions.removeAt(0) % mapSizeY,
          speed:
              Random().nextDouble() * (workerMaxSpeed - workerMinSpeed) +
              workerMinSpeed,
        ),
    ];

    worldObjects.forEach(addObject);

    if (workers.isNotEmpty) {
      game.camera.follow(workers.first);
    }
  }

  final Set<Worker> workers = {};
  final Map<IntVector2, Terrain> _terrain = {};
  late final List<ColonistsObject> worldObjects;

  void addTerrain(IntVector2 position, Terrain terrain) {
    _terrain[position] = terrain;
    add(
      terrain
        ..x = position.x * Constants.tileSize
        ..y = position.y * Constants.tileSize
        ..width = Constants.tileSize
        ..height = Constants.tileSize,
    );
  }

  void addObject(ColonistsObject object) {
    if (object is Worker) {
      workers.add(object);
    }

    if (object is StaticColonistsObject) {
      (_terrain[object.tilePosition]! as Grass).difficulty = object.difficulty;
    }

    add(object);
  }

  PathFinderData get pathFinderData => PathFinderData.fromWorld(
    terrain: _terrain,
    worldObjects: game.worldObjects,
  );

  Terrain tileAtPosition(int x, int y) {
    return _terrain[IntVector2(x, y)]!;
  }
}
