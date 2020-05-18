# Effects
An effect can be applied to any `PositionComponent`, there are currently two effects that you can use and that is the MoveEffect and the ScaleEffect.

If you want to create an effect that only runs once only specify the required parameters of your wanted Effect class.

## More advanced effects
Then there are two optional boolean parameters called `isInfinite` and `isAlternating`, by combining them you can get different effects.

If both of them are true the effect will be infinite and when it is done with going through the `curve` it will go back in reverse through the `curve`.

If `isInfinite` is true and `isAlternating` is false the effect will be applied from start to end of the curve and then restart from the start, for an infinite amount of time.

If `isInfinite` is false and `isAlternating` is true the effect will go from the beginning of the curve and then back again but after that stop.

`isInfinite` and `isAlternating` are false by default and then the effect is just applied once, from the beginning of the curve until the end.

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

# Examples

Full examples can be found [here](/docs/examples/effects/simple) and [here](/docs/examples/effects/infinite_effects).
