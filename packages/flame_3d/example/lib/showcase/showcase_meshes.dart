import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flame_3d/core.dart';
import 'package:flame_3d/graphics.dart';
import 'package:flame_3d/model.dart';
import 'package:flame_3d/resources.dart';

/// Procedural textures, stylized meshes, LOD chains, and a multi-joint skinned
/// [Model] built on the fly for the `flame_3d` maximum-feature showcase.
class ShowcaseAssets() {
  /// 16-color accent palette shared by instanced stylized tiles and pillars.
  static const List<ui.Color> accentPalette = [
    ui.Color(0xFFE53935),
    ui.Color(0xFFD81B60),
    ui.Color(0xFF8E24AA),
    ui.Color(0xFF5E35B1),
    ui.Color(0xFF3949AB),
    ui.Color(0xFF1E88E5),
    ui.Color(0xFF039BE5),
    ui.Color(0xFF00ACC1),
    ui.Color(0xFF00897B),
    ui.Color(0xFF43A047),
    ui.Color(0xFF7CB342),
    ui.Color(0xFFC0CA33),
    ui.Color(0xFFFDD835),
    ui.Color(0xFFFFB300),
    ui.Color(0xFFFB8C00),
    ui.Color(0xFFF4511E),
  ];

  /// Clear-coat MatCap sphere texture (`64x64`, linear + mipmaps).
  late final Texture coatMatCap = _buildMatCap(
    size: 64,
    base: const (0.04, 0.06, 0.1),
    highlight: const (0.95, 0.97, 1.0),
    rim: const (0.18, 0.34, 0.56),
    power: 22,
  );

  /// Metallic gold MatCap sphere texture (`64x64`, linear + mipmaps).
  late final Texture goldMatCap = _buildMatCap(
    size: 64,
    base: const (0.34, 0.21, 0.05),
    highlight: const (1.0, 0.92, 0.56),
    rim: const (0.85, 0.58, 0.16),
    power: 12,
  );

  /// Iridescent gem MatCap sphere texture (`64x64`, linear + mipmaps).
  late final Texture gemMatCap = _buildMatCap(
    size: 64,
    base: const (0.08, 0.32, 0.48),
    highlight: const (0.85, 1.0, 1.0),
    rim: const (0.55, 0.25, 0.92),
    power: 28,
  );

  /// Procedural `2x2` decal atlas (`64x64`): crosshair, star, rune diamond,
  /// and chevrons, premultiplied RGBA8.
  late final Texture decalAtlas = _buildDecalAtlas(64);

  /// Procedural `4x4` = 16-frame animated plasma/flame flipbook (`64x64`,
  /// premultiplied RGBA8) for `ParticleMaterial` + `ParticleFlipbook3D`.
  late final Texture flipbookFireTexture = _buildFlipbookFire(64);

  /// Procedural `64x16` streaked glowing plasma strip (`TextureWrap.repeat`)
  /// for textured `RibbonMaterial3D` trails and beams.
  late final Texture ribbonPlasmaTexture = _buildRibbonPlasma(64, 16);

  /// Builds a stylized pillar/tile mesh whose base uses the tint mask and
  /// whose cap uses the accent mask + gloss + gem finial.
  Mesh buildAccentTileMesh(StylizedMaterial material) {
    final pos = <double>[];
    final nrm = <double>[];
    final col = <double>[];
    final occ = <double>[];
    final tint = <double>[];
    final accent = <double>[];
    final emissive = <double>[];
    final gloss = <double>[];
    final idx = <int>[];

    void addBox({
      required double halfX,
      required double halfY,
      required double z0,
      required double z1,
      required (double, double, double) rgb,
      required double aoBottom,
      required double tintMask,
      required double accentMask,
      required double emissiveMask,
      required double glossVal,
    }) {
      const faces = [
        // +X
        (
          (1.0, 0.0, 0.0),
          [
            (1.0, -1.0, 0.0),
            (1.0, 1.0, 0.0),
            (1.0, 1.0, 1.0),
            (1.0, -1.0, 1.0),
          ],
        ),
        // -X
        (
          (-1.0, 0.0, 0.0),
          [
            (-1.0, 1.0, 0.0),
            (-1.0, -1.0, 0.0),
            (-1.0, -1.0, 1.0),
            (-1.0, 1.0, 1.0),
          ],
        ),
        // +Y
        (
          (0.0, 1.0, 0.0),
          [
            (1.0, 1.0, 0.0),
            (-1.0, 1.0, 0.0),
            (-1.0, 1.0, 1.0),
            (1.0, 1.0, 1.0),
          ],
        ),
        // -Y
        (
          (0.0, -1.0, 0.0),
          [
            (-1.0, -1.0, 0.0),
            (1.0, -1.0, 0.0),
            (1.0, -1.0, 1.0),
            (-1.0, -1.0, 1.0),
          ],
        ),
        // +Z
        (
          (0.0, 0.0, 1.0),
          [
            (-1.0, -1.0, 1.0),
            (1.0, -1.0, 1.0),
            (1.0, 1.0, 1.0),
            (-1.0, 1.0, 1.0),
          ],
        ),
      ];
      for (final (n, corners) in faces) {
        final base = pos.length ~/ 3;
        for (final (sx, sy, tz) in corners) {
          pos.addAll([sx * halfX, sy * halfY, z0 + (z1 - z0) * tz]);
          nrm.addAll([n.$1, n.$2, n.$3]);
          col.addAll([rgb.$1, rgb.$2, rgb.$3, 1.0]);
          occ.add(tz < 0.5 ? aoBottom : 1.0);
          tint.add(tintMask);
          accent.add(accentMask);
          emissive.add(emissiveMask);
          gloss.add(glossVal);
        }
        idx.addAll([base, base + 1, base + 2, base, base + 2, base + 3]);
      }
    }

    // Plinth (tinted by instance color).
    addBox(
      halfX: 0.36,
      halfY: 0.36,
      z0: 0.0,
      z1: 0.22,
      rgb: const (0.86, 0.84, 0.8),
      aoBottom: 0.55,
      tintMask: 0.85,
      accentMask: 0.0,
      emissiveMask: 0.0,
      glossVal: 0.25,
    );
    // Accent trim band (colored by `accentPalette` via `packAccentAndFade`).
    addBox(
      halfX: 0.28,
      halfY: 0.28,
      z0: 0.22,
      z1: 0.38,
      rgb: const (0.95, 0.95, 0.98),
      aoBottom: 0.8,
      tintMask: 0.0,
      accentMask: 1.0,
      emissiveMask: 0.12,
      glossVal: 0.65,
    );
    // Gem cap (`gloss > gemThreshold` triggers `gemMatCapTexture`).
    addBox(
      halfX: 0.15,
      halfY: 0.15,
      z0: 0.38,
      z1: 0.58,
      rgb: const (0.9, 0.96, 1.0),
      aoBottom: 0.95,
      tintMask: 0.0,
      accentMask: 0.45,
      emissiveMask: 0.35,
      glossVal: 1.65,
    );

    return Mesh()..addSurface(
      StylizedMaterial.buildSurface(
        positions: pos,
        normals: nrm,
        colors: col,
        occlusion: occ,
        tint: tint,
        accent: accent,
        emissive: emissive,
        gloss: gloss,
        indices: idx,
        material: material,
      ),
    );
  }

