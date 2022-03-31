import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
// ignore: implementation_imports
import 'package:flame/src/game/camera/camera_wrapper.dart';

import 'body_component.dart';

/// This class encapsulates Forge2DGame's rendering functionality. It will be
/// converted into a proper Component in a future release, but until then
/// using it in any code other than the Forge2DGame class is unsafe and
/// not recommended.
// ignore: invalid_use_of_internal_member
class Forge2DCameraWrapper extends CameraWrapper {
  Forge2DCameraWrapper(Camera camera, ComponentSet world)
      : super(camera, world);

  final Matrix4 _flipYTransform = Matrix4.identity()..scale(1.0, -1.0);

  @override
  void render(Canvas canvas) {
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
      if (component is! BodyComponent) {
        canvas.save();
        canvas.transform(_flipYTransform.storage);
      }
      component.renderTree(canvas);
      if (component is! BodyComponent) {
        canvas.restore();
      }
      _previousType = component.positionType;
    });

    if (_previousType != PositionType.widget) {
      canvas.restore();
    }
  }
}
