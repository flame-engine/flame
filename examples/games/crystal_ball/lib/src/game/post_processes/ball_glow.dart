import 'dart:ui';

import 'package:crystal_ball/src/game/constants.dart';
import 'package:crystal_ball/src/game/game.dart';
import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/post_process.dart';

class BallGlow extends PostProcessComponent<BallGlowPostProcess>
    with HasGameReference<CrystalBallGame> {
  BallGlow({
    super.position,
    super.scale,
    super.angle,
    super.nativeAngle,
    super.anchor = Anchor.center,
    super.children,
    super.priority,
    super.key,
  }) : super(postProcess: BallGlowPostProcess());

  @override
  Future<void> onLoad() {
    postProcess.world = game.world;
    return super.onLoad();
  }

  @override
  void update(double dt) {
    position = game.world.cameraTarget.position;
    size = game.size;
    super.update(dt);
  }
}

/// A post process that draws a glow effect around the ball component
///
/// Differently from the other post processes, this one is not added to the
/// camera directly, but rather a component.
///
/// Also, its shader is not preloaded in the game, but rather loaded
/// when the post process is loaded.
class BallGlowPostProcess extends PostProcess {
  late CrystalBallGameWorld world;

  late final FragmentProgram fragmentProgram;

  @override
  Future<void> onLoad() async {
    // Example of loading a shader from an asset within
    // the post process. Ideally, you will want to load this
    // on something like a loading screen.
    fragmentProgram = await FragmentProgram.fromAsset(
      'packages/crystal_ball/shaders/the_ball.frag',
    );
  }

  @override
  void postProcess(
    Vector2 size,
    Canvas canvas,
  ) {
    final origin =
        world.findGame()!.camera.visibleWorldRect.topLeft.toVector2();
    final theBall = world.theBall;
    final ballPosition = theBall.absolutePosition;
    final uvBall = (ballPosition - origin)..divide(kCameraSize);
    final velocity = theBall.velocity.clone() / 1600;
    final shader = fragmentProgram.fragmentShader();
    shader.setFloatUniforms((value) {
      value
        ..setVector(size)
        ..setVector(uvBall)
        ..setVector(-velocity)
        ..setFloat(theBall.gamma)
        ..setFloat(theBall.radius);
    });

    canvas
      ..save()
      ..drawRect(Offset.zero & size.toSize(), Paint()..shader = shader)
      ..restore();
  }
}