  /// Builds a stylized tree mesh with trunk + 2 foliage tiers carrying sway,
  /// per-branch wind phase, and leaf flutter weights (Z-up).
  Mesh buildWindTreeMesh(StylizedMaterial material) {
    final pos = <double>[];
    final nrm = <double>[];
    final col = <double>[];
    final occ = <double>[];
    final sway = <double>[];
    final phase = <double>[];
    final flutter = <double>[];
    final gloss = <double>[];
    final idx = <int>[];

    void addCone({
      required int segs,
      required double rBottom,
      required double rTop,
      required double z0,
      required double z1,
      required (double, double, double) rgb,
      required double sway0,
      required double sway1,
      required double flutterVal,
      required double phaseOffset,
      required double glossVal,
    }) {
      for (var i = 0; i < segs; i++) {
        final a0 = (i / segs) * math.pi * 2;
        final a1 = ((i + 1) / segs) * math.pi * 2;
        final c0 = math.cos(a0);
        final s0 = math.sin(a0);
        final c1 = math.cos(a1);
        final s1 = math.sin(a1);
        final slope = (rBottom - rTop) / math.max(1e-4, z1 - z0);
        final nz = slope / math.sqrt(1 + slope * slope);
        final nr = 1 / math.sqrt(1 + slope * slope);

        final base = pos.length ~/ 3;
        final verts = [
          (c0 * rBottom, s0 * rBottom, z0, c0 * nr, s0 * nr, nz, 0.0, a0),
          (c1 * rBottom, s1 * rBottom, z0, c1 * nr, s1 * nr, nz, 0.0, a1),
          (c1 * rTop, s1 * rTop, z1, c1 * nr, s1 * nr, nz, 1.0, a1),
          (c0 * rTop, s0 * rTop, z1, c0 * nr, s0 * nr, nz, 1.0, a0),
        ];
        for (final v in verts) {
          final t = v.$7;
          pos.addAll([v.$1, v.$2, v.$3]);
          nrm.addAll([v.$4, v.$5, v.$6]);
          col.addAll([rgb.$1, rgb.$2, rgb.$3, 1.0]);
          occ.add(0.62 + 0.38 * t);
          sway.add(sway0 + (sway1 - sway0) * t);
          phase.add((phaseOffset + v.$8 / (math.pi * 2)) % 1.0);
          flutter.add(flutterVal * (0.35 + 0.65 * t));
          gloss.add(glossVal);
        }
        idx.addAll([base, base + 1, base + 2, base, base + 2, base + 3]);
      }
    }

    // Trunk
    addCone(
      segs: 8,
      rBottom: 0.14,
      rTop: 0.09,
      z0: 0.0,
      z1: 0.65,
      rgb: const (0.44, 0.3, 0.2),
      sway0: 0.0,
      sway1: 0.18,
      flutterVal: 0.0,
      phaseOffset: 0.0,
      glossVal: 0.1,
    );
    // Lower canopy
    addCone(
      segs: 10,
      rBottom: 0.48,
      rTop: 0.08,
      z0: 0.48,
      z1: 1.32,
      rgb: const (0.2, 0.56, 0.32),
      sway0: 0.22,
      sway1: 0.72,
      flutterVal: 0.65,
      phaseOffset: 0.15,
      glossVal: 0.28,
    );
    // Upper canopy
    addCone(
      segs: 10,
      rBottom: 0.36,
      rTop: 0.02,
      z0: 1.02,
      z1: 1.85,
      rgb: const (0.28, 0.72, 0.4),
      sway0: 0.55,
      sway1: 1.0,
      flutterVal: 1.0,
      phaseOffset: 0.42,
      glossVal: 0.36,
    );

    return Mesh()..addSurface(
      StylizedMaterial.buildSurface(
        positions: pos,
        normals: nrm,
        colors: col,
        occlusion: occ,
        sway: sway,
        windPhase: phase,
        windFlutter: flutter,
        gloss: gloss,
        indices: idx,
        material: material,
      ),
    );
  }

