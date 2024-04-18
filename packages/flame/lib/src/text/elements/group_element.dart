import 'package:flame/extensions.dart';
import 'package:flame/text.dart';

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

  @override
  Rect get boundingBox {
    return children.fold<Rect?>(
          null,
          (previousValue, element) {
            final box = element.boundingBox;
            return previousValue?.expandToInclude(box) ?? box;
          },
        ) ??
        Rect.zero;
  }
}
