import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../components.dart';
import '../../../game.dart';
import 'game.dart';

/// A [Component] mixin to add keyboard handling capability to components.
/// Must be used in components that can only be added to games that are mixed
/// with [HasKeyboardHandlerComponents].
mixin KeyboardHandler on Component {
  bool onKeyEvent(
    RawKeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    return true;
  }
}

/// A [FlameGame] mixin that implements [KeyboardEvents] with keyboard event
/// propagation to components that are mixed with [KeyboardHandler].
///
/// Attention: should not be used alongside [KeyboardEvents] in a game subclass.
/// Using this mixin remove the necessity of [KeyboardEvents].
mixin HasKeyboardHandlerComponents on FlameGame implements KeyboardEvents {
  bool _handleKeyboardEvent(
    bool Function(KeyboardHandler child) keyboardEventHandler,
  ) {
    var shouldContinue = true;
    for (final c in children.toList().reversed) {
      shouldContinue = c.propagateToChildren<KeyboardHandler>(
        keyboardEventHandler,
      );
      if (c is KeyboardHandler && shouldContinue) {
        shouldContinue = keyboardEventHandler(c);
      }
      if (!shouldContinue) {
        break;
      }
    }

    return shouldContinue;
  }

  @override
  @mustCallSuper
  KeyEventResult onKeyEvent(
    RawKeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    final blockedPropagation = !_handleKeyboardEvent(
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
