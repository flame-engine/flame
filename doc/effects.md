# Effects
An effect can be applied to any `PositionComponent`, there are currently two effects that you can use and that is the MoveEffect and the ScaleEffect.

If you want to create an effect that only runs once only specify the required parameters of your wanted Effect class.

## More advanced effects
Then there are two optional boolean parameters called `isInfinite` and `isAlternating`, by combining them you can get different effects.

If both of them are true the effect will be infinite and when it is done with going through the `curve` it will go back in reverse through the `curve`.

If `isInfinite` is true and `isAlternating` is false the effect will be applied from start to end of the curve and then restart from the start, for an infinite amount of time.

If `isInfinite` is false and `isAlternating` is true the effect will go from the beginning of the curve and then back again but after that stop.

`isInfinite` and `isAlternating` are false by default and then the effect is just applied once, from the beginning of the curve until the end.

When an effect is completed the callback `onComplete` will be called, it can be set as an optional argument to your effect.

## MoveEffect

Applied to `PositionComponent`s, this effect can be used to move the component to a new position, using an [animation curve](https://api.flutter.dev/flutter/animation/Curves-class.html).

Usage example:
```dart
import 'package:flame/effects/effects.dart';

// Square is a PositionComponent
square.addEffect(MoveEffect(
  destination: Position(200, 200),
  speed: 250.0,
  curve: Curves.bounceInOut,
));
```

## ScaleEffect

Applied to `PositionComponent`s, this effect can be used to change the width and height of the component, using an [animation curve](https://api.flutter.dev/flutter/animation/Curves-class.html).

Usage example:
```dart
import 'package:flame/effects/effects.dart';

// Square is a PositionComponent
square.addEffect(ScaleEffect(
  size: Size(300, 300),
  speed: 250.0,
  curve: Curves.bounceInOut,
));
```

## RotateEffect

Applied to `PositionComponent`s, this effect can be used to rotate the component, using an [animation curve](https://api.flutter.dev/flutter/animation/Curves-class.html).

The angle (`radians`) is in radians and the speed is in radians per second, so if you for example want to turn 180° in 2 seconds you set `radians: pi` and `speed: 0.25`.

Usage example:
```dart
import 'dart:math';

import 'package:flame/effects/effects.dart';

// Square is a PositionComponent
square.addEffect(RotateEffect(
  radians: 2 * pi, // In radians
  speed: 1.0, // Radians per second
  curve: Curves.easeInOut,
));
```

## SequenceEffect

This effect is a combination of other effects. You provide it with a list of your predefined effects.
 
The effects in the list should only be passed to the SequenceEffect, never added to a PositionComponent with `addEffect`.

Note that no effect (except the last) added to the sequence should have their `isInfinite` property set to `true`, because then naturally the sequence will get stuck once it gets to that effect.

You can make the sequence go in a loop by setting both `isInfinite: true` and `isAlternating: true`.

Usage example:
```dart
final sequence = SequenceEffect(
    effects: [move1, scale, move2, rotate],
    isInfinite: true, 
    isAlternating: true);
myComponent.addEffect(sequence);
```
An example of how to use the SequenceEffect can be found [here](/doc/examples/effects/sequence_effect).
 
## CombinedEffect

This effect runs several different type of effects simultaneously. You provide it with a list of your predefined effects and an offset in time which should pass in between starting each effect.
 
The effects in the list should only be passed to the CombinedEffect, never added to a PositionComponent with `addEffect`.

Note that no effects should be of the same type since they will clash when trying to modify the PositionComponent.

You can make the combined effect go in a loop by setting both `isInfinite: true` and `isAlternating: true`.

Usage example:
```dart
final combination = CombinedEffect(
    effects: [move, scale, rotate],
    isInfinite: true, 
    isAlternating: true);
myComponent.addEffect(combination);
```
An example of how to use the CombinedEffect can be found [here](/doc/examples/effects/combined_effect).
 
# Examples

Full examples can be found [here](/doc/examples/effects/simple), [here](/doc/examples/effects/infinite_effects) and [here](/doc/examples/effects/combined_effects).
