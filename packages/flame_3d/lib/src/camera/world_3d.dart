import 'dart:ui';

import 'package:flame/components.dart' as flame;
import 'package:flame_3d/camera.dart';
import 'package:flame_3d/graphics.dart';

class World3D extends flame.World {
  final graphics = GraphicsDevice(clearValue: const Color(0xFFFFFFFF));

  final _paint = Paint();

  @override
  void renderFromCamera(Canvas canvas) {
    final camera = CameraComponent3D.currentCamera!;

    final viewport = camera.viewport;
    graphics.begin(
      Size(viewport.virtualSize.x, viewport.virtualSize.y),
      transformMatrix: camera.projectionMatrix,
    );

    // ignore: invalid_use_of_internal_member
    super.renderFromCamera(canvas);

    final image = graphics.end();
    canvas.drawImage(image, (-viewport.virtualSize / 2).toOffset(), _paint);
    image.dispose();
  }
}
