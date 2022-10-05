import 'package:flame/components.dart';
import 'package:flutter/widgets.dart';

enum Direction { horizontal, vertical }

/// Super class for [RowComponent] and ComponentColumn
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

  void layoutChildren();
}
