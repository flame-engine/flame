import 'package:flutter/services.dart';
import '../../../components.dart';
import '../../../game.dart';
import '../../game/mixins/keyboard.dart';

/// The signature for a key handle function
typedef KeyHandlerCallback = bool Function();

/// {@template keyboard_component}
/// A [Component] that receives keyboard input and executes registered methods.
/// This component is based on [KeyboardHandler], which requires the [FlameGame]
/// which it is used to be mixed with [HasKeyboardHandlerComponents]
/// {@endtemplate}
class KeyboardComponent extends Component with KeyboardHandler {
  /// {@macro keyboard_component}
  KeyboardComponent({
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
      return handler();
    }

    return true;
  }
}
