import 'package:flame/components.dart';
import 'package:flame/game.dart';

import '../input/draggables.dart';
import 'composability.dart';

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
    Component? swapChild;
    final t = Timer(5, callback: () {
      swapChild ??= draggablesGame.square;
      print('');
      print(swapChild!.parent);
      swapChild!.changeParent(
        swapChild!.parent == draggablesGame
            ? composedGame.parentSquare
            : draggablesGame,
      );
    }, repeat: true);
    t.start();
    add(t.asComponent());
  }
}
