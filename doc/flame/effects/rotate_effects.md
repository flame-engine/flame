# Rotate Effects

Rotate effects are used to change the orientation of a component over time. They can be used to make
a component spin, turn towards a target, or rotate around a point. The rotation is specified in
radians, and the effects can be applied to any component that has a rotation property, such as the
`PositionComponent`.


## `RotateEffect.by`

Rotates the target clockwise by the specified angle relative to its current orientation. The angle
is in radians. For example, the following effect will rotate the target 90º (=[tau]/4 in radians)
clockwise:

```{flutter-app}
:sources: ../flame/examples
:page: rotate_by_effect
:show: widget code infobox
:width: 180
:height: 160
```

```dart
final effect = RotateEffect.by(
  tau/4,
  EffectController(duration: 2),
);
```


## `RotateEffect.to`

Rotates the target clockwise to the specified angle. For example, the following will rotate the
target to look east (0º is north, 90º=[tau]/4 east, 180º=tau/2 south, and 270º=tau*3/4 west):

```{flutter-app}
:sources: ../flame/examples
:page: rotate_to_effect
:show: widget code infobox
:width: 180
:height: 160
```

```dart
final effect = RotateEffect.to(
  tau/4,
  EffectController(duration: 2),
);
```


## `RotateAroundEffect`

Rotates the target clockwise by the specified angle relative to its current orientation around
the specified center. The angle is in radians. For example, the following effect will rotate the
target 90º (=[tau]/4 in radians) clockwise around (100, 100).

```{flutter-app}
:sources: ../flame/examples
:page: rotate_around_effect
:show: widget code infobox
:width: 180
:height: 160
```

```dart
final effect = RotateAroundEffect(
  tau/4,
  center: Vector2(100, 100),
  EffectController(duration: 2),
);
```

[tau]: https://en.wikipedia.org/wiki/Tau_(mathematical_constant)
