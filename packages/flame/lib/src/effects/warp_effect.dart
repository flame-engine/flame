import 'dart:typed_data';

import 'package:flame/components.dart';
import 'package:flame/src/effects/controllers/effect_controller.dart';
import 'package:flame/src/effects/effect.dart';
import 'package:flame/src/effects/effect_target.dart';
import 'package:flame/src/effects/provider_interfaces.dart';

/// Change the [WarpGrid] of a component over time, similarly to SpriteKit's
/// `SKAction.warp(to:duration:)`.
///
/// This effect applies incremental changes to the positions of the target's
/// warp grid, and requires that any other effect or update logic applied to
/// the same grid also used incremental updates.
///
/// To animate through several grids, use a `SequenceEffect` of
/// [WarpEffect.to] effects.
class WarpEffect.by(
  List<Vector2> offsets,
  super.controller, {
  List<Vector2>? sourceOffsets,
  WarpGridProvider? target,
  super.onComplete,
  super.key,
}) extends Effect with EffectTarget<WarpGridProvider> {
  /// This constructor will create an effect that moves each destination
  /// position of the target's grid by the corresponding entry of [offsets],
  /// and each source position by the corresponding entry of [sourceOffsets],
  /// if given.
  ///
  /// The offsets are normalized like the grid positions, and there must be
  /// one per vertex. The target must have a grid when the effect starts.
  this {
    this.target = target;
  }

  /// This constructor will create an effect that changes both the source and
  /// destination positions of the target's grid to those of [grid].
  ///
  /// The target's grid must have the same number of columns and rows as
  /// [grid]. If the target has no grid when the effect starts, it starts from
  /// an identity grid.
  factory WarpEffect.to(
    WarpGrid grid,
    EffectController controller, {
    WarpGridProvider? target,
    void Function()? onComplete,
    ComponentKey? key,
  }) {
    return _WarpToEffect(
      grid,
      controller,
      target: target,
      onComplete: onComplete,
      key: key,
    );
  }

  Float32List? _destinationOffsets = _toRaw(offsets);
  Float32List? _sourceOffsets = sourceOffsets == null
      ? null
      : _toRaw(sourceOffsets);

  @override
  void onStart() {
    final grid = target.warpGrid;
    if (grid == null) {
      throw StateError('Can only apply this effect to a target with a grid');
    }
    _checkLength(grid, _destinationOffsets);
    _checkLength(grid, _sourceOffsets);
  }

  @override
  void apply(double progress) {
    final dProgress = progress - previousProgress;
    // Without offsets the grid is left as it is, so that its mesh is not
    // rebuilt every frame.
    if (dProgress == 0 ||
        (_sourceOffsets == null && _destinationOffsets == null)) {
      return;
    }
    final grid = target.warpGrid;
    if (grid == null) {
      throw StateError('The grid was removed while being warped');
    }
    target.warpGrid = WarpGrid.raw(
      grid.columns,
      grid.rows,
      _offsetBy(grid.rawSourcePositions, _sourceOffsets, dProgress),
      _offsetBy(grid.rawDestinationPositions, _destinationOffsets, dProgress),
    );
  }

  static Float32List _offsetBy(
    Float32List positions,
    Float32List? offsets,
    double factor,
  ) {
    if (offsets == null) {
      return positions;
    }
    assert(
      offsets.length == positions.length,
      'The grid changed its number of vertices while being warped',
    );
    final result = Float32List(positions.length);
    for (var i = 0; i < result.length; i++) {
      result[i] = positions[i] + offsets[i] * factor;
    }
    return result;
  }

  static void _checkLength(WarpGrid grid, Float32List? offsets) {
    if (offsets != null && offsets.length != 2 * grid.vertexCount) {
      throw ArgumentError(
        'Expected ${grid.vertexCount} offsets for a $grid, '
        'got ${offsets.length ~/ 2}',
      );
    }
  }

  static Float32List _toRaw(List<Vector2> vectors) {
    final result = Float32List(2 * vectors.length);
    for (var i = 0; i < vectors.length; i++) {
      result[2 * i] = vectors[i].x;
      result[2 * i + 1] = vectors[i].y;
    }
    return result;
  }

  /// Returns `a - b`, or `null` when they are equal so that unchanged
  /// positions are shared between grids instead of being copied every frame.
  static Float32List? _difference(Float32List a, Float32List b) {
    final result = Float32List(a.length);
    var isZero = true;
    for (var i = 0; i < result.length; i++) {
      result[i] = a[i] - b[i];
      isZero = isZero && result[i] == 0;
    }
    return isZero ? null : result;
  }
}

/// Implementation class for [WarpEffect.to]
class _WarpToEffect(
  final WarpGrid _grid,
  EffectController controller, {
  super.target,
  super.onComplete,
  super.key,
}) extends WarpEffect {
  this : super.by(const [], controller);

  @override
  void onStart() {
    final grid = target.warpGrid ??= WarpGrid.identity(
      columns: _grid.columns,
      rows: _grid.rows,
    );
    if (grid.columns != _grid.columns || grid.rows != _grid.rows) {
      throw ArgumentError(
        'Cannot warp a ${grid.columns} x ${grid.rows} grid '
        'to a ${_grid.columns} x ${_grid.rows} grid',
      );
    }
    _destinationOffsets = WarpEffect._difference(
      _grid.rawDestinationPositions,
      grid.rawDestinationPositions,
    );
    _sourceOffsets = WarpEffect._difference(
      _grid.rawSourcePositions,
      grid.rawSourcePositions,
    );
  }
}