  /// Builds a crystal tower mesh at a chosen polygonal detail [segments] so
  /// `LodMeshComponent` can switch smoothly across high / mid / low / shadow
  /// tiers (Z-up).
  Mesh buildCrystalTowerLodMesh(
    StylizedMaterial material, {
    required int segments,
    required ui.Color crystalTint,
  }) {
    final pos = <double>[];
    final nrm = <double>[];
    final col = <double>[];
    final occ = <double>[];
    final emissive = <double>[];
    final gloss = <double>[];
    final idx = <int>[];

    void ringSection({
      required double r0,
      required double r1,
      required double z0,
      required double z1,
      required ui.Color c,
      required double em,
      required double gl,
      required double ao0,
    }) {
      final slope = (r0 - r1) / math.max(1e-4, z1 - z0);
      final nz = slope / math.sqrt(1 + slope * slope);
      final nr = 1 / math.sqrt(1 + slope * slope);
      for (var i = 0; i < segments; i++) {
        final a0 = (i / segments) * math.pi * 2;
        final a1 = ((i + 1) / segments) * math.pi * 2;
        final base = pos.length ~/ 3;
        for (final (ang, r, z, ao) in [
          (a0, r0, z0, ao0),
          (a1, r0, z0, ao0),
          (a1, r1, z1, 1.0),
          (a0, r1, z1, 1.0),
        ]) {
          final cs = math.cos(ang);
          final sn = math.sin(ang);
          pos.addAll([cs * r, sn * r, z]);
          nrm.addAll([cs * nr, sn * nr, nz]);
          col.addAll([c.r, c.g, c.b, 1.0]);
          occ.add(ao);
          emissive.add(em);
          gloss.add(gl);
        }
        idx.addAll([base, base + 1, base + 2, base, base + 2, base + 3]);
      }
    }

    ringSection(
      r0: 0.44,
      r1: 0.34,
      z0: 0.0,
      z1: 1.0,
      c: const ui.Color(0xFFD8D4EC),
      em: 0.0,
      gl: 0.35,
      ao0: 0.5,
    );
    ringSection(
      r0: 0.34,
      r1: 0.28,
      z0: 1.0,
      z1: 1.35,
      c: crystalTint,
      em: 0.9,
      gl: 1.2,
      ao0: 0.95,
    );
    ringSection(
      r0: 0.32,
      r1: 0.02,
      z0: 1.35,
      z1: 2.25,
      c: crystalTint,
      em: 0.55,
      gl: 1.8,
      ao0: 0.9,
    );

    return Mesh()..addSurface(
      StylizedMaterial.buildSurface(
        positions: pos,
        normals: nrm,
        colors: col,
        occlusion: occ,
        emissive: emissive,
        gloss: gloss,
        indices: idx,
        material: material,
      ),
    );
  }

