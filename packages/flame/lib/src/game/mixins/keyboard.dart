import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/src/components/mixins/keyboard_handler.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A [FlameGame] mixin that implements [KeyboardEvents] with keyboard event
/// propagation to components that are mixed with [KeyboardHandler].
///
/// Attention: should not be used alongside [KeyboardEvents] in a game subclass.
/// Using this mixin remove the necessity of [KeyboardEvents].
mixin HasKeyboardHandlerComponents on FlameGame implements KeyboardEvents {
  @override
  @mustCallSuper
  KeyEventResult onKeyEvent(
    RawKeyEvent event,
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
  KeyEventResult onKeyEvent(
    RawKeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    assert(
      this is! HasKeyboardHandlerComponents,
      'A keyboard event was registered by KeyboardEvents for a game also '
      'mixed with HasKeyboardHandlerComponents. Do not mix with both, '
      'HasKeyboardHandlerComponents removes the necessity of KeyboardEvents',
    );

    return KeyEventResult.handled;
  }
}
