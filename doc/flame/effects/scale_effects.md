# Scale Effects

Scale effects are used to change the scale of a component over time. They can be used to make a
component grow, shrink, or change its scale in a specific direction. The scale is specified as a
`Vector2` value, where each x represents the width factor and y represents the height factor. The
effects can be applied to any component that has a scale property, such as the `PositionComponent`.
The difference between size effects and scale effects is that size only changes the size of the
target component, while scale changes the "size" of all children too.


## `ScaleEffect.by`

This effect will change the target's scale by the specified amount. For example, this will cause
the component to grow 50% larger:

 ```{flutter-app}
 :sources: ../flame/examples
 :page: scale_by_effect
 :show: widget code infobox
 :width: 180
 :height: 160
 ```

```dart
final effect = ScaleEffect.by(
  Vector2.all(1.5),
  EffectController(duration: 0.3),
);
```


## `ScaleEffect.to`

This effect works similar to `ScaleEffect.by`, but sets the absolute value of the target's scale.

 ```{flutter-app}
 :sources: ../flame/examples
 :page: scale_to_effect
 :show: widget code infobox
 :width: 180
 :height: 160
 ```

```dart
final effect = ScaleEffect.to(
  Vector2.all(0.5),
  EffectController(duration: 0.5),
);
```
