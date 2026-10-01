import 'package:examples/commons/commons.dart';
import 'package:examples/commons/example_use_case.dart';
import 'package:examples/stories/rendering/flip_sprite_example.dart';
import 'package:examples/stories/rendering/isometric_tile_map_example.dart';
import 'package:examples/stories/rendering/layers_example.dart';
import 'package:examples/stories/rendering/nine_tile_box_example.dart';
import 'package:examples/stories/rendering/particles_example.dart';
import 'package:examples/stories/rendering/particles_interactive_example.dart';
import 'package:examples/stories/rendering/rich_text_example.dart';
import 'package:examples/stories/rendering/text_box_example.dart';
import 'package:examples/stories/rendering/text_example.dart';
import 'package:flame/game.dart';
import 'package:material_ui/material_ui.dart';
import 'package:widgetbook/widgetbook.dart';

WidgetbookComponent renderingStories() {
  return WidgetbookComponent(
    name: 'Rendering',
    useCases: [
      ExampleUseCase(
        name: 'Text',
        builder: (_) => GameWidget(game: TextExample()),
        codeLink: baseLink('rendering/text_example.dart'),
        info: TextExample.description,
      ),
      ExampleUseCase(
        name: 'Isometric Tile Map',
        builder: (context) => GameWidget(
          game: IsometricTileMapExample(
            halfSize: context.knobs.boolean(
              label: 'Half size',
              initialValue: true,
            ),
          ),
        ),
        codeLink: baseLink('rendering/isometric_tile_map_example.dart'),
        info: IsometricTileMapExample.description,
      ),
      ExampleUseCase(
        name: 'Nine Tile Box',
        builder: (_) => GameWidget(game: NineTileBoxExample()),
        codeLink: baseLink('rendering/nine_tile_box_example.dart'),
        info: NineTileBoxExample.description,
      ),
      ExampleUseCase(
        name: 'Flip Sprite',
        builder: (_) => GameWidget(game: FlipSpriteExample()),
        codeLink: baseLink('rendering/flip_sprite_example.dart'),
        info: FlipSpriteExample.description,
      ),
      ExampleUseCase(
        name: 'Layers',
        builder: (_) => GameWidget(game: LayerExample()),
        codeLink: baseLink('rendering/layers_example.dart'),
        info: LayerExample.description,
      ),
      ExampleUseCase(
        name: 'Particles',
        builder: (_) => GameWidget(game: ParticlesExample()),
        codeLink: baseLink('rendering/particles_example.dart'),
        info: ParticlesExample.description,
      ),
      ExampleUseCase(
        name: 'Particles (Interactive)',
        builder: (context) => GameWidget(
          game: ParticlesInteractiveExample(
            effect: context.knobs.object.dropdown(
              label: 'Effect',
              initialOption: ParticleEffect.sparkles,
              options: ParticleEffect.values,
              labelBuilder: (value) => value.name,
            ),
            zoom: context.knobs.double.input(
              label: 'Zoom',
              initialValue: 1,
            ),
          ),
        ),
        codeLink: baseLink('rendering/particles_interactive_example.dart'),
        info: ParticlesInteractiveExample.description,
      ),
      ExampleUseCase(
        name: 'Rich Text',
        builder: (context) => GameWidget(
          game: RichTextExample(
            textAlign: context.knobs.object.dropdown(
              label: 'Text align',
              initialOption: TextAlign.left,
              options: TextAlign.values,
              labelBuilder: (value) => value.name,
            ),
            width: context.knobs.double.input(
              label: 'Width',
              initialValue: 400,
            ),
          ),
        ),
        codeLink: baseLink('rendering/rich_text_example.dart'),
        info: RichTextExample.description,
      ),
      ExampleUseCase(
        name: 'TextBoxComponent',
        builder: (context) {
          return GameWidget(
            game: TextBoxExample(),
          );
        },
        codeLink: baseLink('rendering/text_box_example.dart'),
        info: TextBoxExample.description,
      ),
    ],
  );
}
