import 'package:dashbook/dashbook.dart';
import 'package:examples/commons/commons.dart';
import 'package:examples/stories/sprites/base64_sprite_example.dart';
import 'package:examples/stories/sprites/basic_sprite_example.dart';
import 'package:examples/stories/sprites/sprite_group_example.dart';
import 'package:examples/stories/sprites/spritebatch_example.dart';
import 'package:examples/stories/sprites/spritebatch_load_example.dart';
import 'package:examples/stories/sprites/spritesheet_example.dart';
import 'package:flame/game.dart';

void addSpritesStories(Dashbook dashbook) {
  dashbook.storiesOf('Sprites')
    ..add(
      'Basic Sprite',
      (_) => GameWidget(game: BasicSpriteExample()),
      codeLink: baseLink('sprites/basic_sprite_example.dart'),
      info: BasicSpriteExample.description,
    )
    ..add(
      'Base64 Sprite',
      (_) => GameWidget(game: Base64SpriteExample()),
      codeLink: baseLink('sprites/base64_sprite_example.dart'),
      info: Base64SpriteExample.description,
    )
    ..add(
      'Spritesheet',
      (_) => GameWidget(game: SpritesheetExample()),
      codeLink: baseLink('sprites/spritesheet_example.dart'),
      info: SpritesheetExample.description,
    )
    ..add(
      'Spritebatch',
      (_) => GameWidget(game: SpritebatchExample()),
      codeLink: baseLink('sprites/spritebatch_example.dart'),
      info: SpritebatchExample.description,
    )
    ..add(
      'Spritebatch Auto Load',
      (_) => GameWidget(game: SpritebatchLoadExample()),
      codeLink: baseLink('sprites/spritebatch_load_example.dart'),
      info: SpritebatchLoadExample.description,
    )
    ..add(
      'SpriteGroup',
      (_) => GameWidget(game: SpriteGroupExample()),
      codeLink: baseLink('sprites/sprite_group_example.dart'),
      info: SpriteGroupExample.description,
    );
}
