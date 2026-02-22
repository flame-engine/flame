import 'package:flame/components.dart';

/// A mixin for components that can be pooled and reused.
///
/// Components that mix in [Poolable] should implement the [reset] method to
/// reset their state to the initial conditions, allowing them to be reused
/// without needing to be recreated.
///
/// Example usage:
/// ```dart
/// class MyBullet extends SpriteComponent with Poolable {
///  @override
///  void reset() {
///    // Reset position, velocity, and other properties to initial state
///  }
/// }
/// ```
/// This mixin is intended to be used with a [ComponentPool] to manage the
/// lifecycle of poolable components efficiently.
mixin Poolable on Component {
  /// Resets the component to its initial state, so it can be reused.
  void reset();
}
