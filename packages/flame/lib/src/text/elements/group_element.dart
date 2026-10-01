import 'package:flame/extensions.dart';
import 'package:flame/text.dart';

class GroupElement({
  required double width,
  required double height,
  required final List<TextElement> children,
}) extends BlockElement {
  this : super(width, height);

  @override
  void translate(double dx, double dy) {
    for (final child in children) {
      child.translate(dx, dy);
    }
  }

  @override
  void draw(Canvas canvas) {
    for (final child in children) {
      child.draw(canvas);
    }
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

  @override
  void dispose() {
    for (final child in children) {
      child.dispose();
    }
  }
}
