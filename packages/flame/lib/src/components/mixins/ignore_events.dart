import 'package:flame/src/components/core/component.dart';

/// This mixin allows a component and all it's descendants to ignore events.
///
/// Do note that this will also ignore the component and its descendants in
/// calls to [Component.componentsAtPoint].
///
/// If you want to dynamically use this mixin, you can add it and set
/// [ignoreEvents] true or false at runtime.
///
/// This mixin is to be used when you have a large subtree of components that
/// shouldn't receive any events and you want to optimize the event handling.
mixin IgnoreEvents on Component {
  bool ignoreEvents = true;
}
