import 'dart:ui' as ui;

import 'package:flame/collisions.dart' as flame;
import 'package:flame/components.dart' as flame;
import 'package:flame_studio/component_editor/widgets/preview/preview_hitboxes.dart';
import 'package:flame_studio/component_editor/widgets/preview/preview_position_component.dart';
import 'package:flame_studio/component_editor/widgets/preview/preview_sprite_component.dart';
import 'package:flame_studio/repositories/repositories.dart';
import 'package:flutter/painting.dart';

/// Builds the Flame component that previews the root [component], with its
/// children.
///
/// The root is anchored at its center, at the origin of the world, so it
/// is centered on screen; its stored position is ignored because the root
/// is placed by whoever uses it, and it is not rotated for the same reason.
/// Children use their own anchor (Flame's default top left one unless
/// edited) and angle, and are positioned relative to their parent, like in
/// the generated code.
///
/// Sprites draw the [images] of their image, by asset path.
flame.PositionComponent buildFlameComponent(
  Component component, {
  Map<String, ui.Image> images = const {},
}) {
  return _placeRoot(_build(component, images));
}

flame.PositionComponent _placeRoot(flame.PositionComponent root) {
  root
    ..anchor = flame.Anchor.center
    ..angle = 0
    ..position.setZero();
  return root;
}

flame.PositionComponent _build(
  Component component,
  Map<String, ui.Image> images,
) {
  final target = switch (component) {
    RectangleComponent() => flame.RectangleComponent(),
    CircleComponent() => flame.CircleComponent(),
    PolygonComponent(:final vertices) => flame.PolygonComponent(
      _vectors(vertices),
    ),
    // Flame's SpriteComponent can't be mounted without a sprite.
    SpriteComponent() => PreviewSpriteComponent(),
    // Outlined, since a plain PositionComponent would be invisible.
    PositionComponent() => PreviewPositionComponent(),
    // Hitboxes draw nothing either, so they are outlined too.
    RectangleHitboxComponent() => PreviewRectangleHitbox(),
    CircleHitboxComponent() => PreviewCircleHitbox(),
    PolygonHitboxComponent(:final vertices) => PreviewPolygonHitbox(
      _vectors(vertices),
    ),
  };
  applyProperties(target, component, images: images);
  // Children added before mounting are stored right away, in order.
  for (final child in component.children) {
    target.add(_build(child, images));
  }
  return target;
}

/// A new list of the [vertices], since Flame changes the list it is given.
List<flame.Vector2> _vectors(ComponentVertices vertices) => [
  for (final vertex in vertices.vertices) flame.Vector2(vertex.x, vertex.y),
];

/// Whether [a] and [b] have the same types arranged in the same tree, so
/// that the Flame components built for [a] can be updated to show [b].
///
/// Polygons with different vertices don't have the same shape: a Flame
/// polygon can't change its number of vertices, nor be given new ones from
/// outside.
bool haveSameShape(Component a, Component b) {
  if (a.type != b.type || a.children.length != b.children.length) {
    return false;
  }
  if ((a, b) case (final VerticesComponent a, final VerticesComponent b)
      when a.vertices != b.vertices) {
    return false;
  }
  for (var i = 0; i < a.children.length; i++) {
    if (!haveSameShape(a.children[i], b.children[i])) {
      return false;
    }
  }
  return true;
}

/// Applies the properties of the root [component] and of all of its
/// children to [target] and its children, which must have been built by
/// [buildFlameComponent] for a component of the same shape (see
/// [haveSameShape]).
///
/// Like in [buildFlameComponent], the root stays centered.
void applyTree(
  flame.PositionComponent target,
  Component component, {
  Map<String, ui.Image> images = const {},
}) {
  _placeRoot(_applyNode(target, component, images));
}

flame.PositionComponent _applyNode(
  flame.PositionComponent target,
  Component component,
  Map<String, ui.Image> images,
) {
  applyProperties(target, component, images: images);
  final children = target.children.whereType<flame.PositionComponent>();
  for (final (index, child) in children.indexed) {
    _applyNode(child, component.children[index], images);
  }
  return target;
}

