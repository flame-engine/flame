import 'package:flame_3d/src/parser/gltf/camera_orthographic.dart';
import 'package:flame_3d/src/parser/gltf/camera_perspective.dart';
import 'package:flame_3d/src/parser/gltf/camera_type.dart';
import 'package:flame_3d/src/parser/gltf/gltf_node.dart';
import 'package:flame_3d/src/parser/gltf/gltf_root.dart';

/// A camera's projection.
///
/// A node **MAY** reference a camera to apply a transform to place the camera
/// in the scene.
class Camera extends GltfNode {
  /// Specifies if the camera uses a perspective or orthographic projection.
  /// Based on this, either the camera's `perspective` or `orthographic`
  /// property **MUST** be defined.
  final CameraType type;

  /// An orthographic camera containing properties to create an orthographic
  /// projection matrix.
  /// This property **MUST NOT** be defined when `perspective` is defined.
  final CameraOrthographic? orthographic;

  /// A perspective camera containing properties to create a perspective
  /// projection matrix.
  /// This property **MUST NOT** be defined when `orthographic` is defined.
  final CameraPerspective? perspective;

  Camera({
    required super.root,
    required this.type,
    required this.orthographic,
    required this.perspective,
  });

  Camera.parse(
    GltfRoot root,
    Map<String, Object?> map,
  ) : this(
        root: root,
        type: CameraType.parse(map, 'type')!,
        orthographic: Parser.object(
          root,
          map,
          'orthographic',
          CameraOrthographic.parse,
        ),
        perspective: Parser.object(
          root,
          map,
          'perspective',
          CameraPerspective.parse,
        ),
      );
}
