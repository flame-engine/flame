import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/src/game/transform2d.dart';
import 'package:meta/meta.dart';

class Lens extends Component
    with ParentIsA<CameraComponent>
    implements ReadOnlyScaleProvider {
  /// Reference to the parent camera.
  CameraComponent get camera => parent;

  @internal
  final Transform2D transform = Transform2D();

  @override
  Vector2 get scale => transform.scale;

  void onViewportResize() {}

  /// Convert a point from the global coordinate system to the lens'
  /// coordinate system.
  ///
  /// Use [output] to send in a Vector2 object that will be used to avoid
  /// creating a new Vector2 object in this method.
  ///
  /// Opposite of [localToGlobal].
  Vector2 globalToLocal(Vector2 point, {Vector2? output}) {
    return transform.globalToLocal(point, output: output);
  }

  /// Convert a point from the lens' coordinate system to the global
  /// coordinate system.
  ///
  /// Use [output] to send in a Vector2 object that will be used to avoid
  /// creating a new Vector2 object in this method.
  ///
  /// Opposite of [globalToLocal].
  Vector2 localToGlobal(Vector2 point, {Vector2? output}) {
    return transform.localToGlobal(point, output: output);
  }
}
