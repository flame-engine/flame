import 'package:flame_3d/game.dart';
import 'package:flame_3d/graphics.dart';
import 'package:flame_3d/resources.dart';

/// {@template light}
/// A [Resource] that represents a light source that changes how the scene is
/// rendered.
///
/// This class isn't a true resource, it does not upload it self to the GPU.
/// Instead, it is used to modify how meshes are uploaded.
/// {@endtemplate}
class Light extends Resource<void> {
  /// {@macro light}
  Light({
    required this.position,
  }): super(null);

  // TODO(luan): Add more attributes and light types
  final Vector3 position;

  void bind(GraphicsDevice device) {
    device.bindLight(this);
  }
}
