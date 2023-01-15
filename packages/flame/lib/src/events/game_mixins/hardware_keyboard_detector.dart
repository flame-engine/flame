import 'package:flame/src/game/game.dart';
import 'package:flutter/services.dart';

/// This mixin allows directly listening to events from a hardware keyboard,
/// bypassing the `Focus` widget in Flutter. It will not listen for events from
/// any on-screen keyboards.
///
/// The mixin provides the [onKeyEvent] event handler that can be overridden in
/// your game. This event handler fires whenever the user presses or releases
/// any key on a keyboard, and also when a key is being held.
mixin HardwareKeyboardDetector on Game {
  /// The list of keys that are currently being pressed on the keyboard (or a
  /// keyboard-like device). The keys are listed in the order in which they
  /// were pressed, except for the modifier keys which may be listed
  /// out-of-order on some systems.
  List<PhysicalKeyboardKey> physicalKeysPressed = [];

  /// The set of logical keys that are currently being pressed on the keyboard.
  /// This set corresponds to the [physicalKeysPressed] list, and can be used
  /// to search for keys in a keyboard-layout-independent way.
  Set<LogicalKeyboardKey> logicalKeysPressed = {};

  /// Is the <Ctrl> key currently being pressed (either left or right)?
  bool get isControlPressed =>
      logicalKeysPressed.contains(LogicalKeyboardKey.controlLeft) ||
      logicalKeysPressed.contains(LogicalKeyboardKey.controlRight);

  /// Is the <Shift> key currently being pressed (either left or right)?
  bool get isShiftPressed =>
      logicalKeysPressed.contains(LogicalKeyboardKey.shiftLeft) ||
      logicalKeysPressed.contains(LogicalKeyboardKey.shiftRight);

  /// Is the <Alt> key currently being pressed (either left or right)?
  bool get isAltPressed =>
      logicalKeysPressed.contains(LogicalKeyboardKey.altLeft) ||
      logicalKeysPressed.contains(LogicalKeyboardKey.altRight);

  /// Is <NumLock> currently turned on?
  bool get isNumLockOn => _hasLock(KeyboardLockMode.numLock);

  /// Is <CapsLock> currently turned on?
  bool get isCapsLockOn => _hasLock(KeyboardLockMode.capsLock);

  /// Is <ScrollLock> currently turned on?
  bool get isScrollLockOn => _hasLock(KeyboardLockMode.scrollLock);

  bool _hasLock(KeyboardLockMode key) =>
      HardwareKeyboard.instance.lockModesEnabled.contains(key);

  /// Override this event handler if you want to get notified whenever any key
  /// on a keyboard is pressed, held, or released. The [event] will be one of
  /// [KeyDownEvent], [KeyRepeatEvent], or [KeyUpEvent], respectively.
  void onKeyEvent(KeyEvent event) {}

  /// Internal handler of raw key events.
  bool _handleKeyEvent(KeyEvent event) {
    logicalKeysPressed = HardwareKeyboard.instance.logicalKeysPressed;
    if (event is KeyDownEvent) {
      physicalKeysPressed.add(event.physicalKey);
    } else if (event is KeyUpEvent) {
      physicalKeysPressed.remove(event.physicalKey);
    }
    onKeyEvent(event);
    return true; // handled
  }

  @override
  void onMount() {
    super.onMount();
    HardwareKeyboard.instance.addHandler(_handleKeyEvent);
  }

  @override
  void onRemove() {
    super.onRemove();
    HardwareKeyboard.instance.removeHandler(_handleKeyEvent);
  }
}
