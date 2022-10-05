import 'package:dashbook/dashbook.dart';
import 'package:examples/commons/commons.dart';
import 'package:examples/stories/animations/animation_group_example.dart';
import 'package:examples/stories/animations/aseprite_example.dart';
import 'package:examples/stories/animations/basic_animation_example.dart';
import 'package:flame/game.dart';

void addAnimationStories(Dashbook dashbook) {
  dashbook.storiesOf('Animations')
    ..add(
      'Basic Animations',
      (_) => GameWidget(game: BasicAnimationsExample()),
      codeLink: baseLink('animations/basic_animation_example.dart'),
      info: BasicAnimationsExample.description,
    )
    ..add(
      'Group animation',
      (_) => GameWidget(game: AnimationGroupExample()),
      codeLink: baseLink('animations/aseprite_example.dart'),
      info: AnimationGroupExample.description,
    )
    ..add(
      'Aseprite',
      (_) => GameWidget(game: AsepriteExample()),
      codeLink: baseLink('animations/aseprite_example.dart'),
      info: AsepriteExample.description,
    );
}
