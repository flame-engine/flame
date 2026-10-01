import 'dart:math' as math;

import 'package:tiled/tiled.dart';

/// {@template _simple_flips}
/// Tiled represents all flips and rotation using three possible flips:
/// horizontal, vertical and diagonal.
/// This class converts that representation to a simpler one, that uses one
/// angle (with pi/2 steps) and one flip (horizontal). All vertical flips are
/// represented as horizontal flips + 180º.
/// Further reference:
/// https://doc.mapeditor.org/en/stable/reference/tmx-map-format/#tile-flipping.
///
/// `cos` and `sin` are the cosine and sine of the rotation respectively, and
/// and are provided for simple calculation with RSTransform.
/// Further reference:
/// https://api.flutter.dev/flutter/dart-ui/RSTransform/RSTransform.html
///
/// Hexagonal maps are the exception: Tiled rotates their tiles in steps of
/// pi/3 instead, see [SimpleFlips.fromHexagonalFlips].
/// {@endtemplate}
class SimpleFlips {
  /// The angle (in steps of pi/2 rads, or pi/3 rads if [isHexagonal] is true),
  /// clockwise, around the center of the tile.
  final int angle;

  /// The cosine of the rotation.
  final double cos;

  /// The sine of the rotation.
  final double sin;

  /// Whether to flip (across a central vertical axis).
  final bool flip;

  /// Whether the rotation is in steps of pi/3, as in hexagonal maps, instead
  /// of steps of pi/2.
  ///
  /// Tiles that are rotated in steps of pi/2 swap their width and height.
  final bool isHexagonal;

  /// {@macro _simple_flips}
  SimpleFlips(
    this.angle,
    this.cos,
    this.sin, {
    required this.flip,
    this.isHexagonal = false,
  });

  /// Converts the flips of a tile in a hexagonal map.
  ///
  /// Tiled doesn't rotate tiles in steps of 90º in hexagonal maps, the
  /// diagonal flip rotates the tile 60º and the flag Tiled calls "rotated
  /// hexagonal 120" (anti-diagonal here) rotates it a further 120º. Horizontal
  /// and vertical flips mirror the tile before it is rotated.
  factory SimpleFlips.fromHexagonalFlips(Flips flips) {
    var angle = (flips.diagonally ? 1 : 0) + (flips.antiDiagonally ? 2 : 0);
    var flip = flips.horizontally;
    if (flips.vertically) {
      // A vertical flip is a horizontal flip + 180º.
      angle += 3;
      flip = !flip;
    }
    angle %= 6;
    final radians = angle * math.pi / 3;
    return SimpleFlips(
      angle,
      _exact(math.cos(radians)),
      _exact(math.sin(radians)),
      flip: flip,
      isHexagonal: true,
    );
  }

  /// Avoids tiny floating point errors for the exact values of the angles.
  static double _exact(double value) => value.abs() < 1e-12 ? 0 : value;

  /// This is the conversion from the truth table that I drew.
  factory SimpleFlips.fromFlips(Flips flips) {
    final int angle;
    final double cos;
    final double sin;
    final bool flip;

    if (!flips.diagonally && !flips.vertically && !flips.horizontally) {
      angle = 0;
      cos = 1.0;
      sin = 0.0;
      flip = false;
    } else if (!flips.diagonally && !flips.vertically && flips.horizontally) {
      angle = 0;
      cos = 1.0;
      sin = 0.0;
      flip = true;
    } else if (flips.diagonally && !flips.vertically && flips.horizontally) {
      angle = 1;
      cos = 0.0;
      sin = 1.0;
      flip = false;
    } else if (flips.diagonally && flips.vertically && flips.horizontally) {
      angle = 1;
      cos = 0.0;
      sin = 1.0;
      flip = true;
    } else if (!flips.diagonally && flips.vertically && flips.horizontally) {
      angle = 2;
      cos = -1.0;
      sin = 0.0;
      flip = false;
    } else if (!flips.diagonally && flips.vertically && !flips.horizontally) {
      angle = 2;
      cos = -1.0;
      sin = 0.0;
      flip = true;
    } else if (flips.diagonally && flips.vertically && !flips.horizontally) {
      angle = 3;
      cos = 0.0;
      sin = -1.0;
      flip = false;
    } else if (flips.diagonally && !flips.vertically && !flips.horizontally) {
      angle = 3;
      cos = 0.0;
      sin = -1.0;
      flip = true;
    } else {
      // this should be exhaustive
      throw 'Invalid combination of booleans: $flips';
    }

    return SimpleFlips(angle, cos, sin, flip: flip);
  }
}
