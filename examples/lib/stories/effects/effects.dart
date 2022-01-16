import 'package:dashbook/dashbook.dart';
import 'package:flame/game.dart';

import '../../commons/commons.dart';
import 'color_effect_example.dart';
import 'dual_effect_removal_example.dart';
import 'effect_controllers_example.dart';
import 'move_effect_example.dart';
import 'opacity_effect_example.dart';
import 'remove_effect_example.dart';
import 'rotate_effect_example.dart';
import 'scale_effect_example.dart';
import 'sequence_effect_example.dart';
import 'size_effect_example.dart';

void addEffectsStories(Dashbook dashbook) {
  dashbook.storiesOf('Effects')
    ..add(
      'Move Effect',
      (_) => GameWidget(game: MoveEffectExample()),
      codeLink: baseLink('effects/move_effect_example.dart'),
      info: MoveEffectExample.description,
    )
    ..add(
      'Dual Effect Removal',
      (_) => GameWidget(game: DualEffectRemovalExample()),
      codeLink: baseLink('effects/dual_effect_removal_example.dart'),
      info: DualEffectRemovalExample.description,
    )
    ..add(
      'Rotate Effect',
      (_) => GameWidget(game: RotateEffectExample()),
      codeLink: baseLink('effects/rotate_effect_example.dart'),
      info: RotateEffectExample.description,
    )
    ..add(
      'Size Effect',
      (_) => GameWidget(game: SizeEffectExample()),
      codeLink: baseLink('effects/size_effect_example.dart'),
      info: SizeEffectExample.description,
    )
    ..add(
      'Scale Effect',
      (_) => GameWidget(game: ScaleEffectExample()),
      codeLink: baseLink('effects/scale_effect_example.dart'),
      info: ScaleEffectExample.description,
    )
    ..add(
      'Opacity Effect',
      (_) => GameWidget(game: OpacityEffectExample()),
      codeLink: baseLink('effects/opacity_effect_example.dart'),
      info: OpacityEffectExample.description,
    )
    ..add(
      'Color Effect',
      (_) => GameWidget(game: ColorEffectExample()),
      codeLink: baseLink('effects/color_effect_example.dart'),
      info: ColorEffectExample.description,
    )
    ..add(
      'Sequence Effect',
      (_) => GameWidget(game: SequenceEffectExample()),
      codeLink: baseLink('effects/sequence_effect_example.dart'),
      info: SequenceEffectExample.description,
    )
    ..add(
      'Remove Effect',
      (_) => GameWidget(game: RemoveEffectExample()),
      codeLink: baseLink('effects/remove_effect_example.dart'),
      info: RemoveEffectExample.description,
    )
    ..add(
      'EffectControllers',
      (_) => GameWidget(game: EffectControllersExample()),
      codeLink: baseLink('effects/effect_controllers_example.dart'),
      info: EffectControllersExample.description,
    );
}
