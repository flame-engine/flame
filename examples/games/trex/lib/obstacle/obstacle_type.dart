// ignore_for_file: unused_element_parameter

import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

enum ObstacleType() {
  cactusSmall,
  cactusLarge,
}

class const ObstacleTypeSettings._internal(
  final ObstacleType type, {
  required final Vector2 size,
  required final double y,
  required final int allowedAt,
  required final int multipleAt,
  required final double minGap,
  required final double minSpeed,
  required final List<ShapeHitbox> Function() generateHitboxes,
  final int? numFrames,
  final double? frameRate,
  final double? speedOffset,
}) {
  static const maxGroupSize = 3.0;

  static final cactusSmall = ObstacleTypeSettings._internal(
    ObstacleType.cactusSmall,
    size: Vector2(34.0, 70.0),
    y: -55.0,
    allowedAt: 0,
    multipleAt: 1000,
    minGap: 120.0,
    minSpeed: 0.0,
    generateHitboxes: () => <ShapeHitbox>[
      RectangleHitbox(
        position: Vector2(5.0, 7.0),
        size: Vector2(10.0, 54.0),
      ),
      RectangleHitbox(
        position: Vector2(5.0, 7.0),
        size: Vector2(12.0, 68.0),
      ),
      RectangleHitbox(
        position: Vector2(15.0, 4.0),
        size: Vector2(14.0, 28.0),
      ),
    ],
  );

  static final cactusLarge = ObstacleTypeSettings._internal(
    ObstacleType.cactusLarge,
    size: Vector2(50.0, 100.0),
    y: -74.0,
    allowedAt: 800,
    multipleAt: 1500,
    minGap: 120.0,
    minSpeed: 0.0,
    generateHitboxes: () => <ShapeHitbox>[
      RectangleHitbox(
        position: Vector2(0.0, 26.0),
        size: Vector2(14.0, 40.0),
      ),
      RectangleHitbox(
        position: Vector2(16.0, 0.0),
        size: Vector2(14.0, 98.0),
      ),
      RectangleHitbox(
        position: Vector2(28.0, 22.0),
        size: Vector2(20.0, 40.0),
      ),
    ],
  );

  Sprite sprite(Image spriteImage) {
    return switch (type) {
      ObstacleType.cactusSmall => Sprite(
        spriteImage,
        srcPosition: Vector2(446.0, 2.0),
        srcSize: size,
      ),
      ObstacleType.cactusLarge => Sprite(
        spriteImage,
        srcPosition: Vector2(652.0, 2.0),
        srcSize: size,
      ),
    };
  }
}
