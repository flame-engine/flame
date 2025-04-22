import 'package:flame_3d/core.dart';
import 'package:flutter/services.dart';

// TODO(luan): add this as part of the input API
bool readArrowLikeKeysIntoVector2(
  KeyEvent event,
  Set<LogicalKeyboardKey> keysPressed,
  Vector2 vector, {
  LogicalKeyboardKey up = LogicalKeyboardKey.keyW,
  LogicalKeyboardKey down = LogicalKeyboardKey.keyS,
  LogicalKeyboardKey left = LogicalKeyboardKey.keyA,
  LogicalKeyboardKey right = LogicalKeyboardKey.keyD,
}) {
  final isDown = event is KeyDownEvent || event is KeyRepeatEvent;
  if (event.logicalKey == up) {
    if (isDown) {
      vector.y = -1;
    } else if (keysPressed.contains(down)) {
      vector.y = 1;
    } else {
      vector.y = 0;
    }
    return false;
  } else if (event.logicalKey == down) {
    if (isDown) {
      vector.y = 1;
    } else if (keysPressed.contains(up)) {
      vector.y = -1;
    } else {
      vector.y = 0;
    }
    return false;
  } else if (event.logicalKey == left) {
    if (isDown) {
      vector.x = -1;
    } else if (keysPressed.contains(right)) {
      vector.x = 1;
    } else {
      vector.x = 0;
    }
    return false;
  } else if (event.logicalKey == right) {
    if (isDown) {
      vector.x = 1;
    } else if (keysPressed.contains(left)) {
      vector.x = -1;
    } else {
      vector.x = 0;
    }
    return false;
  }
  return true;
}
