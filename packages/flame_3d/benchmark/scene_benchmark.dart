// A 3D layer over a 2D world, built to measure what rendering it costs: see
// README.md.

import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' show Canvas, Color, Paint;

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame_3d/components.dart';
import 'package:flame_3d/graphics.dart';
import 'package:flame_3d/particles.dart';
import 'package:flame_3d/resources.dart';

/// How big the benchmark scene is.
class BenchmarkConfig({
  /// The number of instanced objects, each made of several surfaces.
  final int objects = 200,

  /// How many times more triangles each object has than by default.
  final double triangleScale = 1,

  /// The number of skinned characters.
  final int characters = 8,

  /// The number of translucent objects, each with a mesh of its own.
  final int translucentParts = 8,

  /// The number of additive glows, each with a mesh of its own.
  final int additiveParts = 6,

  /// The number of particle systems.
  final int particleSystems = 3,

  /// Whether the sun casts shadows onto the objects and a catcher ground.
  final bool shadows = true,

  /// The number of point lights, of which [activePointLights] shine.
  final int pointLights = 8,

  /// The number of point lights with a non-zero intensity.
  final int activePointLights = 3,

  /// Whether the layer renders with 4x multisampling.
  final bool msaa = true,
});

/// A 2D game whose world holds a 3D layer ([layer]) of [config]'s size, and
/// whose camera keeps moving, so the layer renders anew every frame.
class BenchmarkGame(final BenchmarkConfig config) extends FlameGame {
  late final BenchmarkLayer layer;

  /// The dimetric projection of a board of cells, z up.
  static final Scene3DProjection projection = Scene3DProjection.affine(
    origin: Vector2(0, -18),
    xAxis: Vector2(44, 22),
    yAxis: Vector2(-44, 22),
    zAxis: Vector2(0, -53.889),
    towardsViewer: Vector3(0.6124, 0.6124, 0.5),
    near: -50,
    far: 50,
  );

  /// The side of the board, in cells.
  static const int board = 16;

  final List<_Character> _characters = [];
  final List<StylizedMaterial> _windMaterials = [];
  double _time = 0;

