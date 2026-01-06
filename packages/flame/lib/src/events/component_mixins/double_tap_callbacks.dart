import 'package:flame/components.dart';
import 'package:flame/events.dart';

/// [DoubleTapCallbacks] adds the ability to receive double-tap events in a
/// component.
///
/// In addition to adding this mixin, the component must also implement the
/// [containsLocalPoint] method.
///
/// At present, flutter detects only one double-tap events simultaneously.
/// This means that if you're double-tapping two [DoubleTapCallbacks] located
/// far away from each other, only one callback will be fired (or none).
mixin DoubleTapCallbacks on Component {
  /// This triggers when the pointer stops contacting the device after the
  /// second tap.
  void onDoubleTapUp(DoubleTapEvent event) {}

  /// This triggers immediately after the down event of the second tap.
  void onDoubleTapDown(DoubleTapDownEvent event) {}

  /// This triggers once the gesture loses the arena if [onDoubleTapDown] has
  /// previously been triggered.
  void onDoubleTapCancel(DoubleTapCancelEvent event) {}

  @override
  void onMount() {
    super.onMount();
    final game = findRootGame()!;
    if (game.findByKey(const DoubleTapDispatcherKey()) == null) {
      final dispatcher = DoubleTapDispatcher();
      game.registerKey(const DoubleTapDispatcherKey(), dispatcher);
      game.add(dispatcher);
    }
  }
}
