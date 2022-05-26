import 'package:flame/extensions.dart';
import 'package:flutter/material.dart' hide Image, Gradient;

enum GameColors {
  green,
  blue,
}

extension GameColorExtension on GameColors {
  Color get color {
    switch (this) {
      case GameColors.green:
        return ColorExtension.fromRGBHexString('#14F596');
      case GameColors.blue:
        return ColorExtension.fromRGBHexString('#81DDF9');
    }
  }

  Paint get paint => Paint()..color = color;
}
