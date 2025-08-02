import 'package:flame/components.dart';
import 'package:flame/src/experimental/expanded_component.dart';
import 'package:flame/src/experimental/nullable_vector_2.dart';
import 'package:flame/src/game/notifying_vector2.dart';
import 'package:meta/meta.dart';

abstract class LayoutComponent extends PositionComponent {
  LayoutComponent({
    required super.key,
    required super.position,
    required double? layoutWidth,
    required double? layoutHeight,
    required super.anchor,
    required super.priority,
    super.children,
  }) {
    this.layoutWidth = layoutWidth;
    this.layoutHeight = layoutHeight;
  }

  double? _layoutWidth;

  double? get layoutWidth => _layoutWidth;

  set layoutWidth(double? value) {
    _layoutWidth = value;
    width = value ?? intrinsicSize.x;
  }

  double? _layoutHeight;

  double? get layoutHeight => _layoutHeight;

  set layoutHeight(double? value) {
    _layoutHeight = value;
    height = value ?? intrinsicSize.y;
  }

  /// Reset the size of this [LayoutComponent] to either the layout dimensions
  /// or the [intrinsicSize].
  void resetSize() {
    width = layoutWidth ?? intrinsicSize.x;
    height = layoutHeight ?? intrinsicSize.y;
  }

  /// A helper function to set the appropriate layout dimension based on
  /// [axisIndex].
  /// e.g. if [axisIndex] is 1, then that's the y axis.
  void setLayoutAxisLength(int axisIndex, double? value) {
    switch (axisIndex) {
      case 0:
        layoutWidth = value;
      case 1:
        layoutHeight = value;
      default:
        throw Exception('Unsupported axisIndex: $axisIndex');
    }
  }

  /// returns the layout dimension based on the [axisIndex].
  /// e.g. if [axisIndex] is 0, then that's the x axis.
  double? layoutAxisLength(int axisIndex) {
    return switch (axisIndex) {
      0 => layoutWidth,
      1 => layoutHeight,
      _ => throw Exception('Unsupported axisIndex: $axisIndex')
    };
  }

  bool shrinkWrappedIn(int index) {
    return layoutAxisLength(index) == null;
  }

  /// This size setter is nullable unlike its superclass, to allow this
  /// [LayoutComponent] to shrink-wrap its children. In other words, it sets
  /// the size to [intrinsicSize]. This setter also records the intent to
  /// shrink-wrap via the [shrinkWrapMode] property, so that [layoutChildren]
  /// knows whether or not to invoke this setter.
  ///
  /// Internally, this [size] setter should only ever be invoked upon
  /// construction, and inside [layoutChildren] to make it easier to track and
  /// reason about.
  ///
  /// Externally, this [size] setter is designed as an API, so a library user
  /// should feel free to use this.
  // @override
  // set size(Vector2? newSize) {
  //   final newShrinkWrapMode = newSize == null;
  //   if (shrinkWrapMode != newShrinkWrapMode) {
  //     // We only invoke this when [_shrinkWrapMode]'s value is changing.
  //     // This is so we can avoid accumulation of listeners on the children.
  //     _setupChildSizeListeners(newShrinkWrapMode);
  //   }
  //   shrinkWrapMode = newShrinkWrapMode;
  //   // we use [super.size] to benefit from the superclass's notifier mechanisms.
  //   if (newSize == null) {
  //     super.size = intrinsicSize;
  //   } else {
  //     super.size = newSize;
  //   }
  //   // We might be tempted to invoke [layoutChildren], but depending on the
  //   // needs of the component, we may want to attach a listener to [size].
  // }

  /// Attaches or removes size listeners from [positionChildren], depending on
  /// the mode of operation. [shrinkWrapMode] is a property accessible to this
  /// function, so technically we can access the property directly from within
  /// the function, but because this function is very sensitive to the value of
  /// this property, as a safety measure we are making it explicitly a function
  /// of [shrinkWrapMode].
  ///
  /// Previously, this method also attached or removed a listener on the
  /// component [size] itself, but now that [size] is being overloaded to
  /// signal intent to shrink wrap, the layout methods are invoked directly
  /// from the [size] setter itself.
  // void _setupChildSizeListeners(bool shrinkWrapMode) {
  //   for (final child in positionChildren) {
  //     child.size.removeListener(layoutChildren);
  //     if (shrinkWrapMode) {
  //       child.size.addListener(layoutChildren);
  //     }
  //   }
  // }

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
  /// By default, simply sets [size] to null, which sets [size] to
  /// [intrinsicSize] under the hood.
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
