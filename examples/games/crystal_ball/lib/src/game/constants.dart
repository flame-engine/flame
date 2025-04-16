import 'dart:math';

import 'package:flame/extensions.dart';

final kCameraSize = Vector2(900, 1600);
const double kPlayerRadius = 20;
final kPlayerSize = Vector2.all(kPlayerRadius * 2);


const double kGravity = 100;
const double kJumpVelocity = 3000;

const double kPlatformSpawnDuration = 0.4;
const double kPlatformVerticalInterval = 1;
const double kStartPlatformHeight = 400;
const double kMeanPlatformInterval = 370;
const double kPlatformIntervalVariation = 100;
const double kPlatformMinWidth = 60;
const double kPlatformWidthVariation = 100;
const double kPlatformHeight = 10;
const double kPlatformPreloadArea = 1600;

const double kReaperTolerance = 100;

extension RandomX on Random {
  double nextDoubleAntiSmooth() {
    final normal = nextDouble();
    return _invSmoothstep(normal);
  }

  double nextVariation() {
    return nextDoubleAntiSmooth() * 2 - 1;
  }

  double nextDoubleInBetween(double min, double max) {
    return nextDoubleAntiSmooth() * (max - min) + min;
  }
}

double _invSmoothstep(double normal) {
  if (normal <= 0) {
    return 0;
  }
  if (normal >= 1) {
    return 1;
  }
  return 0.5 - sin(asin(1 - 2 * normal) / 3);
}
