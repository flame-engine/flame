import 'package:flame/components.dart';
import 'package:flame/game.dart';

import '../input/draggables.dart';
import 'composability.dart';

const gameInGameInfo = '''
This example shows two games having another game as a parent.
One game contains draggable components and the other is a rotating square with
other square children.
After 5 seconds, one of the components from the game with draggable squares
changes its parent from its original game to the component that is rotating.
After another 5 seconds it changes back to its original parent, and so on.
''';

class GameChangeTimer extends TimerComponent with HasGameRef<GameInGame> {
  GameChangeTimer() : super(period: 5, repeat: true, autoStart: true);

  @override
  void onTick() {
    final child = gameRef.draggablesGame.square;
    final newParent = child.parent == gameRef.draggablesGame
        ? gameRef.composedGame.parentSquare
        : gameRef.draggablesGame;
    child.changeParent(newParent);
  }
}

class GameInGame extends FlameGame with HasDraggableComponents {
  @override
  bool debugMode = true;
  late final Composability composedGame;
  late final DraggablesGame draggablesGame;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    composedGame = Composability();
    draggablesGame = DraggablesGame(zoom: 1.0);

    await add(composedGame);
    await add(draggablesGame);

    add(GameChangeTimer());
  }
}
