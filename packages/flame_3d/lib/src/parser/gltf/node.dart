import 'dart:math' as math;

import 'package:flame_3d/core.dart';
import 'package:flame_3d/src/parser/gltf/accessor.dart';
import 'package:flame_3d/src/parser/gltf/camera.dart';
import 'package:flame_3d/src/parser/gltf/gltf_extensions.dart';
import 'package:flame_3d/src/parser/gltf/gltf_node.dart';
import 'package:flame_3d/src/parser/gltf/gltf_ref.dart';
import 'package:flame_3d/src/parser/gltf/gltf_root.dart';
import 'package:flame_3d/src/parser/gltf/mesh.dart';
import 'package:flame_3d/src/parser/gltf/skin.dart';

/// A node in the node hierarchy.
///
/// When the node contains `skin`, all `mesh.primitives` **MUST** contain
/// `JOINTS_0` and `WEIGHTS_0` attributes.
///
/// A node **MAY** have either a `matrix` or any combination of
/// `translation`/`rotation`/`scale` (TRS) properties.
class Node({
  required super.root,

  /// The reference to the camera referenced by this node.
  required final GltfRef<Camera>? camera,

  /// The references to this node's children.
  required final List<GltfRef<Node>> children,

  /// The reference to skeleton nodes.
  required final List<GltfRef<Node>> skeletons,

  /// The reference to the skin referenced by this node.
  required final GltfRef<Skin>? skin,

  /// Name used when this node is a joint in a skin.
  required final String? jointName,

  /// A floating-point 4x4 transformation matrix stored in column-major order.
  required final Matrix4? matrix,

  /// The reference to the mesh in this node.
  required final GltfRef<Mesh>? mesh,

  /// The node's unit quaternion rotation in the order (x, y, z, w).
  required final Quaternion? rotation,

  /// The node's non-uniform scale along the x, y, and z axes.
  required final Vector3? scale,

  /// The node's translation along the x, y, and z axes.
  required final Vector3? translation,

  /// The weights of the instantiated morph target.
  required final List<double>? weights,
  required final String? name,
  final Map<String, Object?>? extensions,
  final Object? extras,
}) extends GltfNode {
  Node.parse(
    GltfRoot root,
    Map<String, Object?> map,
  ) : this(
        root: root,
        camera: Parser.ref(root, map, 'camera'),
        children: Parser.refList(root, map, 'children') ?? [],
        skeletons: Parser.refList(root, map, 'skeletons') ?? [],
        skin: Parser.ref(root, map, 'skin'),
        jointName: Parser.string(map, 'jointName'),
        matrix: Parser.matrix4(root, map, 'matrix'),
        mesh: Parser.ref(root, map, 'mesh'),
        rotation: Parser.quaternion(root, map, 'rotation'),
        scale: Parser.vector3(root, map, 'scale'),
        translation: Parser.vector3(root, map, 'translation'),
        weights: Parser.floatList(map, 'weights'),
        name: Parser.string(map, 'name'),
        extensions: Parser.extensions(map),
        extras: Parser.extras(map),
      );

  /// Index into [GltfRoot.punctualLights] when `KHR_lights_punctual` is
  /// attached to this node, or `null`.
  int? get punctualLightIndex {
    final ext = extensions?['KHR_lights_punctual'];
    if (ext is Map<String, Object?>) {
      return Parser.integer(ext, 'light');
    }
    return null;
  }

  /// Resolved [KhrPunctualLight] attached to this node via
  /// `KHR_lights_punctual`, or `null`.
  KhrPunctualLight? get punctualLight {
    final idx = punctualLightIndex;
    if (idx == null || idx < 0 || idx >= root.punctualLights.length) {
      return null;
    }
    return root.punctualLights[idx];
  }

  /// Local instance transforms parsed from `EXT_mesh_gpu_instancing`
  /// (`TRANSLATION`, `ROTATION`, `SCALE` accessors), empty when the extension
  /// is absent.
  late final List<Matrix4> gpuInstanceTransforms = _parseGpuInstances();

  List<Matrix4> _parseGpuInstances() {
    final ext = extensions?['EXT_mesh_gpu_instancing'];
    if (ext is! Map<String, Object?>) {
      return const [];
    }
    final attrs = ext['attributes'];
    if (attrs is! Map<String, Object?>) {
      return const [];
    }
    final tIdx = Parser.integer(attrs, 'TRANSLATION');
    final rIdx = Parser.integer(attrs, 'ROTATION');
    final sIdx = Parser.integer(attrs, 'SCALE');
    if (tIdx == null && rIdx == null && sIdx == null) {
      return const [];
    }

    final translations = tIdx != null
        ? root.resolve<Vector3Accessor>(tIdx).typedData()
        : null;
    final rotations = rIdx != null
        ? root.resolve<QuaternionAccessor>(rIdx).typedData()
        : null;
    final scales = sIdx != null
        ? root.resolve<Vector3Accessor>(sIdx).typedData()
        : null;

    final count = math.max(
      translations?.length ?? 0,
      math.max(rotations?.length ?? 0, scales?.length ?? 0),
    );
    if (count <= 0) {
      return const [];
    }

    final zero = Vector3.zero();
    final identityQ = Quaternion.identity();
    final unitScale = Vector3.all(1.0);
    return List<Matrix4>.unmodifiable([
      for (var i = 0; i < count; i++)
        Matrix4.compose(
          translations != null && i < translations.length
              ? translations[i]
              : zero,
          rotations != null && i < rotations.length
              ? (rotations[i].clone()..normalize())
              : identityQ,
          scales != null && i < scales.length ? scales[i] : unitScale,
        ),
    ]);
  }

  Matrix4? get _trs {
    if (translation == null && rotation == null && scale == null) {
      return null;
    }
    return Matrix4.compose(
      translation ?? Vector3.zero(),
      rotation ?? Quaternion.identity(),
      scale ?? Vector3.all(1.0),
    );
  }

  Matrix4 get transform => matrix ?? _trs ?? Matrix4.identity();
}
