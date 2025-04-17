import 'dart:ui';

import 'package:crystal_ball/src/game/constants.dart';
import 'package:crystal_ball/src/game/game.dart';
import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/post_process.dart';
import 'package:flutter_shaders/flutter_shaders.dart';

class ForegroundFogPostProcess extends PostProcess {
  ForegroundFogPostProcess({
    required this.fragmentProgram,
    required this.world,
    super.pixelRatio,
  });

  final FragmentProgram fragmentProgram;
  final CrystalBallGameWorld world;

  late final FragmentShader shader = fragmentProgram.fragmentShader();

  double time = 0;
  @override
  void update(double dt) {
    super.update(dt);
    time += dt;
  }

  @override
  void postProcess(Vector2 size, Canvas canvas) {
    //  renderSubtree(canvas);
    // return;
    final origin =
        CameraComponent.currentCamera!.visibleWorldRect.topLeft.toVector2();

    shader.setFloatUniforms((value) {
      value.setVector(size);

      final groundpos =
          world.ground.rectangle.absolutePosition + Vector2(0, 200);
      final uvGround = (groundpos - origin)..divide(kCameraSize);

      final cameraVerticalPos = world.cameraTarget.position.clone()..absolute();

      final uvCameraVerticalPos = cameraVerticalPos..divide(kCameraSize);

      value
        ..setFloat(uvGround.y)
        ..setFloat(uvCameraVerticalPos.y)
        ..setFloat(0.3)
        ..setFloat(time);
    });

    canvas
      ..save()
      ..drawRect(
        Offset.zero & size.toSize(),
        Paint()
          // ..color = const Color(0xFF00F000)
          ..shader = shader,
      )
      ..restore();
  }
}
