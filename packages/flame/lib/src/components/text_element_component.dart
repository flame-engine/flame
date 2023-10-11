import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/text.dart';

class TextElementComponent extends PositionComponent {
  TextElement element;

  TextElementComponent({
    required this.element,
    super.position,
    super.size,
    super.scale,
    super.angle,
    super.anchor,
    super.children,
    super.priority,
    super.key,
  });

  factory TextElementComponent.fromDocument({
    required DocumentRoot document,
    DocumentStyle? style,
    Vector2? position,
    Vector2? size,
    Vector2? scale,
    double? angle,
    Anchor? anchor,
    List<Component>? children,
    int priority = 0,
    ComponentKey? key,
  }) {
    final effectiveStyle = style ?? DocumentStyle();
    final effectiveSize = _coalesceSize(effectiveStyle, size);
    final element = document.format(
      effectiveStyle,
      width: effectiveSize.x,
      height: effectiveSize.y,
    );
    return TextElementComponent(
      element: element,
      position: position,
      size: effectiveSize,
      scale: scale,
      angle: angle,
      anchor: anchor,
      children: children,
      priority: priority,
      key: key,
    );
  }

  @override
  void render(Canvas canvas) {
    element.draw(canvas);
  }

  static Vector2 _coalesceSize(DocumentStyle style, Vector2? size) {
    final width = style.width ?? size?.x;
    final height = style.height ?? size?.y;
    if (width == null || height == null) {
      throw ArgumentError('Either style.width or size.x must be provided.');
    }
    if ((style.width != null && style.width != width) ||
        (size?.x != null && size?.x != width)) {
      throw ArgumentError(
        'style.width and size.x, if both provided, must match.',
      );
    }
    if ((style.height != null && style.height != height) ||
        (size?.y != null && size?.y != height)) {
      throw ArgumentError(
        'style.height and size.y, if both provided, must match.',
      );
    }
    return Vector2(width, height);
  }
}