  @override
  Future<void> onLoad() async {
    layer = BenchmarkLayer(
      projection: projection,
      msaa: config.msaa ? Msaa.sample4 : Msaa.off,
      priority: 1,
    );
    world.addAll([
      for (var i = 0; i < 6; i++)
        RectangleComponent(
          position: Vector2(-600 + i * 200, -400 + i * 120),
          size: Vector2(400, 300),
          paint: Paint()..color = Color(0xFF203020 + i * 0x000A0A04),
        ),
      layer,
    ]);
    layer.world.addAll(_buildScene());
    camera.viewfinder.position = layer.scenePointToLocal(
      Vector3(board / 2, board / 2, 0),
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    _time += dt;
    // The camera pans and zooms a little: the layer renders every frame.
    final center = layer.scenePointToLocal(Vector3(board / 2, board / 2, 0));
    camera.viewfinder
      ..position = center + Vector2(math.sin(_time) * 40, math.cos(_time) * 25)
      ..zoom = 1 + 0.05 * math.sin(_time * 0.7);
    for (final material in _windMaterials) {
      material.windTime = _time;
    }
    for (final character in _characters) {
      character.animate(_time);
    }
  }

  List<Component3D> _buildScene() {
    final random = math.Random(7);
    final matCaps = _MatCaps();
    // Ten stylized materials, as a board of buildings has.
    final walls = StylizedMaterial(
      matCapTexture: matCaps.coat,
      matCapThreshold: 0.36,
      matCapGlossWeight: 0,
      gemMatCapTexture: matCaps.gem,
      gemThreshold: 0.9,
    );
    final roofs = StylizedMaterial(accentColor: const Color(0xFFB0412E));
    final windows = StylizedMaterial(
      emissiveColor: const Color(0xFFFFE2A0),
      emissiveBoostColor: const Color(0xFFFF9A40),
      emissiveStrength: 0.4,
    );
    final metal = StylizedMaterial(
      matCapTexture: matCaps.gold,
      matCapThreshold: -1,
      matCapMetallic: 1,
      gemMatCapTexture: matCaps.gem,
    );
    final foliage = StylizedMaterial(
      windSpace: WindSpace.model,
      windDirection: Vector3(1, 0.3, 0),
      windAmplitude: 0.05,
    );
    final stone = StylizedMaterial(
      rimStrength: 0.2,
      saturation: 0.8,
    );
    final ghost = StylizedMaterial(translucent: true);
    final glow = StylizedMaterial(
      emissiveColor: const Color(0xFF60C0FF),
    )..renderState = RenderState.additive.copyWith(translucent: true);
    final skin = StylizedMaterial(
      matCapTexture: matCaps.coat,
      matCapThreshold: 0.5,
    );
    final glass = StylizedMaterial(
      translucent: true,
      overlayColor: const Color(0x2060A0FF),
    );
    _windMaterials.addAll([walls, roofs, windows, metal, foliage, stone]);

    final components = <Component3D>[];

    // Lights: a hemisphere, a sun, and point lights of which some shine.
    components.addAll([
      LightComponent.hemisphere(
        skyColor: const Color(0xFFB4CCF0),
        groundColor: const Color(0xFF6E7A50),
        intensity: 0.44,
        up: Vector3(0, 0, 1),
      ),
      LightComponent.directional(
        direction: Vector3(0.32, -0.48, -0.816),
        intensity: 0.76,
        shadows: config.shadows
            ? ShadowSettings(strength: 0.8, color: const Color(0xFF1E2A55))
            : null,
      ),
      for (var i = 0; i < config.pointLights; i++)
        LightComponent.point(
          position: Vector3(2.0 + i * 1.7, 3.0 + (i % 3) * 4, 1.2),
          color: const Color(0xFFFFC080),
          intensity: i < config.activePointLights ? 1.5 : 0,
          range: 3,
        ),
    ]);

    if (config.shadows) {
      components.add(
        MeshComponent(
          mesh: PlaneMesh(
            size: Vector2.all(board + 4.0),
            material: ShadowCatcherMaterial(color: const Color(0xB31B2440)),
          ),
          position: Vector3(board / 2, board / 2, 0),
          rotation: Quaternion.axisAngle(Vector3(1, 0, 0), math.pi / 2),
        ),
      );
    }

    // Twelve kinds of buildings, four or five surfaces each, shared by the
    // objects: one instanced draw per surface.
    final kinds = [
      for (var k = 0; k < 12; k++)
        _building(
          k,
          config.triangleScale,
          walls: walls,
          roofs: roofs,
          windows: windows,
          trim: k.isEven ? metal : stone,
          foliage: k % 3 == 0 ? foliage : null,
        ),
    ];
    for (var n = 0; n < config.objects; n++) {
      final i = n % board;
      final j = n ~/ board % board;
      final level = n ~/ (board * board);
      components.add(
        MeshComponent(
          mesh: kinds[random.nextInt(kinds.length)],
          position: Vector3(i + 0.5, j + 0.5, level * 1.5),
          rotation: Quaternion.axisAngle(
            Vector3(0, 0, 1),
            random.nextInt(4) * math.pi / 2,
          ),
          scale: Vector3.all(0.7 + random.nextDouble() * 0.2),
          color: Color.from(
            alpha: 1,
            red: 0.6 + random.nextDouble() * 0.4,
            green: 0.6 + random.nextDouble() * 0.4,
            blue: 0.6 + random.nextDouble() * 0.4,
          ),
          instanceData: Vector4(random.nextDouble(), 0, 0, 0),
        ),
      );
    }

    // Unique translucent parts (previews, glass) and additive glows.
    for (var n = 0; n < config.translucentParts; n++) {
      final material = n.isEven ? ghost : glass;
      components.add(
        MeshComponent(
          mesh: Mesh()
            ..addSurface(
              _surface(
                _Geometry()..box(0, 0, 0.5, 0.8, 0.8, 1, 3),
                material,
              ),
            ),
          position: Vector3(1.5 + n * 1.8, board - 2.5, 0),
          instanceData: Vector4(0, 0, 0, 0.45),
        ),
      );
    }
    for (var n = 0; n < config.additiveParts; n++) {
      components.add(
        MeshComponent(
          mesh: Mesh()
            ..addSurface(
              _surface(
                _Geometry()..cylinder(0, 0, 0, 0.3, 0.05, 16, 1, emissive: 1),
                glow,
              ),
            ),
          position: Vector3(2.5 + n * 2.1, 1.5, 0.02),
        ),
      );
    }

    // Skinned characters: two meshes, each draw on its own.
    final bodies = [
      for (var k = 0; k < 2; k++) _characterSurface(skin, segments: 10 + k * 4),
    ];
    for (var n = 0; n < config.characters; n++) {
      final character = _Character(bodies[n % 2], phase: n * 0.8)
        ..position = Vector3(
          1 + n * 1.9,
          board / 2 + (n.isEven ? 0.5 : -0.5),
          0,
        )
        ..color = Color(0xFFFFFFFF - n * 0x00102030);
      _characters.add(character);
      components.add(character);
    }

    // Particle systems: chimney smoke, sparks and dust, a few hundred
    // particles in all.
    final up = Vector3(0, 0, 1);
    final particles = [
      ParticlePresets3D.smoke(rate: 45, up: up, scale: 0.5),
      ParticlePresets3D.sparks(rate: 160, up: up, scale: 0.5),
      ParticlePresets3D.smoke(
        rate: 60,
        up: up,
        scale: 0.3,
        color: const Color(0xFFC8B48C),
        seed: 5,
      ),
    ];
    for (var n = 0; n < config.particleSystems; n++) {
      components.add(
        particles[n % particles.length]
          ..position = Vector3(3.5 + n * 4.5, 5.5 + n * 2, 1.2),
      );
    }
    return components;
  }

  /// One kind of building: walls with windows, a roof, a trim and maybe
  /// foliage, about 600 triangles at a [triangleScale] of 1.
  static Mesh _building(
    int kind,
    double triangleScale, {
    required StylizedMaterial walls,
    required StylizedMaterial roofs,
    required StylizedMaterial windows,
    required StylizedMaterial trim,
    StylizedMaterial? foliage,
  }) {
    final detail = math.sqrt(triangleScale);
    int level(double base) => math.max(1, (base * detail).round());
    final height = 0.6 + (kind % 4) * 0.25;
    final mesh = Mesh()
      ..addSurface(
        _surface(
          _Geometry()..box(0, 0, height / 2, 0.8, 0.8, height, level(4)),
          walls,
          tint: 1,
          gloss: 0.5,
        ),
      )
      ..addSurface(
        _surface(
          _Geometry()
            ..cone(0, 0, height, 0.62, 0.45, level(12).clamp(4, 64), level(3)),
          roofs,
          accent: 1,
        ),
      )
      ..addSurface(
        _surface(
          _Geometry()
            ..box(0.41, 0, height * 0.55, 0.02, 0.5, height * 0.4, level(2))
            ..box(-0.41, 0, height * 0.55, 0.02, 0.5, height * 0.4, level(2))
            ..box(0, 0.41, height * 0.55, 0.5, 0.02, height * 0.4, level(2)),
          windows,
          emissive: 1,
        ),
      )
      ..addSurface(
        _surface(
          _Geometry()
            ..cylinder(0.3, 0.3, height, 0.06, 0.25, level(10), level(2)),
          trim,
          gloss: 1,
        ),
      );
    if (foliage != null) {
      mesh.addSurface(
        _surface(
          _Geometry()..cone(-0.45, -0.45, 0, 0.18, 0.5, level(10), level(3)),
          foliage,
          sway: 1,
        ),
      );
    }
    return mesh;
  }

  /// A worm-like body of [segments] rings, skinned to 16 joints along it.
  static Surface _characterSurface(
    StylizedMaterial material, {
    required int segments,
  }) {
    const sides = 16;
    const joints = StylizedMaterial.maxJoints;
    const length = 1.2;
    final geometry = _Geometry();
    final jointList = <double>[];
    final weightList = <double>[];
    for (var r = 0; r <= segments * 4; r++) {
      final t = r / (segments * 4);
      final z = t * length;
      final radius = 0.18 * (1 - 0.5 * (t - 0.5).abs());
      for (var s = 0; s <= sides; s++) {
        final a = s / sides * 2 * math.pi;
        geometry
          ..positions.addAll([math.cos(a) * radius, math.sin(a) * radius, z])
          ..normals.addAll([math.cos(a), math.sin(a), 0]);
        final position = t * (joints - 1);
        final joint = position.floor().clamp(0, joints - 2);
        final f = position - joint;
        jointList.addAll([joint.toDouble(), joint + 1.0, 0, 0]);
        weightList.addAll([1 - f, f, 0, 0]);
      }
    }
    for (var r = 0; r < segments * 4; r++) {
      for (var s = 0; s < sides; s++) {
        final a = r * (sides + 1) + s;
        final b = a + sides + 1;
        geometry.indices.addAll([a, a + 1, b, b, a + 1, b + 1]);
      }
    }
    return StylizedMaterial.buildSurface(
      positions: geometry.positions,
      normals: geometry.normals,
      indices: geometry.indices,
      material: material,
      tint: List.filled(geometry.positions.length ~/ 3, 1),
      gloss: List.filled(geometry.positions.length ~/ 3, 0.7),
      joints: jointList,
      weights: weightList,
      aabb: Aabb3.minMax(Vector3(-1, -1, -0.2), Vector3(1, 1, 1.6)),
    );
  }

  static Surface _surface(
    _Geometry geometry,
    Material material, {
    double tint = 0,
    double accent = 0,
    double emissive = 0,
    double gloss = 0,
    double sway = 0,
  }) {
    final count = geometry.positions.length ~/ 3;
    return StylizedMaterial.buildSurface(
      positions: geometry.positions,
      normals: geometry.normals,
      indices: geometry.indices,
      material: material,
      tint: List.filled(count, tint),
      accent: List.filled(count, accent),
      emissive: geometry.emissive.isEmpty
          ? List.filled(count, emissive)
          : geometry.emissive,
      gloss: List.filled(count, gloss),
      sway: [
        for (var i = 0; i < count; i++) sway * geometry.positions[i * 3 + 2],
      ],
    );
  }
}

/// The 3D layer of [BenchmarkGame], which can stop rendering to measure
/// what the rest of a frame costs.
class BenchmarkLayer({
  required super.projection,
  super.msaa,
  super.priority,
}) extends Scene3DComponent {
  /// Whether the layer renders.
  bool renders = true;

  @override
  void render(Canvas canvas) {
    if (renders) {
      super.render(canvas);
    }
  }
}

/// A skinned character whose 16 joints wave every frame.
class _Character(Surface body, {required final double phase})
    extends MeshComponent {
  this : super(mesh: Mesh()..addSurface(body));

  final List<Matrix4> _joints = List.generate(
    StylizedMaterial.maxJoints,
    (_) => Matrix4.identity(),
  );

  @override
  Future<void> onLoad() async {
    jointTransforms = {0: _joints};
  }

  final Matrix4 _local = Matrix4.identity();

  void animate(double time) {
    // A chain: each joint bends the body a little more about x.
    const length = 1.2 / (StylizedMaterial.maxJoints - 1);
    Matrix4? parent;
    for (var j = 0; j < _joints.length; j++) {
      final angle = 0.12 * math.sin(time * 3 + phase + j * 0.4);
      final z = j * length;
      // Bind pose at height z: joint = T(z) R(angle) T(-z) relative to the
      // parent's frame.
      _local
        ..setIdentity()
        ..translateByDouble(0, 0, z, 1)
        ..rotateX(angle)
        ..translateByDouble(0, 0, -z, 1);
      final joint = _joints[j];
      if (parent == null) {
        joint.setFrom(_local);
      } else {
        joint
          ..setFrom(parent)
          ..multiply(_local);
      }
      parent = joint;
    }
  }
}

/// Procedural geometry: positions, normals and triangle indices.
class _Geometry() {
  final List<double> positions = [];
  final List<double> normals = [];
  final List<int> indices = [];
  final List<double> emissive = [];

