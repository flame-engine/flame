import 'package:flame/src/events/callbacks/input_callbacks.dart';

/// Marker interface implemented by every input callbacks mixin whose events
/// carry a position (taps, drags, scrolls, hover) and thus participate in
/// hit-testing.
///
/// Non-positional input, such as keyboard, implements [InputCallbacks].
abstract interface class PointerInputCallbacks implements InputCallbacks {}
