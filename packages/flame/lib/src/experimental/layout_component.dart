import 'package:flame/components.dart';
import 'package:flame/src/experimental/nullable_vector_2.dart';

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
  }) : _layoutSize = size == null
           ? NullableVector2.blank()
           : NullableVector2.fromVector2(size) {
    resetSize();
  }

  final NullableVector2 _layoutSize;

  NullableVector2 get layoutSize => _layoutSize;

  /// Clobbers current [_layoutSize]. Avoid using within layout logic.
  /// Instead, use [setLayoutAxisLength], as it allows selective setting of
  /// vector components, and subsequently selective setting of the
  /// size components.
  set layoutSize(NullableVector2? newLayoutSize) {
    _layoutSize.setFrom(newLayoutSize);
    resetSize();
  }

  /// A helper function to set the appropriate layout dimension based on
  /// [axis]. This is needed because currently there's no other way, at the
  /// [LayoutComponent] level, to selective set width or height without setting
  /// both.
  /// e.g. if [axis] is [LayoutAxis.y], then that's the y axis.
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
        _layoutSize.x = value;
        width = _layoutSize.x ?? intrinsicSize.x;
      case LayoutAxis.y:
        _layoutSize.y = value;
        height = _layoutSize.y ?? intrinsicSize.y;
    }
  }

  /// Reset the size of this [LayoutComponent] to either the layout dimensions
  /// or the [intrinsicSize].
  void resetSize() {
    width = _layoutSize.x ?? intrinsicSize.x;
    height = _layoutSize.y ?? intrinsicSize.y;
  }

  bool shrinkWrappedIn(LayoutAxis axis) {
    return layoutSize[axis.axisIndex] == null;
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
