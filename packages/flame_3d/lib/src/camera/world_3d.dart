import 'dart:ui';

import 'package:flame/components.dart' as flame;
import 'package:flame_3d/camera.dart';
import 'package:flame_3d/components.dart';
import 'package:flame_3d/game.dart';
import 'package:flame_3d/graphics.dart';
import 'package:flame_3d/resources.dart';
import 'package:flutter/widgets.dart' show MediaQuery;
import 'package:meta/meta.dart';

/// {@template world_3d}
/// The root component for all 3D world elements.
///
/// The primary feature of this component is that it allows [Component3D]s to
/// render directly to a [GraphicsDevice] instead of the regular rendering.
/// {@endtemplate}
class World3D extends flame.World with flame.HasGameReference<FlameGame3D> {
  /// {@macro world_3d}
  World3D({
    super.children,
    super.priority,
  });

  final List<Light> _lights = [];

  RenderContext3D get context => game.context;

  /// Register a [light] with this world.
  @internal
  void addLight(Light light) => _lights.add(light);

  /// Unregister a [light] from this world.
  @internal
  void removeLight(Light light) => _lights.remove(light);

  @internal
  @override
  void renderFromCamera(Canvas canvas) {
    final camera = CameraComponent3D.currentCamera!;
    final Viewport(virtualSize: size) = camera.viewport;

    final pixelRatio = MediaQuery.devicePixelRatioOf(game.buildContext!);
    final renderSize = Size(size.x * pixelRatio, size.y * pixelRatio);

    context
      ..lights = _lights
      ..setCamera(camera.viewMatrix, camera.projectionMatrix);

    game.device.beginPass(renderSize);
    super.renderFromCamera(canvas);
    context.flush();

    final image = game.device.endPass();
    canvas.drawImageRect(
      image,
      Offset.zero & renderSize,
      Offset(-size.x / 2, -size.y / 2) & Size(size.x, size.y),
      _paint,
    );
    image.dispose();
  }

  static final _paint = Paint();
}