/// The Flame component at [path] in the tree built by
/// [buildFlameComponent] from [root] (see `ComponentTree` for paths).
flame.PositionComponent flameNodeAt(
  flame.PositionComponent root,
  List<int> path,
) {
  var node = root;
  for (final index in path) {
    node = node.children.whereType<flame.PositionComponent>().elementAt(index);
  }
  return node;
}

/// Applies every property [component] has to [target].
///
/// New shared properties should be wired here so that every component type
/// that has them is previewed correctly.
T applyProperties<T extends flame.PositionComponent>(
  T target,
  Component component, {
  Map<String, ui.Image> images = const {},
}) {
  if (component case final PositionedComponent positioned) {
    applyPosition(target, positioned.position);
  }
  if (component case final AnchoredComponent anchored) {
    applyAnchor(target, anchored.anchor);
  }
  if (component case final RotatedComponent rotated) {
    applyAngle(target, rotated.angle);
  }
  if (component case final SizedComponent sized) {
    applySize(target, sized.size);
  }
  if (component case final RadiusComponent round
      when target is flame.CircleComponent) {
    applyRadius(target as flame.CircleComponent, round.radius);
  }
  if (component case final PaintedComponent painted
      when target is flame.HasPaint) {
    applyPaint(target as flame.HasPaint, painted.paint);
  }
  if (component case final SpritedComponent sprited
      when target is PreviewSpriteComponent) {
    applySprite(target as PreviewSpriteComponent, sprited.sprite, images);
  }
  if (component case final HitboxComponent hitbox
      when target is flame.ShapeHitbox) {
    applyCollision(target as flame.ShapeHitbox, hitbox.collision);
  }
  return target;
}

/// Applies [position] to [target].
void applyPosition(flame.PositionComponent target, ComponentPosition position) {
  target.position.setValues(position.x, position.y);
}

/// Applies [anchor] to [target].
void applyAnchor(flame.PositionComponent target, ComponentAnchor anchor) {
  target.anchor = flame.Anchor(anchor.x, anchor.y);
}

/// Applies [angle] to [target].
void applyAngle(flame.PositionComponent target, ComponentAngle angle) {
  target.angle = angle.radians;
}

/// Applies [size] to [target].
void applySize(flame.PositionComponent target, ComponentSize size) {
  target.size.setValues(size.width, size.height);
}

/// Applies [radius] to [target], which also sets its size.
void applyRadius(flame.CircleComponent target, ComponentRadius radius) {
  target.radius = radius.radius;
}

/// Applies [paint] to [target].
void applyPaint(flame.HasPaint target, ComponentPaint paint) {
  target.paint
    ..color = Color(paint.color)
    ..style = switch (paint.style) {
      PaintStyle.fill => PaintingStyle.fill,
      PaintStyle.stroke => PaintingStyle.stroke,
    };
}

/// Applies [sprite] to [target], which draws nothing while its image is not
/// one of [images].
void applySprite(
  PreviewSpriteComponent target,
  ComponentSprite sprite,
  Map<String, ui.Image> images,
) {
  final image = images[sprite.image];
  target.sprite = image == null
      ? null
      : flame.Sprite(
          image,
          srcPosition: flame.Vector2(
            sprite.srcPosition.x,
            sprite.srcPosition.y,
          ),
          srcSize: flame.Vector2(sprite.srcSize.width, sprite.srcSize.height),
        );
}

/// Applies [collision] to [target].
void applyCollision(flame.ShapeHitbox target, ComponentCollision collision) {
  target
    ..collisionType = switch (collision.type) {
      HitboxCollisionType.active => flame.CollisionType.active,
      HitboxCollisionType.passive => flame.CollisionType.passive,
      HitboxCollisionType.inactive => flame.CollisionType.inactive,
    }
    ..isSolid = collision.isSolid;
}
