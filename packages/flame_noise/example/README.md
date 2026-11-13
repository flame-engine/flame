# flame_noise example

Shake a component by moving it with a `NoiseEffectController`, which oscillates around the
original position following a noise curve, and fades out over the duration of the effect:

```dart
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame_noise/flame_noise.dart';

void shake(PositionComponent component) {
  component.add(
    MoveEffect.by(
      Vector2(0, 10),
      NoiseEffectController(
        duration: 1,
        noise: PerlinNoise(frequency: 20),
      ),
    ),
  );
}
```

The `noise` can be any of the 2D noises from the `fast_noise` package, which are exported by
`flame_noise`, and when it isn't given a `PerlinNoise` is used.
