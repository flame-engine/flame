# Warp Effects

Warp effects animate the [`WarpGrid`](../components/sprite_components.md#warping) of a component
over time. They can be applied to any component that implements the `WarpGridProvider` interface,
such as a component with the `HasWarpGrid` mixin.

Like the other built-in effects, warp effects change the grid incrementally, so several of them
can run on the same component at the same time, and they can be combined with any other code that
moves the grid's vertices by relative amounts.


## `WarpEffect.by`

This effect moves each destination position of the target's grid by the corresponding offset,
relative to its current position. Offsets are normalized like the grid positions, and there must
be one per vertex. For example, the following effect pulls the bottom-right corner of a 1x1 grid
down and to the right by half the size of the component:

```dart
final effect = WarpEffect.by(
  [Vector2.zero(), Vector2.zero(), Vector2.zero(), Vector2(0.5, 0.5)],
  EffectController(duration: 1),
);
```

Source positions can be moved as well with the optional `sourceOffsets` parameter. The target must
already have a grid when the effect starts.


## `WarpEffect.to`

Changes both the source and destination positions of the target's grid to those of the specified
grid, which must have the same number of columns and rows. If the target has no grid when the
effect starts, it starts from an undistorted grid:

```dart
final grid = WarpGrid.identity(columns: 2, rows: 2);
final positions = grid.destinationPositions;
positions[grid.vertexIndex(1, 1)] = Vector2(0.7, 0.3);

final effect = WarpEffect.to(
  grid.replacingDestinationPositions(positions),
  EffectController(duration: 1, reverseDuration: 1, infinite: true),
);
```

To animate through several grids, use a `SequenceEffect` of `WarpEffect.to` effects.

Since the warp changes at every tick while the effect runs, keep the grid as small as the warp
allows, especially when many sprites are warped at the same time.

The `Animate` knob of the
[Sprite Warp example](https://examples.flame-engine.org/#/?path=sprites/sprite-warp) warps two
sprites between their grids with two infinite `WarpEffect.to`. See
[Warping](../components/sprite_components.md#warping) for details.
