import 'package:flame_3d/src/parser/gltf/gltf_node.dart';
import 'package:flame_3d/src/parser/gltf/gltf_root.dart';

/// A perspective camera containing properties to create a perspective
/// projection matrix.
class CameraPerspective extends GltfNode {
  /// The floating-point aspect ratio of the field of view.
  /// When undefined, the aspect ratio of the rendering viewport **MUST** be
  /// used.
  final double? aspectRatio;

  /// The floating-point vertical field of view in radians.
  /// This value **SHOULD** be less than π.
  final double yFov;

  /// The floating-point distance to the far clipping plane.
  /// When defined, `zFar` **MUST** be greater than `zNear`.
  /// If `zFar` is undefined, client implementations **SHOULD** use
  /// infinite projection matrix.
  final double? zFar;

  /// The floating-point distance to the near clipping plane.
  final double zNear;

  CameraPerspective({
    required super.root,
    required this.aspectRatio,
    required this.yFov,
    required this.zFar,
    required this.zNear,
  });

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
