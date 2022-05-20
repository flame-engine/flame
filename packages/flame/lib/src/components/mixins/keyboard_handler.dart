import 'package:flame/components.dart';
import 'package:flame/input.dart';
import 'package:flutter/services.dart';

/// A [Component] mixin to add keyboard handling capability to components.
/// Must be used in components that can only be added to games that are mixed
/// with [HasKeyboardHandlerComponents].
mixin KeyboardHandler on Component {
  bool onKeyEvent(RawKeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    return true;
  }
}
