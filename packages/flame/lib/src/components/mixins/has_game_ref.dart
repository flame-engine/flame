import '../../../components.dart';
import '../../game/game.dart';

mixin HasGameRef<T extends Game> {
  T? _gameRef;

  T get gameRef {
    final ref = _gameRef;
    if (ref == null) {
      throw 'Accessing gameRef before the component was added to the game!';
    }
    return ref;
  }

  bool get hasGameRef => _gameRef != null;

  set gameRef(T gameRef) {
    _gameRef = gameRef;
    if (this is BaseComponent) {
      (this as BaseComponent)
          .children
          .whereType<HasGameRef<T>>()
          .forEach((e) => e.gameRef = gameRef);
    }
  }
}
