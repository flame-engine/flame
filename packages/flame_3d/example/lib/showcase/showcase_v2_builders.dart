import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flame_3d/core.dart';
import 'package:flame_3d/model.dart';
import 'package:flame_3d/resources.dart';

/// Procedural PBR maps, equirectangular environment panoramas, HD-2D standee
/// atlases, 32-joint (`> 16`) `CubicSpline` serpent rigs, blend-shape morph
/// crystals, and dual-layer IK/LookAt/SpringBone rigs for Labs 9–12.
class ShowcaseV2Builders() {
  /// `64x64` tangent-space cobblestone normal map.
  late final Texture cobbleNormalTexture = _buildCobbleNormal(64);

  /// `64x64` glTF ORM (`R` = occlusion, `G` = roughness, `B` = metallic).
  late final Texture cobbleOrmTexture = _buildCobbleOrm(64);

  /// `64x64` glowing cyan rune crevices emissive map.
  late final Texture cobbleEmissiveTexture = _buildCobbleEmissive(64);

  /// `128x64` equirectangular sunset/sky reflection panorama.
  late final Texture equirectEnvTexture = _buildEquirectEnv(128, 64);

  /// `32x32` perforated lattice cutout texture for `alphaCutoff` + doubleSided.
  late final Texture perforatedCutoutTexture = _buildPerforatedCutout(32);

  /// `64x64` `2x2` HD-2D standee character sprite atlas.
  late final Texture standeeAtlasTexture = _buildStandeeAtlas(64);

  /// Builds a **32-joint** (`> 16`, up to `64`) undulating serpent spine model
  /// driven by `AnimationInterpolation.cubicSpline` Hermite keyframes.
  Model buildSerpent32BoneModel(StylizedMaterial material) {
    const jointCount = 32;
    const segLen = 0.22;
    const rings = 48;
    const sides = 8;

    final nodes = <int, ModelNode>{};
    final modelJoints = <int, ModelJoint>{};
    final surfaceJointMap = <int, int>{};

    for (var j = 0; j < jointCount; j++) {
      final local = j == 0
          ? Matrix4.identity()
          : Matrix4.translationValues(segLen, 0, 0);
      nodes[j] = ModelNode(
        name: 'Spine_$j',
        nodeIndex: j,
        parentNodeIndex: j == 0 ? null : j - 1,
        transform: local,
        mesh: null,
        joints: const {},
      );
      modelJoints[j] = ModelJoint(
        nodeIndex: j,
        inverseBindMatrix: Matrix4.translationValues(-j * segLen, 0, 0),
      );
      surfaceJointMap[j] = j;
    }

    final pos = <double>[];
    final nrm = <double>[];
    final col = <double>[];
    final occ = <double>[];
    final accent = <double>[];
    final gloss = <double>[];
    final joints = <double>[];
    final weights = <double>[];
    final idx = <int>[];

    const totalLen = (jointCount - 1) * segLen;
    for (var r = 0; r <= rings; r++) {
      final u = r / rings;
      final x = u * totalLen;
      final taper = math.sin(u * math.pi * 0.92 + 0.12).clamp(0.18, 1.0);
      final radius = 0.26 * taper;

      final fJoint = (u * (jointCount - 1)).clamp(0.0, jointCount - 1.0001);
      final j0 = fJoint.floor();
      final j1 = math.min(jointCount - 1, j0 + 1);
      final w1 = fJoint - j0;
      final w0 = 1.0 - w1;

      for (var s = 0; s < sides; s++) {
        final a = (s / sides) * math.pi * 2;
        final cy = math.cos(a);
        final cz = math.sin(a);
        pos.addAll([x, cy * radius, cz * radius]);
        nrm.addAll([0.0, cy, cz]);
        col.addAll([0.18 + 0.65 * u, 0.85 - 0.3 * u, 0.92, 1.0]);
        occ.add(0.55 + 0.45 * (0.5 + 0.5 * cz));
        accent.add(r % 3 == 0 ? 0.9 : 0.1);
        gloss.add(0.65);
        joints.addAll([j0.toDouble(), j1.toDouble(), 0, 0]);
        weights.addAll([w0, w1, 0, 0]);
      }
    }
    for (var r = 0; r < rings; r++) {
      for (var s = 0; s < sides; s++) {
        final sn = (s + 1) % sides;
        final i0 = r * sides + s;
        final i1 = r * sides + sn;
        final i2 = (r + 1) * sides + sn;
        final i3 = (r + 1) * sides + s;
        idx.addAll([i0, i1, i2, i0, i2, i3]);
      }
    }

    final wideBox = Aabb3.minMax(
      Vector3(-1.0, -3.5, -2.5),
      Vector3(totalLen + 1.0, 3.5, 2.5),
    );
    final rawSurf = StylizedMaterial.buildSurface(
      positions: pos,
      normals: nrm,
      colors: col,
      occlusion: occ,
      accent: accent,
      gloss: gloss,
      joints: joints,
      weights: weights,
      indices: idx,
      material: material,
      aabb: wideBox,
    );
    final skinSurf = Surface.fromBuffers(
      vertices: rawSurf.vertexData,
      indices: rawSurf.indices,
      layout: rawSurf.layout,
      material: material,
      jointMap: surfaceJointMap,
      aabb: wideBox,
    );

    nodes[jointCount] = ModelNode(
      name: 'SerpentBody32',
      nodeIndex: jointCount,
      parentNodeIndex: null,
      transform: Matrix4.identity(),
      mesh: Mesh()..addSurface(skinSurf),
      joints: modelJoints,
    );

    final animNodes = <int, NodeAnimation>{};
    for (var j = 0; j < jointCount; j++) {
      final phase = j * 0.35;
      final a0 = 0.16 * math.sin(phase);
      final a1 = 0.16 * math.sin(phase + math.pi * 0.5);
      final a2 = 0.16 * math.sin(phase + math.pi);
      final a3 = 0.16 * math.sin(phase + math.pi * 1.5);
      animNodes[j] = NodeAnimation(
        channels: [
          AnimationController(
            animation: RotationAnimationSpline.from(
              interpolation: AnimationInterpolation.cubicSpline,
              times: const [0.0, 0.5, 1.0, 1.5, 2.0],
              values: [
                Quaternion.axisAngle(Vector3(0, 0, 1), a0),
                Quaternion.axisAngle(Vector3(0, 0, 1), a1),
                Quaternion.axisAngle(Vector3(0, 0, 1), a2),
                Quaternion.axisAngle(Vector3(0, 0, 1), a3),
                Quaternion.axisAngle(Vector3(0, 0, 1), a0),
              ],
            ),
          ),
        ],
      );
    }

    return Model(
      nodes: nodes,
      animations: [ModelAnimation(name: 'Slither', nodes: animNodes)],
    );
  }

