import 'package:flame/extensions.dart';
import 'package:flutter/material.dart' hide Image, Gradient;

enum GameColors {
  green,
  blue,
}

extension GameColorExtension on GameColors {
  Color get color {
    return switch (this) {
      GameColors.green => ColorExtension.fromRGBHexString('#14F596'),
      GameColors.blue => ColorExtension.fromRGBHexString('#81DDF9'),
    };
  }

  Paint get paint => Paint()..color = color;
}
