import 'package:flame_3d/src/parser/gltf/gltf_node.dart';
import 'package:flame_3d/src/parser/gltf/gltf_root.dart';

/// An orthographic camera containing properties to create an orthographic
/// projection matrix.
class CameraOrthographic extends GltfNode {
  /// The floating-point horizontal magnification of the view.
  /// This value **MUST NOT** be equal to zero.
  /// This value **SHOULD NOT** be negative.
  final double xMag;

  /// The floating-point vertical magnification of the view.
  /// This value **MUST NOT** be equal to zero.
  /// This value **SHOULD NOT** be negative.
  final double yMag;

  /// The floating-point distance to the far clipping plane.
  /// This value **MUST NOT** be equal to zero.
  /// `zFar` **MUST** be greater than `zNear`.
  final double xFar;

  /// The floating-point distance to the near clipping plane.
  final double zNear;

  CameraOrthographic({
    required super.root,
    required this.xMag,
    required this.yMag,
    required this.xFar,
    required this.zNear,
  });

  CameraOrthographic.parse(
    GltfRoot root,
    Map<String, Object?> map,
  ) : this(
        root: root,
        xMag: Parser.float(map, 'xmag')!, // cSpell:ignore xmag
        yMag: Parser.float(map, 'ymag')!, // cSpell:ignore ymag
        xFar: Parser.float(map, 'zfar')!, // cSpell:ignore zfar
        zNear: Parser.float(map, 'znear')!, // cSpell:ignore znear
      );
}
