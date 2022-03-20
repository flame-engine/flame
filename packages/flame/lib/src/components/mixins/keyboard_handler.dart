import 'package:flutter/services.dart';

import '../../../components.dart';
import '../../../input.dart';

/// A [Component] mixin to add keyboard handling capability to components.
/// Must be used in components that can only be added to games that are mixed
/// with [HasKeyboardHandlerComponents].
mixin KeyboardHandler on Component {
  bool onKeyEvent(RawKeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    return true;
  }
}
