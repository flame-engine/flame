import 'package:flame/components.dart';
import 'package:flutter/widgets.dart';

/// Allows laying out children in a column by defining a [MainAxisAlignment]
/// type.
class ColumnComponent extends LayoutComponent {
  ColumnComponent({
    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.start,
    double gap = 0.0,
  }) : super(Direction.vertical, mainAxisAlignment, gap);

  @override
  void layoutChildren() {
    final list = children.whereType<PositionComponent>().toList();
    if (list.isEmpty) {
      return;
    }
    final currentPosition = Vector2.zero();
    final componentsHeight = list.fold<double>(
      0,
      (previousValue, element) => previousValue + element.height,
    );
    final gapHeight = gap * (list.length - 1);
    final heightAvailable = size.y != 0.0
        ? size.y - absoluteTopLeftPosition.y
        : gameRef.canvasSize.y - absoluteTopLeftPosition.y;

    if (mainAxisAlignment == MainAxisAlignment.start) {
      for (final child in list) {
        child.position = Vector2(currentPosition.x, currentPosition.y);
        currentPosition.y += child.height + gap;
      }
    } else if (mainAxisAlignment == MainAxisAlignment.end) {
      for (final child in list.reversed) {
        currentPosition.y -= child.height + gap;
        child.position = Vector2(currentPosition.x, currentPosition.y);
      }
    } else if (mainAxisAlignment == MainAxisAlignment.spaceBetween) {
      final freeSpacePerComponent =
          (heightAvailable - componentsHeight - gapHeight) / list.length;
      for (final child in list) {
        child.position = Vector2(currentPosition.x, currentPosition.y);
        currentPosition.y += freeSpacePerComponent + child.height + gap;
      }
    } else if (mainAxisAlignment == MainAxisAlignment.spaceEvenly) {
      final freeSpacePerComponent =
          (heightAvailable - componentsHeight - gapHeight) / (list.length + 2);
      currentPosition.y += freeSpacePerComponent;
      for (final child in list) {
        child.position = Vector2(currentPosition.x, currentPosition.y);
        currentPosition.y += freeSpacePerComponent + child.height + gap;
      }
    } else if (mainAxisAlignment == MainAxisAlignment.spaceAround) {
      final freeSpacePerComponent =
          (heightAvailable - componentsHeight - gapHeight) / (list.length + 1);
      currentPosition.y += freeSpacePerComponent / 2;
      for (final child in list) {
        child.position = Vector2(currentPosition.x, currentPosition.y);
        currentPosition.y += freeSpacePerComponent + child.height + gap;
      }
    } else if (mainAxisAlignment == MainAxisAlignment.center) {
      final freeSpace = heightAvailable - componentsHeight - gapHeight;
      currentPosition.y += freeSpace / 2;
      for (final child in list) {
        child.position = Vector2(currentPosition.x, currentPosition.y);
        currentPosition.y += child.height + gap;
      }
    }
  }
}
