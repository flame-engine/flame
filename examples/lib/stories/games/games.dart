import 'package:dashbook/dashbook.dart';
import 'package:padracing/padracing_game.dart';
import 'package:padracing/padracing_widget.dart';
import 'package:rogue_shooter/rogue_shooter_game.dart';
import 'package:rogue_shooter/rogue_shooter_widget.dart';
import 'package:trex_game/trex_game.dart';
import 'package:trex_game/trex_widget.dart';

String gamesLink(String game) =>
    'https://github.com/flame-engine/flame/blob/main/examples/games/$game';

void addGameStories(Dashbook dashbook) {
  dashbook.storiesOf('Sample Games')
    ..add(
      'Padracing',
      (_) => const PadracingWidget(),
      codeLink: gamesLink('padracing'),
      info: PadRacingGame.description,
    )
    ..add(
      'Rogue Shooter',
      (_) => const RogueShooterWidget(),
      codeLink: gamesLink('rogue_shooter'),
      info: RogueShooterGame.description,
    )
    ..add(
      'T-Rex',
      (_) => const TRexWidget(),
      codeLink: gamesLink('trex'),
      info: TRexGame.description,
    );
}
