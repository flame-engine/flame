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
      (_) => GameWidget(game: BasicSpriteGame()),
      codeLink: baseLink('sprites/basic.dart'),
    )
    ..add(
      'Base64 Sprite',
      (_) => GameWidget(game: Base64SpriteGame()),
      codeLink: baseLink('sprites/base64.dart'),
    )
    ..add(
      'Spritesheet',
      (_) => GameWidget(game: SpritesheetGame()),
      codeLink: baseLink('sprites/spritesheet.dart'),
    )
    ..add(
      'Spritebatch',
      (_) => GameWidget(game: SpritebatchGame()),
      codeLink: baseLink('sprites/spritebatch.dart'),
    )
    ..add(
      'Spritebatch Auto Load',
      (_) => GameWidget(game: SpritebatchAutoLoadGame()),
      codeLink: baseLink('sprites/spritebatch_auto_load.dart'),
    )
    ..add(
      'SpriteGroup',
      (_) => GameWidget(game: SpriteGroupExample()),
      codeLink: baseLink('sprites/sprite_group.dart'),
    );
}
