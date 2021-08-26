import 'package:dashbook/dashbook.dart';
import 'package:flame/game.dart';

import '../../commons/commons.dart';
import 'color_effect.dart';
import 'combined_effect.dart';
import 'infinite_effect.dart';
import 'move_effect.dart';
import 'opacity_effect.dart';
import 'rotate_effect.dart';
import 'scale_effect.dart';
import 'sequence_effect.dart';
import 'size_effect.dart';

const scaleInfo = '''
The `ScaleEffect` scales up the canvas before drawing the components and its
children.
In this example you can tap the screen and the component will scale up or down,
depending on its current state.
''';

void addEffectsStories(Dashbook dashbook) {
  dashbook.storiesOf('Effects')
    ..add(
      'Size Effect',
      (_) => GameWidget(game: SizeEffectGame()),
      codeLink: baseLink('effects/size_effect.dart'),
      info: sizeInfo,
    )
    ..add(
      'Scale Effect',
      (_) => GameWidget(game: ScaleEffectGame()),
      codeLink: baseLink('effects/scale_effect.dart'),
      info: scaleInfo,
    )
    ..add(
      'Move Effect',
      (_) => GameWidget(game: MoveEffectGame()),
      codeLink: baseLink('effects/move_effect.dart'),
    )
    ..add(
      'Rotate Effect',
      (_) => GameWidget(game: RotateEffectGame()),
      codeLink: baseLink('effects/rotate_effect.dart'),
    )
    ..add(
      'Sequence Effect',
      (_) => GameWidget(game: SequenceEffectGame()),
      codeLink: baseLink('effects/sequence_effect.dart'),
    )
    ..add(
      'Combined Effect',
      (_) => GameWidget(game: CombinedEffectGame()),
      codeLink: baseLink('effects/combined_effect.dart'),
    )
    ..add(
      'Infinite Effect',
      (_) => GameWidget(game: InfiniteEffectGame()),
      codeLink: baseLink('effects/infinite_effect.dart'),
    )
    ..add(
      'Opacity Effect',
      (_) => GameWidget(game: OpacityEffectGame()),
      codeLink: baseLink('effects/opacity_effect.dart'),
    )
    ..add(
      'Color Effect',
      (_) => GameWidget(game: ColorEffectGame()),
      codeLink: baseLink('effects/color_effect.dart'),
    );
}
