import 'dart:ui';

import 'package:box2d/box2d.dart';

class Viewport extends ViewportTransform {
  Size dimensions;

  double scale;

  Viewport(this.dimensions, this.scale)
      : super(new Vector2(dimensions.width / 2, dimensions.height / 2),
            new Vector2(dimensions.width / 2, dimensions.height / 2), scale);

  double worldAlignBottom(double height) =>
      -(dimensions.height / 2 / scale) + height;

  /**
   * Computes the number of horizontal world meters of this viewport considering a
   * percentage of its width.
   *
   * @param percent percetage of the width in [0, 1] range
   */
  double worldWidth(double percent) {
    return percent * (dimensions.width / scale);
  }

  /**
   * Computes the scroll percentage of total screen width of the current viwerport
   * center position.
   *
   * @param screens multiplies the visible screen with to create a bigger virtual
   * screen.
   * @return the percentage in the range of [0, 1]
   */
  double getCenterHorizontalScreenPercentage({double screens: 1.0}) {
    var width = dimensions.width * screens;
//    print("width: $width");
    var x = center.x + ((screens - 1) * dimensions.width / 2);
    double rest = x.abs() % width;
    double scroll = rest / width;
    return x > 0 ? scroll : 1 - scroll;
  }
}
