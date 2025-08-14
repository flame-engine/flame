# Size Effects

Size effects are used to change the size of a component over time. They can be used to make a
component grow, shrink, or change its size in a specific direction. The size is specified as a
`Vector2` value, where x represents the width and y represents the height. The effects can be
applied to any component that implements the `SizeProvider` interface, such as the
`PositionComponent`. The difference between size effects and scale effects is that size only
changes the size of the target component, while scale changes the "size" of all children too.


## `SizeEffect.by`

This effect will change the size of the target component, relative to its current size. For example,
if the target has size `Vector2(100, 100)`, then after the following effect is applied and runs its
course, the new size will be `Vector2(120, 50)`:

 ```{flutter-app}
 :sources: ../flame/examples
 :page: size_by_effect
 :show: widget code infobox
 :width: 180
 :height: 160
 ```

```dart
final effect = SizeEffect.by(
   Vector2(-15, 30),
   EffectController(duration: 1),
);
```

The size of a `PositionComponent` cannot be negative. If an effect attempts to set the size to a
negative value, the size will be clamped at zero.

Note that for this effect to work, the target component must implement the `SizeProvider` interface
and take its `size` into account when rendering. Only few of the built-in components implement this
API, but you can always make your own component work with size effects by adding
`implements SizeEffect` to the class declaration.

An alternative to `SizeEffect` is the `ScaleEffect`, which works more generally and scales both the
target component and its children.


## `SizeEffect.to`

Changes the size of the target component to the specified size. Target size cannot be negative:


 ```{flutter-app}
 :sources: ../flame/examples
 :page: size_to_effect
 :show: widget code infobox
 :width: 180
 :height: 160
 ```

```dart
final effect = SizeEffect.to(
  Vector2(90, 80),
  EffectController(duration: 1),
);
```
