import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flame_3d/camera.dart';
import 'package:flame_3d/components.dart';
import 'package:flame_3d/game.dart';
import 'package:flame_3d/resources.dart';

/// Lit scene: spatial materials only.
FlameGame3D litScene() {
  return FlameGame3D(
    world: World3D(
      children: [
        LightComponent.ambient(intensity: 0.5),
        LightComponent.point(position: Vector3(2, 5, 4), intensity: 40),
        MeshComponent(
          mesh: CuboidMesh(
            size: Vector3.all(1.4),
            material: SpatialMaterial(
              albedoColor: const ui.Color(0xFFE0502A),
              metallic: 0.1,
              roughness: 0.4,
            ),
          ),
          rotation: Quaternion.euler(math.pi / 4, 0, 0),
        ),
        MeshComponent(
          position: Vector3(0, -0.71, 0),
          mesh: PlaneMesh(
            size: Vector2.all(6),
            material: SpatialMaterial(albedoColor: const ui.Color(0xFF3A6EA5)),
          ),
        ),
        for (var i = 0; i < 3; i++)
          MeshComponent(
            position: Vector3(-1.6 + i * 1.6, -0.2, 1.6),
            mesh: SphereMesh(
              radius: 0.45,
              material: SpatialMaterial(
                albedoColor: ui.Color(0xFF000000 | (0x40C040 << i)),
                metallic: 0.3 * i,
                roughness: 0.3 + 0.2 * i,
              ),
            ),
          ),
      ],
    ),
    camera: CameraComponent3D(
      position: Vector3(3, 3, 3.5),
      target: Vector3.zero(),
    ),
  );
}

/// Unlit scene: an opaque unlit cuboid and two overlapping translucent planes.
FlameGame3D unlitScene() {
  return FlameGame3D(
    world: World3D(
      children: [
        MeshComponent(
          mesh: CuboidMesh(
            size: Vector3.all(1),
            material: UnlitMaterial(albedoColor: const ui.Color(0xFF20A040)),
          ),
          rotation: Quaternion.euler(0.5, 0.3, 0),
        ),
        MeshComponent(
          position: Vector3(-0.3, 0, 1.0),
          rotation: Quaternion.euler(0, math.pi / 2, 0),
          mesh: PlaneMesh(
            size: Vector2.all(1.2),
            material: UnlitMaterial(albedoColor: const ui.Color(0x80FF2020)),
          ),
        ),
        MeshComponent(
          position: Vector3(0.3, 0.2, 1.6),
          rotation: Quaternion.euler(0, math.pi / 2, 0),
          mesh: PlaneMesh(
            size: Vector2.all(1.0),
            material: UnlitMaterial(albedoColor: const ui.Color(0x802020FF)),
          ),
        ),
      ],
    ),
    camera: CameraComponent3D(
      position: Vector3(0, 0.5, 4),
      target: Vector3.zero(),
    ),
  );
}
