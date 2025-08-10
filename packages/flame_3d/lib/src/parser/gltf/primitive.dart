import 'dart:math';
import 'dart:ui' show Color;

import 'package:flame_3d/core.dart';
import 'package:flame_3d/resources.dart' as flame_3d;
import 'package:flame_3d/src/parser/gltf/accessor.dart';
import 'package:flame_3d/src/parser/gltf/gltf_node.dart';
import 'package:flame_3d/src/parser/gltf/gltf_ref.dart';
import 'package:flame_3d/src/parser/gltf/gltf_root.dart';
import 'package:flame_3d/src/parser/gltf/material.dart';
import 'package:flame_3d/src/parser/gltf/morph_target.dart';
import 'package:flame_3d/src/parser/gltf/primitive_mode.dart';

// cSpell:ignore TEXCOORD
// (used in GLTF as the key for texture coordinate attributes)

/// Geometry to be rendered with the given material.
class Primitive extends GltfNode {
  /// The topology type of primitives to render.
  final PrimitiveMode mode;

  /// A plain JSON object, where each key corresponds to a mesh attribute
  /// semantic and each value is the index of the accessor containing
  /// attribute's data.
  ///
  /// Typical keys include: `POSITION`, `NORMAL`, `TEXCOORD_0`, etc.
  final Map<String, int> attributes;

  /// The reference to the accessor that contains the vertex indices.
  /// When this is undefined, the primitive defines non-indexed geometry.
  /// When defined, the accessor **MUST** have `SCALAR` type and an unsigned
  /// integer component type.
  final GltfRef<IntAccessor>? indices;

  /// The reference to the material to apply to this primitive when rendering.
  final GltfRef<Material>? material;

  /// An array of morph targets.
  final List<MorphTarget> targets;

  Primitive({
    required super.root,
    required this.mode,
    required this.attributes,
    required this.indices,
    required this.material,
    required this.targets,
  });

  GltfRef<Vector3Accessor>? get positions => _accessor('POSITION');
  GltfRef<Vector3Accessor>? get normals => _accessor('NORMAL');
  GltfRef<Vector2Accessor>? get texCoords => _accessor('TEXCOORD_0');
  GltfRef<Vector4Accessor>? get joints => _accessor('JOINTS_0');
  GltfRef<Vector4Accessor>? get weights => _accessor('WEIGHTS_0');

  GltfRef<T>? _accessor<T extends GltfNode>(String key) {
    final joints = attributes[key];
    if (joints == null) {
      return null;
    }
    return GltfRef<T>(
      root: root,
      index: joints,
    );
  }

  (List<flame_3d.Vertex>, List<int>) toFlameVertices(
    JointData jointData,
    Matrix4 transform,
  ) {
    assert(mode == PrimitiveMode.triangles);

    final positions = this.positions!.get().typedData();
    final indices =
        this.indices?.get().typedData() ??
        // for non-indexed geometries
        List.generate(positions.length, (i) => i);
    final texCoords = this.texCoords?.get().typedData();
    final normals =
        this.normals?.get().typedData() ??
        flame_3d.Vertex.calculateVertexNormals(positions, indices);

    Vector3? process(Vector3? v) {
      if (v == null) {
        return null;
      }
      return transform.transform3(v.clone());
    }

    final maxIndex = indices.reduce(max);
    final vertices = <flame_3d.Vertex>[];
    for (var i = 0; i <= maxIndex; i++) {
      vertices.add(
        flame_3d.Vertex(
          position: process(positions[i])!,
          texCoord: texCoords?.elementAtOrNull(i) ?? Vector2.zero(),
          normal: process(normals.elementAtOrNull(i)),
          joints: jointData.localizedJoint(i),
          weights: jointData.weight(i),
        ),
      );
    }

    return (vertices, indices);
  }

  flame_3d.Surface toFlameSurface([Matrix4? transform]) {
    final jointData = computeJointData();

    final (vertices, indices) = toFlameVertices(
      jointData,
      transform ?? Matrix4.identity(),
    );

    return flame_3d.Surface(
      vertices: vertices.toList(),
      indices: indices,
      jointMap: jointData.jointMap,
      material:
          material?.get().toFlameMaterial() ??
          flame_3d.SpatialMaterial(
            albedoColor: const Color(0xFFFF00FF),
          ),
    );
  }

  JointData computeJointData() {
    final weights = this.weights?.get().typedData() ?? [];
    // this are the indexes (0, 1, 2, 3) that have any relevance at all
    final relevantIndexes = weights.expand((w) {
      return w.storage.indexed
          .where((e) => e.$2 > 0.0)
          .map((e) => e.$1)
          .toSet();
    }).toSet();

    final joints = this.joints?.get().typedData() ?? [];
    final globalToLocalJointMap = Map.fromEntries(
      joints
          .expand((e) {
            return e.storage.indexed
                .where((e) => relevantIndexes.contains(e.$1))
                .map((e) => e.$2);
          })
          .toSet()
          .indexed
          .map((e) => MapEntry(e.$2.toInt(), e.$1)),
    );

    final localizedJoints = joints.map((joint) {
      return Vector4.array(
        joint.storage.map((e) {
          final index = e.toInt();
          if (index != e) {
            throw StateError('Invalid joint index: $e');
          }
          // TODO(luan): remove this logic entirely once we support arrays
          if (e == 0.0 && globalToLocalJointMap[index] == null) {
            // this must be a 0 weight value that just happens to be id = 0
            return 0.0;
          }
          return globalToLocalJointMap[index]!.toDouble();
        }).toList(),
      );
    }).toList();

    return JointData(
      weights: weights,
      localizedJoints: localizedJoints,
      jointMap: globalToLocalJointMap,
    );
  }

  Primitive.parse(
    GltfRoot root,
    Map<String, Object?> map,
  ) : this(
        root: root,
        mode: PrimitiveMode.parse(map, 'mode') ?? PrimitiveMode.triangles,
        attributes: Parser.mapInt(map, 'attributes') ?? {},
        indices: Parser.ref(root, map, 'indices'),
        material: Parser.ref(root, map, 'material'),
        targets:
            Parser.objectList<MorphTarget>(
              root,
              map,
              'targets',
              MorphTarget.parse,
            ) ??
            [],
      );
}

class JointData {
  final List<Vector4> weights;
  final List<Vector4> localizedJoints;
  final Map<int, int> jointMap;

  JointData({
    required this.weights,
    required this.localizedJoints,
    required this.jointMap,
  });

  Vector4 weight(int index) {
    return weights.elementAtOrNull(index) ?? Vector4.zero();
  }

  Vector4 localizedJoint(int index) {
    return localizedJoints.elementAtOrNull(index) ?? Vector4.zero();
  }
}
