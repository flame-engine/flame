import 'package:examples/stories/components/composability_example.dart';
import 'package:examples/stories/input/draggables_example.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';

class GameInGameExample extends FlameGame with HasDraggables {
  static const String description = '''
    This example shows two games having another game as a parent.
    One game contains draggable components and the other is a rotating square
    with other square children.
    After 5 seconds, one of the components from the game with draggable squares
    changes its parent from its original game to the component that is rotating.
    After another 5 seconds it changes back to its original parent, and so on.
  ''';

  @override
  bool debugMode = true;
  late final ComposabilityExample composedGame;
  late final DraggablesExample draggablesGame;

  @override
  Future<void> onLoad() async {
    composedGame = ComposabilityExample();
    draggablesGame = DraggablesExample(zoom: 1.0);
    await add(composedGame);
    await add(draggablesGame);

    add(GameChangeTimer());
  }
}

class GameChangeTimer extends TimerComponent
    with HasGameRef<GameInGameExample> {
  GameChangeTimer() : super(period: 5, repeat: true);

  @override
  void onTick() {
    final child = gameRef.draggablesGame.square;
    final newParent = child.parent == gameRef.draggablesGame
        ? gameRef.composedGame.parentSquare
        : gameRef.draggablesGame;
    child.changeParent(newParent);
  }
}
