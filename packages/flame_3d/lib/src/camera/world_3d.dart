import 'dart:ui';

import 'package:flame/components.dart' as flame;
import 'package:flame_3d/camera.dart';
import 'package:flame_3d/components.dart';
import 'package:flame_3d/graphics.dart';
import 'package:flutter/cupertino.dart';
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
  }) : device = GraphicsDevice(clearValue: clearColor);

  /// The graphical device attached to this world.
  @internal
  final GraphicsDevice device;

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

    device
      // Set the view matrix
      ..view.setFrom(camera.viewMatrix)
      // Set the projection matrix
      ..projection.setFrom(camera.projectionMatrix)
      ..begin(size);

    culled = 0;
    // ignore: invalid_use_of_internal_member
    super.renderFromCamera(canvas);

    final image = device.end();
    canvas.drawImageRect(
      image,
      Offset.zero & size,
      (-viewport.virtualSize / 2).toOffset() &
          Size(viewport.virtualSize.x, viewport.virtualSize.y),
      _paint,
    );
    image.dispose();
  }

  // TODO(wolfen): this is only here for testing purposes
  int culled = 0;
}
