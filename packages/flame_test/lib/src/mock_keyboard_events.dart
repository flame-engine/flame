import 'package:flame/events.dart';
import 'package:flutter/services.dart';

/// Creates a [KeyPressEvent] for [logicalKey].
///
/// [keysPressed] defaults to just [logicalKey]. [physicalKey] defaults to a
/// key with no layout meaning; pass one if the code under test reads it.
KeyPressEvent createKeyPressEvent({
  required LogicalKeyboardKey logicalKey,
  PhysicalKeyboardKey? physicalKey,
  String? character,
  Set<LogicalKeyboardKey>? keysPressed,
  Set<KeyboardLockMode>? lockModesEnabled,
}) {
  return KeyPressEvent(
    raw: KeyDownEvent(
      physicalKey: physicalKey ?? const PhysicalKeyboardKey(0),
      logicalKey: logicalKey,
      character: character,
      timeStamp: Duration.zero,
    ),
    keysPressed: keysPressed ?? {logicalKey},
    lockModesEnabled: lockModesEnabled ?? const {},
  );
}

/// Creates a [KeyHoldEvent] for [logicalKey].
///
/// [keysPressed] defaults to just [logicalKey]. [physicalKey] defaults to a
/// key with no layout meaning; pass one if the code under test reads it.
KeyHoldEvent createKeyHoldEvent({
  required LogicalKeyboardKey logicalKey,
  PhysicalKeyboardKey? physicalKey,
  String? character,
  Set<LogicalKeyboardKey>? keysPressed,
  Set<KeyboardLockMode>? lockModesEnabled,
}) {
  return KeyHoldEvent(
    raw: KeyRepeatEvent(
      physicalKey: physicalKey ?? const PhysicalKeyboardKey(0),
      logicalKey: logicalKey,
      character: character,
      timeStamp: Duration.zero,
    ),
    keysPressed: keysPressed ?? {logicalKey},
    lockModesEnabled: lockModesEnabled ?? const {},
  );
}

/// Creates a [KeyReleaseEvent] for [logicalKey].
///
/// [keysPressed] defaults to empty, since the released key is no longer held.
/// [physicalKey] defaults to a key with no layout meaning; pass one if the
/// code under test reads it.
KeyReleaseEvent createKeyReleaseEvent({
  required LogicalKeyboardKey logicalKey,
  PhysicalKeyboardKey? physicalKey,
  Set<LogicalKeyboardKey>? keysPressed,
  Set<KeyboardLockMode>? lockModesEnabled,
}) {
  return KeyReleaseEvent(
    raw: KeyUpEvent(
      physicalKey: physicalKey ?? const PhysicalKeyboardKey(0),
      logicalKey: logicalKey,
      timeStamp: Duration.zero,
    ),
    keysPressed: keysPressed ?? const {},
    lockModesEnabled: lockModesEnabled ?? const {},
  );
}
