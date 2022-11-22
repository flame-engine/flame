import 'dart:ui';

import 'package:flame/src/camera/camera_component.dart';
import 'package:flame/src/components/core/component.dart';
import 'package:flame/src/components/mixins/coordinate_transform.dart';
import 'package:meta/meta.dart';
import 'package:vector_math/vector_math_64.dart';

/// The root component for all game world elements.
///
/// The primary feature of this component is that it disables regular rendering,
/// and allows itself to be rendered through a [CameraComponent] only. The
/// updates proceed through the world tree normally.
class World extends Component implements CoordinateTransform {
  World({super.children});

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
  Vector2? localToParent(Vector2 point) => null;

  @override
  Vector2? parentToLocal(Vector2 point) => null;
}
