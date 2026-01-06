# Combined Effect

This effect can be used to run multiple other effects simultaneously.

The combined effect can also be alternating (the sequence will first run forward, and then
backward); and also repeat a certain predetermined number of times, or infinitely.

```{flutter-app}
:sources: ../flame/examples
:page: combined_effect
:show: widget code infobox
:width: 450
:height: 350
```

```dart
final effect = CombinedEffect(
  [
    MoveEffect.by(Vector2(200, 0), EffectController(duration: 1)),
    RotateEffect.by(tau / 4, EffectController(duration: 2)),
    ScaleEffect.by(Vector2.all(1.5), EffectController(duration: 1)),
  ],
  alternate: true,
  infinite: true,
);
```
