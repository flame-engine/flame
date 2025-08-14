import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/palette.dart';
import 'package:flame_3d/components.dart';
import 'package:flame_3d/resources.dart';

class RoomBounds extends Component {
  @override
  FutureOr<void> onLoad() {
    addAll([
      // Floor
      MeshComponent(
        mesh: PlaneMesh(
          size: Vector2(32, 32),
          material: SpatialMaterial(
            albedoTexture: ColorTexture(
              BasicPalette.gray.color,
            ),
          ),
        ),
      ),

      // Front wall
      MeshComponent(
        position: Vector3(16.5, 2.5, 0),
        mesh: CuboidMesh(
          size: Vector3(1, 5, 32),
          material: SpatialMaterial(
            albedoTexture: ColorTexture(
              BasicPalette.yellow.color,
            ),
          ),
        ),
      ),

      // Left wall
      MeshComponent(
        position: Vector3(0, 2.5, 16.5),
        mesh: CuboidMesh(
          size: Vector3(32, 5, 1),
          material: SpatialMaterial(
            albedoTexture: ColorTexture(
              BasicPalette.blue.color,
            ),
          ),
        ),
      ),

      // Right wall
      MeshComponent(
        position: Vector3(0, 2.5, -16.5),
        mesh: CuboidMesh(
          size: Vector3(32, 5, 1),
          material: SpatialMaterial(
            albedoTexture: ColorTexture(
              BasicPalette.lime.color,
            ),
          ),
          useFaceNormals: false,
        ),
      ),
    ]);
  }
}
