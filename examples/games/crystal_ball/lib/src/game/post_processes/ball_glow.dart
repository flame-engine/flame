import 'dart:ui';

import 'package:crystal_ball/src/game/constants.dart';
import 'package:crystal_ball/src/game/game.dart';
import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/post_process.dart';
import 'package:flutter_shaders/flutter_shaders.dart';

class BallGlow extends PostProcessComponent<BallGlowPostProcess>
    with HasGameReference<CrystalBallGame> {
  BallGlow({
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

class BallGlowPostProcess extends PostProcess {
  late CrystalBallGameWorld world;

  late final FragmentProgram fragmentProgram;

  @override
  Future<void> onLoad() async {
    // example of loading a shader from an asset within
    // the post process. Ideally, you will want to load this
    // on something like a loading screen
    fragmentProgram = await FragmentProgram.fromAsset('shaders/the_ball.frag');
  }

  @override
  void postProcess(
    Vector2 size,
    Canvas canvas,
  ) {
    final origin =
        world.findGame()!.camera.visibleWorldRect.topLeft.toVector2();

    final theBall = world.theBall;

    final ballpos = theBall.absolutePosition;

    final uvBall = (ballpos - origin)..divide(kCameraSize);

    final velocity = theBall.velocity.clone() / 1600;

    final shader = fragmentProgram.fragmentShader();

    shader.setFloatUniforms((value) {
      value
        ..setVector(size)
        ..setVector(uvBall)
        ..setVector(-velocity)
        ..setFloat(theBall.gama)
        ..setFloat(theBall.radius);
    });

    canvas
      ..save()
      ..drawRect(Offset.zero & size.toSize(), Paint()..shader = shader)
      ..restore();
  }
}
