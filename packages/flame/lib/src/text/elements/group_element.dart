
import 'dart:ui';

import 'package:flame/src/text/elements/element.dart';

class GroupElement extends Element {
  GroupElement(this.children);

  final List<Element> children;

  @override
  void translate(double dx, double dy) {
    children.forEach((child) => child.translate(dx, dy));
  }

  @override
  void render(Canvas canvas) {
    children.forEach((child) => child.render(canvas));
  }
}