  /// Builds a self-contained 3-bone articulated [Model] (`Base` -> `Arm` ->
  /// `ArmTip`) with a 2-joint skinned mesh, a matching skinned
  /// [OutlineMaterial] silhouette model, and 3 named animation clips (`Idle`,
  /// `Swing`, `Spin`) to exercise zero-alloc `AnimationState`,
  /// `crossFadeToByName`, `BoneSocket3D`, and `Model.animatedAabb`.
  ({Model shaded, Model outlined}) buildArticulatedModels({
    required StylizedMaterial bodyMaterial,
    required OutlineMaterial outlineMaterial,
  }) {
    // 2-joint vertical segmented prism along +Z (`z` in `0..2.2`):
    // joint 0 (`Base` at z=0) drives the lower body, joint 1 (`Arm` at z=0.9)
    // bends and twists the upper arm up to `ArmTip` at z=2.1!
    const rings = 7;
    const sides = 8;
    final vertices = <Vertex>[];
    final indices = <int>[];

    for (var r = 0; r <= rings; r++) {
      final t = r / rings;
      final z = t * 2.1;
      final radius = 0.34 * (1.0 - 0.55 * t) + 0.06 * math.sin(t * math.pi * 2);
      final armWeight = ((z - 0.55) / 0.75).clamp(0.0, 1.0);
      final baseWeight = 1.0 - armWeight;
      for (var s = 0; s < sides; s++) {
        final ang = (s / sides) * math.pi * 2;
        final cx = math.cos(ang);
        final cy = math.sin(ang);
        vertices.add(
          Vertex(
            position: Vector3(cx * radius, cy * radius, z),
            normal: Vector3(cx, cy, 0.18).normalized(),
            texCoord: Vector2(s / sides, t),
            color: ui.Color.from(
              alpha: 1.0,
              red: 0.3 + 0.55 * t,
              green: 0.72 - 0.2 * t,
              blue: 0.95,
            ),
            joints: Vector4(0, 1, 0, 0),
            weights: Vector4(baseWeight, armWeight, 0, 0),
          ),
        );
      }
    }
    for (var r = 0; r < rings; r++) {
      for (var s = 0; s < sides; s++) {
        final sn = (s + 1) % sides;
        final i0 = r * sides + s;
        final i1 = r * sides + sn;
        final i2 = (r + 1) * sides + sn;
        final i3 = (r + 1) * sides + s;
        indices.addAll([i0, i1, i2, i0, i2, i3]);
      }
    }

    final wideAabb = Aabb3.minMax(
      Vector3(-2.4, -2.4, -0.3),
      Vector3(2.4, 2.4, 2.8),
    );

    Surface makeSkinnedSurface(Material mat) {
      final raw = Surface(
        vertices: vertices,
        indices: indices,
        material: mat,
        jointMap: const {0: 0, 1: 1},
        calculateNormals: false,
      );
      return Surface.fromBuffers(
        vertices: raw.vertexData,
        indices: raw.indices,
        layout: raw.layout,
        material: mat,
        jointMap: const {0: 0, 1: 1},
        aabb: wideAabb,
      );
    }

    final shadedMesh = Mesh()..addSurface(makeSkinnedSurface(bodyMaterial));
    final outlineMesh = Mesh()..addSurface(makeSkinnedSurface(outlineMaterial));

    final invBind0 = Matrix4.identity();
    final invBind1 = Matrix4.translationValues(0, 0, -0.9);

    Map<int, ModelNode> buildNodes(Mesh skinMesh) => {
      0: ModelNode(
        name: 'Base',
        nodeIndex: 0,
        parentNodeIndex: null,
        transform: Matrix4.identity(),
        mesh: null,
        joints: const {},
      ),
      1: ModelNode(
        name: 'Arm',
        nodeIndex: 1,
        parentNodeIndex: 0,
        transform: Matrix4.translationValues(0, 0, 0.9),
        mesh: null,
        joints: const {},
      ),
      2: ModelNode(
        name: 'ArmTip',
        nodeIndex: 2,
        parentNodeIndex: 1,
        transform: Matrix4.translationValues(0, 0, 1.2),
        mesh: null,
        joints: const {},
      ),
      3: ModelNode(
        name: 'SkinnedMesh',
        nodeIndex: 3,
        parentNodeIndex: null,
        transform: Matrix4.identity(),
        mesh: skinMesh,
        joints: {
          0: ModelJoint(nodeIndex: 0, inverseBindMatrix: invBind0),
          1: ModelJoint(nodeIndex: 1, inverseBindMatrix: invBind1),
        },
      ),
    };

    final idleClip = ModelAnimation(
      name: 'Idle',
      nodes: {
        0: NodeAnimation(
          channels: [
            AnimationController(
              animation: TranslationAnimationSpline.from(
                interpolation: AnimationInterpolation.linear,
                times: const [0.0, 1.0, 2.0],
                values: [
                  Vector3(0, 0, 0),
                  Vector3(0, 0, 0.14),
                  Vector3(0, 0, 0),
                ],
              ),
            ),
          ],
        ),
        1: NodeAnimation(
          channels: [
            AnimationController(
              animation: RotationAnimationSpline.from(
                interpolation: AnimationInterpolation.linear,
                times: const [0.0, 1.0, 2.0],
                values: [
                  Quaternion.axisAngle(Vector3(1, 0, 0), -0.18),
                  Quaternion.axisAngle(Vector3(1, 0, 0), 0.22),
                  Quaternion.axisAngle(Vector3(1, 0, 0), -0.18),
                ],
              ),
            ),
          ],
        ),
      },
    );

    final swingClip = ModelAnimation(
      name: 'Swing',
      nodes: {
        0: NodeAnimation(
          channels: [
            AnimationController(
              animation: RotationAnimationSpline.from(
                interpolation: AnimationInterpolation.linear,
                times: const [0.0, 0.6, 1.2, 1.8],
                values: [
                  Quaternion.axisAngle(Vector3(0, 0, 1), 0.0),
                  Quaternion.axisAngle(Vector3(0, 0, 1), 0.85),
                  Quaternion.axisAngle(Vector3(0, 0, 1), -0.85),
                  Quaternion.axisAngle(Vector3(0, 0, 1), 0.0),
                ],
              ),
            ),
          ],
        ),
        1: NodeAnimation(
          channels: [
            AnimationController(
              animation: RotationAnimationSpline.from(
                interpolation: AnimationInterpolation.linear,
                times: const [0.0, 0.9, 1.8],
                values: [
                  Quaternion.axisAngle(Vector3(0, 1, 0), 0.68),
                  Quaternion.axisAngle(Vector3(0, 1, 0), -0.68),
                  Quaternion.axisAngle(Vector3(0, 1, 0), 0.68),
                ],
              ),
            ),
          ],
        ),
      },
    );

    final spinClip = ModelAnimation(
      name: 'Spin',
      nodes: {
        0: NodeAnimation(
          channels: [
            AnimationController(
              animation: RotationAnimationSpline.from(
                interpolation: AnimationInterpolation.linear,
                times: const [0.0, 0.5, 1.0, 1.5],
                values: [
                  Quaternion.axisAngle(Vector3(0, 0, 1), 0.0),
                  Quaternion.axisAngle(Vector3(0, 0, 1), math.pi * 2 / 3),
                  Quaternion.axisAngle(Vector3(0, 0, 1), math.pi * 4 / 3),
                  Quaternion.axisAngle(Vector3(0, 0, 1), math.pi * 2),
                ],
              ),
            ),
          ],
        ),
        1: NodeAnimation(
          channels: [
            AnimationController(
              animation: RotationAnimationSpline.from(
                interpolation: AnimationInterpolation.linear,
                times: const [0.0, 0.75, 1.5],
                values: [
                  Quaternion.axisAngle(Vector3(1, 0, 0), 0.52),
                  Quaternion.axisAngle(Vector3(1, 0, 0), 0.78),
                  Quaternion.axisAngle(Vector3(1, 0, 0), 0.52),
                ],
              ),
            ),
          ],
        ),
      },
    );

    final clips = [idleClip, swingClip, spinClip];
    return (
      shaded: Model(
        nodes: buildNodes(shadedMesh),
        animations: clips,
      ),
      outlined: Model(
        nodes: buildNodes(outlineMesh),
        animations: clips,
      ),
    );
  }