  /// Builds a faceted crystal obelisk with 2 blend-shape [MorphTargetData]s and
  /// an animated [MorphWeightsChannel].
  Model buildMorphCrystalModel(Material material) {
    final baseSphere = SphereMesh(
      radius: 0.52,
      segments: 14,
      material: material,
    );
    final baseSurf = baseSphere.surfaces.single;
    final stride = baseSurf.layout.strideInFloats;
    final vCount = baseSurf.vertexCount;
    final vData = baseSurf.vertexData;

    final flareDeltas = Float32List(vCount * 3);
    final spireDeltas = Float32List(vCount * 3);

    for (var i = 0; i < vCount; i++) {
      final px = vData[i * stride];
      final py = vData[i * stride + 1];
      final pz = vData[i * stride + 2];
      final ang = math.atan2(py, px);
      final petal = 0.35 * (0.5 + 0.5 * math.cos(ang * 4.0));
      flareDeltas[i * 3] = px * petal * 1.6;
      flareDeltas[i * 3 + 1] = py * petal * 1.6;
      flareDeltas[i * 3 + 2] = 0.0;

      spireDeltas[i * 3] = -px * 0.28;
      spireDeltas[i * 3 + 1] = -py * 0.28;
      spireDeltas[i * 3 + 2] = pz > 0 ? pz * 1.35 : pz * 0.2;
    }

    final morphSurf = Surface.fromBuffers(
      vertices: Float32List.fromList(vData),
      indices: baseSurf.indices,
      layout: baseSurf.layout,
      material: material,
      aabb: Aabb3.minMax(Vector3.all(-1.6), Vector3.all(1.8)),
      morphTargets: [
        MorphTargetData(name: 'Flare', positionDeltas: flareDeltas),
        MorphTargetData(name: 'Spire', positionDeltas: spireDeltas),
      ],
    );

    final node = ModelNode(
      name: 'CrystalCore',
      nodeIndex: 0,
      parentNodeIndex: null,
      transform: Matrix4.identity(),
      mesh: Mesh()..addSurface(morphSurf),
      joints: const {},
    );

    final breathe = ModelAnimation(
      name: 'Breathe',
      nodes: {
        0: NodeAnimation(
          channels: const [],
          morphWeights: MorphWeightsChannel(
            targetCount: 2,
            interpolation: AnimationInterpolation.cubicSpline,
            times: const [0.0, 0.8, 1.6, 2.4],
            weights: Float32List.fromList(const [
              0.0, 0.0, //
              0.95, 0.15, //
              0.2, 0.95, //
              0.0, 0.0, //
            ]),
          ),
        ),
      },
    );

    return Model(nodes: {0: node}, animations: [breathe]);
  }

