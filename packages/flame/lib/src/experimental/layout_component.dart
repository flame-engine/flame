import 'package:flame/components.dart';

enum LayoutAxis {
  x(0),
  y(1);

  const LayoutAxis(this.axisIndex);

  /// Necessary for use with LinearLayoutComponent's Direction
  final int axisIndex;
}

abstract class LayoutComponent extends PositionComponent {
  LayoutComponent({
    required super.key,
    required super.position,
    required Vector2? size,
    required super.anchor,
    required super.priority,
    super.children,
  }) : _layoutSizeX = size?.x,
       _layoutSizeY = size?.y {
    resetSize();
  }

  double? _layoutSizeX;
  double? _layoutSizeY;

  double? get layoutSizeX => _layoutSizeX;
  double? get layoutSizeY => _layoutSizeY;

  /// Sets both layout axes at the same time, and consequently, sets the [size]
  /// in one go.
  /// If you intend to only selectively set one axis length at a time, use
  /// [setLayoutAxisLength].
  ///
  /// This is *not* equivalent to calling [setLayoutAxisLength] for both
  /// axes. Doing so would result size listeners being called twice: once for
  /// the x axis, and again for the y axis.
  void setLayoutSize(double? layoutSizeX, double? layoutSizeY) {
    _layoutSizeX = layoutSizeX;
    _layoutSizeY = layoutSizeY;
    resetSize();
  }

  /// Sets the appropriate layout dimension based on [axis]. This is needed
  /// because currently there's no other way, at the [LayoutComponent] level,
  /// to selectively set width or height without setting both.
  /// e.g. to set Y axis to 100, `setLayoutAxisLength(LayoutAxis.y, 100)`
  ///
  /// If you intend to set both axes at the same time, use [setLayoutSize]
  ///
  /// This is *not* equivalent to calling [setLayoutSize] with one of the axes
  /// set to null. Doing so would actually set the axis to the intrinsic length
  /// of that dimension.
  void setLayoutAxisLength(LayoutAxis axis, double? value) {
    // This is necessary because we cannot extend the accessor assignment of
    // NullableVector2 to trigger some extra functionality
    // (i.e. setting height/width) when the accessor is set.
    //
    // We also cannot use listeners at the moment, because listeners are
    // triggered when either height/width are set, when we need things to happen
    // *only* when height or width are set. Current functionality results in
    // a race condition.
    switch (axis) {
      case LayoutAxis.x:
        _layoutSizeX = value;
        width = _layoutSizeX ?? intrinsicSize.x;
      case LayoutAxis.y:
        _layoutSizeY = value;
        height = _layoutSizeY ?? intrinsicSize.y;
    }
  }

  /// Reset the size of this [LayoutComponent] to either the layout dimensions
  /// or the [intrinsicSize].
  void resetSize() {
    size.setValues(
      _layoutSizeX ?? intrinsicSize.x,
      _layoutSizeY ?? intrinsicSize.y,
    );
  }

  bool isShrinkWrappedIn(LayoutAxis axis) {
    return switch (axis) {
      LayoutAxis.x => layoutSizeX == null,
      LayoutAxis.y => layoutSizeY == null,
    };
  }

  @override
  void onChildrenChanged(Component child, ChildrenChangeType type) {
    if (child is! PositionComponent) {
      return;
    }
    if (type == ChildrenChangeType.added) {
      child.size.addListener(layoutChildren);
    } else {
      child.size.removeListener(layoutChildren);
    }
    layoutChildren();
  }

  /// The method to refresh the layout, triggered by various events.
  /// (e.g. [onChildrenChanged], size changes on both this component and its
  /// children)
  ///
  /// Override this method for any specific layout needs.
  void layoutChildren();

  /// A helper property to get only the [PositionComponent]s
  /// among the [children].
  List<PositionComponent> get positionChildren =>
      children.whereType<PositionComponent>().toList();

  /// The smallest possible size this component can possibly have, as a
  /// container of other components, and given whatever constraints any
  /// subclass of [LayoutComponent] may prescribe.
  Vector2 get intrinsicSize;
}
