import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' show Color;

import 'package:flame_3d/core.dart';
import 'package:flame_3d/graphics.dart' as flame_gfx;
import 'package:flame_3d/resources.dart' as flame_3d;
import 'package:flame_3d/src/parser/gltf/accessor.dart';
import 'package:flame_3d/src/parser/gltf/accessor_type.dart';
import 'package:flame_3d/src/parser/gltf/gltf_node.dart';
import 'package:flame_3d/src/parser/gltf/gltf_ref.dart';
import 'package:flame_3d/src/parser/gltf/gltf_root.dart';
import 'package:flame_3d/src/parser/gltf/material.dart';
import 'package:flame_3d/src/parser/gltf/morph_target.dart';
import 'package:flame_3d/src/parser/gltf/primitive_mode.dart';

// cSpell:ignore TEXCOORD

/// Geometry to be rendered with the given material.
class Primitive({
  required super.root,
  required final PrimitiveMode mode,
  required final Map<String, int> attributes,
  required final GltfRef<IntAccessor>? indices,
  required final GltfRef<Material>? material,
  required final List<MorphTarget> targets,
}) extends GltfNode {
  static const int _maxJointsPerSurface = 64;

  GltfRef<Vector3Accessor>? get positions => _accessor('POSITION');
  GltfRef<Vector3Accessor>? get normals => _accessor('NORMAL');
  GltfRef<Vector2Accessor>? get texCoords => _accessor('TEXCOORD_0');
  GltfRef<RawAccessor>? get colors => _accessor('COLOR_0');
  GltfRef<Vector4Accessor>? get joints => _accessor('JOINTS_0');
  GltfRef<Vector4Accessor>? get weights => _accessor('WEIGHTS_0');

  GltfRef<T>? _accessor<T extends GltfNode>(String key) {
    final idx = attributes[key];
    if (idx == null) {
      return null;
    }
    return GltfRef<T>(
      root: root,
      index: idx,
    );
  }

  /// Builds a single [flame_3d.Surface] (or the first sub-surface if joint
  /// partitioning was required).
  flame_3d.Surface toFlameSurface([Matrix4? transform]) {
    return toFlameSurfaces(transform).first;
  }

  /// Converts this glTF primitive directly into typed GPU vertex/index buffers
  /// with zero intermediate `Vertex` heap allocations, automatically splitting
  /// into multiple `<= 64`-joint sub-surfaces if more than 64 bones influence
  /// the primitive.
  List<flame_3d.Surface> toFlameSurfaces([Matrix4? transform]) {
    assert(mode == PrimitiveMode.triangles);

    final posList = positions!.get().typedData();
    final rawIndices =
        indices?.get().typedData() ??
        List<int>.generate(posList.length, (i) => i);
    final uvList = texCoords?.get().typedData();
    final nrmList =
        normals?.get().typedData() ??
        flame_3d.Vertex.calculateVertexNormals(posList, rawIndices);
    final colorList = _readVertexColors(posList.length);
    final weightList = weights?.get().typedData();
    final jointList = joints?.get().typedData();

    final maxIdx = rawIndices.isEmpty ? -1 : rawIndices.reduce(math.max);
    final vertCount = maxIdx + 1;
    if (vertCount <= 0) {
      return [
        flame_3d.Surface.fromBuffers(
          vertices: Float32List(0),
          indices: Uint16List(0),
          material: _resolveMaterial(),
        ),
      ];
    }

    final morphList = _extractMorphTargets(vertCount, transform);
    final mat = _resolveMaterial();

    // Check how many unique non-zero joints influence this primitive.
    final uniqueJoints = <int>{};
    if (weightList != null && jointList != null) {
      for (var v = 0; v < vertCount && v < jointList.length; v++) {
        final w = v < weightList.length ? weightList[v] : null;
        final j = jointList[v];
        if (w == null) {
          continue;
        }
        if (w.x > 0) {
          uniqueJoints.add(j.x.toInt());
        }
        if (w.y > 0) {
          uniqueJoints.add(j.y.toInt());
        }
        if (w.z > 0) {
          uniqueJoints.add(j.z.toInt());
        }
        if (w.w > 0) {
          uniqueJoints.add(j.w.toInt());
        }
      }
    }

    if (uniqueJoints.length <= _maxJointsPerSurface) {
      return [
        _packSubSurface(
          vertIndices: null,
          triIndices: rawIndices,
          vertCount: vertCount,
          posList: posList,
          uvList: uvList,
          colorList: colorList,
          nrmList: nrmList,
          jointList: jointList,
          weightList: weightList,
          morphList: morphList,
          transform: transform,
          material: mat,
        ),
      ];
    }

    // Partition triangles into batches that each reference `<= 64` joints.
    final surfaces = <flame_3d.Surface>[];
    final batchTris = <int>[];
    final batchJoints = <int>{};
    final triJoints = <int>{};

    void flushBatch() {
      if (batchTris.isEmpty) {
        return;
      }
      final remap = <int, int>{};
      final usedVerts = <int>[];
      final localTris = <int>[];
      for (final oldV in batchTris) {
        final nextV = remap.putIfAbsent(oldV, () {
          final id = usedVerts.length;
          usedVerts.add(oldV);
          return id;
        });
        localTris.add(nextV);
      }
      surfaces.add(
        _packSubSurface(
          vertIndices: usedVerts,
          triIndices: localTris,
          vertCount: usedVerts.length,
          posList: posList,
          uvList: uvList,
          colorList: colorList,
          nrmList: nrmList,
          jointList: jointList,
          weightList: weightList,
          morphList: _sliceMorphTargets(morphList, usedVerts),
          transform: transform,
          material: mat,
        ),
      );
      batchTris.clear();
      batchJoints.clear();
    }

    for (var t = 0; t + 2 < rawIndices.length; t += 3) {
      triJoints.clear();
      for (var c = 0; c < 3; c++) {
        final v = rawIndices[t + c];
        if (weightList != null &&
            jointList != null &&
            v < weightList.length &&
            v < jointList.length) {
          final w = weightList[v];
          final j = jointList[v];
          if (w.x > 0) {
            triJoints.add(j.x.toInt());
          }
          if (w.y > 0) {
            triJoints.add(j.y.toInt());
          }
          if (w.z > 0) {
            triJoints.add(j.z.toInt());
          }
          if (w.w > 0) {
            triJoints.add(j.w.toInt());
          }
        }
      }
      var added = 0;
      for (final j in triJoints) {
        if (!batchJoints.contains(j)) {
          added++;
        }
      }
      if (batchJoints.isNotEmpty &&
          batchJoints.length + added > _maxJointsPerSurface) {
        flushBatch();
      }
      batchJoints.addAll(triJoints);
      batchTris
        ..add(rawIndices[t])
        ..add(rawIndices[t + 1])
        ..add(rawIndices[t + 2]);
    }
    flushBatch();
    return surfaces;
  }

  flame_3d.Material _resolveMaterial() {
    return material?.get().toFlameMaterial() ??
        flame_3d.SpatialMaterial(albedoColor: const Color(0xFFFF00FF));
  }

  flame_3d.Surface _packSubSurface({
    required List<int>? vertIndices,
    required List<int> triIndices,
    required int vertCount,
    required List<Vector3> posList,
    required List<Vector2>? uvList,
    required Float32List? colorList,
    required List<Vector3> nrmList,
    required List<Vector4>? jointList,
    required List<Vector4>? weightList,
    required List<flame_3d.MorphTargetData> morphList,
    required Matrix4? transform,
    required flame_3d.Material material,
  }) {
    final stride = flame_gfx.VertexLayout.standard.strideInFloats;
    final packed = Float32List(vertCount * stride);
    final globalToLocal = <int, int>{};

    int mapJoint(double rawJoint, double weight) {
      if (weight <= 0.0) {
        return 0;
      }
      final idx = rawJoint.toInt();
      if (idx != rawJoint) {
        throw StateError('Invalid joint index: $rawJoint');
      }
      return globalToLocal.putIfAbsent(idx, () => globalToLocal.length);
    }

    final hasTransform = transform != null && !transform.isIdentity();
    final scratchP = Vector3.zero();
    final scratchN = Vector3.zero();

    for (var localIdx = 0; localIdx < vertCount; localIdx++) {
      final srcIdx = vertIndices != null ? vertIndices[localIdx] : localIdx;
      final o = localIdx * stride;

      final p = posList[srcIdx];
      if (hasTransform) {
        scratchP.setFrom(p);
        transform.transform3(scratchP);
        packed[o] = scratchP.x;
        packed[o + 1] = scratchP.y;
        packed[o + 2] = scratchP.z;
      } else {
        packed[o] = p.x;
        packed[o + 1] = p.y;
        packed[o + 2] = p.z;
      }

      if (uvList != null && srcIdx < uvList.length) {
        final uv = uvList[srcIdx];
        packed[o + 3] = uv.x;
        packed[o + 4] = uv.y;
      }

      if (colorList != null && srcIdx * 4 + 3 < colorList.length) {
        final co = srcIdx * 4;
        packed[o + 5] = colorList[co];
        packed[o + 6] = colorList[co + 1];
        packed[o + 7] = colorList[co + 2];
        packed[o + 8] = colorList[co + 3];
      } else {
        packed[o + 5] = 1.0;
        packed[o + 6] = 1.0;
        packed[o + 7] = 1.0;
        packed[o + 8] = 1.0;
      }

      if (srcIdx < nrmList.length) {
        final n = nrmList[srcIdx];
        if (hasTransform) {
          scratchN.setFrom(n);
          transform.transform3(scratchN);
          if (scratchN.length2 > 1e-12) {
            scratchN.normalize();
          }
          packed[o + 9] = scratchN.x;
          packed[o + 10] = scratchN.y;
          packed[o + 11] = scratchN.z;
        } else {
          packed[o + 9] = n.x;
          packed[o + 10] = n.y;
          packed[o + 11] = n.z;
        }
      } else {
        packed[o + 10] = 1.0;
      }

      if (jointList != null &&
          weightList != null &&
          srcIdx < jointList.length &&
          srcIdx < weightList.length) {
        final j = jointList[srcIdx];
        final w = weightList[srcIdx];
        packed[o + 12] = mapJoint(j.x, w.x).toDouble();
        packed[o + 13] = mapJoint(j.y, w.y).toDouble();
        packed[o + 14] = mapJoint(j.z, w.z).toDouble();
        packed[o + 15] = mapJoint(j.w, w.w).toDouble();
        packed[o + 16] = w.x;
        packed[o + 17] = w.y;
        packed[o + 18] = w.z;
        packed[o + 19] = w.w;
      }
    }

    var wide = vertCount > 0xFFFF;
    for (var i = 0; !wide && i < triIndices.length; i++) {
      wide = triIndices[i] >= 0xFFFF;
    }
    final typedIndices = wide
        ? Uint32List.fromList(triIndices)
        : Uint16List.fromList(triIndices);

    return flame_3d.Surface.fromBuffers(
      vertices: packed,
      indices: typedIndices,
      jointMap: globalToLocal.isEmpty ? null : globalToLocal,
      morphTargets: morphList,
      material: material,
    );
  }

  Float32List? _readVertexColors(int expectedCount) {
    final accRef = colors;
    if (accRef == null) {
      return null;
    }
    final raw = accRef.get();
    final out = Float32List(expectedCount * 4);
    if (raw.type == AccessorType.vec4) {
      final list = raw.asVector4().typedData();
      final len = math.min(expectedCount, list.length);
      for (var i = 0; i < len; i++) {
        final c = list[i];
        out[i * 4] = c.x.clamp(0.0, 1.0);
        out[i * 4 + 1] = c.y.clamp(0.0, 1.0);
        out[i * 4 + 2] = c.z.clamp(0.0, 1.0);
        out[i * 4 + 3] = c.w.clamp(0.0, 1.0);
      }
    } else if (raw.type == AccessorType.vec3) {
      final list = raw.asVector3().typedData();
      final len = math.min(expectedCount, list.length);
      for (var i = 0; i < len; i++) {
        final c = list[i];
        out[i * 4] = c.x.clamp(0.0, 1.0);
        out[i * 4 + 1] = c.y.clamp(0.0, 1.0);
        out[i * 4 + 2] = c.z.clamp(0.0, 1.0);
        out[i * 4 + 3] = 1.0;
      }
    } else {
      return null;
    }
    return out;
  }

  List<flame_3d.MorphTargetData> _extractMorphTargets(
    int vertCount,
    Matrix4? transform,
  ) {
    if (targets.isEmpty) {
      return const [];
    }
    final hasTransform = transform != null && !transform.isIdentity();
    final scratch = Vector3.zero();
    final out = <flame_3d.MorphTargetData>[];

    for (var ti = 0; ti < targets.length; ti++) {
      final t = targets[ti];
      final posRef = t.attributes[MorphTargetType.position];
      if (posRef == null) {
        continue;
      }
      final posVecs = posRef.get().asVector3().typedData();
      final pDeltas = Float32List(vertCount * 3);
      final pCount = math.min(vertCount, posVecs.length);
      for (var i = 0; i < pCount; i++) {
        if (hasTransform) {
          scratch.setFrom(posVecs[i]);
          transform.transform3(scratch);
          pDeltas[i * 3] = scratch.x;
          pDeltas[i * 3 + 1] = scratch.y;
          pDeltas[i * 3 + 2] = scratch.z;
        } else {
          final v = posVecs[i];
          pDeltas[i * 3] = v.x;
          pDeltas[i * 3 + 1] = v.y;
          pDeltas[i * 3 + 2] = v.z;
        }
      }

      Float32List? nDeltas;
      final nrmRef = t.attributes[MorphTargetType.normal];
      if (nrmRef != null) {
        final nrmVecs = nrmRef.get().asVector3().typedData();
        nDeltas = Float32List(vertCount * 3);
        final nCount = math.min(vertCount, nrmVecs.length);
        for (var i = 0; i < nCount; i++) {
          final v = nrmVecs[i];
          nDeltas[i * 3] = v.x;
          nDeltas[i * 3 + 1] = v.y;
          nDeltas[i * 3 + 2] = v.z;
        }
      }
      out.add(
        flame_3d.MorphTargetData(
          name: 'target_$ti',
          positionDeltas: pDeltas,
          normalDeltas: nDeltas,
        ),
      );
    }
    return out;
  }

  List<flame_3d.MorphTargetData> _sliceMorphTargets(
    List<flame_3d.MorphTargetData> source,
    List<int> usedVerts,
  ) {
    if (source.isEmpty) {
      return const [];
    }
    final vLen = usedVerts.length;
    return [
      for (final m in source)
        flame_3d.MorphTargetData(
          name: m.name,
          positionDeltas: Float32List.fromList([
            for (var i = 0; i < vLen; i++) ...[
              m.positionDeltas[usedVerts[i] * 3],
              m.positionDeltas[usedVerts[i] * 3 + 1],
              m.positionDeltas[usedVerts[i] * 3 + 2],
            ],
          ]),
          normalDeltas: m.normalDeltas == null
              ? null
              : Float32List.fromList([
                  for (var i = 0; i < vLen; i++) ...[
                    m.normalDeltas![usedVerts[i] * 3],
                    m.normalDeltas![usedVerts[i] * 3 + 1],
                    m.normalDeltas![usedVerts[i] * 3 + 2],
                  ],
                ]),
        ),
    ];
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
