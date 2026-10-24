import 'package:flame/events.dart';
import 'package:flutter/services.dart';

/// Base class for the keyboard events delivered to [KeyboardCallbacks]
/// components: [KeyPressEvent], [KeyHoldEvent] and [KeyReleaseEvent].
///
/// Keyboard events are delivered to every [KeyboardCallbacks] component in the
/// game, from the topmost child down to the game itself. Any component may set
/// [continuePropagation] to false to stop the event from reaching the
/// components after it.
sealed class KeyboardEvent<R extends KeyEvent>({
  required super.raw,

  /// The logical keys that were held down when this event happened, including
  /// the key of this event itself unless it is a [KeyReleaseEvent].
  required final Set<LogicalKeyboardKey> keysPressed,

  /// The lock modes (such as <kbd>Caps Lock</kbd>) that were turned on when
  /// this event happened.
  final Set<KeyboardLockMode> lockModesEnabled = const {},
}) extends Event<R> {
  /// The key that was pressed, held or released, according to the current
  /// keyboard layout.
  LogicalKeyboardKey get logicalKey => raw.logicalKey;

  /// The physical location of the key on the keyboard, regardless of layout.
  PhysicalKeyboardKey get physicalKey => raw.physicalKey;

  bool _hasPressedAny(List<LogicalKeyboardKey> keysToCheck) {
    return keysPressed.any((key) => keysToCheck.contains(key));
  }

  /// True if <kbd>Shift</kbd> was held down when this event happened.
  bool get isShiftPressed => _hasPressedAny([
    LogicalKeyboardKey.shiftLeft,
    LogicalKeyboardKey.shiftRight,
  ]);

  /// True if <kbd>Ctrl</kbd> was held down when this event happened.
  bool get isControlPressed => _hasPressedAny([
    LogicalKeyboardKey.controlLeft,
    LogicalKeyboardKey.controlRight,
  ]);

  /// True if <kbd>Alt</kbd> was held down when this event happened.
  bool get isAltPressed => _hasPressedAny([
    LogicalKeyboardKey.altLeft,
    LogicalKeyboardKey.altRight,
  ]);

  /// True if <kbd>Meta</kbd> (<kbd>Cmd</kbd> on macOS, <kbd>Win</kbd> on
  /// Windows) was held down when this event happened.
  bool get isMetaPressed => _hasPressedAny([
    LogicalKeyboardKey.metaLeft,
    LogicalKeyboardKey.metaRight,
  ]);

  /// True if <kbd>Caps Lock</kbd> was turned on when this event happened.
  bool get isCapsLockOn => lockModesEnabled.contains(KeyboardLockMode.capsLock);

  /// True if <kbd>Num Lock</kbd> was turned on when this event happened.
  bool get isNumLockOn => lockModesEnabled.contains(KeyboardLockMode.numLock);

  /// True if <kbd>Scroll Lock</kbd> was turned on when this event happened.
  bool get isScrollLockOn {
    return lockModesEnabled.contains(KeyboardLockMode.scrollLock);
  }

  /// Wraps a Flutter [KeyEvent], reading the pressed keys and lock modes from
  /// [HardwareKeyboard].
  static KeyboardEvent<KeyEvent> fromKeyEvent(KeyEvent event) {
    final keysPressed = HardwareKeyboard.instance.logicalKeysPressed;
    final lockModesEnabled = HardwareKeyboard.instance.lockModesEnabled;
    return switch (event) {
      final KeyDownEvent raw => KeyPressEvent(
        raw: raw,
        keysPressed: keysPressed,
        lockModesEnabled: lockModesEnabled,
      ),
      final KeyRepeatEvent raw => KeyHoldEvent(
        raw: raw,
        keysPressed: keysPressed,
        lockModesEnabled: lockModesEnabled,
      ),
      final KeyUpEvent raw => KeyReleaseEvent(
        raw: raw,
        keysPressed: keysPressed,
        lockModesEnabled: lockModesEnabled,
      ),
      _ => throw ArgumentError.value(event, 'event', 'Unknown KeyEvent type'),
    };
  }
}

/// Fired when a key is pressed down. Wraps Flutter's [KeyDownEvent].
class KeyPressEvent({
  required super.raw,
  required super.keysPressed,
  super.lockModesEnabled,
}) extends KeyboardEvent<KeyDownEvent> {
  /// The text this key stroke produced, if any. Null for keys that produce no
  /// text, such as modifier or arrow keys.
  String? get character => raw.character;
}

/// Fired repeatedly while a key is held down, at the operating system's key
/// repeat rate. Wraps Flutter's [KeyRepeatEvent].
class KeyHoldEvent({
  required super.raw,
  required super.keysPressed,
  super.lockModesEnabled,
}) extends KeyboardEvent<KeyRepeatEvent> {
  /// The text this key repeat produced, if any. Null for keys that produce no
  /// text, such as modifier or arrow keys.
  String? get character => raw.character;
}

/// Fired when a key is released. Wraps Flutter's [KeyUpEvent].
class KeyReleaseEvent({
  required super.raw,
  required super.keysPressed,
  super.lockModesEnabled,
}) extends KeyboardEvent<KeyUpEvent>;
