import 'package:dashbook/dashbook.dart';
import 'package:flame/game.dart';

import '../../commons/commons.dart';
import 'color_effect_example.dart';
import 'combined_effect_example.dart';
import 'infinite_effect_example.dart';
import 'move_effect_example.dart';
import 'old_move_effect_example.dart';
import 'old_rotate_effect_example.dart';
import 'old_scale_effect_example.dart';
import 'old_size_effect_example.dart';
import 'opacity_effect_example.dart';
import 'remove_effect_example.dart';
import 'rotate_effect_example.dart';
import 'scale_effect_example.dart';
import 'sequence_effect_example.dart';
import 'size_effect_example.dart';

void addEffectsStories(Dashbook dashbook) {
  dashbook.storiesOf('Effects')
    ..add(
      'Size Effect',
      (_) => GameWidget(game: OldSizeEffectExample()),
      codeLink: baseLink('effects/size_effect_example.dart'),
      info: OldSizeEffectExample.description,
    )
    ..add(
      'Scale Effect',
      (_) => GameWidget(game: OldScaleEffectExample()),
      codeLink: baseLink('effects/old_scale_effect_example.dart'),
      info: OldScaleEffectExample.description,
    )
    ..add(
      'Move Effect',
      (_) => GameWidget(game: OldMoveEffectExample()),
      codeLink: baseLink('effects/old_move_effect_example.dart'),
      info: OldMoveEffectExample.description,
    )
    ..add(
      'Rotate Effect',
      (_) => GameWidget(game: OldRotateEffectExample()),
      codeLink: baseLink('effects/old_rotate_effect_example.dart'),
      info: OldRotateEffectExample.description,
    )
    ..add(
      'Sequence Effect',
      (_) => GameWidget(game: SequenceEffectExample()),
      codeLink: baseLink('effects/sequence_effect_example.dart'),
      info: SequenceEffectExample.description,
    )
    ..add(
      'Combined Effect',
      (_) => GameWidget(game: CombinedEffectExample()),
      codeLink: baseLink('effects/combined_effect_example.dart'),
      info: CombinedEffectExample.description,
    )
    ..add(
      'Infinite Effect',
      (_) => GameWidget(game: InfiniteEffectExample()),
      codeLink: baseLink('effects/infinite_effect_example.dart'),
      info: InfiniteEffectExample.description,
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
    )
    ..add(
      'Move Effect (v2)',
      (_) => GameWidget(game: MoveEffectExample()),
      codeLink: baseLink('effects/move_effect_example.dart'),
      info: MoveEffectExample.description,
    )
    ..add(
      'Rotate Effect (v2)',
      (_) => GameWidget(game: RotateEffectExample()),
      codeLink: baseLink('effects/rotate_effect_example.dart'),
      info: RotateEffectExample.description,
    )
    ..add(
      'Size Effect (v2)',
      (_) => GameWidget(game: SizeEffectExample()),
      codeLink: baseLink('effects/size_effect_example.dart'),
      info: SizeEffectExample.description,
    ..add(
      'Scale Effect (v2)',
      (_) => GameWidget(game: ScaleEffectExample()),
      codeLink: baseLink('effects/scale_effect_example.dart'),
      info: ScaleEffectExample.description,
    )
    ..add(
      'Remove Effect',
      (_) => GameWidget(game: RemoveEffectExample()),
      codeLink: baseLink('effects/remove_effect_example.dart'),
      info: RemoveEffectExample.description,
    );
}
