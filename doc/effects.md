# Effects

An effect is a special component that can attach to another component in order to modify its
properties or appearance.

For example, suppose you are making a game with collectible power-up items. You want these power-ups
to generate randomly around the map and then de-spawn after some time. Obviously, you could make a
sprite component for the power-up and then place that component on the map, but we could do even
better!

Let's add a `ScaleEffect` to grow the item from 0 to 100% when the power-up first appears. Add
another infinitely repeating alternating `MoveEffect` in order to make the item move slightly up
and down. Then add an `OpacityEffect` that will "blink" the item 3 times, this effect will have a
built-in delay of 30 seconds, or however long you want your power-up to stay in place. Lastly, add
a `RemoveEffect` that will automatically remove the item from the game tree after the specified
time (you probably want to time it right after the end of the `OpacityEffect`).

As you can see, with a few simple effects we have turned a simple lifeless sprite into a much more
interesting item. And what's more important, it didn't result in an increased code complexity: the
effects, once added, will work automatically, and then self-remove from the game tree when
finished.


## Overview

The function of an `Effect` is to effect a change over time in some component's property. In order
to achieve that, the `Effect` must know the initial value of the property, the final value, and how
it should progress over time. The initial value is usually determined by an effect automatically,
the final value is provided by the user explicitly, and progression over time is handled by
`EffectController`s.

