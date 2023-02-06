import 'package:flame/game.dart';
import 'package:flame/src/components/core/component.dart';
import 'package:flame/src/events/flame_game_mixins/double_tap_dispatcher.dart';
import 'package:flame/src/events/messages/double_tap_cancel_event.dart';
import 'package:flame/src/events/messages/double_tap_down_event.dart';
import 'package:flame/src/events/messages/double_tap_event.dart';

mixin DoubleTapCallbacks on Component {
  void onDoubleTap(DoubleTapEvent event) {}

  void onDoubleTapCancel(DoubleTapCancelEvent event) {}

  void onDoubleTapDown(DoubleTapDownEvent event) {}

  @override
  void onMount() {
    super.onMount();
    final game = findGame()! as FlameGame;
    if (game.firstChild<DoubleTapDispatcher>() == null) {
      game.add(DoubleTapDispatcher());
    }
  }
}
