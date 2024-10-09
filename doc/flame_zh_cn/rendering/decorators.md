# Decorators

**Decorators** are classes that can encapsulate certain visual effects and then apply those visual
effects to a sequence of canvas drawing operations. Decorators are not [Component]s, but they can
be applied to components either manually or via the [HasDecorator] mixin. Likewise, decorators are
not [Effect]s, although they can be used to implement certain `Effect`s.

There are a certain number of decorators available in Flame, and it is simple to add one's own if
necessary. We are planning to add shader-based decorators once Flutter fully supports them on the
web.


## Flame built-in decorators


### PaintDecorator.blur

```{flutter-app}
:sources: ../flame/examples
:page: decorator_blur
:show: widget code infobox
:width: 180
:height: 160
```

This decorator applies a Gaussian blur to the underlying component. The amount of blur can be
different in the X and Y direction, though this is not very common.

```dart
final decorator = PaintDecorator.blur(3.0);
```

Possible uses:

- soft shadows;
- "out-of-focus" objects in the distance or very close to the camera;
- motion blur effects;
- deemphasize/obscure content when showing a popup dialog;
- blurred vision when the character is drunk.


### PaintDecorator.grayscale

```{flutter-app}
:sources: ../flame/examples
:page: decorator_grayscale
:show: widget code infobox
:width: 180
:height: 160
```

This decorator converts the underlying image into the shades of grey, as if it was a
black-and-white photograph. In addition, you can make the image semi-transparent to the desired
level of `opacity`.

```dart
final decorator = PaintDecorator.grayscale(opacity: 0.5);
```

Possible uses:

- apply to an NPC to turn them into stone, or into a ghost!
- apply to a scene to indicate that it is a memory of the past;
- black-and-white photos.


### PaintDecorator.tint

```{flutter-app}
:sources: ../flame/examples
:page: decorator_tint
:show: widget code infobox
:width: 180
:height: 160
```

This decorator *tints* the underlying image with the specified color, as if watching it through a
colored glass. It is recommended that the `color` used by this decorator was semi-transparent, so
that you can see the details of the image below.

```dart
final decorator = PaintDecorator.tint(const Color(0xAAFF0000);
```

Possible uses:

- NPCs affected by certain types of magic;
- items/characters in the shadows can be tinted black;
- tint the scene red to show bloodlust, or that the character is low on health;
- tint green to show that the character is poisoned or sick;
- tint the scene deep blue during the night time;


### Rotate3DDecorator

```{flutter-app}
:sources: ../flame/examples
:page: decorator_rotate3d
:show: widget code infobox
:width: 180
:height: 160
```

This decorator applies a 3D rotation to the underlying component. You can specify the angles of the
rotation, as well as the pivot point and the amount of perspective distortion to apply.

The decorator also supplies the `isFlipped` property, which allows you to determine whether the
component is currently being viewed from the front side or from the back. This is useful if you want
to draw a component whose appearance is different in the front and in the back.

```dart
final decorator = Rotate3DDecorator(
  center: component.center,
  angleX: rotationAngle,
  perspective: 0.002,
);
```

Possible uses:

- a card that can be flipped over;
- pages in a book;
- transitions between app routes;
- 3d falling particles such as snowflakes or leaves.


### Shadow3DDecorator

```{flutter-app}
:sources: ../flame/examples
:page: decorator_shadow3d
:show: widget code infobox
:width: 180
:height: 160
```

This decorator renders a shadow underneath the component, as if the component was a 3D object
standing on a plane. This effect works best for games that use isometric camera projection.

The shadow produced by this generator is quite flexible: you can control its angle, length, opacity,
blur, etc. For a full description of what properties this decorator has and their meaning, see the
class documentation.

```dart
final decorator = Shadow3DDecorator(
  base: Vector2(100, 150),
  angle: -1.4,
  xShift: 200,
  yScale: 1.5,
  opacity: 0.5,
  blur: 1.5,
);
```

The primary purpose of this decorator is to add shadows on the ground to your components. The main
limitation is that the shadows are flat and cannot interact with the environment. For example, this
decorator cannot handle shadows that fall onto walls or other vertical structures.


## Using decorators


### HasDecorator mixin

This `Component` mixin adds the `decorator` property, which is initially `null`. If you set this
property to an actual `Decorator` object, then that decorator will apply its visual effect during
the rendering of the component. In order to remove this visual effect, simply set the `decorator`
property back to `null`.


### PositionComponent

`PositionComponent` (and all the derived classes) already has a `decorator` property, so for these
components the `HasDecorator` mixin is not needed.

In fact, the `PositionComponent` uses its decorator in order to properly position the component on
the screen. Thus, any new decorators that you'd want to apply to the `PositionComponent` will need
to be chained (see the [](#multiple-decorators) section below).

It is also possible to replace the root decorator of the `PositionComponent`, if you want to create
an alternative logic for how the component shall be positioned on the screen.


### Multiple decorators

It is possible to apply several decorators simultaneously to the same component: the `Decorator`
class supports chaining. That is, if you have an existing decorator on a component and you want to
add another one, then you can call `component.decorator.addLast(newDecorator)` -- this will add
the new decorator at the end of the existing chain. The method `removeLast()` can remove that
decorator later.

Several decorators can be chain that way. For example, if `A` is an initial decorator, then
`A.addLast(B)` can be followed by either `A.addLast(C)` or `B.addLast(C)` -- and in both cases the
chain `A -> B -> C` will be created. In practice, it means that the entire chain can be manipulated
from its root, which usually is `component.decorator`.


[Component]: ../../flame/components.md#component
[Effect]: ../../flame/effects.md
[HasDecorator]: #hasdecorator-mixin
