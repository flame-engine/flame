import 'package:dashbook/dashbook.dart';
import 'package:examples/commons/commons.dart';
import 'package:examples/stories/rendering/flip_sprite_example.dart';
import 'package:examples/stories/rendering/isometric_tile_map_example.dart';
import 'package:examples/stories/rendering/layers_example.dart';
import 'package:examples/stories/rendering/nine_tile_box_example.dart';
import 'package:examples/stories/rendering/particles_example.dart';
import 'package:examples/stories/rendering/particles_interactive_example.dart';
import 'package:examples/stories/rendering/rich_text_example.dart';
import 'package:examples/stories/rendering/text_example.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

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
      (context) => GameWidget(
        game: IsometricTileMapExample(
          halfSize: context.boolProperty('Half size', true),
        ),
      ),
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
    )
    ..add(
      'Particles (Interactive)',
      (context) => GameWidget(
        game: ParticlesInteractiveExample(
          from: context.colorProperty('From color', Colors.pink),
          to: context.colorProperty('To color', Colors.blue),
          zoom: context.numberProperty('Zoom', 1),
        ),
      ),
      codeLink: baseLink('rendering/particles_interactive_example.dart'),
      info: ParticlesInteractiveExample.description,
    )
    ..add(
      'Rich Text',
      (context) => GameWidget(
        game: RichTextExample(
          textAlign: context.listProperty(
            'Text align',
            TextAlign.left,
            TextAlign.values,
          ),
        ),
      ),
      codeLink: baseLink('rendering/rich_text_example.dart'),
      info: RichTextExample.description,
    );
}
