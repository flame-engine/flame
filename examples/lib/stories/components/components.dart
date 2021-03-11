import 'package:dashbook/dashbook.dart';
import 'package:flame/game.dart';

import '../../commons/commons.dart';
import 'composability.dart';
import 'debug.dart';

void addComponentsStories(Dashbook dashbook) {
  dashbook.storiesOf('Components')
    ..add(
      'Composability',
      (_) => GameWidget(game: Composability()),
      codeLink: baseLink('components/composability.dart'),
    )
    ..add(
      'Debug',
      (_) => GameWidget(game: DebugGame()),
      codeLink: baseLink('components/debug.dart'),
    );
}
