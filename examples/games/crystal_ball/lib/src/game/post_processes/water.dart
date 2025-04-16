import 'dart:math';
import 'dart:ui';

import 'package:crystal_ball/src/game/game.dart';
import 'package:flame/components.dart';
import 'package:flame/shader_pipeline.dart';
import 'package:flutter_shaders/flutter_shaders.dart';

class WaterPostProcess extends PostProcess {
  WaterPostProcess({
    required this.fragmentProgram,
    super.pixelRatio,
  });

  late CrystalBallGameWorld world;

  final FragmentProgram fragmentProgram;
  late final FragmentShader shader = fragmentProgram.fragmentShader();

  double time = 0;

  @override
  void update(double dt) {
    super.update(dt);
    time += dt;
  }

  @override
  void postProcess(List<Image> samples, Vector2 size, Canvas canvas) {
    final groundpos = world.ground.rectangle.position;
    final camera = CameraComponent.currentCamera!;
    final globalGroundPos = camera.viewfinder.localToGlobal(groundpos);
    final uvGround = globalGroundPos.y / size.y;

    shader
      ..setFloatUniforms((value) {
        value
          ..setVector(size)
          ..setFloat(pixelRatio)
          ..setFloat(uvGround)
          ..setFloat(time);
      })
      ..setImageSampler(0, samples[0]);

    canvas.drawRect(
      Offset.zero & size.toSize(),
      Paint()..shader = shader,
    );
  }

  @override
  int get samplingPasses => 1;
}
