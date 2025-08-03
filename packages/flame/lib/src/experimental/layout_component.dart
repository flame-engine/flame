import 'package:flame/components.dart';
import 'package:flame/src/experimental/expanded_component.dart';
import 'package:flame/src/experimental/notifying_nullable_vector_2.dart';
import 'package:flame/src/experimental/nullable_vector_2.dart';
import 'package:flame/src/game/notifying_vector2.dart';
import 'package:meta/meta.dart';

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
    // layoutSize.addListener(resetSize);
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
  /// [axisIndex]. This is needed because currently there's no other way, at the
  /// [LayoutComponent] level, to selective set width or height without setting
  /// both.
  /// e.g. if [axisIndex] is 1, then that's the y axis.
  ///
  /// We cannot, for example, extend the accessor assignment of NullableVector2
  /// to trigger some extra functionality (i.e. setting height/width) when the
  /// accessor is set.
  ///
  /// We also cannot use listeners at the moment, because listeners are
  /// triggered when either height/width are set, when we need things to happen
  /// *only* when height or width are set. Current functionality results in
  /// a race condition.
  void setLayoutAxisLength(int axisIndex, double? value) {
    switch (axisIndex) {
      case 0:
        _layoutSize.x = value;
        width = _layoutSize.x ?? intrinsicSize.x;
      case 1:
        _layoutSize.y = value;
        height = _layoutSize.y ?? intrinsicSize.y;
      default:
        throw Exception('Unsupported axisIndex: $axisIndex');
    }
  }

  /// Reset the size of this [LayoutComponent] to either the layout dimensions
  /// or the [intrinsicSize].
  void resetSize() {
    width = _layoutSize.x ?? intrinsicSize.x;
    height = _layoutSize.y ?? intrinsicSize.y;
  }

  bool shrinkWrappedIn(int index) {
    return layoutSize[index] == null;
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
