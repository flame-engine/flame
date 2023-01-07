import 'package:flame/src/game/game.dart';
import 'package:flutter/services.dart';

/// This mixin allows listening to raw keyboard events, bypassing the `Focus`
/// widget in Flutter.
///
/// The mixin provides two event handlers that can be overridden in your game:
/// - [onKeyEvent] fires whenever the user presses or releases any key on a
///   keyboard. Use this to handle "one-off" key events, such as the user
///   pressing <Space> to jump, or <Esc> to open a menu.
/// - [onKeysPressed] fires on every game tick as long as the user presses at
///   least some keys on the keyboard. Use this to reliably handle repeating
///   key events, such as user pressing arrow keys to move their character, or
///   holding down <Ctrl> to shoot continuously.
mixin RawKeyboardDetector on Game {
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

  /// Override this event handler if you want to get notified whenever any key
  /// on a keyboard is pressed or released. The [event] will be either a
  /// [RawKeyDownEvent] or a [RawKeyUpEvent], respectively.
  ///
  /// This event may also fire when the user presses a key and then holds it
  /// down. In such a case `event.repeat` property will be set to `true`.
  /// However, this should not be used for character navigation, since this
  /// behavior may not be reliable, and the frequency of such events is system-
  /// dependent. Use [onKeysPressed] event handler instead.
  void onKeyEvent(RawKeyEvent event) {}

  /// Override this event handler if you want to get notified whenever any keys
  /// are being pressed. This event handler is fired at the start of every game
  /// tick.
  ///
  /// The list of keys currently being pressed can be accessed via the
  /// [physicalKeysPressed] or [logicalKeysPressed] properties.
  void onKeysPressed() {}

  /// Internal handler of raw key events.
  void _onRawKeyEvent(RawKeyEvent event) {
    logicalKeysPressed = RawKeyboard.instance.keysPressed;
    if (event is RawKeyDownEvent) {
      physicalKeysPressed.add(event.physicalKey);
    } else if (event is RawKeyUpEvent) {
      physicalKeysPressed.remove(event.physicalKey);
    }
    // The list of physical keys may need to be reconciled with the RawKeyboard
    if (physicalKeysPressed.length != logicalKeysPressed.length) {
      final rawPhysicalKeysPressed = RawKeyboard.instance.physicalKeysPressed;
      physicalKeysPressed
        ..removeWhere((key) => !rawPhysicalKeysPressed.contains(key))
        ..addAll(
          rawPhysicalKeysPressed
              .where((key) => !physicalKeysPressed.contains(key))
              .toList(),
        );
    }
    onKeyEvent(event);
  }

  @override
  void onMount() {
    super.onMount();
    RawKeyboard.instance.addListener(_onRawKeyEvent);
  }

  @override
  void onRemove() {
    super.onRemove();
    RawKeyboard.instance.removeListener(_onRawKeyEvent);
  }

  @override
  void update(double dt) {
    if (physicalKeysPressed.isNotEmpty) {
      onKeysPressed();
    }
    super.update(dt);
  }
}
