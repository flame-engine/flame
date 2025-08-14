import 'package:flame/extensions.dart';

final kCameraSize = Vector2(900, 1600);
const double kPlayerRadius = 20;
final kPlayerSize = Vector2.all(kPlayerRadius * 2);

const double kGravity = 100;
const double kJumpVelocity = 3000;

const double kPlatformSpawnDuration = 0.4;
const double kPlatformVerticalInterval = 1;
const double kStartPlatformHeight = 400;
const double kMeanPlatformInterval = 170;
const double kPlatformIntervalVariation = 100;
const double kPlatformMinWidth = 60;
const double kPlatformWidthVariation = 100;
const double kPlatformHeight = 10;
const double kPlatformPreloadArea = 1600;

const double kReaperTolerance = 100;
