import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:meta/meta.dart';

/// Makes a component capable of notifying listeners of changes.
///
/// Notifier components will automatically notify when
/// new instances are added or removed to the game instance.
///
/// To notify internal changes of a component instance, the component
/// should call [notifyListeners].
mixin Notifier on Component {
  FlameGame get _gameRef {
    final game = findGame();
    assert(
      game == null || game is FlameGame,
      "Notifier can't be used without FlameGame",
    );
    return game! as FlameGame;
  }

  @override
  @mustCallSuper
  void onMount() {
    super.onMount();

    _gameRef.propagateToApplicableNotifiers(this, (notifier) {
      notifier.add(this);
    });
  }

  @override
  @mustCallSuper
  void onRemove() {
    _gameRef.propagateToApplicableNotifiers(this, (notifier) {
      notifier.remove(this);
    });

    super.onRemove();
  }

  /// When called, will notify listeners that a change happened on
  /// this component's class notifier.
  void notifyListeners() {
    _gameRef.propagateToApplicableNotifiers(this, (notifier) {
      notifier.notify();
    });
  }
}
