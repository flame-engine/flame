import 'package:flame/components.dart';
import 'package:flame/experimental.dart';
import 'package:flutter/widgets.dart';

enum Direction { horizontal, vertical }

/// Super class for [RowComponent] and [ColumnComponent]
/// A relayout is performed when
///  - a change in this component's children takes place
///  - the [gap] parameter is changed
abstract class LayoutComponent extends PositionComponent {
  LayoutComponent(
    this.direction,
    this.alignment,
    this._gap,
  );
  final Direction direction;
  final MainAxisAlignment alignment;
  bool _allowSetSize = false;

  /// gap between components
  double _gap;

  set gap(double gap) {
    _gap = gap;
    layoutChildren();
  }

  @override
  set size(Vector2 size) {
    assert(_allowSetSize, 'Setting the size is currently unsupported.');
    this.size = size;
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
    final vectorIndex = direction == Direction.horizontal ? 0 : 1;
    final totalSizeOfComponents = list.fold<double>(
      0,
      (previousValue, element) => previousValue + element.size[vectorIndex],
    );
    _allowSetSize = true;
    size[vectorIndex] = totalSizeOfComponents;
    _allowSetSize = false;

    final totalGapsSize = gap * (list.length - 1);

    final availableSpace = totalSizeOfComponents;
    switch (alignment) {
      case MainAxisAlignment.start:
        for (final child in list) {
          child.position.setFrom(currentPosition);
          currentPosition[vectorIndex] += child.size[vectorIndex] + gap;
        }
        break;
      case MainAxisAlignment.end:
        var index = 0;
        double componentsGap;
        for (final child in list.reversed) {
          if (index == 0) {
            componentsGap = 0;
          } else {
            componentsGap = gap;
          }
          currentPosition[vectorIndex] -=
              child.size[vectorIndex] + componentsGap;
          child.position.setFrom(currentPosition);
          index++;
        }
        break;
      case MainAxisAlignment.spaceBetween:
        final freeSpacePerComponent =
            (availableSpace - totalSizeOfComponents - totalGapsSize) /
                (list.length - 1);
        for (final child in list) {
          child.position.setFrom(currentPosition);
          currentPosition[vectorIndex] +=
              freeSpacePerComponent + child.size[vectorIndex] + gap;
        }
        break;
      case MainAxisAlignment.spaceEvenly:
        final freeSpacePerComponent =
            (availableSpace - totalSizeOfComponents - totalGapsSize) /
                (list.length + 1);
        currentPosition[vectorIndex] += freeSpacePerComponent;
        for (final child in list) {
          child.position.setFrom(currentPosition);
          currentPosition[vectorIndex] +=
              freeSpacePerComponent + child.size[vectorIndex] + gap;
        }
        break;
      case MainAxisAlignment.spaceAround:
        final freeSpacePerComponent =
            (availableSpace - totalSizeOfComponents - totalGapsSize) /
                list.length;
        currentPosition[vectorIndex] += freeSpacePerComponent / 2;
        for (final child in list) {
          child.position.setFrom(currentPosition);
          currentPosition[vectorIndex] +=
              freeSpacePerComponent + child.size[vectorIndex] + gap;
        }
        break;
      case MainAxisAlignment.center:
        final freeSpace =
            availableSpace - totalSizeOfComponents - totalGapsSize;
        currentPosition[vectorIndex] += freeSpace / 2;
        for (final child in list) {
          child.position.setFrom(currentPosition);
          currentPosition[vectorIndex] += child.size[vectorIndex] + gap;
        }
        break;
    }
  }
}
