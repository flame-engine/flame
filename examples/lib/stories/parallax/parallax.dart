import 'package:dashbook/dashbook.dart';
import 'package:flame/game.dart';

import '../../commons/commons.dart';
import 'advanced.dart';
import 'basic.dart';
import 'component.dart';
import 'no_fcs.dart';
import 'small_parallax.dart';

void addParallaxStories(Dashbook dashbook) {
  dashbook.storiesOf('Parallax')
    ..add(
      'Basic',
      (_) => GameWidget(game: BasicParallaxGame()),
      codeLink: baseLink('parallax/basic.dart'),
      info: 'Shows the simplest way to use a fullscreen ParallaxComponent',
    )
    ..add(
      'Component',
      (_) => GameWidget(game: ComponentParallaxGame()),
      codeLink: baseLink('parallax/component.dart'),
      info: 'Shows how to do initiation and loading of assets from within an '
          'extended ParallaxComponent',
    )
    ..add(
      'Non-fullscreen',
      (_) => GameWidget(game: SmallParallaxGame()),
      codeLink: baseLink('parallax/small_parallax.dart'),
      info: 'Shows how to create a smaller parallax in the center of the '
          'screen',
    )
    ..add(
      'No FCS',
      (_) => GameWidget(game: NoFCSParallaxGame()),
      codeLink: baseLink('parallax/no_fcs.dart'),
      info: "Shows how to use the parallax without Flame's component system",
    )
    ..add(
      'Advanced',
      (_) => GameWidget(game: AdvancedParallaxGame()),
      codeLink: baseLink('parallax/advanced.dart'),
      info: 'Shows how to create a parallax with different velocity deltas on '
          'each layer',
    );
}
