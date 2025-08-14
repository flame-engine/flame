import 'dart:ui';

import 'package:crystal_ball/src/game/constants.dart';
import 'package:crystal_ball/src/game/game.dart';
import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/post_process.dart';

class FireflyPostProcess extends PostProcess {
  FireflyPostProcess({
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
    final fogShader = shader;
    fogShader.setFloatUniforms((value) {
      final camera = CameraComponent.currentCamera!;

      final groundPosition =
          world.ground.rectangle.absolutePosition + Vector2(0, 1800);
      final globalGroundPosition = camera.viewfinder.localToGlobal(
        groundPosition,
      );
      final uvGround = globalGroundPosition.y / size.y;

      final cameraVerticalPos = world.cameraTarget.position.clone()
        ..absolute()
        ..y *= 1.9;

      final uvCameraVerticalPos = cameraVerticalPos..divide(kCameraSize);

      value
        ..setVector(size)
        ..setFloat(uvGround)
        ..setFloat(uvCameraVerticalPos.y)
        ..setFloat(3.2)
        ..setFloat(time * 0.5);
    });

    canvas.drawRect(
      Offset.zero & size.toSize(),
      Paint()..shader = fogShader,
    );

    renderSubtree(canvas);
  }
}
