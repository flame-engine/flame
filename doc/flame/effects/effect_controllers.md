# Effect controllers

An `EffectController` is an object that describes how the effect should evolve over time. If you
think of the initial value of the effect as 0% progress, and the final value as 100% progress, then
the job of the effect controller is to map from the "physical" time, measured in seconds, into the
"logical" time, which changes from 0 to 1.

There are multiple effect controllers provided by the Flame framework:

- [`EffectController`](#effectcontroller)
- [`LinearEffectController`](#lineareffectcontroller)
- [`ReverseLinearEffectController`](#reverselineareffectcontroller)
- [`CurvedEffectController`](#curvedeffectcontroller)
- [`ReverseCurvedEffectController`](#reversecurvedeffectcontroller)
- [`PauseEffectController`](#pauseeffectcontroller)
- [`RepeatedEffectController`](#repeatedeffectcontroller)
- [`InfiniteEffectController`](#infiniteeffectcontroller)
- [`SequenceEffectController`](#sequenceeffectcontroller)
- [`SpeedEffectController`](#speedeffectcontroller)
- [`DelayedEffectController`](#delayedeffectcontroller)
- [`NoiseEffectController`](#noiseeffectcontroller)
- [`RandomEffectController`](#randomeffectcontroller)
- [`SineEffectController`](#sineeffectcontroller)
- [`ZigzagEffectController`](#zigzageffectcontroller)


## `EffectController`

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
    VoidCallback? onMax,
    VoidCallback? onMin,
});
```

- *`duration`* -- the length of the main part of the effect, i.e. how long it should take to go
  from 0 to 100%. This parameter cannot be negative, but can be zero. If this is the only parameter
  specified then the effect will grow linearly over the `duration` seconds.

- *`curve`* -- if given, creates a non-linear effect that grows from 0 to 100% according to the
  provided [curve](https://api.flutter.dev/flutter/animation/Curves-class.html).

- *`reverseDuration`* -- if provided, adds an additional step to the controller: after the effect
  has grown from 0 to 100% over the `duration` seconds, it will then go backwards from 100% to 0
  over the `reverseDuration` seconds. In addition, the effect will complete at progress level of 0
  (normally the effect completes at progress 1).

- *`reverseCurve`* -- the curve to be used during the "reverse" step of the effect. If not given,
  this will default to `curve.flipped`.

- *`alternate`* -- setting this to true is equivalent to specifying the `reverseDuration` equal
  to the `duration`. If the `reverseDuration` is already set, this flag has no effect.

- *`atMaxDuration`* -- if non-zero, this inserts a pause after the effect reaches its max
  progress and before the reverse stage. During this time the effect is kept at 100% progress. If
  there is no reverse stage, then this will simply be a pause before the effect is marked as
  completed.

- *`atMinDuration`* -- if non-zero, this inserts a pause after the reaches its lowest progress
  (0) at the end of the reverse stage. During this time, the effect's progress is at 0%. If there
  is no reverse stage, then this pause will still be inserted after the "at-max" pause if it's
  present, or after the forward stage otherwise. In addition, the effect will now complete at
  progress level of 0.

- *`repeatCount`* -- if greater than one, it will cause the effect to repeat itself the prescribed
  number of times. Each iteration will consists of the forward stage, pause at max, reverse stage,
  then pause at min (skipping those that were not specified).

- *`infinite`* -- if true, the effect will repeat infinitely and never reach completion. This is
  equivalent to as if `repeatCount` was set to infinity.

- *`startDelay`* -- an additional wait time inserted before the beginning of the effect. This
  wait time is executed only once, even if the effect is repeating. During this time the effect's
  `.started` property returns false. The effect's `onStart()` callback will be executed at the end
  of this waiting period.

  Using this parameter is the simplest way to create a chain of effects that execute one after
  another (or with an overlap).

- *`onMax`* -- callback function which will be invoked right after reaching its max progress and
  before the optional pause and reverse stage.

- *`onMin`* -- callback function which will be invoked right after reaching its lowest progress
  at the end of the reverse stage and before the optional pause and forward stage.

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


## `LinearEffectController`

This is the simplest effect controller that grows linearly from 0 to 1 over the specified
`duration`:

```dart
final controller = LinearEffectController(3);
```


## `ReverseLinearEffectController`

Similar to the `LinearEffectController`, but it goes in the opposite direction and grows linearly
from 1 to 0 over the specified duration:

```dart
final controller = ReverseLinearEffectController(1);
```


## `CurvedEffectController`

This effect controller grows non-linearly from 0 to 1 over the specified `duration` and following
the provided `curve`:

```dart
final controller = CurvedEffectController(0.5, Curves.easeOut);
```


## `ReverseCurvedEffectController`

Similar to the `CurvedEffectController`, but the controller grows down from 1 to 0 following the
provided `curve`:

```dart
final controller = ReverseCurvedEffectController(0.5, Curves.bounceInOut);
```


## `PauseEffectController`

This effect controller keeps the progress at a constant value for the specified time duration.
Typically, the `progress` would be either 0 or 1:

```dart
final controller = PauseEffectController(1.5, progress: 0);
```


## `RepeatedEffectController`

This is a composite effect controller. It takes another effect controller as a child, and repeats
it multiple times, resetting before the start of each next cycle.

```dart
final controller = RepeatedEffectController(LinearEffectController(1), 10);
```

The child effect controller cannot be infinite. If the child is random, then it will be
re-initialized with new random values on each iteration.


## `InfiniteEffectController`

Similar to the `RepeatedEffectController`, but repeats its child controller indefinitely.

```dart
final controller = InfiniteEffectController(LinearEffectController(1));
```


## `SequenceEffectController`

Executes a sequence of effect controllers, one after another. The list of controllers cannot be
empty.

```dart
final controller = SequenceEffectController([
  LinearEffectController(1),
  PauseEffectController(0.2),
  ReverseLinearEffectController(1),
]);
```


## `SpeedEffectController`

Alters the duration of its child effect controller so that the effect proceeds at the predefined
speed. The initial duration of the child EffectController is irrelevant. The child controller must
be the subclass of `DurationEffectController`.

The `SpeedEffectController` can only be applied to effects for which the notion of speed is
well-defined. Such effects must implement the `MeasurableEffect` interface. For example, the
following effects qualify:

- [`MoveByEffect`](move_effects.md#movebyeffect)
- [`MoveToEffect`](move_effects.md#movetoeffect)
- [`MoveAlongPathEffect`](move_effects.md#movealongpatheffect)
- [`RotateEffect.by`](rotate_effects.md#rotateeffectby)
- [`RotateEffect.to`](rotate_effects.md#rotateeffectto)

The parameter `speed` is in units per second, where the notion of a "unit" depends on the target
effect. For example, for move effects, they refer to the distance traveled; for rotation effects
the units are radians.

```dart
final speedController = SpeedEffectController(LinearEffectController(0), speed: 1);
final controller = EffectController(speed: 1); // same as speedController
```


## `DelayedEffectController`

Effect controller that executes its child controller after the prescribed `delay`. While the
controller is executing the "delay" stage, the effect will be considered "not started", i.e. its
`.started` property will be returning `false`.

```dart
final controller = DelayedEffectController(LinearEffectController(1), delay: 5);
```


## `NoiseEffectController`

This effect controller exhibits noisy behavior, i.e. it oscillates randomly around zero. Such effect
controller can be used to implement a variety of shake effects.

```dart
final controller = NoiseEffectController(duration: 0.6, frequency: 10);
```


## `RandomEffectController`

This controller wraps another controller and makes its duration random. The actual value for the
duration is re-generated upon each reset, which makes this controller particularly useful within
repeated contexts, such as [](#repeatedeffectcontroller) or [](#infiniteeffectcontroller).

```dart
final controller = RandomEffectController.uniform(
  LinearEffectController(0),  // duration here is irrelevant
  min: 0.5,
  max: 1.5,
);
```

The user has the ability to control which `Random` source to use, as well as the exact distribution
of the produced random durations. Two distributions -- `.uniform` and `.exponential` are included,
any other can be implemented by the user.


## `SineEffectController`

An effect controller that represents a single period of the sine function. Use this to create
natural-looking harmonic oscillations. Two perpendicular move effects governed by
`SineEffectControllers` with different periods, will create a [Lissajous curve].

```dart
final controller = SineEffectController(period: 1);
```


## `ZigzagEffectController`

Simple alternating effect controller. Over the course of one `period`, this controller will proceed
linearly from 0 to 1, then to -1, and then back to 0. Use this for oscillating effects where the
starting position should be the center of the oscillations, rather than the extreme (as provided
by the standard alternating `EffectController`).

```dart
final controller = ZigzagEffectController(period: 2);
```

[Lissajous curve]: https://en.wikipedia.org/wiki/Lissajous_curve
