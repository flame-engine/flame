import 'package:dashbook/dashbook.dart';
import 'package:flame/game.dart';

import '../../commons/commons.dart';
import 'flip_sprite_example.dart';
import 'isometric_tile_map_example.dart';
import 'layers_example.dart';
import 'nine_tile_box_example.dart';
import 'particles_example.dart';
import 'text_example.dart';

void addRenderingStories(Dashbook dashbook) {
  dashbook.storiesOf('Rendering')
    ..add(
      'Text',
      (_) => GameWidget(game: TextExample()),
      codeLink: baseLink('rendering/text_example.dart'),
      info: TextExample.description,
    )
    ..add(
      'Isometric Tile Map',
      (_) => GameWidget(game: IsometricTileMapExample()),
      codeLink: baseLink('rendering/isometric_tile_map_example.dart'),
      info: IsometricTileMapExample.description,
    )
    ..add(
      'Nine Tile Box',
      (_) => GameWidget(game: NineTileBoxExample()),
      codeLink: baseLink('rendering/nine_tile_box_example.dart'),
      info: NineTileBoxExample.description,
    )
    ..add(
      'Flip Sprite',
      (_) => GameWidget(game: FlipSpriteExample()),
      codeLink: baseLink('rendering/flip_sprite_example.dart'),
      info: FlipSpriteExample.description,
    )
    ..add(
      'Layers',
      (_) => GameWidget(game: LayerExample()),
      codeLink: baseLink('rendering/layers_example.dart'),
      info: LayerExample.description,
    )
    ..add(
      'Particles',
      (_) => GameWidget(game: ParticlesExample()),
      codeLink: baseLink('rendering/particles_example.dart'),
      info: ParticlesExample.description,
    );
}
