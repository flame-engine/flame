import 'package:dashbook/dashbook.dart';
import 'package:flame/game.dart';

import '../../commons/commons.dart';
import 'animation_group.dart';
import 'aseprite.dart';
import 'basic.dart';

void addAnimationStories(Dashbook dashbook) {
  dashbook.storiesOf('Animations')
    ..add(
      'Basic Animations',
      (_) => GameWidget(game: BasicAnimationsExample()),
      codeLink: baseLink('animations/basic.dart'),
      info: BasicAnimationsExample.description,
    )
    ..add(
      'Group animation',
      (_) => GameWidget(game: AnimationGroupExample()),
      codeLink: baseLink('animations/aseprite.dart'),
      info: AnimationGroupExample.description,
    )
    ..add(
      'Aseprite',
      (_) => GameWidget(game: AsepriteExample()),
      codeLink: baseLink('animations/aseprite.dart'),
      info: AsepriteExample.description,
    );
}
