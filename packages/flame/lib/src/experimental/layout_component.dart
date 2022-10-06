import 'package:flame/components.dart';
import 'package:flame/experimental.dart';
import 'package:flutter/widgets.dart';

enum Direction { horizontal, vertical }

/// Super class for [RowComponent] and [ColumnComponent]
/// A relayout is performed when
///  - a change in this component's children takes place
///  - the [gap] parameter is changed
abstract class LayoutComponent extends PositionComponent with HasGameRef {
  LayoutComponent(this.direction, this.mainAxisAlignment, this._gap);
  final Direction direction;
  final MainAxisAlignment mainAxisAlignment;

  /// gap between components
  double _gap;

  set gap(double gap) {
    _gap = gap;
    layoutChildren();
  }

  double get gap => _gap;

  @override
  void onChildrenChanged(Component child, ChildrenChangeType changeType) {
    layoutChildren();
  }

  void layoutChildren() {
    final list = children.whereType<PositionComponent>().toList();
    if (list.isEmpty) {
      return;
    }
    final currentPosition = Vector2.zero();
    final componentsDimension = list.fold<double>(
      0,
      (previousValue, element) => direction == Direction.horizontal
          ? previousValue + element.width
          : previousValue + element.height,
    );
    final vectorIndex = direction == Direction.horizontal ? 0 : 1;
    final gapDimension = gap * (list.length - 1);
    final dimensionAvailable = size[vectorIndex] != 0.0
        ? size[vectorIndex] - absoluteTopLeftPosition[vectorIndex]
        : gameRef.canvasSize[vectorIndex] -
            absoluteTopLeftPosition[vectorIndex];

    switch (mainAxisAlignment) {
      case MainAxisAlignment.start:
        for (final child in list) {
          child.position = Vector2(currentPosition.x, currentPosition.y);
          currentPosition[vectorIndex] += direction == Direction.horizontal
              ? child.width + gap
              : child.height + gap;
        }
        break;
      case MainAxisAlignment.end:
        for (final child in list.reversed) {
          currentPosition[vectorIndex] -= direction == Direction.horizontal
              ? child.width + gap
              : child.height + gap;
          child.position = Vector2(currentPosition.x, currentPosition.y);
        }
        break;
      case MainAxisAlignment.spaceBetween:
        final freeSpacePerComponent =
            (dimensionAvailable - componentsDimension - gapDimension) /
                list.length;
        for (final child in list) {
          child.position = Vector2(currentPosition.x, currentPosition.y);
          currentPosition[vectorIndex] += direction == Direction.horizontal
              ? freeSpacePerComponent + child.width + gap
              : freeSpacePerComponent + child.height + gap;
        }
        break;
      case MainAxisAlignment.spaceEvenly:
        final freeSpacePerComponent =
            (dimensionAvailable - componentsDimension - gapDimension) /
                (list.length + 2);
        currentPosition[vectorIndex] += freeSpacePerComponent;
        for (final child in list) {
          child.position = Vector2(currentPosition.x, currentPosition.y);
          currentPosition[vectorIndex] += direction == Direction.horizontal
              ? freeSpacePerComponent + child.width + gap
              : freeSpacePerComponent + child.height + gap;
        }
        break;
      case MainAxisAlignment.spaceAround:
        final freeSpacePerComponent =
            (dimensionAvailable - componentsDimension - gapDimension) /
                (list.length + 1);
        currentPosition[vectorIndex] += freeSpacePerComponent / 2;
        for (final child in list) {
          child.position = Vector2(currentPosition.x, currentPosition.y);
          currentPosition[vectorIndex] += direction == Direction.horizontal
              ? freeSpacePerComponent + child.width + gap
              : freeSpacePerComponent + child.height + gap;
        }
        break;
      case MainAxisAlignment.center:
        final freeSpace =
            dimensionAvailable - componentsDimension - gapDimension;
        currentPosition[vectorIndex] += freeSpace / 2;
        for (final child in list) {
          child.position = Vector2(currentPosition.x, currentPosition.y);
          currentPosition[vectorIndex] += direction == Direction.horizontal
              ? child.width + gap
              : child.height + gap;
        }
        break;
    }
  }
}
