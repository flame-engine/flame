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
  final Vector3 position;

  final LightSource source;

  /// {@macro light}
  Light({
    required this.position,
    required this.source,
  });

  @override
  void createResource() {}
}
