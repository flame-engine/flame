import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:crystal_ball/src/game/components/camera_target.dart';
import 'package:crystal_ball/src/game/components/input_handler.dart';
import 'package:crystal_ball/src/game/constants.dart';
import 'package:crystal_ball/src/game/entities/ground.dart';
import 'package:crystal_ball/src/game/entities/the_ball.dart';
import 'package:crystal_ball/src/game/post_processes/firefly.dart';
import 'package:crystal_ball/src/game/post_processes/ball_glow.dart';
import 'package:crystal_ball/src/game/post_processes/foreground_fog.dart';
import 'package:crystal_ball/src/game/post_processes/water.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame/post_process.dart';

typedef PreloadedPrograms = ({
  FragmentProgram waterFragmentProgram,
  FragmentProgram fogFragmentProgram,
  FragmentProgram fireflyFragmentProgram,
});

class CrystalBallGame extends FlameGame<CrystalBallGameWorld>
    with
        HasKeyboardHandlerComponents,
        HasCollisionDetection,
        SingleGameInstance {
  CrystalBallGame({
    required this.preloadedPrograms,
    required this.pixelRatio,
    required this.random,
  }) : super(
          camera: CameraComponent.withFixedResolution(
            width: kCameraSize.x,
            height: kCameraSize.y,
          ),
          world: CrystalBallGameWorld(random: random),
        ) {
    camera.postProcess = PostProcessGroup(
      postProcesses: [
        PostProcessSequentialGroup(postProcesses: [
          FireflyPostProcess(
            world: world,
            fragmentProgram: preloadedPrograms.fireflyFragmentProgram,
          ),
          WaterPostProcess(
            world: world,
            fragmentProgram: preloadedPrograms.waterFragmentProgram,
          ),
        ]),
        ForegroundFogPostProcess(
          world: world,
          fragmentProgram: preloadedPrograms.fogFragmentProgram,
        ),
      ],
    );

    world.addAll([
      inputHandler = InputHandler(),
    ]);
  }

  @override
  FutureOr<void> onLoad() {
    camera.follow(world.cameraTarget);

    return super.onLoad();
  }

  final PreloadedPrograms preloadedPrograms;
  final double pixelRatio;
  late final InputHandler inputHandler;

  final Random random;
}

class CrystalBallGameWorld extends World {
  CrystalBallGameWorld({
    required this.random,
    super.children,
    super.priority = -0x7fffffff,
    super.key,
  }) {
    addAll([
      BallGlow(),
      theBall = TheBall(position: Vector2.zero()),
      ground = Ground(),
    ]);

    add(cameraTarget);
  }

  late final cameraTarget = CameraTarget();

  late final TheBall theBall;
  late final Ground ground;

  final Random random;
}
