import 'package:flame/components.dart';
import 'package:flutter/widgets.dart';

/// Allows laying out children in a row by defining a [MainAxisAlignment] type.
/// A relayout is performed when
///  - a new child is added
///  - an existing child changes its size
///  - the [gap] parameter is changed
class ComponentRow extends LayoutComponent {
  ComponentRow({
    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.start,
    double gap = 0.0,
  }) : super(Direction.horizontal, mainAxisAlignment, gap);

  @override
  void layoutChildren() {
    final list = children.whereType<PositionComponent>().toList();
    if (list.isEmpty) {
      return;
    }
    final currentPosition = Vector2.zero();
    double componentsWidth =
      list.fold(0, (previousValue, element) => previousValue + element.width);
    final gapWidth = gap * (list.length - 1);
    final widthAvailable = size.x != 0.0
        ? size.x - absoluteTopLeftPosition.x
        : gameRef.canvasSize.x - absoluteTopLeftPosition.x;

    if (mainAxisAlignment == MainAxisAlignment.start) {
      for (final child in list) {
        child.position = Vector2(currentPosition.x, currentPosition.y);
        currentPosition.x += child.width + gap;
      }
    } else if (mainAxisAlignment == MainAxisAlignment.end) {
      for (final child in list.reversed) {
        currentPosition.x -= (child.width + gap);
        child.position = Vector2(currentPosition.x, currentPosition.y);
      }
    } else if (mainAxisAlignment == MainAxisAlignment.spaceBetween) {
      final freeSpacePerComponent =
          (widthAvailable - componentsWidth - gapWidth) / list.length;
      for (final child in list) {
        child.position = Vector2(currentPosition.x, currentPosition.y);
        currentPosition.x += (freeSpacePerComponent + child.width + gap);
      }
    } else if (mainAxisAlignment == MainAxisAlignment.spaceEvenly) {
      final freeSpacePerComponent =
          (widthAvailable - componentsWidth - gapWidth) / (list.length + 2);
      currentPosition.x += freeSpacePerComponent;
      for (final child in list) {
        child.position = Vector2(currentPosition.x, currentPosition.y);
        currentPosition.x += (freeSpacePerComponent + child.width + gap);
      }
    } else if (mainAxisAlignment == MainAxisAlignment.spaceAround) {
      final freeSpacePerComponent =
          (widthAvailable - componentsWidth - gapWidth) / (list.length + 1);
      currentPosition.x += freeSpacePerComponent / 2;
      for (final child in list) {
        child.position = Vector2(currentPosition.x, currentPosition.y);
        currentPosition.x += (freeSpacePerComponent + child.width + gap);
      }
    } else if (mainAxisAlignment == MainAxisAlignment.center) {
      final freeSpace = widthAvailable - componentsWidth - gapWidth;
      currentPosition.x += freeSpace / 2;
      for (final child in list) {
        child.position = Vector2(currentPosition.x, currentPosition.y);
        currentPosition.x += (child.width + gap);
      }
    }
  }
}
