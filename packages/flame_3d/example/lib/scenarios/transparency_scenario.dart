import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flame/extensions.dart';
import 'package:flame_3d/components.dart';
import 'package:flame_3d/graphics.dart';
import 'package:flame_3d/resources.dart';
import 'package:flame_3d_example/example_game_3d.dart';
import 'package:flame_3d_example/scenarios/game_scenario.dart';

/// One quad per [Transparency] mode in front of an opaque wall, and two
/// overlapping quads whose `renderPriority` draws the far one on top.
class TransparencyScenario() implements GameScenario {
  late final Texture _softDisc = _buildSoftDiscTexture(128);

  @override
  Future<void> onLoad() async {}

  @override
  void setup(ExampleGame3D game) {
    // The player spawns at (0, 1, 0) facing +Z.
    const z = 4.5;

    for (final (i, mode) in Transparency.values.indexed) {
      game.world.add(
        _BobbingQuad(
          position: Vector3((i - 2) * 1.5, 1.6, z),
          material: _quadMaterial(_tints[i])..transparency = mode,
        ),
      );
    }

    game.world.addAll([
      _BobbingQuad(
        position: Vector3(0, 3.2, z - 0.35),
        material: _quadMaterial(const Color(0xFFFF4477))
          ..transparency = Transparency.alpha
          ..renderPriority = -1,
      ),
      _BobbingQuad(
        position: Vector3(0, 3.2, z + 0.35),
        material: _quadMaterial(const Color(0xFF44DDFF))
          ..transparency = Transparency.alpha
          ..renderPriority = 1,
      ),
      MeshComponent(
        position: Vector3(0, 1.6, z + 0.6),
        rotation: _upright,
        mesh: PlaneMesh(
          size: Vector2(10, 3.5),
          material: UnlitMaterial(albedoColor: const Color(0xFF334466))
            ..cullMode = CullMode.none,
        ),
      ),
    ]);
  }

  UnlitMaterial _quadMaterial(Color tint) =>
      UnlitMaterial(albedoColor: tint, albedoTexture: _softDisc)
        ..cullMode = CullMode.none;

  static const _tints = [
    Color(0xFFE0E0E0),
    Color(0xFFFFCC44),
    Color(0xFF66FF66),
    Color(0xFFFF66AA),
    Color(0xFF66CCFF),
  ];
}

// PlaneMesh lies in the XZ plane, so rotate it to stand upright.
final _upright = Quaternion.axisAngle(Vector3(1, 0, 0), math.pi / 2);

/// A quad that bobs up and down, so the alphaHash dither shows that it
/// stays fixed to the surface.
class _BobbingQuad({
  required Vector3 position,
  required UnlitMaterial material,
}) extends MeshComponent {
  this
    : super(
        position: position,
        rotation: _upright,
        mesh: PlaneMesh(size: Vector2.all(1.35), material: material),
      );

  late final double _baseY = position.y;
  double _t = 0;

  @override
  void update(double dt) {
    super.update(dt);
    _t += dt;
    position.y = _baseY + math.sin(_t * 2) * 0.4;
  }
}

/// White texture with a radial alpha ramp, so each mode looks different.
Texture _buildSoftDiscTexture(int size) {
  final bytes = Uint8List(size * size * 4)..fillRange(0, size * size * 4, 255);
  final center = (size - 1) / 2;
  final maxRadius = size * 0.48;

  for (var y = 0; y < size; y++) {
    for (var x = 0; x < size; x++) {
      final dist = math.sqrt(math.pow(x - center, 2) + math.pow(y - center, 2));
      final alpha = (1 - dist / maxRadius).clamp(0.0, 1.0);
      bytes[(y * size + x) * 4 + 3] = (alpha * 255).round();
    }
  }

  return Texture(ByteData.view(bytes.buffer), width: size, height: size);
}
