import 'package:dashbook/dashbook.dart';
import 'package:flame/game.dart';

import '../../commons/commons.dart';
import 'flip.dart';
import 'isometric_tile_map.dart';
import 'layers.dart';
import 'nine_tile_box.dart';
import 'particles.dart';
import 'text.dart';

void addRenderingStories(Dashbook dashbook) {
  dashbook.storiesOf('Rendering')
    ..add(
      'Text',
      (_) => GameWidget(game: TextExample()),
      codeLink: baseLink('rendering/text.dart'),
      info: TextExample.description,
    )
    ..add(
      'Isometric Tile Map',
      (_) => GameWidget(game: IsometricTileMapExample()),
      codeLink: baseLink('tile_maps/isometric_tile_map.dart'),
      info: IsometricTileMapExample.description,
    )
    ..add(
      'Nine Tile Box',
      (_) => GameWidget(game: NineTileBoxExample()),
      codeLink: baseLink('utils/nine_tile_box.dart'),
      info: NineTileBoxExample.description,
    )
    ..add(
      'Flip Sprite',
      (_) => GameWidget(game: FlipSpriteExample()),
      codeLink: baseLink('rendering/flip.dart'),
      info: FlipSpriteExample.description,
    )
    ..add(
      'Layers',
      (_) => GameWidget(game: LayerExample()),
      codeLink: baseLink('rendering/layers.dart'),
      info: LayerExample.description,
    )
    ..add(
      'Particles',
      (_) => GameWidget(game: ParticlesExample()),
      codeLink: baseLink('utils/particles.dart'),
      info: ParticlesExample.description,
    );
}
