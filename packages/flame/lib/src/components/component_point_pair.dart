import 'dart:ui';

import 'package:flame/src/components/component.dart';
import 'package:meta/meta.dart';
import 'package:vector_math/vector_math_64.dart';

/// A simple tuple of a component and a point. This is a helper class for the
/// [Component.componentsAtPoint] method.
@immutable
class ComponentPointPair {
  const ComponentPointPair(this.component, this.point);
  final Component component;
  final Vector2 point;

  @override
  bool operator ==(Object other) =>
      other is ComponentPointPair &&
      other.component == component &&
      other.point == point;

  @override
  int get hashCode => hashValues(component, point);

  @override
  String toString() => '<$component, $point>';
}
