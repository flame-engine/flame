# Function Effect

The `FunctionEffect` class is a very generic Effect that allows you to do almost anything without
having to define a new effect.

It runs a function that takes the target and the progress of the effect and then the user can
decide what to do with that input.

This could for example be used to make game state changes that happen over time, but that isn't
necessarily visual, like most other effects are.

In the following example we have a `PlayerState` enum that we want to change over time. We want to
change the state to `yawn` when the progress is over 50% and then back to `idle` when the progress
is over 80%.

```dart
enum PlayerState {
  idle,
  yawn,
}

final effect = FunctionEffect<SpriteAnimationGroupComponent<PlayerState>>(
  (target, progress) {
    if (progress > 0.5) {
      target.current = PlayerState.yawn;
    } else if(progress > 0.8) {
      target.current = PlayerState.idle;
    }
  },
  EffectController(
    duration: 10,
    infinite: true,
  ),
);
```
