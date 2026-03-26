import 'dart:ui';

import 'package:flame/components.dart' as flame;
import 'package:flame_3d/camera.dart';
import 'package:flame_3d/components.dart';
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
class World3D extends flame.World with flame.HasGameReference {
  /// {@macro world_3d}
  World3D({
    super.children,
    super.priority,
    Color clearColor = const Color(0x00000000),
  }) : context = RenderContext3D(GraphicsDevice(clearValue: clearColor));

  /// The 3D render context attached to this world.
  @internal
  final RenderContext3D context;

  final List<Light> _lights = [];

  /// Register a [light] with this world.
  @internal
  void addLight(Light light) => _lights.add(light);

  /// Unregister a [light] from this world.
  @internal
  void removeLight(Light light) => _lights.remove(light);

  final _paint = Paint();

  @internal
  @override
  void renderFromCamera(Canvas canvas) {
    final camera = CameraComponent3D.currentCamera!;
    final viewport = camera.viewport;

    final devicePixelRatio = MediaQuery.of(game.buildContext!).devicePixelRatio;
    final size = Size(
      viewport.virtualSize.x * devicePixelRatio,
      viewport.virtualSize.y * devicePixelRatio,
    );

    context
      ..lights = _lights
      ..setCamera(camera.viewMatrix, camera.projectionMatrix)
      ..device.begin(size);

    culled = 0;

    // ignore: invalid_use_of_internal_member
    super.renderFromCamera(canvas);
    context.flush();

    final image = context.device.end();
    canvas.drawImageRect(
      image,
      Offset.zero & size,
      (-viewport.virtualSize / 2).toOffset() &
          Size(viewport.virtualSize.x, viewport.virtualSize.y),
      _paint,
    );
    image.dispose();
  }

  // TODO(wolfenrain): this is only here for testing purposes
  int culled = 0;
}
