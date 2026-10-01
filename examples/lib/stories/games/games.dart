import 'package:crystal_ball/crystal_ball.dart';
import 'package:examples/commons/example_use_case.dart';
import 'package:padracing/padracing_game.dart';
import 'package:padracing/padracing_widget.dart';
import 'package:rogue_shooter/rogue_shooter_game.dart';
import 'package:rogue_shooter/rogue_shooter_widget.dart';
import 'package:trex_game/trex_game.dart';
import 'package:trex_game/trex_widget.dart';
import 'package:widgetbook/widgetbook.dart';

String gamesLink(String game) =>
    'https://github.com/flame-engine/flame/blob/main/examples/games/$game';

WidgetbookComponent gameStories() {
  return WidgetbookComponent(
    name: 'Sample Games',
    useCases: [
      ExampleUseCase(
        name: 'Crystal Ball',
        builder: (_) => const CrystalBallWidget(),
        codeLink: gamesLink('crystal_ball'),
        info: CrystalBallWidget.description,
      ),
      ExampleUseCase(
        name: 'Padracing',
        builder: (_) => const PadracingWidget(),
        codeLink: gamesLink('padracing'),
        info: PadRacingGame.description,
      ),
      ExampleUseCase(
        name: 'Rogue Shooter',
        builder: (_) => const RogueShooterWidget(),
        codeLink: gamesLink('rogue_shooter'),
        info: RogueShooterGame.description,
      ),
      ExampleUseCase(
        name: 'T-Rex',
        builder: (_) => const TRexWidget(),
        codeLink: gamesLink('trex'),
        info: TRexGame.description,
      ),
    ],
  );
}
