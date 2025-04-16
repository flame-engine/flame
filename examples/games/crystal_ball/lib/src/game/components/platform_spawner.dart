import 'dart:math';

import 'package:crystal_ball/src/game/constants.dart';
import 'package:crystal_ball/src/game/entities/platform.dart';
import 'package:crystal_ball/src/game/game.dart';
import 'package:flame/components.dart';

class PlatformSpawner extends Component with HasGameReference<CrystalBallGame> {
  PlatformSpawner({
    required this.random,
  });

  final Random random;

  double currentMinY = kStartPlatformHeight;

  bool needsPreloadCheck = false;

  Platform? lastPlatform;

  Future<Platform> spawnPlatform({bool advance = true, double? avoidX}) async {
    final width = kPlatformMinWidth +
        random.nextDoubleAntiSmooth() * kPlatformWidthVariation;
    final y = currentMinY;
    final padedHalfWidth = (kCameraSize.x - 150 - width / 2) / 2;

    final lastX = lastPlatform?.position.x ?? 0;

    late final double x;
    if (avoidX != null) {
      if (avoidX < 0) {
        x = random.nextDoubleInBetween(0, padedHalfWidth);
      } else {
        x = random.nextDoubleInBetween(-padedHalfWidth, 0);
      }
    } else {
      var minX = padedHalfWidth;
      var maxX = padedHalfWidth;
      if (lastX < -(padedHalfWidth * 0.6)) {
        maxX = padedHalfWidth * 0.4;
      } else if (lastX > (padedHalfWidth * 0.6)) {
        minX = padedHalfWidth * 0.4;
      }
      x = random.nextDoubleInBetween(-minX, maxX);
    }

    final color = PlatformColor.rarityRandom(random);
    final size = Vector2(width, kPlatformHeight);

    final result = lastPlatform = Platform(
      position: Vector2(x, -y),
      random: random,
      size: size,
      color: color,
    );
    await game.world.add(
      result,
    );

    final interval = kMeanPlatformInterval +
        random.nextVariation() * kPlatformIntervalVariation;
    if (advance) {
      currentMinY += interval;
    }

    return result;
  }

  Future<void> preloadPlatforms() async {
    needsPreloadCheck = false;
    var count = 0;
    while (distanceToCameraTop < kPlatformPreloadArea && count < 10) {
      final spawnTwo = random.nextInt(30) == 0;
      if (spawnTwo) {
        final plat = await spawnPlatform(advance: false);
        await spawnPlatform(avoidX: plat.position.x);
      } else {
        await spawnPlatform();
      }

      count++;
    }
    needsPreloadCheck = true;
  }

  Future<void> spawnIntitialPlatforms() async {
    await Future<void>.delayed(const Duration(milliseconds: 1200));
    var count = 0;
    while (distanceToCameraTop < kPlatformPreloadArea && count < 10) {
      final delayed = Future<void>.delayed(
        Duration(
          milliseconds: (kPlatformSpawnDuration * 1000).floor(),
        ),
      );
      await Future.wait<void>([spawnPlatform(), delayed]);
      count++;
    }
    needsPreloadCheck = true;
  }

  double get cameraTop => game.world.cameraTarget.y - kCameraSize.y / 2;

  double get distanceToCameraTop => currentMinY - (-cameraTop);

  @override
  void update(double dt) {
    super.update(dt);
    if (needsPreloadCheck && distanceToCameraTop < kPlatformPreloadArea) {
      needsPreloadCheck = false;
      preloadPlatforms();
    }
  }
}
