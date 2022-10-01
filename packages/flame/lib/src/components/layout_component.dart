import 'package:flame/components.dart';
import 'package:flutter/widgets.dart';

enum Direction { horizontal, vertical }

/// Super class for [RowComponent] and ComponentColumn
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
  Future<void>? add(Component component) {
    assert(
      component is PositionComponent,
      'The added component has to be a child of PositionComponent',
    );
    (component as PositionComponent).size.addListener(layoutChildren);

    component.mounted.then((_) => layoutChildren());
    return super.add(component);
  }

  @override
  void remove(Component component) {
    assert(
      contains(component),
      'This component is not a child of this class',
    );
    (component as PositionComponent).size.removeListener(layoutChildren);

    super.remove(component);
    // will be corrected when this issue has been resolved:
    // https://github.com/flame-engine/flame/issues/1956
    Future.delayed(const Duration(milliseconds: 50), layoutChildren);
  }

  @protected
  void layoutChildren();
}
