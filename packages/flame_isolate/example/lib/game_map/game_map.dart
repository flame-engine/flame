import 'dart:math';

import 'package:flame/components.dart';
import 'package:flutter_colonists/brains/path_finder.dart';
import 'package:flutter_colonists/colonists_game.dart';
import 'package:flutter_colonists/constants.dart';
import 'package:flutter_colonists/extensions/range_extensions.dart';
import 'package:flutter_colonists/objects/bread.dart';
import 'package:flutter_colonists/objects/cheese.dart';
import 'package:flutter_colonists/objects/colonists_object.dart';
import 'package:flutter_colonists/standard/int_vector2.dart';
import 'package:flutter_colonists/terrain/grass.dart';
import 'package:flutter_colonists/terrain/terrain.dart';
import 'package:flutter_colonists/units/worker.dart';

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
    for (int x = 0; x < mapSizeX; x++) {
      for (int y = 0; y < mapSizeY; y++) {
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

    for (final object in worldObjects) {
      addObject(object);
    }

    super.onLoad();
  }

  Set<Worker> workers = {};

  //TODO: A class should probably take care of difficulty as well as height to properly calculate difficulty between two tiles.
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
