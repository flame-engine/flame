# PositionComponent

Most visible objects in a game need a position, size, and rotation. `PositionComponent` provides
these transform properties, making it the base class for nearly every visual element in Flame:
sprites, animations, shapes, and your own custom components. It mirrors the concept of a
[`Positioned`](https://api.flutter.dev/flutter/widgets/Positioned-class.html) widget in Flutter, but
in a game-oriented coordinate system.

This class represents a positioned object on the screen, being a floating rectangle, a rotating
sprite, or anything else with position and size. It can also represent a group of positioned
components if children are added to it.

The base of the `PositionComponent` is that it has a `position`, `size`, `scale`, `angle` and
`anchor` which transforms how the component is rendered.


## Position

The `position` is just a `Vector2` which represents the position of the component's anchor in
relation to its parent; if the parent is a `FlameGame`, it is in relation to the viewport.


## Size

The `size` of the component when the zoom level of the camera is 1.0 (no zoom, default).
The `size` is *not* in relation to the parent of the component.


## Scale

The `scale` is how much the component and its children should be scaled. Since it is represented
by a `Vector2`, you can scale in a uniform way by changing `x` and `y` with the same amount, or in a
non-uniform way, by change `x` or `y` by different amounts.


## Angle

The `angle` is the rotation angle around the anchor, represented as a double in radians. It is
relative to the parent's angle.


## Native Angle

The `nativeAngle` is an angle in radians, measured clockwise, representing the default orientation
of the component. It can be used to define the direction in which the component is facing when
[angle](#angle) is zero.

It is specially helpful when making a sprite based component look at a specific target. If the
original image of the sprite is not facing in the up/north direction, the calculated angle to make
the component look at the target will need some offset to make it look correct. For such cases,
`nativeAngle` can be used to let the component know what direction the original image is faces.

An example could be a bullet image pointing in east direction. In this case `nativeAngle` can be set
to pi/2 radians. Following are some common directions and their corresponding native angle values.

Direction | Native Angle | In degrees
----------|--------------|-------------
Up/North  | 0            | 0
Down/South| pi or -pi    | 180 or -180
Left/West | -pi/2        | -90
Right/East| pi/2         | 90


## Anchor

```{flutter-app}
:sources: ../../flame/examples
:page: anchor
:show: widget code infobox
This example shows effect of changing `anchor` point of parent
(red) and child (blue) components. Tap on them to cycle through
the anchor points. Note that the local position of the child
component is (0, 0) at all times.
```

The `anchor` is where on the component that the position and rotation should be defined from (the
default is `Anchor.topLeft`). So if you have the anchor set as `Anchor.center` the component's
position on the screen will be in the center of the component and if an `angle` is applied, it is
rotated around the anchor, so in this case around the center of the component. You can think of it
as the point within the component by which Flame "grabs" it.

When `position` or `absolutePosition` of a component is queried, the returned coordinates are that
of the `anchor` of the component. In case if you want to find the position of a specific anchor
point of a component which is not actually the `anchor` of that component, you can use the
`positionOfAnchor` and `absolutePositionOfAnchor` method.

```dart
final comp = PositionComponent(
  size: Vector2.all(20),
  anchor: Anchor.center,
);

// Returns (0,0)
final p1 = component.position;

// Returns (10, 10)
final p2 = component.positionOfAnchor(Anchor.bottomRight);
```

A common pitfall when using `anchor` is confusing it as being the attachment point for children
components. For example, setting `anchor` to `Anchor.center` for a parent component does not mean
that the children components will be placed w.r.t the center of parent.

```{note}
Local origin for a child component is always the top-left
corner of its parent component, irrespective of their
`anchor` values.
```


## PositionComponent children

All children of the `PositionComponent` will be transformed in relation to the parent, which means
that the `position`, `angle` and `scale` will be relative to the parents state.
So if you, for example, wanted to position a child in the center of the parent you would do this:

```dart
@override
void onLoad() {
  final parent = PositionComponent(
    position: Vector2(100, 100),
    size: Vector2(100, 100),
  );
  final child = PositionComponent(
    position: parent.size / 2,
    anchor: Anchor.center,
  );
  parent.add(child);
}
```

Remember that most components that are rendered on the screen are `PositionComponent`s, so
this pattern can be used in for example [SpriteComponent](sprite_components.md#spritecomponent)
and [SpriteAnimationComponent](sprite_components.md#spriteanimationcomponent) too.


## Render PositionComponent

When implementing the `render` method for a component that extends `PositionComponent` remember to
render from the top left corner (0.0). Your render method should not handle where on the screen your
component should be rendered. To handle where and how your component should be rendered use the
`position`, `angle` and `anchor` properties and Flame will automatically handle the rest for you.

If you want to know where on the screen the bounding box of the component is you can use the
`toRect` method.

In the event that you want to change the direction of your components rendering, you can also use
`flipHorizontally()` and `flipVertically()` to flip anything drawn to canvas during
`render(Canvas canvas)`, around the anchor point. These methods are available on all
`PositionComponent` objects, and are especially useful on `SpriteComponent` and
`SpriteAnimationComponent`.

In case you want to flip a component around its center without having to change the anchor to
`Anchor.center`, you can use `flipHorizontallyAroundCenter()` and `flipVerticallyAroundCenter()`.
