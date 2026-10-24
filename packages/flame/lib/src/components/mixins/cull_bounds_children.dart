import 'dart:ui';

import 'package:flame/src/components/mixins/cull_when_offscreen.dart';
import 'package:flame/src/components/position_component.dart';

/// Makes [CullWhenOffscreen] look at some of the children of a component too.
///
/// By default, [CullWhenOffscreen] only looks at the box of the component
/// itself. A child that sticks out of that box disappears when the box leaves
/// the screen, even if the child is still visible. List such children in
/// [cullBoundsChildren], and their boxes are added to the box of the component.
///
/// ```dart
/// class Tank extends PositionComponent
///     with CullWhenOffscreen, CullBoundsChildren {
///   late final HealthBar healthBar;
///
///   @override
///   Iterable<PositionComponent> get cullBoundsChildren => [healthBar];
/// }
/// ```
///
/// List only the children that stick out. Each listed child is measured on
/// every frame, so listing all of the children of a component with many
/// children can cost nearly as much as drawing them.
///
/// The list is read on every frame, so it can change at any time, for example
/// in `update`. To use all of the direct children, return the cached list of
/// the children. It follows children that are added or removed:
///
/// ```dart
/// @override
/// Iterable<PositionComponent> get cullBoundsChildren =>
///     hasChildren ? children.query<PositionComponent>() : const [];
/// ```
mixin CullBoundsChildren on CullWhenOffscreen {
  /// The children (or other descendants) that stick out of the box of this
  /// component, and that must be on-screen when deciding to draw it.
  ///
  /// The area that is checked is the [cullBounds] of the component without
  /// this mixin, plus the box of each component in this list, plus
  /// [cullPadding]. The boxes are measured on every frame, so a listed child
  /// that moves is followed. A listed component that is not mounted is ignored.
  ///
  /// This is a getter, so it is read on every frame. Return components that
  /// you keep in fields, and do not create new components in it.
  Iterable<PositionComponent> get cullBoundsChildren;

  @override
  Rect get cullBounds {
    var bounds = super.cullBounds;
    for (final child in cullBoundsChildren) {
      if (child.isMounted) {
        bounds = bounds.expandToInclude(child.toAbsoluteRect());
      }
    }
    return bounds;
  }
}
