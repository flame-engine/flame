import 'package:flame/components.dart';
import 'package:flame/experimental.dart';

/// A common abstract class for [LayoutComponent]s that are designed to work
/// with only a single [child]. This includes components like
/// [ExpandedComponent] and [PaddingComponent], and can possibly be used to
/// refactor AlignComponent.
///
/// Setting [child] automatically reparents and adds.
abstract class SingleLayoutComponent extends LayoutComponent {
  SingleLayoutComponent({
    required super.key,
    required super.position,
    required super.anchor,
    required super.priority,
    required super.size,
    required PositionComponent? child,
  }) {
    this.child = child;
  }

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

  @override
  Vector2 get intrinsicSize => child?.size ?? Vector2.zero();
}
