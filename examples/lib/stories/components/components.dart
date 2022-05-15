import 'package:dashbook/dashbook.dart';
import 'package:examples/commons/commons.dart';
import 'package:examples/stories/components/composability_example.dart';
import 'package:examples/stories/components/debug_example.dart';
import 'package:examples/stories/components/game_in_game_example.dart';
import 'package:examples/stories/components/priority_example.dart';
import 'package:flame/game.dart';

void addComponentsStories(Dashbook dashbook) {
  dashbook.storiesOf('Components')
    ..add(
      'Composability',
      (_) => GameWidget(game: ComposabilityExample()),
      codeLink: baseLink('components/composability_example.dart'),
      info: ComposabilityExample.description,
    )
    ..add(
      'Priority',
      (_) => GameWidget(game: PriorityExample()),
      codeLink: baseLink('components/priority_example.dart'),
      info: PriorityExample.description,
    )
    ..add(
      'Debug',
      (_) => GameWidget(game: DebugExample()),
      codeLink: baseLink('components/debug_example.dart'),
      info: DebugExample.description,
    )
    ..add(
      'Game-in-game',
      (_) => GameWidget(game: GameInGameExample()),
      codeLink: baseLink('components/game_in_game_example.dart'),
      info: GameInGameExample.description,
    );
}
