# Sequence Effect

This effect can be used to run multiple other effects one after another. The constituent effects
may have different types.

The sequence effect can also be alternating (the sequence will first run forward, and then
backward); and also repeat a certain predetermined number of times, or infinitely.

```{flutter-app}
:sources: ../flame/examples
:page: sequence_effect
:show: widget code infobox
:width: 180
:height: 160
```

```dart
final effect = SequenceEffect([
  ScaleEffect.by(
    Vector2.all(1.5),
    EffectController(
      duration: 0.2,
      alternate: true,
    ),
  ),
  MoveEffect.by(
    Vector2(30, -50),
    EffectController(
      duration: 0.5,
    ),
  ),
  OpacityEffect.to(
    0,
    EffectController(
      duration: 0.3,
    ),
  ),
  RemoveEffect(),
]);
```
