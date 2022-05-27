import 'package:dashbook/dashbook.dart';
import 'package:examples/commons/commons.dart';
import 'package:padracing/padracing_game.dart';
import 'package:padracing/padracing_widget.dart';
import 'package:trex_game/trex_game.dart';
import 'package:trex_game/trex_widget.dart';

void addGameStories(Dashbook dashbook) {
  dashbook.storiesOf('Sample Games')
    ..add(
      'Padracing',
      (_) => const PadracingWidget(),
      codeLink: baseLink('games/padracing'),
      info: PadRacingGame.description,
    )
    ..add(
      'T-Rex',
      (_) => const TRexWidget(),
      codeLink: baseLink('games/trex'),
      info: TRexGame.description,
    );
}
