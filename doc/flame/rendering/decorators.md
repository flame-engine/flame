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
:show: widget infobox
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


### PaintDecorator.tinted

```{flutter-app}
:sources: ../flame/examples
:page: decorator_tinted
:show: widget infobox
:width: 180
:height: 160
```

This decorator "tints" the underlying image with the specified color, as if watching it through a
colored glass. It is recommended that the `color` used by this decorator was semi-transparent, so
that you can see the details of the image below.

```dart
final decorator = PaintDecorator.tinted(const Color(0xAAFF0000);
```

Possible uses:
- NPCs affected by certain types of magic;
- items/characters in the shadows can be tinted black;
- tint the scene red to show bloodlust, or that the character is low on health;
- tint green to show that the character is poisoned or sick;
- tint the scene deep blue during the night time;


## Using decorators

### HasDecorator mixin

This `Component` mixin adds the `decorator` property, which is initially `null`. If you set this
property to an actual `Decorator` object, then that decorator will apply its visual effect during
the rendering of the component. In order to remove this visual effect, simply set the `decorator`
property back to `null`.



[Component]: ../../flame/components.md#component
[Effect]: ../../flame/effects.md
[HasDecorator]: #hasdecorator-mixin
