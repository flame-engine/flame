import 'dart:convert';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flame_3d/collisions.dart';
import 'package:flame_3d/components.dart';
import 'package:flame_3d/core.dart';
import 'package:flame_3d/effects.dart';
import 'package:flame_3d/graphics.dart';
import 'package:flame_3d/input.dart';
import 'package:flame_3d/model.dart';
import 'package:flame_3d/navigation.dart';
import 'package:flame_3d/resources.dart';

/// Interactive 3D crystal totem exercising [TapCallbacks3D],
/// [HoverCallbacks3D], [DragCallbacks3D] (3D ray-plane dragging), and
/// [FixedTransformInterpolation3D].
class InteractiveCrystalTotem3D({
  required super.mesh,
  super.position,
  super.rotation,
  super.scale,
  super.color,
}) extends MeshComponent
    with
        TapCallbacks3D,
        HoverCallbacks3D,
        DragCallbacks3D,
        FixedTransformInterpolation3D {
  this {
    dragPlaneNormal = Vector3(0, 0, 1);
  }

  int tapCount = 0;
  int hoverEnterCount = 0;
  int hoverExitCount = 0;
  int dragUpdateCount = 0;

  @override
  void onTapUp3D(TapUpEvent3D event) {
    tapCount++;
    event.handled = true;
    add(
      SquashStretchEffect3D(
        controller: EffectController(duration: 0.34),
        intensity: 0.36,
        upAxis: Vector3(0, 0, 1),
      ),
    );
    final nextColor = tapCount.isOdd
        ? const ui.Color(0xFF00F5D4)
        : const ui.Color(0xFFFF70A6);
    add(
      ColorTintEffect3D(
        nextColor,
        EffectController(duration: 0.25),
      ),
    );
  }

  @override
  void onHoverEnter3D(HoverEnterEvent3D event) {
    hoverEnterCount++;
    instanceData.x = 0.95;
  }

  @override
  void onHoverExit3D(HoverExitEvent3D event) {
    hoverExitCount++;
    instanceData.x = 0.15;
  }

  @override
  void onDragUpdate3D(DragUpdateEvent3D event) {
    dragUpdateCount++;
    event.handled = true;
    position
      ..x = (position.x + event.worldDelta.x).clamp(1.2, 12.8)
      ..y = (position.y + event.worldDelta.y).clamp(1.2, 12.8);
  }
}

/// 1D X-axis-constrained 3D translation gizmo handle exercising
/// [DragCallbacks3D.dragAxisConstraint].
class AxisGizmoSlider3D({
  required super.mesh,
  super.position,
  super.rotation,
  super.scale,
  super.color,
}) extends MeshComponent with DragCallbacks3D {
  this {
    dragAxisConstraint = Vector3(1, 0, 0);
  }

  int dragMoves = 0;

  @override
  void onDragUpdate3D(DragUpdateEvent3D event) {
    dragMoves++;
    event.handled = true;
    position.x = (position.x + event.worldDelta.x).clamp(4.0, 10.0);
  }
}

/// Physical beacon exercising [CollisionCallbacks3D] (`onCollisionStart3D` /
/// `onCollisionEnd3D`) inside `CollisionSystem3D`.
class CollisionBeacon3D({
  required super.mesh,
  required Shape3D colliderShape,
  super.position,
  super.color,
}) extends MeshComponent with CollisionCallbacks3D {
  this {
    add(Collider3D(shape: colliderShape));
  }

  int collisionStarts = 0;
  int collisionEnds = 0;

  @override
  void onCollisionStart3D(Collider3D other, CollisionManifold3D manifold) {
    collisionStarts++;
    color = const ui.Color(0xFF34D399);
  }

  @override
  void onCollisionEnd3D(Collider3D other) {
    collisionEnds++;
    color = const ui.Color(0xFF38BDF8);
  }
}

/// Procedural models, binary `.glb` scenes, navmeshes, and IBL probes for
/// Labs 13–16 of the `package:flame_3d` testbed.
class ShowcaseV3Builders() {
  /// Procedural sky-dome `SH9` diffuse irradiance + mipmapped reflection probe.
  late final EnvironmentProbe3D skyDomeProbe = EnvironmentProbe3D.skyDome(
    width: 64,
    height: 32,
    zenithColor: const ui.Color(0xFF1D4ED8),
    horizonColor: const ui.Color(0xFF67E8F9),
    upAxis: Vector3(0, 0, 1),
    sunDirection: Vector3(-0.45, -0.55, -0.7),
    sunIntensity: 1.5,
  );

