# Effects

An effect can be applied to any `Component` that the effect supports.

At the moment there are only `PositionComponentEffect`s, which are applied to `PositionComponent`s,
which are presented below.

If you want to create an effect for another component just extend the `ComponentEffect` class and
add your created effect to the component by calling `component.addEffect(yourEffect)`.

## Common for all effects

All effects can be paused and resumed with `effect.pause()` and `effect.resume()`, and you can check
whether it is paused with `effect.isPaused`.

## More advanced effects

Then there are two optional boolean parameters called `isInfinite` and `isAlternating`, by combining
them you can get different effects.

 - If both of them are `true` the effect will be infinite and when it is done with going through the
 `curve` it will go back in reverse through the `curve`.
 - If `isInfinite` is `true` and `isAlternating` is `false` the effect will be applied from start to end
 of the curve and then restart from the start, for an infinite amount of time.
 - If `isInfinite` is `false` and `isAlternating` is `true` the effect will go from the beginning of the
 curve and then back again but after that stop.
 - `isInfinite` and `isAlternating` are `false` by default and then the effect is just applied once,
 from the beginning of the curve until the end.

`isRelative` is another parameter used on some effects, it is `false` by default. If it is set to `true`
it means that the effect starts at the `PositionComponent`'s value and adds whatever value you give
to it. If it is `false` it will treat the value you give it as absolute and it will go to the value
you give it no matter where it started.

When an effect is completed the callback `onComplete` will be called, it can be set as an optional
argument to your effect.

## Common for MoveEffect, ScaleEffect and RotateEffect (SimplePositionComponentEffects)

A common thing for `MoveEffect`, `ScaleEffect` and `RotateEffect` is that it takes `duration` and
`speed` as arguments, but only use one of them at a time.

 - Duration means the time it takes for one iteration from beginning to end, with alternation taken
 into account (but not `isInfinite`).
 - Speed is the speed of the effect
    + pixels per second for `MoveEffect`
    + pixels per second for `ScaleEffect`
    + radians per second for `RotateEffect`

One of these two needs to be defined, if both are defined `duration` takes precedence.

If we have a `MoveEffect` that should move between its start position and `Vector2(200, 300)` for
infinity and the time it should take from the start position to get back to the start position again
is 5 seconds, the effect would look like this:

```dart
MoveEffect(
  path: [Vector2(200, 300)],
  duration: 5,
  isInfinite: true,
  isAlternating: true,
)
```

## MoveEffect

Applied to `PositionComponent`s, this effect can be used to move the component to new positions,
using an [animation curve](https://api.flutter.dev/flutter/animation/Curves-class.html).

The speed is measured in pixels per second, and remember that you can give `duration` as an argument
instead of `speed`.

Usage example:
```dart
import 'package:flame/effects.dart';

// Square is a PositionComponent
square.addEffect(MoveEffect(
  path: [Vector2(200, 200), Vector2(200, 100), Vector(0, 50)],
  speed: 250.0,
  curve: Curves.bounceInOut,
));
```

If you want the positions in the path list to be relative to the components last position, and not
absolute values on the screen, then you can set `isRelative = true`.

When you use that, the next position in the list will be relative to the previous position in the
list, or if it is the first element of the list it is relative to the components position.
So if you have a component which is positioned at `Vector2(100, 100)` and you use
`isRelative = true` with the following path list `path: [Vector(20, 0), Vector(0, 50)]`, then the
component will first move to `(120, 0)` and then to `(120, 100)`.

## ScaleEffect

Applied to `PositionComponent`s, this effect can be used to change the width and height of the
component, using an [animation curve](https://api.flutter.dev/flutter/animation/Curves-class.html).

The speed is measured in pixels per second, and remember that you can give `duration` as an argument
instead of `speed`.

Usage example:
```dart
import 'package:flame/effects.dart';

// Square is a PositionComponent
square.addEffect(ScaleEffect(
  size: Size(300, 300),
  speed: 250.0,
  curve: Curves.bounceInOut,
));
```

## RotateEffect

Applied to `PositionComponent`s, this effect can be used to rotate the component, using an
[animation curve](https://api.flutter.dev/flutter/animation/Curves-class.html).

The `radians` argument defines the angle in radians and the `speed` argument is how fast it will rotate in radians per second, so if you for example
want to turn 180° in 2 seconds you set `radians: pi` and `speed: 0.25`.

Remember that you can give `duration` as an argument instead of `speed` to say how long the effect
should last for instead of its speed, which would be much simpler for this example.

Usage example:
```dart
import 'dart:math';

import 'package:flame/effects.dart';

// Square is a PositionComponent
square.addEffect(RotateEffect(
  radians: 2 * pi, // In radians
  speed: 1.0, // Radians per second
  curve: Curves.easeInOut,
));
```

## SequenceEffect

This effect is a combination of other effects. You provide it with a list of your predefined
effects.
 
The effects in the list should only be passed to the `SequenceEffect`, never added to a
`PositionComponent` with `addEffect`.

**Note**:  No effect (except the last) added to the sequence should have their `isInfinite` property
set to `true`, because then naturally the sequence will get stuck once it gets to that effect.

You can make the sequence go in a loop by setting both `isInfinite: true` and `isAlternating: true`.

Usage example:
```dart
final sequence = SequenceEffect(
    effects: [move1, scale, move2, rotate],
    isInfinite: true, 
    isAlternating: true);
myComponent.addEffect(sequence);
```

An example of how to use the `SequenceEffect` can be found
[here](https://github.com/flame-engine/flame/tree/main/examples/lib/stories/effects/sequence_effect.dart).
 
## CombinedEffect

This effect runs several different type of effects simultaneously. You provide it with a list of
your predefined effects and an offset in time which should pass in between starting each effect.
 
The effects in the list should only be passed to the `CombinedEffect`, never added to a
`PositionComponent` with `addEffect`.

**Note**: No effects should be of the same type since they will clash when trying to modify the
`PositionComponent`.

You can make the combined effect go in a loop by setting both `isInfinite: true` and
`isAlternating: true`.

Usage example:
```dart
final combination = CombinedEffect(
    effects: [move, scale, rotate],
    isInfinite: true, 
    isAlternating: true);
myComponent.addEffect(combination);
```

An example of how to use the `CombinedEffect` can be found
[here](https://github.com/flame-engine/flame/tree/main/examples/lib/stories/effects/combined_effect.dart).

## Examples

Full examples can be found
[here](https://github.com/flame-engine/flame/tree/main/examples/lib/stories/effects).
