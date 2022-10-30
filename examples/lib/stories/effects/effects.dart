import 'package:dashbook/dashbook.dart';
import 'package:examples/commons/commons.dart';
import 'package:examples/stories/effects/color_effect_example.dart';
import 'package:examples/stories/effects/dual_effect_removal_example.dart';
import 'package:examples/stories/effects/effect_controllers_example.dart';
import 'package:examples/stories/effects/move_effect_example.dart';
import 'package:examples/stories/effects/opacity_effect_example.dart';
import 'package:examples/stories/effects/remove_effect_example.dart';
import 'package:examples/stories/effects/rotate_effect_example.dart';
import 'package:examples/stories/effects/scale_effect_example.dart';
import 'package:examples/stories/effects/sequence_effect_example.dart';
import 'package:examples/stories/effects/size_effect_example.dart';
import 'package:flame/game.dart';

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
