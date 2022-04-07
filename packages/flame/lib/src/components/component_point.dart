import 'dart:ui';

import 'package:meta/meta.dart';
import 'package:vector_math/vector_math_64.dart';

import 'component.dart';

/// A simple tuple of a component and a point. This is a helper class for
/// [Component.componentsAtPoint] method.
@immutable
class ComponentPoint {
  const ComponentPoint(this.component, this.point);
  final Component component;
  final Vector2 point;

  @override
  bool operator ==(Object other) =>
      other is ComponentPoint &&
      other.component == component &&
      other.point == point;

  @override
  int get hashCode => hashValues(component, point);

  @override
  String toString() => '<$component, $point>';
}
