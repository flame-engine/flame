import 'package:flame/text.dart';
import 'package:flutter/rendering.dart' hide TextStyle;

class GroupElement extends BlockElement {
  GroupElement({
    required double width,
    required double height,
    required this.children,
  }) : super(width, height);

  final List<TextElement> children;

  @override
  void translate(double dx, double dy) {
    children.forEach((child) => child.translate(dx, dy));
  }

  @override
  void draw(Canvas canvas) {
    children.forEach((child) => child.draw(canvas));
  }
}
