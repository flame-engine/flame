import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:meta/meta.dart';

mixin Notifiable on Component {
  FlameGame get _gameRef {
    final game = findGame();
    assert(
      game == null || game is FlameGame,
      "Notifiable can't be used without FlameGame",
    );
    return game! as FlameGame;
  }

  @override
  @mustCallSuper
  void onMount() {
    _gameRef.notifiers[runtimeType]?.add(this);
  }

  @override
  @mustCallSuper
  void onRemove() {
    _gameRef.notifiers[runtimeType]?.remove(this);
  }

  void updated() {
    _gameRef.notifiers[runtimeType]?.update();
  }
}
