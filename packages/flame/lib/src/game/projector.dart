import '../../extensions.dart';

/// A simple interface to mark a class that can perform projection operations
/// from one 2D euclidian coordinate space to another.
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
  Vector2 unprojectDelta(Vector2 screenCoordinates);

  /// Converts a vector representing a delta in the world space to the screen
  /// space.
  ///
  /// This considers only the scaling transformation, as the translations are
  /// cancelled in a delta transformation.
  /// A delta can be a displacement (difference between two position
  /// vectors), a velocity (displacement over time), etc.
  Vector2 projectDelta(Vector2 worldCoordinates);

  static Projector combine(List<Projector> projectors) {
    return CombinationProjector(projectors);
  }
}

class CombinationProjector extends Projector {
  final List<Projector> _components;
  CombinationProjector(this._components);

  @override
  Vector2 projectDelta(Vector2 worldCoordinates) {
    return _components.fold(
      worldCoordinates,
      (previousValue, element) => element.projectDelta(previousValue),
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
  Vector2 unprojectDelta(Vector2 screenCoordinates) {
    return _components.reversed.fold(
      screenCoordinates,
      (previousValue, element) => element.unprojectDelta(previousValue),
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
