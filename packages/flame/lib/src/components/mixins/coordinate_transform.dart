import 'package:flame/src/components/component.dart';
import 'package:vector_math/vector_math_64.dart';

/// Interface to be implemented by components that perform a coordinate change.
///
/// Any [Component] that does any coordinate transformation of the canvas during
/// rendering should consider implementing this interface in order to describe
/// how the points from the parent's coordinate system relate to the component's
/// local coordinate system.
///
/// This interface assumes that the component performs a "uniform" coordinate
/// transformation, that is, the transform applies to all children of the
/// component equally. If that is not the case (for example, the component does
/// different transformations for some of its children), then that component
/// must implement [Component.componentsAtPoint] method instead.
///
/// The two methods of this interface convert between the parent's coordinate
/// space and the local coordinates. The methods may also return `null`,
/// indicating that the given cannot be mapped to any local/parent point.
abstract class CoordinateTransform {
  Vector2? parentToLocal(Vector2 point);

  Vector2? localToParent(Vector2 point);
}