  ///Builds a 5-clip procedural biped/walker [Model] (`Idle`, `Walk`, `Run`,
  /// `StrafeL`, `StrafeR`) with root-motion hips translation and boundary-exact
  /// [AnimationEvent3D] footstep markers.
  Model buildLocomotionBlendModel(Material material) {
    final hipMesh = CuboidMesh(
      size: Vector3(0.42, 0.28, 0.36),
      material: material,
    );
    final legMesh = CuboidMesh(
      size: Vector3(0.16, 0.16, 0.44),
      material: material,
    );

    final nodes = <int, ModelNode>{
      0: ModelNode(
        name: 'Hips',
        nodeIndex: 0,
        parentNodeIndex: null,
        transform: Matrix4.translationValues(0, 0, 0.52),
        mesh: hipMesh,
        joints: const {},
      ),
      1: ModelNode(
        name: 'LeftLeg',
        nodeIndex: 1,
        parentNodeIndex: 0,
        transform: Matrix4.translationValues(-0.14, 0, -0.26),
        mesh: legMesh,
        joints: const {},
      ),
      2: ModelNode(
        name: 'RightLeg',
        nodeIndex: 2,
        parentNodeIndex: 0,
        transform: Matrix4.translationValues(0.14, 0, -0.26),
        mesh: legMesh,
        joints: const {},
      ),
    };

    ModelAnimation buildGaitClip({
      required String name,
      required double duration,
      required double strideSwingRad,
      required double rootForwardDist,
      required double rootStrafeDist,
      List<AnimationEvent3D> events = const [],
    }) {
      final times = [
        0.0,
        duration * 0.25,
        duration * 0.5,
        duration * 0.75,
        duration,
      ];
      Quaternion rotX(double a) => Quaternion.axisAngle(Vector3(1, 0, 0), a);
      final leftRot = RotationAnimationSpline.from(
        interpolation: AnimationInterpolation.linear,
        times: times,
        values: [
          rotX(0),
          rotX(strideSwingRad),
          rotX(0),
          rotX(-strideSwingRad),
          rotX(0),
        ],
      );
      final rightRot = RotationAnimationSpline.from(
        interpolation: AnimationInterpolation.linear,
        times: times,
        values: [
          rotX(0),
          rotX(-strideSwingRad),
          rotX(0),
          rotX(strideSwingRad),
          rotX(0),
        ],
      );
      final rootPos = TranslationAnimationSpline.from(
        interpolation: AnimationInterpolation.linear,
        times: [0.0, duration * 0.5, duration],
        values: [
          Vector3(0, 0, 0.52),
          Vector3(
            rootStrafeDist * 0.5,
            rootForwardDist * 0.5,
            0.52 + strideSwingRad.abs() * 0.06,
          ),
          Vector3(rootStrafeDist, rootForwardDist, 0.52),
        ],
      );

      return ModelAnimation(
        name: name,
        nodes: {
          0: NodeAnimation(
            channels: [AnimationController(animation: rootPos)],
          ),
          1: NodeAnimation(
            channels: [AnimationController(animation: leftRot)],
          ),
          2: NodeAnimation(
            channels: [AnimationController(animation: rightRot)],
          ),
        },
        events: events,
      );
    }

    final idle = buildGaitClip(
      name: 'Idle',
      duration: 1.0,
      strideSwingRad: 0.05,
      rootForwardDist: 0.0,
      rootStrafeDist: 0.0,
    );
    final walk = buildGaitClip(
      name: 'Walk',
      duration: 0.8,
      strideSwingRad: 0.48,
      rootForwardDist: 0.9,
      rootStrafeDist: 0.0,
      events: [
        AnimationEvent3D(time: 0.2, name: 'footstep_l'),
        AnimationEvent3D(time: 0.6, name: 'footstep_r'),
      ],
    );
    final run = buildGaitClip(
      name: 'Run',
      duration: 0.5,
      strideSwingRad: 0.85,
      rootForwardDist: 1.8,
      rootStrafeDist: 0.0,
      events: [
        AnimationEvent3D(time: 0.125, name: 'footstep_l'),
        AnimationEvent3D(time: 0.375, name: 'footstep_r'),
      ],
    );
    final strafeL = buildGaitClip(
      name: 'StrafeL',
      duration: 0.7,
      strideSwingRad: 0.38,
      rootForwardDist: 0.0,
      rootStrafeDist: -0.8,
    );
    final strafeR = buildGaitClip(
      name: 'StrafeR',
      duration: 0.7,
      strideSwingRad: 0.38,
      rootForwardDist: 0.0,
      rootStrafeDist: 0.8,
    );

    return Model(
      nodes: nodes,
      animations: [idle, walk, run, strafeL, strafeR],
    );
  }

