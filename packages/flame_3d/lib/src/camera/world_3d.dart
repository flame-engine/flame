import 'dart:ui';

import 'package:flame/components.dart' as flame;
import 'package:flame_3d/camera.dart';
import 'package:flame_3d/components.dart';
import 'package:flame_3d/graphics.dart';

/// {@template world_3d}
/// The root component for all 3D world elements.
///
/// The primary feature of this component is that it allows [Component3D]s to
/// render directly to a [GraphicsDevice] instead of the regular rendering.
/// {@endtemplate}
class World3D extends flame.World {
  /// {@macro world_3d}
  World3D({
    super.children,
    super.priority,
    Color clearColor = const Color(0x00000000),
  }) : graphics = GraphicsDevice(clearValue: clearColor);

  /// The graphical device attached to this world.
  final GraphicsDevice graphics;

  final _paint = Paint();

  @override
  void renderFromCamera(Canvas canvas) {
    final camera = CameraComponent3D.currentCamera!;

    final viewport = camera.viewport;
    graphics.begin(
      Size(viewport.virtualSize.x, viewport.virtualSize.y),
      transformMatrix: camera.projectionMatrix,
    );

    culled = 0;
    // ignore: invalid_use_of_internal_member
    super.renderFromCamera(canvas);

    final image = graphics.end();
    canvas.drawImage(image, (-viewport.virtualSize / 2).toOffset(), _paint);
    image.dispose();
  }

  // TODO(wolfen): this is only here for testing purposes
  int culled = 0;
}
