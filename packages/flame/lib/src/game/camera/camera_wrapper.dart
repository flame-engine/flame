import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/src/experimental/camera_component.dart';
import 'package:flame/src/game/camera/camera.dart';
import 'package:flame/src/game/render_context.dart';
import 'package:meta/meta.dart';

/// This class encapsulates FlameGame's rendering functionality.
///
/// This class has been superseded by [CameraComponent].
@internal
class CameraWrapper {
  CameraWrapper(this.camera, this.world);

  final Camera camera;
  final ComponentSet world;

  void update(double dt) {
    camera.update(dt);
  }

  void render(RenderContext context) {
    final canvas = context.canvas;
    PositionType? _previousType;
    canvas.save();
    world.forEach((component) {
      final sameType = component.positionType == _previousType;
      if (!sameType) {
        if (_previousType != null && _previousType != PositionType.widget) {
          canvas.restore();
          canvas.save();
        }
        switch (component.positionType) {
          case PositionType.game:
            camera.viewport.apply(canvas);
            camera.apply(canvas);
            break;
          case PositionType.viewport:
            camera.viewport.apply(canvas);
            break;
          case PositionType.widget:
        }
      }
      component.renderTree(context);
      _previousType = component.positionType;
    });

    if (_previousType != PositionType.widget) {
      canvas.restore();
    }
  }
}
