import 'dart:async';
import 'dart:ui';

import 'package:crystal_ball/src/game/components/camera_target.dart';
import 'package:crystal_ball/src/game/components/input_handler.dart';
import 'package:crystal_ball/src/game/constants.dart';
import 'package:crystal_ball/src/game/entities/ground.dart';
import 'package:crystal_ball/src/game/entities/the_ball.dart';
import 'package:crystal_ball/src/game/post_processes/ball_glow.dart';
import 'package:crystal_ball/src/game/post_processes/firefly.dart';
import 'package:crystal_ball/src/game/post_processes/foreground_fog.dart';
import 'package:crystal_ball/src/game/post_processes/water.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame/post_process.dart';

class CrystalBallGame extends FlameGame<CrystalBallGameWorld>
    with HasKeyboardHandlerComponents, HasCollisionDetection {
  CrystalBallGame({
    required this.preloadedPrograms,
  }) : super(
          camera: CameraComponent.withFixedResolution(
            width: kCameraSize.x,
            height: kCameraSize.y,
          ),
          world: CrystalBallGameWorld(),
        ) {
    camera.postProcess = PostProcessGroup(
      postProcesses: [
        PostProcessSequentialGroup(
          postProcesses: [
            FireflyPostProcess(
              world: world,
              fragmentProgram: preloadedPrograms.fireflyFragmentProgram,
            ),
            WaterPostProcess(
              world: world,
              fragmentProgram: preloadedPrograms.waterFragmentProgram,
            ),
          ],
        ),
        ForegroundFogPostProcess(
          world: world,
          fragmentProgram: preloadedPrograms.fogFragmentProgram,
        ),
      ],
    );

    world.add(
      inputHandler = InputHandler(),
    );
  }

  @override
  FutureOr<void> onLoad() {
    camera.follow(world.cameraTarget);

    return super.onLoad();
  }

  final PreloadedPrograms preloadedPrograms;
  late final InputHandler inputHandler;
}

class CrystalBallGameWorld extends World {
  CrystalBallGameWorld({
    super.children,
    super.key,
  }) {
    addAll([
      BallGlow(),
      theBall = TheBall(position: Vector2.zero()),
      ground = Ground(),
      cameraTarget = CameraTarget(),
    ]);
  }

  late final TheBall theBall;
  late final Ground ground;
  late final CameraTarget cameraTarget;
}

// Set of fragment programs to be loaded
// at the start of the application, on widget level.
typedef PreloadedPrograms = ({
  FragmentProgram waterFragmentProgram,
  FragmentProgram fogFragmentProgram,
  FragmentProgram fireflyFragmentProgram,
});
