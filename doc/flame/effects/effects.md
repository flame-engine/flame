# Effects

An effect is a special component that can attach to another component in order to modify its
properties or appearance.

For example, suppose you are making a game with collectible power-up items. You want these power-ups
to generate randomly around the map and then de-spawn after some time. Obviously, you could make a
sprite component for the power-up and then place that component on the map, but we could do even
better!

Let's add a `ScaleEffect` to grow the item from 0 to 100% when the power-up first appears. Add
another infinitely repeating alternating `MoveEffect` in order to make the item move slightly up
and down. Then add an `OpacityEffect` that will "blink" the item 3 times, this effect will have a
built-in delay of 30 seconds, or however long you want your power-up to stay in place. Lastly, add
a `RemoveEffect` that will automatically remove the item from the game tree after the specified
time (you probably want to time it right after the end of the `OpacityEffect`).

As you can see, with a few simple effects we have turned a simple lifeless sprite into a much more
interesting item. And what's more important, it didn't result in an increased code complexity: the
effects, once added, will work automatically, and then self-remove from the game tree when
finished.


## Overview

The function of an `Effect` is to effect a change over time in some component's property. In order
to achieve that, the `Effect` must know the initial value of the property, the final value, and how
it should progress over time. The initial value is usually determined by an effect automatically,
the final value is provided by the user explicitly, and progression over time is handled by
[EffectControllers](effect_controllers.md).


### Effect

The base `Effect` class is not usable on its own (it is abstract), but it provides some common
functionality inherited by all other effects. This includes:

- The ability to pause/resume the effect using `effect.pause()` and `effect.resume()`. You can
  check whether the effect is currently paused using `effect.isPaused`.

- Property `removeOnFinish` (which is true by default) will cause the effect component to be
  removed from the game tree and garbage-collected once the effect completes. Set this to false
  if you plan to reuse the effect after it is finished.

- Optional user-provided `onComplete`, which will be invoked when the effect has just
  completed its execution but before it is removed from the game.

- A `completed` future that completes when the effect finishes.

- The `reset()` method reverts the effect to its original state, allowing it to run once again.

There are multiple pre-built effects provided by Flame, and you can also
[create your own](#creating-new-effects). The following effects are included:

- [`MoveByEffect`](move_effects.md#movebyeffect)
- [`MoveToEffect`](move_effects.md#movetoeffect)
- [`MoveAlongPathEffect`](move_effects.md#movealongpatheffect)
- [`RotateAroundEffect`](rotate_effects.md#rotatearoundeffect)
- [`RotateEffect.by`](rotate_effects.md#rotateeffectby)
- [`RotateEffect.to`](rotate_effects.md#rotateeffectto)
- [`ScaleEffect.by`](scale_effects.md#scaleeffectby)
- [`ScaleEffect.to`](scale_effects.md#scaleeffectto)
- [`SizeEffect.by`](size_effects.md#sizeeffectby)
- [`SizeEffect.to`](size_effects.md#sizeeffectto)
- [`AnchorByEffect`](anchor_effects.md#anchorbyeffect)
- [`AnchorToEffect`](anchor_effects.md#anchortoeffect)
- [`OpacityToEffect`](color_effects.md#opacitytoeffect)
- [`OpacityByEffect`](color_effects.md#opacitybyeffect)
- [`ColorEffect`](color_effects.md#coloreffect)
- [`SequenceEffect`](sequence_effect.md)
- [`RemoveEffect`](remove_effect.md)
- [`FunctionEffect`](function_effect.md)


## Creating new effects

Although Flame provides a wide array of built-in effects, eventually you may find them to be
insufficient. Luckily, creating new effects is very simple.

Each effect extends the base `Effect` class, possibly via one of the more specialized abstract
subclasses such as `ComponentEffect<T>` or `Transform2DEffect`.

The `Effect` class' constructor requires an `EffectController` instance as an argument. In most
cases you may want to pass that controller from your own constructor. Luckily, the effect controller
encapsulates much of the complexity of an effect's implementation, so you don't need to worry about
re-creating that functionality.

Lastly, you will need to implement a single method `apply(double progress)` that will be called at
each update tick while the effect is active. In this method you are supposed to make changes to the
target of your effect.

In addition, you may want to implement callbacks `onStart()` and `onFinish()` if there are any
actions that must be taken when the effect starts or ends.

When implementing the `apply()` method we recommend to use relative updates only. That is, change
the target property by incrementing/decrementing its current value, rather than directly setting
that property to a fixed value. This way multiple effects would be able to act on the same component
without interfering with each other.


## See also

- [Examples of various effects](https://examples.flame-engine.org/).

```{toctree}
:hidden:

Effect Controllers        <effect_controllers.md>
Move Effects              <move_effects.md>
Rotate Effects            <rotate_effects.md>
Scale Effects             <scale_effects.md>
Size Effects              <size_effects.md>
Anchor Effects            <anchor_effects.md>
Color Effects             <color_effects.md>
Sequence Effect           <sequence_effect.md>
Remove Effect             <remove_effect.md>
Function Effect           <function_effect.md>
```
