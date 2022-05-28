import 'dart:ui';

import 'package:flame/src/components/component.dart';
import 'package:flame/src/experimental/camera_component.dart';
import 'package:meta/meta.dart';
import 'package:vector_math/vector_math_64.dart';

/// The root component for all game world elements.
///
/// The primary feature of this component is that it disables regular rendering,
/// and allows itself to be rendered through a [CameraComponent] only. The
/// updates proceed through the world tree normally.
class World extends Component {
  @override
  void renderTree(Canvas canvas) {}

  /// Internal rendering method invoked by the [CameraComponent].
  @internal
  void renderFromCamera(Canvas canvas) {
    assert(CameraComponent.currentCamera != null);
    super.renderTree(canvas);
  }

  @override
  bool containsLocalPoint(Vector2 point) => true;

  @override
  Iterable<Component> componentsAtPoint(
    Vector2 point, [
    List<Vector2>? nestedPoints,
  ]) {
    return const Iterable.empty();
  }

  @internal
  Iterable<Component> componentsAtPointFromCamera(
    Vector2 point,
    List<Vector2>? nestedPoints,
  ) {
    return super.componentsAtPoint(point, nestedPoints);
  }
}