  /// Builds a genuine 26-float `StylizedMaterial.skinnedVertexLayout` [Model]
  /// (`StylizedMaterial.buildSurface` with `joints`, `weights`, baked
  /// `occlusion`, `tint`, `accent`, `emissive`, `gloss`, and `sway`) plus an
  /// attachable `Crown` node for `hideNodeByName` testing.
  Model buildStylized26SkinnedModel(StylizedMaterial material) {
    const rings = 6;
    const sides = 8;
    final pos = <double>[];
    final nrm = <double>[];
    final col = <double>[];
    final occ = <double>[];
    final tint = <double>[];
    final accent = <double>[];
    final emissive = <double>[];
    final gloss = <double>[];
    final sway = <double>[];
    final joints = <double>[];
    final weights = <double>[];
    final idx = <int>[];

    for (var r = 0; r <= rings; r++) {
      final t = r / rings;
      final z = t * 1.8;
      final radius = 0.38 * (1.0 - 0.45 * t) + 0.08 * math.sin(t * math.pi);
      final w1 = ((z - 0.45) / 0.9).clamp(0.0, 1.0);
      final w0 = 1.0 - w1;
      for (var s = 0; s < sides; s++) {
        final a = (s / sides) * math.pi * 2;
        final cx = math.cos(a);
        final cy = math.sin(a);
        pos.addAll([cx * radius, cy * radius, z]);
        nrm.addAll([cx, cy, 0.2]);
        col.addAll([0.88, 0.9, 0.96, 1.0]);
        occ.add(0.45 + 0.55 * t);
        tint.add(1.0 - t);
        accent.add(s.isEven ? 0.85 : 0.15);
        emissive.add(r == rings - 1 ? 0.95 : 0.0);
        gloss.add(0.35 + 1.15 * t);
        sway.add(0.25 * t);
        joints.addAll([0, 1, 0, 0]);
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
      Vector3(-1.8, -1.8, -0.2),
      Vector3(1.8, 1.8, 2.6),
    );
    final skinSurface = StylizedMaterial.buildSurface(
      positions: pos,
      normals: nrm,
      colors: col,
      occlusion: occ,
      tint: tint,
      accent: accent,
      emissive: emissive,
      gloss: gloss,
      sway: sway,
      joints: joints,
      weights: weights,
      indices: idx,
      material: material,
      aabb: wideBox,
    )..jointMap = const {0: 0, 1: 1};

    final skinMesh = Mesh()..addSurface(skinSurface);
    final crownMesh = ConeMesh(
      radius: 0.26,
      height: 0.42,
      segments: 6,
      material: material,
    );

    final nodes = <int, ModelNode>{
      0: ModelNode(
        name: 'Root',
        nodeIndex: 0,
        parentNodeIndex: null,
        transform: Matrix4.identity(),
        mesh: null,
        joints: const {},
      ),
      1: ModelNode(
        name: 'Spine',
        nodeIndex: 1,
        parentNodeIndex: 0,
        transform: Matrix4.translationValues(0, 0, 0.8),
        mesh: null,
        joints: const {},
      ),
      2: ModelNode(
        name: 'Crown',
        nodeIndex: 2,
        parentNodeIndex: 1,
        transform: Matrix4.translationValues(0, 0, 1.15)..rotateX(math.pi / 2),
        mesh: crownMesh,
        joints: const {},
      ),
      3: ModelNode(
        name: 'Body26',
        nodeIndex: 3,
        parentNodeIndex: null,
        transform: Matrix4.identity(),
        mesh: skinMesh,
        joints: {
          0: ModelJoint(nodeIndex: 0, inverseBindMatrix: Matrix4.identity()),
          1: ModelJoint(
            nodeIndex: 1,
            inverseBindMatrix: Matrix4.translationValues(0, 0, -0.8),
          ),
        },
      ),
    };

    final pulseClip = ModelAnimation(
      name: 'Pulse',
      nodes: {
        1: NodeAnimation(
          channels: [
            AnimationController(
              animation: RotationAnimationSpline.from(
                interpolation: AnimationInterpolation.linear,
                times: const [0.0, 0.5, 1.0],
                values: [
                  Quaternion.axisAngle(Vector3(0, 1, 0), -0.45),
                  Quaternion.axisAngle(Vector3(0, 1, 0), 0.45),
                  Quaternion.axisAngle(Vector3(0, 1, 0), -0.45),
                ],
              ),
            ),
          ],
        ),
      },
    );

    final waveClip = ModelAnimation(
      name: 'Wave',
      nodes: {
        0: NodeAnimation(
          channels: [
            AnimationController(
              animation: RotationAnimationSpline.from(
                interpolation: AnimationInterpolation.linear,
                times: const [0.0, 0.4, 0.8],
                values: [
                  Quaternion.identity(),
                  Quaternion.axisAngle(Vector3(0, 0, 1), 0.9),
                  Quaternion.identity(),
                ],
              ),
            ),
          ],
        ),
        1: NodeAnimation(
          channels: [
            AnimationController(
              animation: RotationAnimationSpline.from(
                interpolation: AnimationInterpolation.linear,
                times: const [0.0, 0.4, 0.8],
                values: [
                  Quaternion.axisAngle(Vector3(1, 0, 0), 0.55),
                  Quaternion.axisAngle(Vector3(1, 0, 0), -0.55),
                  Quaternion.axisAngle(Vector3(1, 0, 0), 0.55),
                ],
              ),
            ),
          ],
        ),
      },
    );

    return Model(nodes: nodes, animations: [pulseClip, waveClip]);
  }

  /// Builds a multi-part overlapping statue surface (inner core + outer shell)
  /// so naive translucent rendering reveals internal self-overlap whereas a
  /// `RenderState.depthOnly` prepass + `CompareFunction.lessEqual` fades as one
  /// seamless piece.
  Mesh buildOverlappingGhostMesh(StylizedMaterial material) {
    final pos = <double>[];
    final nrm = <double>[];
    final col = <double>[];
    final occ = <double>[];
    final gloss = <double>[];
    final idx = <int>[];

    void addSphere(double cx, double cy, double cz, double r, ui.Color c) {
      const stacks = 10;
      const slices = 14;
      final base = pos.length ~/ 3;
      for (var i = 0; i <= stacks; i++) {
        final v = i / stacks;
        final phi = v * math.pi;
        final sp = math.sin(phi);
        final cp = math.cos(phi);
        for (var j = 0; j <= slices; j++) {
          final u = j / slices;
          final theta = u * math.pi * 2;
          final nx = sp * math.cos(theta);
          final ny = sp * math.sin(theta);
          final nz = cp;
          pos.addAll([cx + nx * r, cy + ny * r, cz + nz * r]);
          nrm.addAll([nx, ny, nz]);
          col.addAll([c.r, c.g, c.b, 1.0]);
          occ.add(0.85);
          gloss.add(0.75);
        }
      }
      const stride = slices + 1;
      for (var i = 0; i < stacks; i++) {
        for (var j = 0; j < slices; j++) {
          final a = base + i * stride + j;
          final b = a + 1;
          final d = a + stride;
          final e = d + 1;
          idx.addAll([a, d, b, b, d, e]);
        }
      }
    }

    // Intersecting spheres: torso, inner bright core, shoulders, head.
    addSphere(0, 0, 0.55, 0.44, const ui.Color(0xFF72EFDD));
    addSphere(0, 0, 0.62, 0.24, const ui.Color(0xFFFF4D6D));
    addSphere(-0.3, 0, 0.78, 0.26, const ui.Color(0xFF64DFDF));
    addSphere(0.3, 0, 0.78, 0.26, const ui.Color(0xFF64DFDF));
    addSphere(0, 0, 1.12, 0.28, const ui.Color(0xFF80FFDB));

    return Mesh()..addSurface(
      StylizedMaterial.buildSurface(
        positions: pos,
        normals: nrm,
        colors: col,
        occlusion: occ,
        gloss: gloss,
        indices: idx,
        material: material,
      ),
    );
  }

  /// Builds an asymmetric L-shaped monument so negative mirror scales
  /// (`scale: Vector3(-1, 1, 1)`) visibly test winding compensation and BVH
  /// raycasting.
  Mesh buildAsymmetricMonumentMesh(StylizedMaterial material) {
    final pos = <double>[];
    final nrm = <double>[];
    final col = <double>[];
    final occ = <double>[];
    final accent = <double>[];
    final gloss = <double>[];
    final idx = <int>[];

    void box(
      double x0,
      double x1,
      double y0,
      double y1,
      double z0,
      double z1,
      double acc,
    ) {
      final faces = [
        (
          (1.0, 0.0, 0.0),
          [(x1, y0, z0), (x1, y1, z0), (x1, y1, z1), (x1, y0, z1)],
        ),
        (
          (-1.0, 0.0, 0.0),
          [(x0, y1, z0), (x0, y0, z0), (x0, y0, z1), (x0, y1, z1)],
        ),
        (
          (0.0, 1.0, 0.0),
          [(x1, y1, z0), (x0, y1, z0), (x0, y1, z1), (x1, y1, z1)],
        ),
        (
          (0.0, -1.0, 0.0),
          [(x0, y0, z0), (x1, y0, z0), (x1, y0, z1), (x0, y0, z1)],
        ),
        (
          (0.0, 0.0, 1.0),
          [(x0, y0, z1), (x1, y0, z1), (x1, y1, z1), (x0, y1, z1)],
        ),
        (
          (0.0, 0.0, -1.0),
          [(x0, y1, z0), (x1, y1, z0), (x1, y0, z0), (x0, y0, z0)],
        ),
      ];
      for (final (n, pts) in faces) {
        final b = pos.length ~/ 3;
        for (final p in pts) {
          pos.addAll([p.$1, p.$2, p.$3]);
          nrm.addAll([n.$1, n.$2, n.$3]);
          col.addAll([0.92, 0.88, 0.82, 1.0]);
          occ.add(p.$3 < 0.05 ? 0.55 : 1.0);
          accent.add(acc);
          gloss.add(0.45);
        }
        idx.addAll([b, b + 1, b + 2, b, b + 2, b + 3]);
      }
    }

    box(-0.35, 0.05, -0.25, 0.25, 0.0, 1.35, 0.0);
    box(0.05, 0.52, -0.18, 0.18, 0.85, 1.22, 1.0);
    return Mesh()..addSurface(
      StylizedMaterial.buildSurface(
        positions: pos,
        normals: nrm,
        colors: col,
        occlusion: occ,
        accent: accent,
        gloss: gloss,
        indices: idx,
        material: material,
      ),
    );
  }

  /// Builds a `260 x 260 = 67,600`-vertex (`> 65,535`) analytic wave terrain
  /// into a `Float32List` + 32-bit `Uint32List` (`Surface.fromBuffers`) to
  /// exercise 32-bit GPU index buffers (`GpuIndexType.uint32`).
  Mesh buildHighPoly32BitWaveMesh(Material material, {int grid = 260}) {
    final vertCount = grid * grid;
    final stride = VertexLayout.standard.strideInFloats;
    final vertices = Float32List(vertCount * stride);

    var o = 0;
    for (var iy = 0; iy < grid; iy++) {
      final v = iy / (grid - 1);
      final y = (v - 0.5) * 4.2;
      for (var ix = 0; ix < grid; ix++) {
        final u = ix / (grid - 1);
        final x = (u - 0.5) * 4.2;
        final r = math.sqrt(x * x + y * y);
        final z = 0.24 * math.cos(r * 4.2) * math.exp(-0.28 * r);
        final dandr =
            -0.24 *
            math.exp(-0.28 * r) *
            (4.2 * math.sin(r * 4.2) + 0.28 * math.cos(r * 4.2));
        final dzdx = r > 1e-5 ? dandr * (x / r) : 0.0;
        final dzdy = r > 1e-5 ? dandr * (y / r) : 0.0;
        final invN = 1.0 / math.sqrt(dzdx * dzdx + dzdy * dzdy + 1.0);

        final crest = (0.5 + z * 2.0).clamp(0.0, 1.0);
        vertices
          ..[o] = x
          ..[o + 1] = y
          ..[o + 2] = z
          ..[o + 3] = u * 4.0
          ..[o + 4] = v * 4.0
          ..[o + 5] = 0.12 + 0.55 * crest
          ..[o + 6] = 0.45 + 0.48 * crest
          ..[o + 7] = 0.78 + 0.22 * crest
          ..[o + 8] = 1.0
          ..[o + 9] = -dzdx * invN
          ..[o + 10] = -dzdy * invN
          ..[o + 11] = invN;
        o += stride;
      }
    }

    final quadCount = (grid - 1) * (grid - 1);
    final indices = Uint32List(quadCount * 6);
    var k = 0;
    for (var iy = 0; iy < grid - 1; iy++) {
      final row0 = iy * grid;
      final row1 = (iy + 1) * grid;
      for (var ix = 0; ix < grid - 1; ix++) {
        final i0 = row0 + ix;
        final i1 = i0 + 1;
        final i2 = row1 + ix + 1;
        final i3 = row1 + ix;
        indices
          ..[k] = i0
          ..[k + 1] = i1
          ..[k + 2] = i2
          ..[k + 3] = i0
          ..[k + 4] = i2
          ..[k + 5] = i3;
        k += 6;
      }
    }

    return Mesh()..addSurface(
      Surface.fromBuffers(
        vertices: vertices,
        indices: indices,
        material: material,
      ),
    );
  }

  /// Procedural checker/grid texture parameterized by [sampler] (`repeat`,
  /// `mirror`, `clamp`, `nearest` vs `linear` + mipmaps).
  Texture buildCheckerTexture({
    required TextureSampler sampler,
    bool mipmaps = true,
  }) {
    const size = 32;
    final bytes = Uint8List(size * size * 4);
    for (var y = 0; y < size; y++) {
      for (var x = 0; x < size; x++) {
        final cell = ((x ~/ 8) + (y ~/ 8)).isEven;
        final border = x < 2 || y < 2 || x >= size - 2 || y >= size - 2;
        final (int r, int g, int b) = border
            ? (255, 190, 11)
            : (cell ? (56, 189, 248) : (30, 41, 59));
        final i = (y * size + x) * 4;
        bytes
          ..[i] = r
          ..[i + 1] = g
          ..[i + 2] = b
          ..[i + 3] = 255;
      }
    }
    return Texture(
      ByteData.sublistView(bytes),
      width: size,
      height: size,
      mipmaps: mipmaps,
      sampler: sampler,
    );
  }

  /// Renders a 2D vector emblem via `ui.PictureRecorder` + `ui.Canvas` and
  /// wraps it as a 3D GPU [ImageTexture] via `ImageTexture.create`.
  Future<ImageTexture> createCanvasBannerTexture() async {
    const w = 128;
    const h = 64;
    final recorder = ui.PictureRecorder();
    ui.Canvas(recorder)
      ..drawRect(
        const ui.Rect.fromLTWH(0, 0, 128, 64),
        ui.Paint()..color = const ui.Color(0xFF0F172A),
      )
      ..drawRRect(
        ui.RRect.fromRectAndRadius(
          const ui.Rect.fromLTWH(4, 4, 120, 56),
          const ui.Radius.circular(10),
        ),
        ui.Paint()
          ..color = const ui.Color(0xFF38BDF8)
          ..style = ui.PaintingStyle.stroke
          ..strokeWidth = 3,
      )
      ..drawCircle(
        const ui.Offset(34, 32),
        16,
        ui.Paint()..color = const ui.Color(0xFFF59E0B),
      )
      ..drawCircle(
        const ui.Offset(64, 32),
        14,
        ui.Paint()..color = const ui.Color(0xFF10B981),
      )
      ..drawCircle(
        const ui.Offset(94, 32),
        16,
        ui.Paint()..color = const ui.Color(0xFFEC4899),
      );
    final picture = recorder.endRecording();
    final image = await picture.toImage(w, h);
    picture.dispose();
    final tex = await ImageTexture.create(
      image,
      sampler: TextureSampler.linear,
    );
    image.dispose();
    return tex;
  }

  static Texture _buildFlipbookFire(int size) {
    const cols = 4;
    const rows = 4;
    final cell = size ~/ cols;
    final bytes = Uint8List(size * size * 4);
    for (var frame = 0; frame < cols * rows; frame++) {
      final col = frame % cols;
      final row = frame ~/ cols;
      final phase = frame / (cols * rows);
      for (var py = 0; py < cell; py++) {
        final ly = (py + 0.5) / cell * 2.0 - 1.0;
        for (var px = 0; px < cell; px++) {
          final lx = (px + 0.5) / cell * 2.0 - 1.0;
          final swirl = 0.22 * math.sin(ly * 4.0 + phase * math.pi * 2);
          final rad = math.sqrt((lx + swirl) * (lx + swirl) + ly * ly);
          final coreRadius = 0.25 + 0.55 * (1.0 - phase * 0.55);
          final mask = (1.0 - rad / coreRadius).clamp(0.0, 1.0);
          final hot = mask * mask;
          final a = (mask * (1.0 - 0.55 * phase)).clamp(0.0, 1.0);
          final cr = (1.0 * a * 255).round();
          final cg = ((0.35 + 0.65 * hot) * a * 255).round();
          final cb = ((0.08 + 0.8 * hot * hot) * a * 255).round();
          final ca = (a * 255).round();
          final gx = col * cell + px;
          final gy = row * cell + py;
          final idx = (gy * size + gx) * 4;
          bytes
            ..[idx] = cr
            ..[idx + 1] = cg
            ..[idx + 2] = cb
            ..[idx + 3] = ca;
        }
      }
    }
    return Texture(
      ByteData.sublistView(bytes),
      width: size,
      height: size,
      sampler: TextureSampler.linear,
    );
  }

  static Texture _buildRibbonPlasma(int width, int height) {
    final bytes = Uint8List(width * height * 4);
    for (var y = 0; y < height; y++) {
      final v = (y + 0.5) / height * 2.0 - 1.0;
      final cross = 1.0 - v.abs();
      for (var x = 0; x < width; x++) {
        final u = x / width;
        final wave =
            0.55 +
            0.45 * math.sin(u * math.pi * 6 + math.sin(v * math.pi) * 1.4);
        final a = (cross * wave).clamp(0.0, 1.0);
        final idx = (y * width + x) * 4;
        bytes
          ..[idx] = (0.45 * a * 255).round()
          ..[idx + 1] = (0.92 * a * 255).round()
          ..[idx + 2] = (1.0 * a * 255).round()
          ..[idx + 3] = (a * 255).round();
      }
    }
    return Texture(
      ByteData.sublistView(bytes),
      width: width,
      height: height,
      sampler: const TextureSampler(
        minFilter: TextureFilter.linear,
        magFilter: TextureFilter.linear,
        wrapU: TextureWrap.repeat,
      ),
    );
  }

  static Texture _buildMatCap({
    required int size,
    required (double, double, double) base,
    required (double, double, double) highlight,
    required (double, double, double) rim,
    required double power,
  }) {
    final bytes = Uint8List(size * size * 4);
    var o = 0;
    for (var y = 0; y < size; y++) {
      final ny = 1.0 - (y + 0.5) * 2.0 / size;
      for (var x = 0; x < size; x++) {
        final nx = (x + 0.5) * 2.0 / size - 1.0;
        final r2 = nx * nx + ny * ny;
        final nz = r2 < 1.0 ? math.sqrt(1.0 - r2) : 0.0;
        final ndotl = math.max(0.0, -0.35 * nx + 0.55 * ny + 0.75 * nz);
        final spec = math.pow(
          math.max(0.0, -0.22 * nx + 0.42 * ny + 0.88 * nz),
          power,
        );
        final fresnel = math.pow(1.0 - nz, 2.6).toDouble();

        final cr =
            (base.$1 * (0.4 + 0.8 * ndotl) +
                    highlight.$1 * spec +
                    rim.$1 * fresnel)
                .clamp(0.0, 1.0);
        final cg =
            (base.$2 * (0.4 + 0.8 * ndotl) +
                    highlight.$2 * spec +
                    rim.$2 * fresnel)
                .clamp(0.0, 1.0);
        final cb =
            (base.$3 * (0.4 + 0.8 * ndotl) +
                    highlight.$3 * spec +
                    rim.$3 * fresnel)
                .clamp(0.0, 1.0);
        bytes
          ..[o] = (cr * 255).round()
          ..[o + 1] = (cg * 255).round()
          ..[o + 2] = (cb * 255).round()
          ..[o + 3] = 255;
        o += 4;
      }
    }
    return Texture(
      ByteData.sublistView(bytes),
      width: size,
      height: size,
      mipmaps: true,
      sampler: TextureSampler.linear,
    );
  }

  static Texture _buildDecalAtlas(int size) {
    final half = size ~/ 2;
    final bytes = Uint8List(size * size * 4);
    for (var y = 0; y < size; y++) {
      final qy = y ~/ half;
      final ly = ((y % half) + 0.5) / half * 2.0 - 1.0;
      for (var x = 0; x < size; x++) {
        final qx = x ~/ half;
        final lx = ((x % half) + 0.5) / half * 2.0 - 1.0;
        final tile = qy * 2 + qx;
        final r = math.sqrt(lx * lx + ly * ly);
        var alpha = 0.0;
        if (tile == 0) {
          // Crosshair ring
          final ring = (1.0 - ((r - 0.72).abs() / 0.12)).clamp(0.0, 1.0);
          final cross = (lx.abs() < 0.09 || ly.abs() < 0.09) && r < 0.88
              ? 0.85
              : 0.0;
          alpha = math.max(ring, cross);
        } else if (tile == 1) {
          // 4-point star
          final d = math.pow(lx.abs(), 0.65) + math.pow(ly.abs(), 0.65);
          alpha = (1.0 - (d - 0.55) / 0.35).clamp(0.0, 1.0);
        } else if (tile == 2) {
          // Diamond rune
          final manhattan = lx.abs() + ly.abs();
          final outer = (1.0 - ((manhattan - 0.78).abs() / 0.14)).clamp(
            0.0,
            1.0,
          );
          final inner = manhattan < 0.3 ? 0.9 : 0.0;
          alpha = math.max(outer, inner);
        } else {
          // Concentric pulse target
          final waves = 0.5 + 0.5 * math.cos(r * math.pi * 5.0);
          alpha = r < 0.92 ? waves * (1.0 - r * 0.65) : 0.0;
        }
        final a = (alpha.clamp(0.0, 1.0) * 255).round();
        final i = (y * size + x) * 4;
        // Premultiplied white glyph so per-decal instance color tints cleanly.
        bytes
          ..[i] = a
          ..[i + 1] = a
          ..[i + 2] = a
          ..[i + 3] = a;
      }
    }
    return Texture(
      ByteData.sublistView(bytes),
      width: size,
      height: size,
      sampler: TextureSampler.linear,
    );
  }
}
