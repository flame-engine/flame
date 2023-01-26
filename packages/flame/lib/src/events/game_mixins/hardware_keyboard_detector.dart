import 'package:flame/src/game/game.dart';
import 'package:flutter/services.dart';

/// This mixin allows directly listening to events from a hardware keyboard,
/// bypassing the `Focus` widget in Flutter. It will not listen for events from
/// any on-screen keyboards.
///
/// The mixin provides the [onKeyEvent] event handler that can be overridden in
/// your game. This event handler fires whenever the user presses or releases
/// any key on a keyboard, and also when a key is being held.
///
/// The stream of key events will be normalized by Flutter, meaning that for
/// every [KeyDownEvent] there will always be the corresponding [KeyUpEvent],
/// possibly with some [KeyRepeatEvent]s in the middle. Depending on the
/// platform, some of these events may be "synthesized", i.e. created by the
/// framework artificially in order to preserve the correct event sequence.
///
/// Use [pauseKeyEvents] property to temporarily halt/resume the delivery of
/// [onKeyEvent]s.
mixin HardwareKeyboardDetector on Game {
  final List<PhysicalKeyboardKey> _physicalKeys = [];
  Set<LogicalKeyboardKey> _logicalKeys = {};
  bool _pause = false;

  /// The list of keys that are currently being pressed on the keyboard (or a
  /// keyboard-like device). The keys are listed in the order in which they
  /// were pressed, except for the modifier keys which may be listed
  /// out-of-order on some systems.
  List<PhysicalKeyboardKey> get physicalKeysPressed => _physicalKeys;

  /// The set of logical keys that are currently being pressed on the keyboard.
  /// This set corresponds to the [physicalKeysPressed] list, and can be used
  /// to search for keys in a keyboard-layout-independent way.
  Set<LogicalKeyboardKey> get logicalKeysPressed => _logicalKeys;

  /// True if the <kbd>Ctrl</kbd> key is currently being pressed.
  bool get isControlPressed =>
      _logicalKeys.contains(LogicalKeyboardKey.controlLeft) ||
      _logicalKeys.contains(LogicalKeyboardKey.controlRight);

  /// True if the <kbd>Shift</kbd> key is currently being pressed.
  bool get isShiftPressed =>
      _logicalKeys.contains(LogicalKeyboardKey.shiftLeft) ||
      _logicalKeys.contains(LogicalKeyboardKey.shiftRight);

  /// True if the <kbd>Alt</kbd> key is currently being pressed.
  bool get isAltPressed =>
      _logicalKeys.contains(LogicalKeyboardKey.altLeft) ||
      _logicalKeys.contains(LogicalKeyboardKey.altRight);

  /// True if <kbd>Num Lock</kbd> currently turned on.
  bool get isNumLockOn => _hasLock(KeyboardLockMode.numLock);

  /// True if <kbd>Caps Lock</kbd> currently turned on.
  bool get isCapsLockOn => _hasLock(KeyboardLockMode.capsLock);

  /// True if <kbd>Scroll Lock</kbd> currently turned on.
  bool get isScrollLockOn => _hasLock(KeyboardLockMode.scrollLock);

  bool _hasLock(KeyboardLockMode key) =>
      HardwareKeyboard.instance.lockModesEnabled.contains(key);

  /// When `true`, delivery of key events will be suspended.
  ///
  /// When this property is set to true, the system generates KeyUp events for
  /// all keys currently being held, as if the user has released them.
  /// Conversely, when this property is switched back to `false`, and the user
  /// was holding some keys at the time, the system will generate KeyDown
  /// events as if the user just started pressing those buttons.
  bool get pauseKeyEvents => _pause;
  set pauseKeyEvents(bool value) {
    if (value == _pause) {
      return;
    }
    _pause = value;
    final timeStamp = ServicesBinding.instance.currentSystemFrameTimeStamp;
    for (final physicalKey in _physicalKeys) {
      onKeyEvent(
        (_pause ? KeyUpEvent.new : KeyDownEvent.new)(
          physicalKey: physicalKey,
          logicalKey: HardwareKeyboard.instance.lookUpLayout(physicalKey)!,
          timeStamp: timeStamp,
          synthesized: true,
        ),
      );
    }
  }

  /// Override this event handler if you want to get notified whenever any key
  /// on a keyboard is pressed, held, or released. The [event] will be one of
  /// [KeyDownEvent], [KeyRepeatEvent], or [KeyUpEvent], respectively.
  void onKeyEvent(KeyEvent event) {}

  /// Internal handler of raw key events.
  bool _handleKeyEvent(KeyEvent event) {
    _logicalKeys = HardwareKeyboard.instance.logicalKeysPressed;
    if (event is KeyDownEvent) {
      _physicalKeys.add(event.physicalKey);
    } else if (event is KeyUpEvent) {
      _physicalKeys.remove(event.physicalKey);
    }
    if (!_pause) {
      onKeyEvent(event);
    }
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
