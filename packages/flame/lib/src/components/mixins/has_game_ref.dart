import '../../../components.dart';
import '../../../game.dart';

mixin HasGameRef<T extends BaseGame> on Component {
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
      // TODO(luan) this is wrong, should be done using propagateToChildren
      (this as BaseComponent)
          .children
          .query<HasGameRef>()
          .forEach((e) => e.gameRef = gameRef);
    }
  }
}
