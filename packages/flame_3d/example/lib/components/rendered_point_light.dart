import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/palette.dart';
import 'package:flame_3d/components.dart';
import 'package:flame_3d/game.dart';
import 'package:flame_3d/resources.dart';

class RenderedPointLight extends Component with HasGameReference<FlameGame3D> {
  final Vector3 position;
  final Color color;

  RenderedPointLight({
    required this.position,
    required this.color,
  });

  late LightComponent _light;

  @override
  FutureOr<void> onLoad() async {
    // TODO(luan): support lights being added nested in the component tree.
    game.world.add(
      _light = LightComponent.point(
        position: position,
        color: color,
      ),
    );
    addAll([
      MeshComponent(
        mesh: SphereMesh(
          radius: 0.05,
          material: SpatialMaterial(
            albedoTexture: ColorTexture(
              color,
            ),
          ),
        ),
        position: position,
      ),
    ]);
  }

  @override
  void onRemove() {
    if (_light.isMounted) {
      game.world.remove(_light);
    }
    super.onRemove();
  }
}
