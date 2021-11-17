import 'package:dashbook/dashbook.dart';
import 'package:flame/game.dart';

import '../../commons/commons.dart';
import 'color_effect.dart';
import 'combined_effect.dart';
import 'infinite_effect.dart';
import 'move_effect.dart';
import 'move_effect_example.dart';
import 'opacity_effect.dart';
import 'remove_effect_example.dart';
import 'rotate_effect.dart';
import 'rotate_effect_example.dart';
import 'scale_effect.dart';
import 'sequence_effect.dart';
import 'size_effect.dart';

void addEffectsStories(Dashbook dashbook) {
  dashbook.storiesOf('Effects')
    ..add(
      'Size Effect',
      (_) => GameWidget(game: SizeEffectGame()),
      codeLink: baseLink('effects/size_effect.dart'),
      info: SizeEffectGame.description,
    )
    ..add(
      'Scale Effect',
      (_) => GameWidget(game: ScaleEffectGame()),
      codeLink: baseLink('effects/scale_effect.dart'),
      info: ScaleEffectGame.description,
    )
    ..add(
      'Move Effect',
      (_) => GameWidget(game: MoveEffectGame()),
      codeLink: baseLink('effects/move_effect.dart'),
      info: MoveEffectGame.description,
    )
    ..add(
      'Rotate Effect',
      (_) => GameWidget(game: RotateEffectGame()),
      codeLink: baseLink('effects/rotate_effect.dart'),
      info: RotateEffectGame.description,
    )
    ..add(
      'Sequence Effect',
      (_) => GameWidget(game: SequenceEffectGame()),
      codeLink: baseLink('effects/sequence_effect.dart'),
      info: SequenceEffectGame.description,
    )
    ..add(
      'Combined Effect',
      (_) => GameWidget(game: CombinedEffectGame()),
      codeLink: baseLink('effects/combined_effect.dart'),
      info: CombinedEffectGame.description,
    )
    ..add(
      'Infinite Effect',
      (_) => GameWidget(game: InfiniteEffectGame()),
      codeLink: baseLink('effects/infinite_effect.dart'),
      info: InfiniteEffectGame.description,
    )
    ..add(
      'Opacity Effect',
      (_) => GameWidget(game: OpacityEffectGame()),
      codeLink: baseLink('effects/opacity_effect.dart'),
      info: OpacityEffectGame.description,
    )
    ..add(
      'Color Effect',
      (_) => GameWidget(game: ColorEffectGame()),
      codeLink: baseLink('effects/color_effect.dart'),
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
      'Remove Effect',
      (_) => GameWidget(game: RemoveEffectExample()),
      codeLink: baseLink('effects/remove_effect_example.dart'),
      info: RemoveEffectExample.description,
    );
}
