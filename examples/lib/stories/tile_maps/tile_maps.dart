import 'package:dashbook/dashbook.dart';
import 'package:flame/game.dart';

import '../../commons/commons.dart';
import 'isometric_tile_map.dart';

void addTileMapStories(Dashbook dashbook) {
  dashbook.storiesOf('Tile Maps')
    ..add(
      'Isometric Tile Map',
      (_) => GameWidget(game: IsometricTileMapGame()),
      codeLink: baseLink('tile_maps/isometric_tile_map.dart'),
    );
}