  /// Builds a multi-node rig with `Hips`, `Torso`, `Head` (LookAt), `Antenna`
  /// (SpringBone), `Shoulder`->`Elbow`->`Hand` (Two-Bone IK), and `WaveArm`
  /// (masked `AnimationLayer3D`).
  Model buildLayeredIkCharacterModel(Material material) {
    final torsoMesh = CapsuleMesh(
      radius: 0.28,
      height: 0.95,
      material: material,
    );
    final headMesh = CuboidMesh(
      size: Vector3(0.44, 0.44, 0.56),
      material: material,
    );
    final limbMesh = CuboidMesh(
      size: Vector3(0.16, 0.58, 0.16),
      material: material,
    );
    final handMesh = SphereMesh(
      radius: 0.15,
      segments: 10,
      material: material,
    );

    final nodes = <int, ModelNode>{
      0: ModelNode(
        name: 'Hips',
        nodeIndex: 0,
        parentNodeIndex: null,
        transform: Matrix4.rotationX(math.pi / 2),
        mesh: null,
        joints: const {},
      ),
      1: ModelNode(
        name: 'Torso',
        nodeIndex: 1,
        parentNodeIndex: 0,
        transform: Matrix4.translationValues(0, 0.55, 0),
        mesh: torsoMesh,
        joints: const {},
      ),
      2: ModelNode(
        name: 'Head',
        nodeIndex: 2,
        parentNodeIndex: 1,
        transform: Matrix4.translationValues(0, 0.68, 0),
        mesh: headMesh,
        joints: const {},
      ),
      3: ModelNode(
        name: 'Antenna',
        nodeIndex: 3,
        parentNodeIndex: 2,
        transform: Matrix4.translationValues(0, 0.35, 0),
        mesh: limbMesh,
        joints: const {},
      ),
      4: ModelNode(
        name: 'Shoulder',
        nodeIndex: 4,
        parentNodeIndex: 1,
        transform: Matrix4.translationValues(0.36, 0.3, 0),
        mesh: limbMesh,
        joints: const {},
      ),
      5: ModelNode(
        name: 'Elbow',
        nodeIndex: 5,
        parentNodeIndex: 4,
        transform: Matrix4.translationValues(0, 0.62, 0),
        mesh: limbMesh,
        joints: const {},
      ),
      6: ModelNode(
        name: 'Hand',
        nodeIndex: 6,
        parentNodeIndex: 5,
        transform: Matrix4.translationValues(0, 0.62, 0),
        mesh: handMesh,
        joints: const {},
      ),
      7: ModelNode(
        name: 'WaveArm',
        nodeIndex: 7,
        parentNodeIndex: 1,
        transform: Matrix4.translationValues(-0.4, 0.3, 0),
        mesh: limbMesh,
        joints: const {},
      ),
    };

    final baseBounce = ModelAnimation(
      name: 'Bounce',
      nodes: {
        1: NodeAnimation(
          channels: [
            AnimationController(
              animation: TranslationAnimationSpline.from(
                interpolation: AnimationInterpolation.cubicSpline,
                times: const [0.0, 0.6, 1.2],
                values: [
                  Vector3(0, 0.5, 0),
                  Vector3(0, 0.68, 0),
                  Vector3(0, 0.5, 0),
                ],
              ),
            ),
          ],
        ),
      },
    );

    final upperWave = ModelAnimation(
      name: 'UpperWave',
      nodes: {
        7: NodeAnimation(
          channels: [
            AnimationController(
              animation: RotationAnimationSpline.from(
                interpolation: AnimationInterpolation.cubicSpline,
                times: const [0.0, 0.45, 0.9],
                values: [
                  Quaternion.axisAngle(Vector3(0, 0, 1), 0.35),
                  Quaternion.axisAngle(Vector3(0, 0, 1), 1.35),
                  Quaternion.axisAngle(Vector3(0, 0, 1), 0.35),
                ],
              ),
            ),
          ],
        ),
      },
    );

    return Model(nodes: nodes, animations: [baseBounce, upperWave]);
  }

