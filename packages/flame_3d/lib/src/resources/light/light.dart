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

  void apply(Shader shader) {
    shader.setVector3('Light.position', transform.position);
    // apply additional parameters
    source.apply(shader);
  }

  static UniformSlot shaderSlot = UniformSlot.value('Light', {'position'});
}