  /// Builds a connected multi-elevation plaza + ramp + upper terrace [Mesh]
  /// (`+Z` up) suitable for both rendering and [NavMesh3D.fromMesh].
  Mesh buildSteppedPlazaNavMesh(Material material) {
    // Lower plaza: x in [2..6], y in [2..8], z = 0.05
    // Ramp:        x in [6..8], y in [4..6], z = 0.05 -> 0.65
    // Upper deck:  x in [8..12], y in [2..8], z = 0.65
    final verts = <double>[
      // 0..3: lower south-half [2..6] x [2..4]
      2, 2, 0.05, 6, 2, 0.05, 6, 4, 0.05, 2, 4, 0.05,
      // 4..7: lower mid [2..6] x [4..6] (shares edge (6,4)-(6,6) with ramp!)
      2, 4, 0.05, 6, 4, 0.05, 6, 6, 0.05, 2, 6, 0.05,
      // 8..11: lower north [2..6] x [6..8]
      2, 6, 0.05, 6, 6, 0.05, 6, 8, 0.05, 2, 8, 0.05,
      // 12..15: sloped ramp [6..8] x [4..6], z: 0.05 -> 0.65 (slope ~16.7 deg)
      6, 4, 0.05, 8, 4, 0.65, 8, 6, 0.65, 6, 6, 0.05,
      // 16..19: upper mid [8..12] x [4..6]
      8, 4, 0.65, 12, 4, 0.65, 12, 6, 0.65, 8, 6, 0.65,
      // 20..23: upper north [8..12] x [6..8]
      8, 6, 0.65, 12, 6, 0.65, 12, 8, 0.65, 8, 8, 0.65,
    ];

    const quadCount = 6;
    const stride = 20; // VertexLayout.standard
    final packed = Float32List(quadCount * 4 * stride);
    final indices = Uint16List(quadCount * 6);

    for (var q = 0; q < quadCount; q++) {
      final p0 = Vector3(
        verts[q * 12],
        verts[q * 12 + 1],
        verts[q * 12 + 2],
      );
      final p1 = Vector3(
        verts[q * 12 + 3],
        verts[q * 12 + 4],
        verts[q * 12 + 5],
      );
      final p2 = Vector3(
        verts[q * 12 + 6],
        verts[q * 12 + 7],
        verts[q * 12 + 8],
      );
      final n = (p1 - p0).cross(p2 - p0)..normalize();

      for (var v = 0; v < 4; v++) {
        final src = (q * 4 + v) * 3;
        final dst = (q * 4 + v) * stride;
        packed
          ..[dst] = verts[src]
          ..[dst + 1] = verts[src + 1]
          ..[dst + 2] = verts[src + 2]
          ..[dst + 3] = n.x
          ..[dst + 4] = n.y
          ..[dst + 5] = n.z
          ..[dst + 6] = (v == 1 || v == 2) ? 1.0 : 0.0
          ..[dst + 7] = (v >= 2) ? 1.0 : 0.0
          ..[dst + 8] = 0.85
          ..[dst + 9] = 0.92
          ..[dst + 10] = 1.0
          ..[dst + 11] = 1.0;
      }

      final baseV = q * 4;
      final baseI = q * 6;
      indices
        ..[baseI] = baseV
        ..[baseI + 1] = baseV + 1
        ..[baseI + 2] = baseV + 2
        ..[baseI + 3] = baseV
        ..[baseI + 4] = baseV + 2
        ..[baseI + 5] = baseV + 3;
    }

    return Mesh()..addSurface(
      Surface.fromBuffers(
        vertices: packed,
        indices: indices,
        layout: VertexLayout.standard,
        material: material,
      ),
    );
  }

