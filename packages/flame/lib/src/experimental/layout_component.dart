import 'package:flame/components.dart';
import 'package:flame/experimental.dart';
import 'package:flame/src/game/notifying_vector2.dart';
import 'package:flutter/widgets.dart';

enum Direction { horizontal, vertical }

/// Super class for [RowComponent] and [ColumnComponent]
/// A relayout is performed when
///  - a change in this component's children takes place
///  - the size of this component or a parent changes
///  - the [gap] parameter is changed
abstract class LayoutComponent extends PositionComponent {
  LayoutComponent(
    this.direction,
    this.mainAxisAlignment,
    this._gap,
    Vector2? size,
  )   : isManuallySized = size != null,
        super(
          size: size,
        );
  final Direction direction;
  final MainAxisAlignment mainAxisAlignment;
  bool isManuallySized;

  /// gap between components
  double _gap;

  set gap(double gap) {
    _gap = gap;
    layoutChildren();
  }

  double get gap => _gap;

  NotifyingVector2? get _bounds =>
      isManuallySized ? size : findParent<PositionComponent>()?.size;

  @override
  Future<void> onLoad() async {
    final size = _bounds;
    size?.addListener(layoutChildren);
  }

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

    /// Either we have a defined size or we just use the summed width/height of
    /// the current children.
    final componentBounds = _bounds;
    final dimensionAvailable =
        componentBounds != null && componentBounds[vectorIndex] != 0.0
            ? componentBounds[vectorIndex]
            : componentsDimension;
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
        var index = 0;
        double componentsGap;
        for (final child in list.reversed) {
          if (index == 0) {
            componentsGap = 0;
          } else {
            componentsGap = gap;
          }
          currentPosition[vectorIndex] -= direction == Direction.horizontal
              ? child.width + componentsGap
              : child.height + componentsGap;
          child.position = Vector2(currentPosition.x, currentPosition.y);
          index++;
        }
        break;
      case MainAxisAlignment.spaceBetween:
        final freeSpacePerComponent =
            (dimensionAvailable - componentsDimension - gapDimension) /
                (list.length - 1);
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
                (list.length + 1);
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
                list.length;
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
