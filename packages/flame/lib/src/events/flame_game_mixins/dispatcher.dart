import 'package:flame/components.dart';
import 'package:flame/src/game/flame_game.dart';

abstract class Dispatcher<G extends FlameGame> extends Component
    with HasGameReference<G> {
  static void addDispatcher<T extends Component>(
    Component component,
    ComponentKey key,
    T Function() create,
  ) {
    final game = component.findRootGame()!;
    if (game.findByKey(key) != null) {
      return;
    }
    final dispatcher = create();
    game.registerKey(key, dispatcher);
    game.add(dispatcher);
  }

  static void removeDispatcher(FlameGame game, ComponentKey key) {
    game.unregisterKey(key);
  }
}
