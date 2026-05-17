import 'dart:ui';

import 'package:flame_3d/components.dart';
import 'package:flame_3d/core.dart';
import 'package:flame_3d/graphics.dart';
import 'package:flame_3d/resources.dart';
import 'package:flame_3d_example/components/rendered_point_light.dart';
import 'package:flame_3d_example/example_game_3d.dart';
import 'package:flame_3d_example/scenarios/game_scenario.dart';

class CullingScenario implements GameScenario {
  @override
  Future<void> onLoad() async {}

  @override
  void setup(ExampleGame3D game) {
    game.world.addAll([
      RenderedPointLight(
        position: Vector3(0, 5, 0),
        color: const Color(0xFFFFFFFF),
      ),

      _buildGroup(
        name: 'North',
        center: Vector3(0, 0, -12),
        color: const Color(0xFFFF4444),
      ),
      _buildGroup(
        name: 'South',
        center: Vector3(0, 0, 12),
        color: const Color(0xFF44FF44),
      ),
      _buildGroup(
        name: 'East',
        center: Vector3(12, 0, 0),
        color: const Color(0xFF4444FF),
      ),
      _buildGroup(
        name: 'West',
        center: Vector3(-12, 0, 0),
        color: const Color(0xFFFFFF44),
      ),
    ]);
  }

  _ObjectGroup _buildGroup({
    required String name,
    required Vector3 center,
    required Color color,
  }) {
    final children = <MeshComponent>[];

    for (var dx = -1; dx <= 1; dx++) {
      for (var dz = -1; dz <= 1; dz++) {
        children.add(
          MeshComponent(
            position: Vector3(dx * 2.0, 1, dz * 2.0),
            mesh: CuboidMesh(
              size: Vector3.all(0.8),
              material: SpatialMaterial(
                albedoTexture: ColorTexture(color),
              ),
            ),
          ),
        );
      }
    }

    return _ObjectGroup(
      position: center,
      children: children,
    );
  }
}

class _ObjectGroup extends Object3D {
  _ObjectGroup({
    required List<MeshComponent> children,
    super.position,
  }) : super(children: children);

  @override
  void draw(RenderContext context) {}
}
