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

class GameInGame extends BaseGame with HasDraggableComponents {
  @override
  bool debugMode = true;
  late final Composability composedGame;
  late final DraggablesGame draggablesGame;

  @override
  Future<void> onLoad() async {
    composedGame = Composability();
    draggablesGame = DraggablesGame(zoom: 1.0);
    await add(composedGame);
    await add(draggablesGame);
    final child = draggablesGame.square;
    final t = Timer(
      5,
      callback: () {
        print('In callback, parent: ${child.parent}');
        print('parent square: ${composedGame.parentSquare}');
        child.changeParent(
          child.parent == draggablesGame
              ? composedGame.parentSquare
              : draggablesGame,
        );
      },
      repeat: true,
    );
    t.start();
    add(t.asComponent());
  }
}