  static Texture _buildCobbleNormal(int size) {
    final bytes = Uint8List(size * size * 4);
    for (var y = 0; y < size; y++) {
      final v = y / size * 4.0;
      for (var x = 0; x < size; x++) {
        final u = x / size * 4.0;
        final rowShift = v.floor().isOdd ? 0.5 : 0.0;
        final fx = (u + rowShift) - (u + rowShift).floorToDouble() - 0.5;
        final fy = v - v.floorToDouble() - 0.5;
        final r2 = fx * fx + fy * fy;
        var nx = 0.0;
        var ny = 0.0;
        var nz = 1.0;
        if (r2 < 0.2) {
          nx = fx * 1.65;
          ny = fy * 1.65;
          nz = math.sqrt(math.max(0.05, 1.0 - nx * nx - ny * ny));
        }
        final i = (y * size + x) * 4;
        bytes
          ..[i] = ((nx * 0.5 + 0.5).clamp(0.0, 1.0) * 255).round()
          ..[i + 1] = ((ny * 0.5 + 0.5).clamp(0.0, 1.0) * 255).round()
          ..[i + 2] = ((nz * 0.5 + 0.5).clamp(0.0, 1.0) * 255).round()
          ..[i + 3] = 255;
      }
    }
    return Texture(
      ByteData.sublistView(bytes),
      width: size,
      height: size,
      mipmaps: true,
      sampler: const TextureSampler(
        minFilter: TextureFilter.linear,
        magFilter: TextureFilter.linear,
        mipFilter: TextureFilter.linear,
        wrapU: TextureWrap.repeat,
        wrapV: TextureWrap.repeat,
      ),
    );
  }

  static Texture _buildCobbleOrm(int size) {
    final bytes = Uint8List(size * size * 4);
    for (var y = 0; y < size; y++) {
      final v = y / size * 4.0;
      for (var x = 0; x < size; x++) {
        final u = x / size * 4.0;
        final rowShift = v.floor().isOdd ? 0.5 : 0.0;
        final fx = (u + rowShift) - (u + rowShift).floorToDouble() - 0.5;
        final fy = v - v.floorToDouble() - 0.5;
        final r = math.sqrt(fx * fx + fy * fy);
        final isStone = r < 0.42;
        final isStud = r < 0.14;
        final ao = isStone ? 245 : 85;
        final rough = isStud ? 48 : (isStone ? 165 : 235);
        final metal = isStud ? 240 : 18;
        final i = (y * size + x) * 4;
        bytes
          ..[i] = ao
          ..[i + 1] = rough
          ..[i + 2] = metal
          ..[i + 3] = 255;
      }
    }
    return Texture(
      ByteData.sublistView(bytes),
      width: size,
      height: size,
      mipmaps: true,
      sampler: const TextureSampler(
        minFilter: TextureFilter.linear,
        magFilter: TextureFilter.linear,
        mipFilter: TextureFilter.linear,
        wrapU: TextureWrap.repeat,
        wrapV: TextureWrap.repeat,
      ),
    );
  }

  static Texture _buildCobbleEmissive(int size) {
    final bytes = Uint8List(size * size * 4);
    for (var y = 0; y < size; y++) {
      final v = y / size * 4.0;
      for (var x = 0; x < size; x++) {
        final u = x / size * 4.0;
        final rowShift = v.floor().isOdd ? 0.5 : 0.0;
        final fx = (u + rowShift) - (u + rowShift).floorToDouble() - 0.5;
        final fy = v - v.floorToDouble() - 0.5;
        final r = math.sqrt(fx * fx + fy * fy);
        final glow = ((r - 0.36) / 0.12).clamp(0.0, 1.0);
        final i = (y * size + x) * 4;
        bytes
          ..[i] = (glow * 30).round()
          ..[i + 1] = (glow * 220).round()
          ..[i + 2] = (glow * 255).round()
          ..[i + 3] = 255;
      }
    }
    return Texture(
      ByteData.sublistView(bytes),
      width: size,
      height: size,
      sampler: const TextureSampler(
        minFilter: TextureFilter.linear,
        magFilter: TextureFilter.linear,
        wrapU: TextureWrap.repeat,
        wrapV: TextureWrap.repeat,
      ),
    );
  }

