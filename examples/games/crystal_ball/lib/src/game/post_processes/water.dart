import 'dart:ui';

import 'package:crystal_ball/src/game/game.dart';
import 'package:flame/components.dart';
import 'package:flame/post_process.dart';

class WaterPostProcess extends PostProcess {
  WaterPostProcess({
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
    final groundPosition = world.ground.rectangle.position;
    final camera = CameraComponent.currentCamera!;
    final globalGroundPosition =
        camera.viewfinder.localToGlobal(groundPosition);
    final uvGround = globalGroundPosition.y / size.y;

    final preRenderedSubtree = rasterizeSubtree();

    shader
      ..setFloatUniforms((value) {
        value
          ..setVector(size)
          ..setFloat(pixelRatio)
          ..setFloat(uvGround)
          ..setFloat(time);
      })
      ..setImageSampler(0, preRenderedSubtree);

    canvas.drawRect(
      Offset.zero & size.toSize(),
      Paint()..shader = shader,
    );
  }
}
