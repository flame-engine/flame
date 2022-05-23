import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/src/game/mixins/keyboard.dart';
import 'package:flutter/services.dart';

/// The signature for a key handle function
typedef KeyHandlerCallback = bool Function(Set<LogicalKeyboardKey>);

/// {@template keyboard_listener_component}
/// A [Component] that receives keyboard input and executes registered methods.
/// This component is based on [KeyboardHandler], which requires the [FlameGame]
/// which is used to be mixed with [HasKeyboardHandlerComponents].
/// {@endtemplate}
class KeyboardListenerComponent extends Component with KeyboardHandler {
  /// {@macro keyboard_listener_component}
  KeyboardListenerComponent({
    Map<LogicalKeyboardKey, KeyHandlerCallback> keyUp = const {},
    Map<LogicalKeyboardKey, KeyHandlerCallback> keyDown = const {},
  })  : _keyUp = keyUp,
        _keyDown = keyDown;

  final Map<LogicalKeyboardKey, KeyHandlerCallback> _keyUp;
  final Map<LogicalKeyboardKey, KeyHandlerCallback> _keyDown;

  @override
  bool onKeyEvent(RawKeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    final isUp = event is RawKeyUpEvent;

    final handlers = isUp ? _keyUp : _keyDown;
    final handler = handlers[event.logicalKey];

    if (handler != null) {
      return handler(keysPressed);
    }

    return true;
  }
}