  static Texture _buildEquirectEnv(int w, int h) {
    final bytes = Uint8List(w * h * 4);
    for (var y = 0; y < h; y++) {
      final elev = 1.0 - (y + 0.5) / h * 2.0; // +1 zenith, -1 nadir
      for (var x = 0; x < w; x++) {
        final az = (x / w) * math.pi * 2.0;
        final cosAz = math.cos(az - 1.1) * (1.0 - (elev - 0.25).abs());
        final sunGlow = math.pow(math.max(0.0, cosAz), 8).toDouble();
        double r;
        double g;
        double b;
        if (elev >= 0) {
          final t = math.pow(elev, 0.6).toDouble();
          r = 0.95 * (1 - t) + 0.08 * t + sunGlow * 0.8;
          g = 0.58 * (1 - t) + 0.35 * t + sunGlow * 0.6;
          b = 0.42 * (1 - t) + 0.88 * t + sunGlow * 0.3;
        } else {
          final t = (-elev).clamp(0.0, 1.0);
          r = 0.24 * (1 - t) + 0.06 * t;
          g = 0.28 * (1 - t) + 0.09 * t;
          b = 0.36 * (1 - t) + 0.14 * t;
        }
        final i = (y * w + x) * 4;
        bytes
          ..[i] = (r.clamp(0.0, 1.0) * 255).round()
          ..[i + 1] = (g.clamp(0.0, 1.0) * 255).round()
          ..[i + 2] = (b.clamp(0.0, 1.0) * 255).round()
          ..[i + 3] = 255;
      }
    }
    return Texture(
      ByteData.sublistView(bytes),
      width: w,
      height: h,
      sampler: TextureSampler.linear,
    );
  }

  static Texture _buildPerforatedCutout(int size) {
    final bytes = Uint8List(size * size * 4);
    for (var y = 0; y < size; y++) {
      for (var x = 0; x < size; x++) {
        final border = x < 3 || y < 3 || x >= size - 3 || y >= size - 3;
        final cx = ((x % 8) - 3.5).abs();
        final cy = ((y % 8) - 3.5).abs();
        final hole = !border && (cx + cy < 3.2);
        final i = (y * size + x) * 4;
        bytes
          ..[i] = 245
          ..[i + 1] = 200
          ..[i + 2] = 95
          ..[i + 3] = hole ? 0 : 255;
      }
    }
    return Texture(
      ByteData.sublistView(bytes),
      width: size,
      height: size,
    );
  }

  static Texture _buildStandeeAtlas(int size) {
    final half = size ~/ 2;
    final bytes = Uint8List(size * size * 4);
    const palettes = [
      (56, 189, 248), // Cyan Knight
      (244, 114, 182), // Rose Mage
      (52, 211, 153), // Emerald Ranger
      (251, 191, 36), // Solar Paladin
    ];
    for (var y = 0; y < size; y++) {
      final qy = y ~/ half;
      final ly = (y % half) / (half - 1); // 0 top .. 1 bottom
      for (var x = 0; x < size; x++) {
        final qx = x ~/ half;
        final lx = ((x % half) / (half - 1)) * 2.0 - 1.0; // -1..+1
        final tile = qy * 2 + qx;
        final pal = palettes[tile];

        final head = lx * lx + (ly - 0.24) * (ly - 0.24) * 4.0 < 0.14;
        final cloak =
            ly >= 0.36 && ly <= 0.95 && lx.abs() < (0.2 + (ly - 0.36) * 0.65);
        final isVisor = ly >= 0.2 && ly <= 0.27 && lx.abs() < 0.18;
        final opaque = head || cloak;
        final i = (y * size + x) * 4;
        if (!opaque) {
          bytes
            ..[i] = 0
            ..[i + 1] = 0
            ..[i + 2] = 0
            ..[i + 3] = 0;
        } else if (isVisor) {
          bytes
            ..[i] = 255
            ..[i + 1] = 250
            ..[i + 2] = 210
            ..[i + 3] = 255;
        } else {
          final shade = (1.1 - ly * 0.35).clamp(0.6, 1.0);
          bytes
            ..[i] = (pal.$1 * shade).round()
            ..[i + 1] = (pal.$2 * shade).round()
            ..[i + 2] = (pal.$3 * shade).round()
            ..[i + 3] = 255;
        }
      }
    }
    return Texture(
      ByteData.sublistView(bytes),
      width: size,
      height: size,
    );
  }
}
