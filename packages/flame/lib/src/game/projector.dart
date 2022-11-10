import 'package:flame/extensions.dart';

/// A simple interface to mark a class that can perform projection operations
/// from one 2D Euclidian coordinate space to another.
///
/// This can be a Viewport, a Camera or anything else that exposes such
/// operations to the user.
abstract class Projector {
  /// Converts a vector in the screen space to the world space.
  ///
  /// This considers both the translation and scaling transformations.
  Vector2 unprojectVector(Vector2 screenCoordinates);

  /// Converts a vector in the world space to the screen space.
  ///
  /// This considers both the translation and scaling transformations.
  Vector2 projectVector(Vector2 worldCoordinates);

  /// Converts a vector representing a delta in the screen space to the world
  /// space.
  ///
  /// This considers only the scaling transformation, as the translations are
  /// cancelled in a delta transformation.
  /// A delta can be a displacement (difference between two position
  /// vectors), a velocity (displacement over time), etc.
  Vector2 unscaleVector(Vector2 screenCoordinates);

  /// Converts a vector representing a delta in the world space to the screen
  /// space.
  ///
  /// This considers only the scaling transformation, as the translations are
  /// cancelled in a delta transformation.
  /// A delta can be a displacement (difference between two position
  /// vectors), a velocity (displacement over time), etc.
  Vector2 scaleVector(Vector2 worldCoordinates);

  /// Creates a [ComposedProjector] that will apply the provided projectors
  /// in order.
  ///
  /// Use when dealing with multiple coordinate transformations in succession.
  static Projector compose(List<Projector> projectors) {
    return ComposedProjector(projectors);
  }
}

/// A simple Projector implementation that represents the identity operation
/// (i.e. no-op).
class IdentityProjector extends Projector {
  @override
  Vector2 projectVector(Vector2 v) => v;

  @override
  Vector2 scaleVector(Vector2 v) => v;

  @override
  Vector2 unprojectVector(Vector2 v) => v;

  @override
  Vector2 unscaleVector(Vector2 v) => v;
}

/// This is a [Projector] implementation that composes a list of projectors,
/// in the order provided.
///
/// It will call the `project*` functions in the order in the array and the
/// `unproject*` in the reversed order.
/// For a list of projectors p1, p2, ..., pn, this is equivalent of the
/// projector p = pn ∘ ... ∘ p2 ∘ p1.
class ComposedProjector extends Projector {
  final List<Projector> _components;
  ComposedProjector(this._components);

  @override
  Vector2 scaleVector(Vector2 worldCoordinates) {
    return _components.fold(
      worldCoordinates,
      (previousValue, element) => element.scaleVector(previousValue),
    );
  }

  @override
  Vector2 projectVector(Vector2 worldCoordinates) {
    return _components.fold(
      worldCoordinates,
      (previousValue, element) => element.projectVector(previousValue),
    );
  }

  @override
  Vector2 unscaleVector(Vector2 screenCoordinates) {
    return _components.reversed.fold(
      screenCoordinates,
      (previousValue, element) => element.unscaleVector(previousValue),
    );
  }

  @override
  Vector2 unprojectVector(Vector2 screenCoordinates) {
    return _components.reversed.fold(
      screenCoordinates,
      (previousValue, element) => element.unprojectVector(previousValue),
    );
  }
}
