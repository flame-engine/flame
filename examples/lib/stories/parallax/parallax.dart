import 'package:dashbook/dashbook.dart';
import 'package:flame/game.dart';

import '../../commons/commons.dart';
import 'advanced.dart';
import 'basic.dart';
import 'component.dart';
import 'no_fcs.dart';

void addParallaxStories(Dashbook dashbook) {
  dashbook.storiesOf('Parallax')
    ..add(
      'Basic',
      (_) => GameWidget(game: BasicParallaxGame()),
      codeLink: baseLink('parallax/basic.dart'),
    )
    ..add(
      'Component',
      (_) => GameWidget(game: ComponentParallaxGame()),
      codeLink: baseLink('parallax/component.dart'),
    )
    ..add(
      'No FCS',
      (_) => GameWidget(game: NoFCSParallaxGame()),
      codeLink: baseLink('parallax/no_fcs.dart'),
    )
    ..add(
      'Advanced',
      (_) => GameWidget(game: AdvancedParallaxGame()),
      codeLink: baseLink('parallax/advanced.dart'),
    );
}
