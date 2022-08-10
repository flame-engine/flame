import 'dart:ui';

import 'package:flame/src/text/elements/block_element.dart';
import 'package:flame/src/text/elements/element.dart';

class GroupElement extends BlockElement {
  GroupElement(super.width, super.height, this.children);

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
