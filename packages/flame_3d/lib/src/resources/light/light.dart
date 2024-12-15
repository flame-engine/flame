import 'package:flame_3d/game.dart';
import 'package:flame_3d/resources.dart';

/// {@template light}
/// A [Resource] that represents a light source that is positioned in the scene
/// and changes how other objects are rendered.
///
/// This class isn't a true resource, it does not upload it self to the GPU.
/// Instead, it is used to modify how other resources are uploaded.
///
/// {@endtemplate}
class Light extends Resource<void> {
  final Transform3D transform;
  final LightSource source;

  /// {@macro light}
  Light({
    required this.transform,
    required this.source,
  }) : super(null);

  void apply(int index, Shader shader) {
    shader.setVector4('Light[$index].position', vec4(transform.position, 1.0));
    shader.setColor('Light[$index].color', source.color);
    shader.setVector4('Light[$index].intensity', Vector4.all(source.intensity));
  }

  Vector4 vec4(Vector3 v, double w) => Vector4(v.x, v.y, v.z, w);
}
