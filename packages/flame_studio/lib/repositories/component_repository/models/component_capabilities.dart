import 'package:flame_studio/repositories/repositories.dart';

/// A [Component] that has a [ComponentPosition].
///
/// Implemented by every component type backed by a Flame
/// `PositionComponent`. The position is only edited on child components:
/// the root is placed by whoever uses it.
abstract interface class PositionedComponent() {
  /// Creates a [PositionedComponent].
  this;

  /// The position of the component, relative to its parent.
  ComponentPosition get position;

  /// Returns a copy of this component with [position] replaced.
  Component copyWithPosition(ComponentPosition position);
}

/// A [Component] that has a [ComponentAnchor].
///
/// Implemented by every component type backed by a Flame
/// `PositionComponent`. Like the position, the anchor is only edited on
/// child components: the root is placed by whoever uses it.
abstract interface class AnchoredComponent() {
  /// Creates an [AnchoredComponent].
  this;

  /// The point of the component that is placed at its position.
  ComponentAnchor get anchor;

  /// Returns a copy of this component with [anchor] replaced.
  Component copyWithAnchor(ComponentAnchor anchor);
}

/// A [Component] that has a [ComponentAngle].
///
/// Implemented by every component type backed by a Flame
/// `PositionComponent`. Like the position, the angle is only edited on
/// child components: the root is placed by whoever uses it.
abstract interface class RotatedComponent() {
  /// Creates a [RotatedComponent].
  this;

  /// The rotation of the component around its anchor.
  ComponentAngle get angle;

  /// Returns a copy of this component with [angle] replaced.
  Component copyWithAngle(ComponentAngle angle);
}

/// A [Component] that has a [ComponentSize].
///
/// Implemented by every component type backed by a Flame
/// `PositionComponent`.
abstract interface class SizedComponent() {
  /// Creates a [SizedComponent].
  this;

  /// The size of the component.
  ComponentSize get size;

  /// Returns a copy of this component with [size] replaced.
  Component copyWithSize(ComponentSize size);
}

/// A [Component] that draws with a [ComponentPaint].
abstract interface class PaintedComponent() {
  /// Creates a [PaintedComponent].
  this;

  /// The paint of the component.
  ComponentPaint get paint;

  /// Returns a copy of this component with [paint] replaced.
  Component copyWithPaint(ComponentPaint paint);
}

/// A [Component] that has a [ComponentRadius].
///
/// Implemented by round component types, such as circles, whose Flame size
/// is derived from the radius.
abstract interface class RadiusComponent() {
  /// Creates a [RadiusComponent].
  this;

  /// The radius of the component.
  ComponentRadius get radius;

  /// Returns a copy of this component with [radius] replaced.
  Component copyWithRadius(ComponentRadius radius);
}

/// A [Component] that has [ComponentVertices].
///
/// Implemented by polygon component types, whose Flame size is the
/// bounding box of the vertices.
abstract interface class VerticesComponent() {
  /// Creates a [VerticesComponent].
  this;

  /// The vertices of the component.
  ComponentVertices get vertices;

  /// Returns a copy of this component with [vertices] replaced.
  Component copyWithVertices(ComponentVertices vertices);
}

/// A [Component] that draws a [ComponentSprite].
abstract interface class SpritedComponent() {
  /// Creates a [SpritedComponent].
  this;

  /// The sprite of the component.
  ComponentSprite get sprite;

  /// Returns a copy of this component with [sprite] replaced.
  Component copyWithSprite(ComponentSprite sprite);
}

/// A [Component] that is a Flame hitbox, with a [ComponentCollision].
///
/// Hitboxes are only children, and have no children of their own: Flame
/// requires a hitbox to be inside a `PositionComponent`.
abstract interface class HitboxComponent() {
  /// Creates a [HitboxComponent].
  this;

  /// How the hitbox collides with others.
  ComponentCollision get collision;

  /// Returns a copy of this component with [collision] replaced.
  Component copyWithCollision(ComponentCollision collision);
}
