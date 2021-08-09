import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../components.dart';
import '../../../game.dart';

mixin KeyboardHandler on BaseComponent {
  bool onKeyEvent(
    RawKeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    return true;
  }
}

mixin HasKeyboardHandlerComponents on BaseGame {
  bool _handleKeyboardEvent(
    bool Function(KeyboardHandler child) keyboardEventHandler,
  ) {
    var shouldContinue = true;
    for (final c in components.toList().reversed) {
      if (c is BaseComponent) {
        shouldContinue = c.propagateToChildren<KeyboardHandler>(
          keyboardEventHandler,
        );
      }
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
  KeyEventResult onKeyEvent(
    RawKeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    final blockedPropagation = !_handleKeyboardEvent(
      (KeyboardHandler child) => child.onKeyEvent(event, keysPressed),
    );

    if (blockedPropagation) {
      return KeyEventResult.handled;
    }
    return super.onKeyEvent(event, keysPressed);
  }
}
