import 'package:examples/commons/commons.dart';
import 'package:examples/commons/example_use_case.dart';
import 'package:examples/stories/sprites/base64_sprite_example.dart';
import 'package:examples/stories/sprites/basic_sprite_example.dart';
import 'package:examples/stories/sprites/sprite_batch_bleed_example.dart';
import 'package:examples/stories/sprites/sprite_batch_example.dart';
import 'package:examples/stories/sprites/sprite_batch_load_example.dart';
import 'package:examples/stories/sprites/sprite_group_example.dart';
import 'package:examples/stories/sprites/sprite_sheet_example.dart';
import 'package:flame/game.dart';
import 'package:widgetbook/widgetbook.dart';

WidgetbookComponent spritesStories() {
  return WidgetbookComponent(
    name: 'Sprites',
    useCases: [
      ExampleUseCase(
        name: 'Basic Sprite',
        builder: (_) => GameWidget(game: BasicSpriteExample()),
        codeLink: baseLink('sprites/basic_sprite_example.dart'),
        info: BasicSpriteExample.description,
      ),
      ExampleUseCase(
        name: 'Base64 Sprite',
        builder: (_) => GameWidget(game: Base64SpriteExample()),
        codeLink: baseLink('sprites/base64_sprite_example.dart'),
        info: Base64SpriteExample.description,
      ),
      ExampleUseCase(
        name: 'SpriteSheet',
        builder: (_) => GameWidget(game: SpriteSheetExample()),
        codeLink: baseLink('sprites/sprite_sheet_example.dart'),
        info: SpriteSheetExample.description,
      ),
      ExampleUseCase(
        name: 'SpriteBatch',
        builder: (_) => GameWidget(game: SpriteBatchExample()),
        codeLink: baseLink('sprites/sprite_batch_example.dart'),
        info: SpriteBatchExample.description,
      ),
      ExampleUseCase(
        name: 'SpriteBatch Auto Load',
        builder: (_) => GameWidget(game: SpriteBatchLoadExample()),
        codeLink: baseLink('sprites/sprite_batch_load_example.dart'),
        info: SpriteBatchLoadExample.description,
      ),
      ExampleUseCase(
        name: 'SpriteBatch Bleed',
        builder: (_) => GameWidget(game: SpriteBatchBleedExample()),
        codeLink: baseLink('sprites/sprite_batch_bleed_example.dart'),
        info: SpriteBatchBleedExample.description,
      ),
      ExampleUseCase(
        name: 'SpriteGroup',
        builder: (_) => GameWidget(game: SpriteGroupExample()),
        codeLink: baseLink('sprites/sprite_group_example.dart'),
        info: SpriteGroupExample.description,
      ),
    ],
  );
}
