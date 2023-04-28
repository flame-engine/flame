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
/// {@endtemplate}
class SimpleFlips {
  /// The angle (in steps of pi/2 rads), clockwise, around the center of the tile.
  final int angle;

  /// The cosine of the rotation.
  final int cos;

  /// The sine of the rotation.
  final int sin;

  /// Whether to flip (across a central vertical axis).
  final bool flip;

  /// {@macro _simple_flips}
  SimpleFlips(this.angle, this.cos, this.sin, {required this.flip});

  /// This is the conversion from the truth table that I drew.
  factory SimpleFlips.fromFlips(Flips flips) {
    final int angle;
    final int cos;
    final int sin;
    final bool flip;

    if (!flips.diagonally && !flips.vertically && !flips.horizontally) {
      angle = 0;
      cos = 1;
      sin = 0;
      flip = false;
    } else if (!flips.diagonally && !flips.vertically && flips.horizontally) {
      angle = 0;
      cos = 1;
      sin = 0;
      flip = true;
    } else if (flips.diagonally && !flips.vertically && flips.horizontally) {
      angle = 1;
      cos = 0;
      sin = 1;
      flip = false;
    } else if (flips.diagonally && flips.vertically && flips.horizontally) {
      angle = 1;
      cos = 0;
      sin = 1;
      flip = true;
    } else if (!flips.diagonally && flips.vertically && flips.horizontally) {
      angle = 2;
      cos = -1;
      sin = 0;
      flip = false;
    } else if (!flips.diagonally && flips.vertically && !flips.horizontally) {
      angle = 2;
      cos = -1;
      sin = 0;
      flip = true;
    } else if (flips.diagonally && flips.vertically && !flips.horizontally) {
      angle = 3;
      cos = 0;
      sin = -1;
      flip = false;
    } else if (flips.diagonally && !flips.vertically && !flips.horizontally) {
      angle = 3;
      cos = 0;
      sin = -1;
      flip = true;
    } else {
      // this should be exhaustive
      throw 'Invalid combination of booleans: $flips';
    }

    return SimpleFlips(angle, cos, sin, flip: flip);
  }
}
