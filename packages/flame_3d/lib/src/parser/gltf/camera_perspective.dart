import 'package:flame_3d/src/parser/gltf/gltf_node.dart';
import 'package:flame_3d/src/parser/gltf/gltf_root.dart';

/// A perspective camera containing properties to create a perspective
/// projection matrix.
class CameraPerspective({
  required super.root,

  /// The floating-point aspect ratio of the field of view.
  /// When undefined, the aspect ratio of the rendering viewport **MUST** be
  /// used.
  required final double? aspectRatio,

  /// The floating-point vertical field of view in radians.
  /// This value **SHOULD** be less than π.
  required final double yFov,

  /// The floating-point distance to the far clipping plane.
  /// When defined, `zFar` **MUST** be greater than `zNear`.
  /// If `zFar` is undefined, client implementations **SHOULD** use
  /// infinite projection matrix.
  required final double? zFar,

  /// The floating-point distance to the near clipping plane.
  required final double zNear,
}) extends GltfNode {
  CameraPerspective.parse(
    GltfRoot root,
    Map<String, Object?> map,
  ) : this(
        root: root,
        aspectRatio: Parser.float(map, 'aspectRatio'),
        yFov: Parser.float(map, 'yfov')!, // cSpell:ignore yfov
        zFar: Parser.float(map, 'zfar'), // cSpell:ignore zfar
        zNear: Parser.float(map, 'znear')!, // cSpell:ignore znear
      );
}
