import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// A [FlameGame] mixin that implements [KeyboardEvents] with keyboard event
/// propagation to components that are mixed with [KeyboardHandler].
///
/// Attention: should not be used alongside [KeyboardEvents] in a game subclass.
/// Using this mixin remove the necessity of [KeyboardEvents].
mixin HasKeyboardHandlerComponents<W extends World> on FlameGame<W>
    implements KeyboardEvents {
  @override
  @mustCallSuper
  KeyEventResult onKeyEvent(
    KeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    final blockedPropagation = !propagateToChildren<KeyboardHandler>(
      (KeyboardHandler child) => child.onKeyEvent(event, keysPressed),
    );

    // If any component received the event, return handled,
    // otherwise, ignore it.
    if (blockedPropagation) {
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }
}

/// A [Game] mixin to make a game subclass sensitive to keyboard events.
///
/// Override [onKeyEvent] to customize the keyboard handling behavior.
mixin KeyboardEvents on Game {
  /// Called when the game has the focus and receives a key event.
  ///
  /// Return [KeyEventResult.handled] for the events that the game consumes
  /// and [KeyEventResult.ignored] for the rest, so that they can reach the
  /// widgets above the game, like the back button on Android popping the
  /// route. The default implementation ignores all key events.
  KeyEventResult onKeyEvent(
    KeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    assert(
      this is! HasKeyboardHandlerComponents,
      'A keyboard event was registered by KeyboardEvents for a game also '
      'mixed with HasKeyboardHandlerComponents. Do not mix with both, '
      'HasKeyboardHandlerComponents removes the necessity of KeyboardEvents',
    );

    return KeyEventResult.ignored;
  }
}
