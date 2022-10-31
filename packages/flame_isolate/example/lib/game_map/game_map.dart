import 'dart:math';

import 'package:flame/components.dart';
import 'package:flutter_isolates_example/brains/path_finder.dart';
import 'package:flutter_isolates_example/colonists_game.dart';
import 'package:flutter_isolates_example/constants.dart';
import 'package:flutter_isolates_example/extensions/range_extensions.dart';
import 'package:flutter_isolates_example/objects/bread.dart';
import 'package:flutter_isolates_example/objects/cheese.dart';
import 'package:flutter_isolates_example/objects/colonists_object.dart';
import 'package:flutter_isolates_example/standard/int_vector2.dart';
import 'package:flutter_isolates_example/terrain/grass.dart';
import 'package:flutter_isolates_example/terrain/terrain.dart';
import 'package:flutter_isolates_example/units/worker.dart';

class GameMap extends Component with HasGameRef<ColonistsGame> {
  static const mapSizeX = 50;
  static const mapSizeY = 50;
  static const totalPositions = mapSizeX * mapSizeY;

  static int cheeseSpread = (0.03 * totalPositions).toInt();
  static int breadSpread = (0.05 * totalPositions).toInt();
  static int workerSpread = (0.1 * totalPositions).toInt();

  static const double workerMinSpeed = 25;
  static const double workerMaxSpeed = 75;

  @override
  Future onLoad() async {
    for (var x = 0; x < mapSizeX; x++) {
      for (var y = 0; y < mapSizeY; y++) {
        addTerrain(IntVector2(x, y), Grass());
      }
    }

    final mapPositions = List.generate(totalPositions, (index) => index)
      ..shuffle();

    final worldObjects = {
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
          (mapPositions[0] ~/ mapSizeX).toDouble(),
          (mapPositions.removeAt(0) % mapSizeY).toDouble(),
          speed: Random().nextDouble() * (workerMaxSpeed - workerMinSpeed) +
              workerMinSpeed,
        ),
    };

    worldObjects.forEach(addObject);

    super.onLoad();
  }

  Set<Worker> workers = {};

  final Map<IntVector2, Terrain> _terrain = {};
  final List<ColonistsObject> _worldObjects = [];

  List<ColonistsObject> get worldObjects => _worldObjects;

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

    _worldObjects.add(object);
    add(object);
  }

  PathFinderData get pathFinderData => PathFinderData.fromWorld(
        terrain: _terrain,
        worldObjects: _worldObjects,
      );

  Terrain tileAtPosition(int x, int y) {
    return _terrain[IntVector2(x, y)]!;
  }
}
