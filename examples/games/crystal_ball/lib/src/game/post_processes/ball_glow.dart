import 'dart:ui';

import 'package:crystal_ball/src/game/constants.dart';
import 'package:crystal_ball/src/game/game.dart';
import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/shader_pipeline.dart';
import 'package:flutter_shaders/flutter_shaders.dart';

class BallGlow extends PostProcessComponent<BallGlowPostProcess>
    with HasGameReference<CrystalBallGame> {
  BallGlow({
    super.pixelRatio,
    super.position,
    super.scale,
    super.angle,
    super.nativeAngle,
    super.anchor,
    super.children,
    super.priority,
    super.key,
  }) : super(postProcess: BallGlowPostProcess());

  @override
  Future<void> onLoad() async {
    postProcess.world = game.world;
    await super.onLoad();
  }



  @override
  void update(double dt) {
    anchor = Anchor.center;
    position = game.world.cameraTarget.position;
    size = game.size;
  }
}

class BallGlowPostProcess extends FragmentShaderPostProcess {
  late CrystalBallGameWorld world;

  @override
  Future<FragmentProgram> fragmentProgramLoader() {
    return FragmentProgram.fromAsset('shaders/the_ball.frag');
  }

  @override
  void postProcess(
    List<Image> samples,
    Vector2 size,
    Canvas canvas,
  ) {
    final origin =
        world.findGame()!.camera.visibleWorldRect.topLeft.toVector2();

    final theBall = world.theBall;

    final ballpos = theBall.absolutePosition;

    final uvBall = (ballpos - origin)..divide(kCameraSize);

    final velocity = theBall.velocity.clone() / 1600;

    fragmentShader.setFloatUniforms((value) {
      value
        ..setVector(size)
        ..setVector(uvBall)
        ..setVector(-velocity)
        ..setFloat(theBall.gama)
        ..setFloat(theBall.radius);
    });

    super.postProcess(samples, size, canvas);
  }
}
