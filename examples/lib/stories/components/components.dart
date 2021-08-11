import 'package:dashbook/dashbook.dart';
import 'package:flame/game.dart';

import '../../commons/commons.dart';
import 'composability.dart';
import 'debug.dart';
import 'game_in_game.dart';
import 'priority.dart';

void addComponentsStories(Dashbook dashbook) {
  dashbook.storiesOf('Components')
    ..add(
      'Composability',
      (_) => GameWidget(game: Composability()),
      codeLink: baseLink('components/composability.dart'),
    )
    ..add(
      'Priority',
      (_) => GameWidget(game: Priority()),
      codeLink: baseLink('components/priority.dart'),
      info: priorityInfo,
    )
    ..add(
      'Debug',
      (_) => GameWidget(game: DebugGame()),
      codeLink: baseLink('components/debug.dart'),
    )
    ..add(
      'Game-in-game',
      (_) => GameWidget(game: GameInGame()),
      codeLink: baseLink('components/game_in_game.dart'),
      info: gameInGameInfo,
    );
}
