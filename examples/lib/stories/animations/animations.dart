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
      (_) => GameWidget(game: BasicAnimations()),
      codeLink: baseLink('animations/basic.dart'),
    )
    ..add(
      'Group animation',
      (_) => GameWidget(game: AnimationGroupExample()),
      codeLink: baseLink('animations/aseprite.dart'),
    )
    ..add(
      'Aseprite',
      (_) => GameWidget(game: Aseprite()),
      codeLink: baseLink('animations/aseprite.dart'),
    );
}