  /// Synthesizes an in-memory binary `.glb` scene exercising:
  /// - `KHR_lights_punctual` (`point` + `spot` lights),
  /// - `KHR_materials_unlit`,
  /// - `KHR_materials_emissive_strength`,
  /// - `KHR_texture_transform`,
  /// - `KHR_mesh_quantization` (`SHORT` normalized positions),
  /// - `EXT_mesh_gpu_instancing` (8 instanced pillars), and
  /// - per-node `extras` metadata (`{"spawnTag": "obelisk_anchor"}`).
  Uint8List buildProceduralExtendedGlbBytes() {
    final bin = BytesBuilder(copy: false);
    final bufferViews = <Map<String, Object>>[];
    final accessors = <Map<String, Object>>[];

    int addAccessor(
      TypedData data, {
      required int componentType,
      required String type,
      required int count,
      bool normalized = false,
    }) {
      final rem = bin.length % 4;
      if (rem != 0) {
        bin.add(Uint8List(4 - rem));
      }
      final offset = bin.length;
      final raw = data.buffer.asUint8List(
        data.offsetInBytes,
        data.lengthInBytes,
      );
      bin.add(raw);
      final pad = (4 - (raw.length % 4)) % 4;
      if (pad != 0) {
        bin.add(Uint8List(pad));
      }
      final bvIdx = bufferViews.length;
      bufferViews.add({
        'buffer': 0,
        'byteOffset': offset,
        'byteLength': raw.length + pad,
      });
      final accIdx = accessors.length;
      accessors.add({
        'bufferView': bvIdx,
        'componentType': componentType,
        'count': count,
        'type': type,
        if (normalized) 'normalized': true,
      });
      return accIdx;
    }

    // Quantized INT16 normalized octahedron/pyramid (`5` vertices, `6` tris).
    final qPos = Int16List.fromList([
      0, 0, 32767, // apex
      -12000, -12000, 0,
      12000, -12000, 0,
      12000, 12000, 0,
      -12000, 12000, 0,
    ]);
    final norms = Float32List.fromList([
      0,
      0,
      1,
      -0.7,
      -0.7,
      0.2,
      0.7,
      -0.7,
      0.2,
      0.7,
      0.7,
      0.2,
      -0.7,
      0.7,
      0.2,
    ]);
    final uvs = Float32List.fromList([
      0.5,
      0.0,
      0.0,
      1.0,
      1.0,
      1.0,
      1.0,
      0.0,
      0.0,
      0.0,
    ]);
    final indices = Uint16List.fromList([
      0,
      1,
      2,
      0,
      2,
      3,
      0,
      3,
      4,
      0,
      4,
      1,
      1,
      3,
      2,
      1,
      4,
      3,
    ]);

    final posAcc = addAccessor(
      qPos,
      componentType: 5122, // SHORT
      type: 'VEC3',
      count: 5,
      normalized: true,
    );
    final normAcc = addAccessor(
      norms,
      componentType: 5126, // FLOAT
      type: 'VEC3',
      count: 5,
    );
    final uvAcc = addAccessor(
      uvs,
      componentType: 5126,
      type: 'VEC2',
      count: 5,
    );
    final idxAcc = addAccessor(
      indices,
      componentType: 5123, // UNSIGNED_SHORT
      type: 'SCALAR',
      count: indices.length,
    );

    // 8 GPU-instanced pillars around `(9.8, 9.5)` via EXT_mesh_gpu_instancing.
    const instCount = 8;
    final instTrans = Float32List(instCount * 3);
    final instScale = Float32List(instCount * 3);
    for (var i = 0; i < instCount; i++) {
      final a = (i / instCount) * math.pi * 2.0;
      instTrans[i * 3] = 9.8 + math.cos(a) * 1.45;
      instTrans[i * 3 + 1] = 9.5 + math.sin(a) * 1.45;
      instTrans[i * 3 + 2] = 0.08;
      instScale[i * 3] = 0.48;
      instScale[i * 3 + 1] = 0.48;
      instScale[i * 3 + 2] = 0.85 + (i % 3) * 0.22;
    }
    final transAcc = addAccessor(
      instTrans,
      componentType: 5126,
      type: 'VEC3',
      count: instCount,
    );
    final scaleAcc = addAccessor(
      instScale,
      componentType: 5126,
      type: 'VEC3',
      count: instCount,
    );

    final binBytes = bin.takeBytes();
    final gltfJson = <String, Object?>{
      'asset': {'version': '2.0'},
      'extensionsUsed': [
        'KHR_lights_punctual',
        'KHR_materials_unlit',
        'KHR_materials_emissive_strength',
        'KHR_texture_transform',
        'KHR_mesh_quantization',
        'EXT_mesh_gpu_instancing',
      ],
      'buffers': [
        {'byteLength': binBytes.length},
      ],
      'bufferViews': bufferViews,
      'accessors': accessors,
      'materials': [
        {
          'name': 'EmissivePillarMat',
          'pbrMetallicRoughness': {
            'baseColorFactor': [0.22, 0.85, 0.96, 1.0],
            'metallicFactor': 0.55,
            'roughnessFactor': 0.25,
          },
          'emissiveFactor': [0.12, 0.55, 0.85],
          'extensions': {
            'KHR_materials_emissive_strength': {'emissiveStrength': 2.6},
          },
        },
        {
          'name': 'UnlitBeaconMat',
          'pbrMetallicRoughness': {
            'baseColorFactor': [1.0, 0.82, 0.24, 1.0],
          },
          'extensions': {
            'KHR_materials_unlit': <String, Object?>{},
          },
        },
      ],
      'meshes': [
        {
          'name': 'QuantizedShard',
          'primitives': [
            {
              'attributes': {
                'POSITION': posAcc,
                'NORMAL': normAcc,
                'TEXCOORD_0': uvAcc,
              },
              'indices': idxAcc,
              'material': 0,
            },
          ],
        },
        {
          'name': 'UnlitCore',
          'primitives': [
            {
              'attributes': {
                'POSITION': posAcc,
                'NORMAL': normAcc,
                'TEXCOORD_0': uvAcc,
              },
              'indices': idxAcc,
              'material': 1,
            },
          ],
        },
      ],
      'extensions': {
        'KHR_lights_punctual': {
          'lights': [
            {
              'name': 'ShrinePoint',
              'type': 'point',
              'color': [0.36, 0.88, 0.98],
              'intensity': 4.5,
              'range': 6.0,
            },
            {
              'name': 'ShrineSpot',
              'type': 'spot',
              'color': [1.0, 0.72, 0.25],
              'intensity': 6.5,
              'range': 8.0,
              'spot': {'innerConeAngle': 0.18, 'outerConeAngle': 0.52},
            },
          ],
        },
      },
      'nodes': [
        {
          'name': 'InstancedShrineRing',
          'mesh': 0,
          'extensions': {
            'EXT_mesh_gpu_instancing': {
              'attributes': {
                'TRANSLATION': transAcc,
                'SCALE': scaleAcc,
              },
            },
          },
        },
        {
          'name': 'ShrineBeacon',
          'mesh': 1,
          'translation': [9.8, 9.5, 0.35],
          'scale': [0.65, 0.65, 1.25],
          'extras': {'spawnTag': 'obelisk_anchor'},
        },
        {
          'name': 'ShrinePointNode',
          'translation': [9.8, 9.5, 1.9],
          'extensions': {
            'KHR_lights_punctual': {'light': 0},
          },
        },
        {
          'name': 'ShrineSpotNode',
          'translation': [9.8, 9.5, 3.4],
          'rotation': [-0.7071068, 0.0, 0.0, 0.7071068],
          'extensions': {
            'KHR_lights_punctual': {'light': 1},
          },
        },
      ],
      'scenes': [
        {
          'name': 'MainShrineScene',
          'nodes': [0, 1, 2, 3],
        },
      ],
      'scene': 0,
    };

    return _packGlb(gltfJson, binBytes);
  }