  int get _vertexCount => positions.length ~/ 3;

  /// A box centered on ([cx], [cy], [cz]) of size ([sx], [sy], [sz]) whose
  /// faces are split into [n] by [n] squares.
  void box(
    double cx,
    double cy,
    double cz,
    double sx,
    double sy,
    double sz,
    int n,
  ) {
    // (normal, u axis, v axis) of each face.
    const faces = [
      ([1.0, 0.0, 0.0], [0.0, 1.0, 0.0], [0.0, 0.0, 1.0]),
      ([-1.0, 0.0, 0.0], [0.0, 0.0, 1.0], [0.0, 1.0, 0.0]),
      ([0.0, 1.0, 0.0], [0.0, 0.0, 1.0], [1.0, 0.0, 0.0]),
      ([0.0, -1.0, 0.0], [1.0, 0.0, 0.0], [0.0, 0.0, 1.0]),
      ([0.0, 0.0, 1.0], [1.0, 0.0, 0.0], [0.0, 1.0, 0.0]),
      ([0.0, 0.0, -1.0], [0.0, 1.0, 0.0], [1.0, 0.0, 0.0]),
    ];
    final half = [sx / 2, sy / 2, sz / 2];
    final center = [cx, cy, cz];
    for (final (normal, u, v) in faces) {
      final base = _vertexCount;
      for (var b = 0; b <= n; b++) {
        for (var a = 0; a <= n; a++) {
          final fu = a / n * 2 - 1;
          final fv = b / n * 2 - 1;
          for (var c = 0; c < 3; c++) {
            positions.add(
              center[c] + half[c] * (normal[c] + u[c] * fu + v[c] * fv),
            );
          }
          normals.addAll(normal);
        }
      }
      for (var b = 0; b < n; b++) {
        for (var a = 0; a < n; a++) {
          final i = base + b * (n + 1) + a;
          indices.addAll([i, i + 1, i + n + 2, i + n + 2, i + n + 1, i]);
        }
      }
    }
  }

