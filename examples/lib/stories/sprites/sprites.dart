import 'package:dashbook/dashbook.dart';
import 'package:flame/game.dart';

import '../../commons/commons.dart';
import 'base64.dart';
import 'basic.dart';
import 'sprite_group.dart';
import 'spritebatch.dart';
import 'spritebatch_auto_load.dart';
import 'spritesheet.dart';

void addSpritesStories(Dashbook dashbook) {
  dashbook.storiesOf('Sprites')
    ..add(
      'Basic Sprite',
      (_) => GameWidget(game: BasicSpriteExample()),
      codeLink: baseLink('sprites/basic.dart'),
      info: BasicSpriteExample.description,
    )
    ..add(
      'Base64 Sprite',
      (_) => GameWidget(game: Base64SpriteExample()),
      codeLink: baseLink('sprites/base64.dart'),
      info: Base64SpriteExample.description,
    )
    ..add(
      'Spritesheet',
      (_) => GameWidget(game: SpritesheetExample()),
      codeLink: baseLink('sprites/spritesheet.dart'),
      info: SpritesheetExample.description,
    )
    ..add(
      'Spritebatch',
      (_) => GameWidget(game: SpritebatchExample()),
      codeLink: baseLink('sprites/spritebatch.dart'),
      info: SpritebatchExample.description,
    )
    ..add(
      'Spritebatch Auto Load',
      (_) => GameWidget(game: SpritebatchAutoLoadExample()),
      codeLink: baseLink('sprites/spritebatch_auto_load.dart'),
      info: SpritebatchAutoLoadExample.description,
    )
    ..add(
      'SpriteGroup',
      (_) => GameWidget(game: SpriteGroupExample()),
      codeLink: baseLink('sprites/sprite_group.dart'),
      info: SpriteGroupExample.description,
    );
}