  static Uint8List _packGlb(
    Map<String, Object?> gltfJson,
    Uint8List binPayload,
  ) {
    final jsonRaw = utf8.encode(jsonEncode(gltfJson));
    final jsonPad = (4 - (jsonRaw.length % 4)) % 4;
    final jsonChunkLen = jsonRaw.length + jsonPad;

    final binPad = (4 - (binPayload.length % 4)) % 4;
    final binChunkLen = binPayload.length + binPad;

    final totalLen = 12 + 8 + jsonChunkLen + 8 + binChunkLen;
    final out = Uint8List(totalLen);
    final bd = ByteData.sublistView(out);

    out.setRange(0, 4, 'glTF'.codeUnits);
    bd
      ..setUint32(4, 2, Endian.little)
      ..setUint32(8, totalLen, Endian.little)
      ..setUint32(12, jsonChunkLen, Endian.little);
    out
      ..setRange(16, 20, 'JSON'.codeUnits)
      ..setRange(20, 20 + jsonRaw.length, jsonRaw)
      ..fillRange(20 + jsonRaw.length, 20 + jsonChunkLen, 0x20);

    final binOff = 20 + jsonChunkLen;
    bd.setUint32(binOff, binChunkLen, Endian.little);
    out
      ..setRange(binOff + 4, binOff + 8, 'BIN\x00'.codeUnits)
      ..setRange(binOff + 8, binOff + 8 + binPayload.length, binPayload);
    return out;
  }
}