  /// A cylinder (or a cone when [radius] tapers to [topRadius]) standing at
  /// ([cx], [cy], [cz]).
  void cylinder(
    double cx,
    double cy,
    double cz,
    double radius,
    double height,
    int sides,
    int rings, {
    double topRadius = -1,
    double emissive = 0,
  }) {
    final top = topRadius < 0 ? radius : topRadius;
    final base = _vertexCount;
    for (var r = 0; r <= rings; r++) {
      final t = r / rings;
      final ringRadius = radius + (top - radius) * t;
      for (var s = 0; s <= sides; s++) {
        final a = s / sides * 2 * math.pi;
        positions.addAll([
          cx + math.cos(a) * ringRadius,
          cy + math.sin(a) * ringRadius,
          cz + t * height,
        ]);
        final slope = (radius - top) / height;
        final length = math.sqrt(1 + slope * slope);
        normals.addAll([
          math.cos(a) / length,
          math.sin(a) / length,
          slope / length,
        ]);
        if (emissive != 0) {
          this.emissive.add(emissive * (1 - t));
        }
      }
    }
    for (var r = 0; r < rings; r++) {
      for (var s = 0; s < sides; s++) {
        final a = base + r * (sides + 1) + s;
        final b = a + sides + 1;
        indices.addAll([a, a + 1, b, b, a + 1, b + 1]);
      }
    }
  }

