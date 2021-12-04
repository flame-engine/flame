import 'package:dashbook/dashbook.dart';
import 'package:flame/game.dart';

import '../../commons/commons.dart';
import 'move_effect_example.dart';
import 'opacity_effect_example.dart';
import 'remove_effect_example.dart';
import 'rotate_effect_example.dart';
import 'scale_effect_example.dart';
import 'size_effect_example.dart';

void addEffectsStories(Dashbook dashbook) {
  dashbook.storiesOf('Effects')
    ..add(
      'Move Effect',
      (_) => GameWidget(game: MoveEffectExample()),
      codeLink: baseLink('effects2/move_effect_example.dart'),
      info: MoveEffectExample.description,
    )
    ..add(
      'Rotate Effect',
      (_) => GameWidget(game: RotateEffectExample()),
      codeLink: baseLink('effects2/rotate_effect_example.dart'),
      info: RotateEffectExample.description,
    )
    ..add(
      'Size Effect',
      (_) => GameWidget(game: SizeEffectExample()),
      codeLink: baseLink('effects2/size_effect_example.dart'),
      info: SizeEffectExample.description,
    )
    ..add(
      'Scale Effect',
      (_) => GameWidget(game: ScaleEffectExample()),
      codeLink: baseLink('effects2/scale_effect_example.dart'),
      info: ScaleEffectExample.description,
    )
    ..add(
      'Opacity Effect',
      (_) => GameWidget(game: OpacityEffectExample()),
      codeLink: baseLink('effects2/opacity_effect_example.dart'),
      info: OpacityEffectExample.description,
    )
    ..add(
      'Remove Effect',
      (_) => GameWidget(game: RemoveEffectExample()),
      codeLink: baseLink('effects2/remove_effect_example.dart'),
      info: RemoveEffectExample.description,
    );
}
