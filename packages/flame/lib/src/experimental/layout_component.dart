import 'package:flame/components.dart';
import 'package:meta/meta.dart';

abstract class LayoutComponent extends PositionComponent {
  LayoutComponent({
    required super.position,
    required Vector2? size,
    super.children,
    super.anchor,
    super.priority,
  }) {
    // use the size setter rather than invoke [layoutChildren] because the
    // latter needs the intent to shrinkwrap pre-set by [_shrinkWrapMode].
    // At the time of construction, [_shrinkWrapMode] only has its default
    // value.
    this.size = size;
  }

  /// This size setter is nullable unlike its superclass, to allow this
  /// [LayoutComponent] to shrink-wrap its children. In other words, it sets
  /// the size to [inherentSize]. This setter also records the intent to
  /// shrink-wrap via the [shrinkWrapMode] property, so that [layoutChildren]
  /// knows whether or not to invoke this setter.
  ///
  /// Internally, this [size] setter should only ever be invoked upon
  /// construction, and inside [layoutChildren] to make it easier to track and
  /// reason about.
  ///
  /// Externally, this [size] setter is designed as an API, so a library user
  /// should feel free to use this.
  @override
  set size(Vector2? newSize) {
    final newShrinkWrapMode = newSize == null;
    if (shrinkWrapMode != newShrinkWrapMode) {
      // We only invoke this when [_shrinkWrapMode]'s value is changing.
      // This is so we can avoid accumulation of listeners on the children.
      _setupSizeListeners(newShrinkWrapMode);
    }
    shrinkWrapMode = newShrinkWrapMode;
    // we use [super.size] to benefit from the superclass's notifier mechanisms.
    if (newSize == null) {
      super.size = inherentSize;
    } else {
      super.size = newSize;
    }
    // We might be tempted to use [layoutChildren], but recall that we already
    // have listeners attached to size via [setupSizeListeners].
  }

  @protected
  bool shrinkWrapMode = false;

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
  void _setupSizeListeners(bool shrinkWrapMode) {
    if (shrinkWrapMode) {
      // In shrink wrap mode, since sizing is bottom-up, the children have the
      // listener and trigger layout.
      for (final child in positionChildren) {
        child.size.addListener(layoutChildren);
      }
    } else {
      // In explicit sizing mode, since sizing is top-down, remove the listeners
      // from the children.
      for (final child in positionChildren) {
        child.size.removeListener(layoutChildren);
      }
    }
  }

  @override
  void onChildrenChanged(Component child, ChildrenChangeType type) {
    if (child is! PositionComponent) {
      return;
    }
    // setupSizeListeners(), but for a single child
    if (type == ChildrenChangeType.added && shrinkWrapMode) {
      child.size.addListener(layoutChildren);
    } else {
      child.size.removeListener(layoutChildren);
    }
    layoutChildren();
  }

  /// Sets the size of this [LayoutComponent], then lays out the children
  /// along both main and cross axes.
  void layoutChildren() {
    if (shrinkWrapMode) {
      size = null;
    }
  }

  /// A helper property to get only the [PositionComponent]s
  /// among the [children].
  List<PositionComponent> get positionChildren =>
      children.whereType<PositionComponent>().toList();

  Vector2 get inherentSize;
}