  /// A cone standing at ([cx], [cy], [cz]).
  void cone(
    double cx,
    double cy,
    double cz,
    double radius,
    double height,
    int sides,
    int rings,
  ) {
    cylinder(cx, cy, cz, radius, height, sides, rings, topRadius: 0.001);
  }
}

/// Procedural MatCap textures: lit spheres in a few tints.
class _MatCaps() {
  late final Texture coat = _sphere(0.9, 0.9, 0.95, 0.35);
  late final Texture gem = _sphere(0.6, 0.85, 1, 0.6);
  late final Texture gold = _sphere(1, 0.78, 0.35, 0.8);

  static Texture _sphere(double r, double g, double b, double shine) {
    const size = 64;
    final pixels = Uint8List(size * size * 4);
    for (var y = 0; y < size; y++) {
      for (var x = 0; x < size; x++) {
        final nx = (x + 0.5) / size * 2 - 1;
        final ny = 1 - (y + 0.5) / size * 2;
        final d = nx * nx + ny * ny;
        final nz = d < 1 ? math.sqrt(1 - d) : 0.0;
        final light =
            (0.3 + 0.7 * math.max(0, nx * -0.4 + ny * 0.5 + nz * 0.77)).clamp(
              0.0,
              1.0,
            );
        final spot = math.pow(math.max(0, nz), 24) * shine;
        final i = (y * size + x) * 4;
        pixels
          ..[i] = ((r * light + spot) * 255).clamp(0, 255).toInt()
          ..[i + 1] = ((g * light + spot) * 255).clamp(0, 255).toInt()
          ..[i + 2] = ((b * light + spot) * 255).clamp(0, 255).toInt()
          ..[i + 3] = 255;
      }
    }
    return Texture(
      ByteData.sublistView(pixels),
      width: size,
      height: size,
      sampler: TextureSampler.linear,
      mipmaps: true,
    );
  }
}
