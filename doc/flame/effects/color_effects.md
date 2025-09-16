# Color Effects

Color effects are used to change the color of a component over time. They can be used to tint a component,
change its opacity, or apply a color filter.


## ColorEffect

This effect will change the base color of the paint, causing the rendered component to be tinted by
the provided color between a provided range.

Usage example:

```{flutter-app}
:sources: ../flame/examples
:page: color_effect
:show: widget code infobox
:width: 180
:height: 160
```

```dart
final effect = ColorEffect(
  const Color(0xFF00FF00),
  EffectController(duration: 1.5),
  opacityFrom: 0.2,
  opacityTo: 0.8,
);
```

The `opacityFrom` and `opacityTo` arguments will determine "how much" of the color that will be
applied to the component. In this example the effect will start with 20% and will go up to 80%.

**Note:** Due to how this effect is implemented, and how Flutter's `ColorFilter` class works, this
effect can't be mixed with other `ColorEffect`s, when more than one is added to the component, only
the last one will have effect.


## `OpacityToEffect`

This effect will change the opacity of the target over time to the specified alpha-value.
It can only be applied to components that implement the `OpacityProvider`.

```{flutter-app}
:sources: ../flame/examples
:page: opacity_to_effect
:show: widget code infobox
:width: 180
:height: 160
```

```dart
final effect = OpacityEffect.to(
  0.2,
  EffectController(duration: 0.75),
);
```

If the component uses multiple paints, the effect can target one more more of those paints
using the `target` parameter. The `HasPaint` mixin implements `OpacityProvider` and exposes APIs
to easily create providers for desired paintIds. For single paintId `opacityProviderOf` can be used
and for multiple paintIds and `opacityProviderOfList` can be used.


```{flutter-app}
:sources: ../flame/examples
:page: opacity_effect_with_target
:show: widget code infobox
:width: 180
:height: 160
```

```dart
final effect = OpacityEffect.to(
  0.2,
  EffectController(duration: 0.75),
  target: component.opacityProviderOfList(
    paintIds: const [paintId1, paintId2],
  ),
);
```

The opacity value of 0 corresponds to a fully transparent component, and the opacity value of 1 is
fully opaque. Convenience constructors `OpacityEffect.fadeOut()` and `OpacityEffect.fadeIn()` will
animate the target into full transparency / full visibility respectively.


## `OpacityByEffect`

This effect will change the opacity of the target relative to the specified alpha-value. For example,
the following effect will change the opacity of the target by `90%`:

```{flutter-app}
:sources: ../flame/examples
:page: opacity_by_effect
:show: widget code infobox
:width: 180
:height: 160
```

```dart
final effect = OpacityEffect.by(
  0.9,
  EffectController(duration: 0.75),
);
```

Currently this effect can only be applied to components that have a `HasPaint` mixin. If the target component
uses multiple paints, the effect can target any individual color using the `paintId` parameter.


## GlowEffect

```{note}
This effect is currently experimental, and its API may change in the future.
```

This effect will apply the glowing shade around target relative to the specified
`glow-strength`. The color of shade will be targets paint color. For example, the following effect
will apply the glowing shade around target by strength of `10`:

```{flutter-app}
:sources: ../flame/examples
:page: glow_effect
:show: widget code infobox
:width: 180
:height: 160
```

```dart
final effect = GlowEffect(
  10.0,
  EffectController(duration: 3),
);
```

Currently this effect can only be applied to components that have a `HasPaint` mixin.
