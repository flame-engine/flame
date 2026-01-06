import 'package:flame/components.dart';
import 'package:flame/experimental.dart';

/// A common abstract class for [LayoutComponent]s that are designed to work
/// with only a single [child]. This includes components like
/// [ExpandedComponent] and [PaddingComponent], and can possibly be used to
/// refactor AlignComponent.
///
/// [inflateChild] is simply a flag that signals whether the underlying layout
/// machinery should alter its child's size. It's up to this class's subclasses
/// to make use of this flag.
///
/// Setting [child] automatically manages removing the old child from this
/// component, as well as adding the new child to this component.
abstract class SingleLayoutComponent extends LayoutComponent {
  SingleLayoutComponent({
    required super.key,
    required super.position,
    required super.anchor,
    required super.priority,
    required super.size,
    required this.inflateChild,
    required PositionComponent? child,
  }) {
    this.child = child;
  }

  final bool inflateChild;

  PositionComponent? _child;

  /// The component that will be positioned by this component. The [child] will
  /// be automatically mounted to the current component.
  PositionComponent? get child => _child;

  set child(PositionComponent? value) {
    final oldChild = _child;
    if (oldChild?.parent == this) {
      oldChild?.removeFromParent();
    }
    _child = value;
    if (value != null) {
      add(value);
    }
  }

  void syncChildSize() {
    if (!inflateChild) {
      return;
    }
    final child = this.child;
    if (child == null) {
      return;
    }
    if (child.size == availableSize) {
      return;
    }
    if (child is LayoutComponent) {
      child.setLayoutSize(availableSize.x, availableSize.y);
    } else {
      child.size = availableSize;
    }
  }

  @override
  void resetSize() {
    super.resetSize();
    syncChildSize();
  }

  Vector2 get availableSize => size;

  @override
  Vector2 get intrinsicSize => child?.size ?? Vector2.zero();
}
