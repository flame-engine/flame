import 'package:flame/src/text/elements/block_element.dart';
import 'package:flame/src/text/elements/element.dart';
import 'package:flutter/rendering.dart' hide TextStyle;

class GroupElement extends BlockElement {
  GroupElement({
    required double width,
    required double height,
    required this.children,
  }) : super(width, height);

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
