import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:crystal_ball/src/game/components/camera_target.dart';
import 'package:crystal_ball/src/game/components/input_handler.dart';
import 'package:crystal_ball/src/game/components/platform_spawner.dart';
import 'package:crystal_ball/src/game/constants.dart';
import 'package:crystal_ball/src/game/entities/ground.dart';
import 'package:crystal_ball/src/game/entities/platform.dart';
import 'package:crystal_ball/src/game/entities/reaper.dart';
import 'package:crystal_ball/src/game/entities/the_ball.dart';
import 'package:crystal_ball/src/game/post_processes/ball_glow.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';

typedef PreloadedPrograms = ({
  FragmentProgram waterFragmentProgram,
  FragmentProgram fogFragmentProgram,
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
          world: CrystalBallGameWorld(
            random: random,
            children: [],
          ),
        ) {
    world.addAll([
      inputHandler = InputHandler(),
    ]);
  }

  @override
  FutureOr<void> onLoad() {
    Future.delayed(
      const Duration(milliseconds: 100),
      () {
        camera.follow(world.cameraTarget);
        start();
      },
    );
    return super.onLoad();
  }

  final PreloadedPrograms preloadedPrograms;
  final double pixelRatio;
  late final InputHandler inputHandler;

  final Random random;

  void start() {
    world.cameraTarget.go(
      to: Vector2(0, -400),
      duration: 3,
    );
    world.platformSpawner.needsPreloadCheck = false;
    world.platformSpawner.currentMinY = kStartPlatformHeight;
    world.platformSpawner.spawnIntitialPlatforms();
  }

  void gameOver() {
    for (final platform in world.getPlatforms()) {
      platform.removeFromParent();
    }
    world.theBall.position = Vector2.zero();
    world.cameraTarget.go(
      to: Vector2(0, 0),
      duration: 0.3,
    );
    Future.delayed(const Duration(milliseconds: 1000), start);
  }
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
      platformSpawner = PlatformSpawner(random: random),
      reaper = Reaper(),
      theBall = TheBall(position: Vector2.zero()),
      ground = Ground(),
    ]);

    add(cameraTarget);
  }

  late final cameraTarget = CameraTarget();

  late final PlatformSpawner platformSpawner;
  late final Reaper reaper;
  late final TheBall theBall;
  late final Ground ground;

  final Random random;

  Iterable<Platform> getPlatforms() {
    return children.query<Platform>();
  }
}