There are multiple effects provided by Flame, and you can also
[create your own](#creating-new-effects). The following effects are included:
- [`MoveEffect.by`](#moveeffectby)
- [`MoveEffect.to`](#moveeffectto)
- [`MoveEffect.along`](#moveeffectalong)
- [`RotateEffect.by`](#rotateeffectby)
- [`RotateEffect.to`](#rotateeffectto)
- [`ScaleEffect.by`](#scaleeffectby)
- [`ScaleEffect.to`](#scaleeffectto)
- [`SizeEffect.by`](#sizeeffectby)
- [`SizeEffect.to`](#sizeeffectto)
- [`OpacityEffect`](#opacityeffect)
- [`RemoveEffect`](#removeeffect)

An `EffectController` is an object that describes how the effect should evolve over time. If you
think of the initial value of the effect as 0% progress, and the final value as 100% progress, then
the job of the effect controller is to map from the "physical" time, measured in seconds, into the
"logical" time, which changes from 0 to 1.

There are multiple effect controllers provided by the Flame framework as well:
- [`EffectController`](#effectcontroller)
- [`LinearEffectController`](#lineareffectcontroller)
- [`ReverseLinearEffectController`](#reverselineareffectcontroller)
- [`CurvedEffectController`](#curvedeffectcontroller)
- [`ReverseCurvedEffectController`](#reversecurvedeffectcontroller)
- [`PauseEffectController`](#pauseeffectcontroller)
- [`RepeatedEffectController`](#repeatedeffectcontroller)
- [`InfiniteEffectController`](#infiniteeffectcontroller)
- [`SequenceEffectController`](#sequenceeffectcontroller)
- [`DelayedEffectController`](#delayedeffectcontroller)


## Built-in effects

### `Effect`

The base `Effect` class is not usable on its own (it is abstract), but it provides some common
functionality inherited by all other effects. This includes:

  - The ability to pause/resume the effect using `effect.pause()` and `effect.resume()`. You can
    check whether the effect is currently paused using `effect.isPaused`.

  - The ability to reverse the effect's time direction using `effect.reverse()`. Use
    `effect.isReversed` to check if the effect is currently running back in time.

  - Property `removeOnFinish` (which is true by default) will cause the effect component to be
    removed from the game tree and garbage-collected once the effect completes. Set this to false
    if you plan to reuse the effect after it is finished.

  - The `reset()` method reverts the effect to its original state, allowing it to run once again.


### `MoveEffect.by`

This effect applies to a `PositionComponent` and shifts it by a prescribed `offset` amount. This
offset is relative to the current position of the target:

```dart
final effect = MoveEffect.by(Vector2(0, -10), EffectController(duration: 0.5));
```

If the component is currently at `Vector2(250, 200)`, then at the end of the effect its position
will be `Vector2(250, 190)`.

Multiple move effects can be applied to a component at the same time. The result will be the
superposition of all the individual effects.


### `MoveEffect.to`

This effect moves a `PositionComponent` from its current position to the specified destination
point in a straight line.

```dart
final effect = MoveEffect.to(Vector2(100, 500), EffectController(duration: 3));
```

It is possible, but not recommended to attach multiple such effects to the same component.


### `MoveEffect.along`

This effect moves a `PositionComponent` along the specified path relative to the component's
current position. The path can have non-linear segments, but must be singly connected. It is
recommended to start a path at `Vector2.zero()` in order to avoid sudden jumps in the component's
position.

```dart
final effect = MoveEffect.along(
  Path() ..quadraticBezierTo(100, 0, 50, -50),
  EffectController(duration: 1.5)
);
```


### `RotateEffect.by`

Rotates the target clockwise by the specified angle relative to its current orientation. The angle
is in radians. For example, the following effect will rotate the target 90º clockwise:

```dart
final effect = RotateEffect.by(tau/4, EffectController(2));
```


### `RotateEffect.to`

Rotates the target clockwise to the specified azimuth. For example, the following will rotate the
target to look east (0º is north, 90º east, 180º south, and 270º west):

```dart
final effect = RotateEffect.to(tau/4, EffectController(2));
```


### `ScaleEffect.by`

This effect will change the target's scale by the specified amount. For example, this will cause
the component to grow 50% larger:

```dart
final effect = ScaleEffect.by(Vector2.all(1.5), EffectController(0.3));
```


### `ScaleEffect.to`

This effect works similar to `ScaleEffect.by`, but sets the absolute value of the target's scale.

```dart
final effect = ScaleEffect.to(Vector2.zero(), EffectController(0.5));
```


### `SizeEffect.by`

This effect will change the size of the target component, relative to its current size. For example,
if the target has size `Vector2(100, 100)`, then after the following effect is applied and runs its
course, the new size will be `Vector2(120, 50)`:

```dart
final effect = SizeEffect.by(Vector2(20, -50), EffectController(1));
```

The size of a `PositionComponent` cannot be negative. If an effect attempts to set the size to a
negative value, the size will be clamped at zero.

Note that for many components that have size, it is intended as an immutable property. Changing the
size of such components may have undesirable effects. In such cases use `ScaleEffect.by` instead.


### `SizeEffect.to`

Changes the size of the target component to the specified size. Target size cannot be negative:

```dart
final effect = SizeEffect.to(Vector2(120, 120), EffectController(1));
```


### `OpacityEffect`

This effect will change over time the opacity of the target to the specified alpha-value. Currently
this effect can only be applied to components that have a `HasPaint` mixin. If the target component
uses multiple paints, the effect can target any individual color using the `paintId` parameter.

```dart
final effect = OpacityEffect.to(0.5, EffectController(0.75));
```

The opacity value of 0 corresponds to a fully transparent component, and the opacity value of 1 is
fully opaque. Convenience constructors `OpacityEffect.fadeOut()` and `OpacityEffect.fadeIn()` will
animate the target into full transparency / full visibility respectively.


### `RemoveEffect`

This is a simple effect that can be attached to a component causing it to be removed from the game
tree after the specified delay has passed:

```dart
final effect = RemoveEffect(delay: 10.0);
```


## Creating new effects

Although Flame provides a wide array of built-in effects, eventually you may find them to be
insufficient. Luckily, creating new effects is very simple.

Each effect extends the base `Effect` class, possibly via one of the more specialized abstract
subclasses such as `ComponentEffect<T>` or `Transform2DEffect`.

The `Effect` class' constructor requires an `EffectController` instance as an argument. In most
cases you may want to pass that controller from your own constructor. Luckily, the effect controller
encapsulates much of the complexity of an effect's implementation, so you don't need to worry about
re-creating that functionality.

Lastly, you will need to implement a single method `apply(double progress)` that will be called at
each update tick while the effect is active. In this method you are supposed to make changes to the
target of your effect.

In addition, you may want to implement callbacks `onStart()` and `onFinish()` if there are any
actions that must be taken when the effect starts or ends.

When implementing the `apply()` method we recommend to use relative updates only. That is, change
the target property by incrementing/decrementing its current value, rather than directly setting
that property to a fixed value. This way multiple effects would be able to act on the same component
without interfering with each other.


## Effect controllers

### `EffectController`

The base `EffectController` class provides a factory constructor capable of creating a variety of
common controllers. The syntax of the constructor is the following:

```dart
EffectController({
    required double duration,
    Curve curve = Curves.linear,
    double? reverseDuration,
    Curve? reverseCurve,
    bool alternate = false,
    double atMaxDuration = 0.0,
    double atMinDuration = 0.0,
    int? repeatCount,
    bool infinite = false,
    double startDelay = 0.0,
});
```

- **`duration`** -- the length of the main part of the effect, i.e. how long it should take to go
  from 0 to 100%. This parameter cannot be negative, but can be zero. If this is the only parameter
  specified then the effect will grow linearly over the `duration` seconds.

- **`curve`** -- if given, creates a non-linear effect that grows from 0 to 100% according to the
  provided [curve](https://api.flutter.dev/flutter/animation/Curves-class.html).

- **`reverseDuration`** -- if provided, adds an additional step to the controller: after the effect
  has had grown from 0 to 100% over the `duration` seconds, it will then grow back from 100% to 0
  over the `reverseDuration` seconds. In addition, the effect will complete at progress level of 0
  (normally the effect completes at progress 1).

- **`reverseCurve`** -- the curve to be used during the "reverse" step of the effect. If not given,
  this will default to `curve.flipped`.

- **`alternate`** -- setting this to true is equivalent to specifying the `reverseDuration` equal
  to the `duration`. If the `reverseDuration` is already set, this flag has no effect.

- **`atMaxDuration`** -- if non-zero, this inserts a pause after the effect reaches its max
  progress and before the reverse stage. During this time the effect is kept at 100% progress. If
  there is no reverse stage, then this will simply be a pause before the effect is marked as
  completed.

- **`atMinDuration`** -- if non-zero, this inserts a pause after the reaches its lowest progress
  (0) at the end of the reverse stage. During this time, the effect's progress is at 0%. If there
  is no reverse stage, then this pause will still be inserted after the "at-max" pause if it's
  present, or after the forward stage otherwise. In addition, the effect will now complete at
  progress level of 0.

- **`repeatCount`** -- if greater than one, it will cause the effect to repeat itself the prescribed
  number of times. Each iteration will consists of the forward stage, pause at max, reverse stage,
  then pause at min (skipping those that were not specified).

- **`infinite`** -- if true, the effect will repeat infinitely and never reach completion. This is
  equivalent to as if `repeatCount` was set to infinity.
  
- **`startDelay`** -- an additional wait time inserted before the beginning of the effect. This
  wait time is executed only once, even if the effect is repeating. During this time the effect's
  `.started` property returns false. The effect's `onStart()` callback will be executed at the end
  of this waiting period.

  Using this parameter is the simplest way to create a chain of effects that execute one after
  another (or with an overlap).

The effect controller returned by this factory constructor will be composited of multiple simpler
effect controllers described further below. If this constructor proves to be too limited for your
needs, you can always create your own combination from the same building blocks.

In addition to the factory constructor, the `EffectController` class defines a number of properties
common for all effect controllers. These properties are:

- `.started` -- true if the effect has already started. For most effect controllers this property
  is always true. The only exception is the `DelayedEffectController` which returns false while the
  effect is in the waiting stage.

- `.completed` -- becomes true when the effect controller finishes execution.

- `.progress` -- current value of the effect controller, a floating-point value from 0 to 1. This
  variable is the main "output" value of an effect controller.

- `.duration` -- total duration of the effect, or `null` if the duration cannot be determined (for
  example if the duration is random or infinite).


### `LinearEffectController`

This is the simplest effect controller that grows linearly from 0 to 1 over the specified
`duration`:

```dart
final ec = LinearEffectController(3);
```


### `ReverseLinearEffectController`

Similar to the `LinearEffectController`, but it goes in the opposite direction and grows linearly
from 1 to 0 over the specified duration:

```dart
final ec = ReverseLinearEffectController(1);
```


### `CurvedEffectController`

This effect controller grows non-linearly from 0 to 1 over the specified `duration` and following
the provided `curve`:

```dart
final ec = CurvedEffectController(0.5, Curves.easeOut);
```


### `ReverseCurvedEffectController`

Similar to the `CurvedEffectController`, but the controller grows down from 1 to 0 following the
provided `curve`:

```dart
final ec = ReverseCurvedEffectController(0.5, Curves.bounceInOut);
```


### `PauseEffectController`

This effect controller keeps the progress at a constant value for the specified time duration.
Typically, the `progress` would be either 0 or 1:

```dart
final ec = PauseEffectController(1.5, progress: 0);
```


### `RepeatedEffectController`

This is a composite effect controller. It takes another effect controller as a child, and repeats
it multiple times, resetting before the start of each next cycle.

```dart
final ec = RepeatedEffectController(LinearEffectController(1), 10);
```

The child effect controller cannot be infinite. If the child is random, then it will be
re-initialized with new random values on each iteration.


### `InfiniteEffectController`

Similar to the `RepeatedEffectController`, but repeats its child controller indefinitely.

```dart
final ec = InfiniteEffectController(LinearEffectController(1));
```


### `SequenceEffectController`

Executes a sequence of effect controllers, one after another. The list of controllers cannot be
empty.

```dart
final ec = SequenceEffectController([
  LinearEffectController(1),
  PauseEffectController(0.2),
  ReverseLinearEffectController(1),
]);
```


### `DelayedEffectController`

Effect controller that executes its child controller after the prescribed `delay`. While the
controller is executing the "delay" stage, the effect will be considered "not started", i.e. its
`.started` property will be returning `false`.

```dart
final ec = DelayedEffectController(LinearEffectController(1), delay: 5);
```


## See also

* [Examples of various effects](https://examples.flame-engine.org/#/).
