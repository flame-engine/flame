import 'package:flame/src/components/core/component.dart';
import 'package:flame/src/events/flame_game_mixins/cursor_hover_dispatcher.dart';
import 'package:flame/src/events/messages/cursor_hover_event.dart';
import 'package:flame/src/game/flame_game.dart';
import 'package:meta/meta.dart';

mixin CursorHoverCallbacks on Component {
  void onMouseMove(CursorHoverEvent event) {}

  @override
  @mustCallSuper
  void onMount() {
    super.onMount();
    final game = findGame()! as FlameGame;
    if (game.firstChild<CursorHoverDispatcher>() == null) {
      game.add(CursorHoverDispatcher());
    }
  }
}
