# Anchor Effects

Anchor effects are used to change the anchor point of a component over time. The anchor point is
the point around which the component rotates and scales.


## `AnchorByEffect`

Changes the location of the target's anchor by the specified offset. This effect can also be created
using `AnchorEffect.by()`.

```{flutter-app}
:sources: ../flame/examples
:page: anchor_by_effect
:show: widget code infobox
:width: 180
:height: 160
```

```dart
final effect = AnchorByEffect(
  Vector2(0.1, 0.1),
  EffectController(speed: 1),
);
```


## `AnchorToEffect`

Changes the location of the target's anchor. This effect can also be created using
`AnchorEffect.to()`.

```{flutter-app}
:sources: ../flame/examples
:page: anchor_to_effect
:show: widget code infobox
:width: 180
:height: 160
```

```dart
final effect = AnchorToEffect(
  Anchor.center,
  EffectController(speed: 1),
);
```
