import 'dart:ui';
import 'package:flutter_svg/flutter_svg.dart';

import 'flame.dart';
import 'position.dart';

class Svg {
  DrawableRoot svgRoot = null;
  Size size;

  Svg(String fileName) {
    Flame.assets.readFile(fileName).then((svgString) async {
      this.svgRoot = await svg.fromSvgString(svgString, svgString);
    });
  }

  render(Canvas canvas, double width, double height) {
    svgRoot.scaleCanvasToViewBox(canvas, Size(width, height));
    svgRoot.draw(canvas, null);
  }

  bool loaded() {
    return svgRoot != null;
  }
}
