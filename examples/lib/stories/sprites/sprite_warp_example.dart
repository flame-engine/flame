import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:material_ui/material_ui.dart';

/// The images that the [SpriteWarpExample] can warp.
enum SpriteWarpImage(final String path) {
  flame('flame.png'),
  zap('zap.png'),
  pizza('pizza.png'),
  player('layers/player.png'),
  enemy('layers/enemy.png'),
  background('layers/background.png'),
  mountain('parallax/mountain-far.png'),
}

/// Predefined target grids of the [SpriteWarpExample].
enum DefaultWarpTarget(final String label) {
  none('None'),
  wave('Wave'),
  waveHorizontal('Wave Horizontal'),
  waveVertical('Wave Vertical'),
  crushNorth('Crush N'),
  crushNorthEast('Crush NE'),
  crushEast('Crush E'),
  crushSouthEast('Crush SE'),
  crushSouth('Crush S'),
  crushSouthWest('Crush SW'),
  crushWest('Crush W'),
  crushNorthWest('Crush NW'),
  deflate('Deflate'),
  inflate('Inflate'),
  implode('Implode'),
  explode('Explode');

  /// Returns this target for a grid of [gridSize] x [gridSize] cells.
  WarpGrid grid(int gridSize) {
    final identity = WarpGrid.identity(columns: gridSize, rows: gridSize);
    if (this == none) {
      return identity;
    }
    // Seeded, so that crushes always look the same.
    final random = Random(index);
    return identity.replacingDestinationPositions([
      for (final position in identity.destinationPositions)
        position + _offset(position.x, position.y, random),
    ]);
  }

  /// The offset of the vertex at ([u], [v]).
  Vector2 _offset(double u, double v, Random random) {
    return switch (this) {
      none => Vector2.zero(),
      wave => Vector2(0.1 * sin(2 * pi * v), 0.1 * sin(2 * pi * u)),
      waveHorizontal => Vector2(0.1 * sin(2 * pi * v), 0),
      waveVertical => Vector2(0, 0.1 * sin(2 * pi * u)),
      crushNorth => _crushSide(u, v, Vector2(0.5, 0), random),
      crushNorthEast => _crush(u, v, Vector2(1, 0), random),
      crushEast => _crushSide(u, v, Vector2(1, 0.5), random),
      crushSouthEast => _crush(u, v, Vector2(1, 1), random),
      crushSouth => _crushSide(u, v, Vector2(0.5, 1), random),
      crushSouthWest => _crush(u, v, Vector2(0, 1), random),
      crushWest => _crushSide(u, v, Vector2(0, 0.5), random),
      crushNorthWest => _crush(u, v, Vector2(0, 0), random),
      deflate => _towardsCenter(u, v, 0.35),
      inflate => _towardsCenter(u, v, -0.25),
      implode => _toCircle(u, v, 0.3),
      explode => _toCircle(u, v, 0.75),
    };
  }

  /// Dents [corner] inwards, crumpled by some jitter.
  static Vector2 _crush(double u, double v, Vector2 corner, Random random) {
    final distance = Vector2(u, v).distanceTo(corner) / sqrt2;
    final falloff = pow(max(0, 1 - distance / 0.55), 2).toDouble();
    return _dent(corner, 0.45, 0.15, falloff, random);
  }

  /// Dents the [middle] of a side inwards, rounder than [_crush].
  static Vector2 _crushSide(double u, double v, Vector2 middle, Random random) {
    final distance = Vector2(u, v).distanceTo(middle) / sqrt2;
    final falloff = pow(max(0, 1 - pow(distance / 0.55, 2)), 2).toDouble();
    return _dent(middle, 0.3, 0.06, falloff, random);
  }

  /// Moves a vertex inwards from [origin] by [depth] plus random [jitter],
  /// scaled by [falloff].
  static Vector2 _dent(
    Vector2 origin,
    double depth,
    double jitter,
    double falloff,
    Random random,
  ) {
    final noise = Vector2(random.nextDouble(), random.nextDouble())
      ..sub(Vector2.all(0.5));
    final inwards = (Vector2.all(0.5) - origin)..normalize();
    return (inwards * depth + noise * jitter) * falloff;
  }

  /// Moves the vertices towards the center (away if [amount] is negative),
  /// the corners the most.
  static Vector2 _towardsCenter(double u, double v, double amount) {
    final cornerOrientation = sqrt(4 * (u - 0.5).abs() * (v - 0.5).abs());
    return Vector2(0.5 - u, 0.5 - v) * amount * (0.4 + 0.6 * cornerOrientation);
  }

  /// Moves the vertices radially, turning the grid's concentric squares into
  /// circles, the outer one of [radius].
  static Vector2 _toCircle(double u, double v, double radius) {
    final outwards = Vector2(u - 0.5, v - 0.5);
    if (outwards.isZero()) {
      return Vector2.zero();
    }
    final square = max(outwards.x.abs(), outwards.y.abs()) * 2;
    return outwards.normalized() * square * radius - outwards;
  }
}

/// Hosts a [SpriteWarpExample], recreated only when [gridSize] changes. A
/// change of [startResets] or [targetResets] resets the matching grid.
class const SpriteWarpStory({
  required final int gridSize,
  required final SpriteWarpImage image,
  required final WarpInterpolation interpolation,
  required final DefaultWarpTarget defaultTarget,
  final bool animate = false,
  final int startResets = 0,
  final int targetResets = 0,
  super.key,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _SpriteWarpGame(
      gridSize: gridSize,
      image: image,
      interpolation: interpolation,
      defaultTarget: defaultTarget,
      animate: animate,
      startResets: startResets,
      targetResets: targetResets,
      key: ValueKey(gridSize),
    );
  }
}

class const _SpriteWarpGame({
  required final int gridSize,
  required final SpriteWarpImage image,
  required final WarpInterpolation interpolation,
  required final DefaultWarpTarget defaultTarget,
  required final bool animate,
  required final int startResets,
  required final int targetResets,
  super.key,
}) extends StatefulWidget {
  @override
  State<_SpriteWarpGame> createState() => _SpriteWarpGameState();
}

class _SpriteWarpGameState() extends State<_SpriteWarpGame> {
  late final SpriteWarpExample _game = SpriteWarpExample(
    gridSize: widget.gridSize,
    image: widget.image,
    interpolation: widget.interpolation,
    defaultTarget: widget.defaultTarget,
    animate: widget.animate,
  );

  @override
  void didUpdateWidget(_SpriteWarpGame oldWidget) {
    super.didUpdateWidget(oldWidget);
    _game
      ..setImage(widget.image)
      ..interpolation = widget.interpolation
      ..defaultTarget = widget.defaultTarget
      ..animate = widget.animate;
    if (widget.startResets != oldWidget.startResets) {
      _game.resetStart();
    }
    if (widget.targetResets != oldWidget.targetResets) {
      _game.resetTarget();
    }
  }

  @override
  Widget build(BuildContext context) => GameWidget(game: _game);
}

class SpriteWarpExample({
  final int gridSize = 4,
  SpriteWarpImage image = SpriteWarpImage.flame,
  WarpInterpolation interpolation = WarpInterpolation.bilinear,
  DefaultWarpTarget defaultTarget = DefaultWarpTarget.none,
  bool animate = false,
}) extends FlameGame {
  static const String description = '''
    Two sprites with the `HasWarpGrid` mixin show the start grid (left) and
    the target grid (right) of a `WarpEffect.to`.

    Drag a handle to move its vertex, or double tap it to reset the vertex.
    Use `Default Target` to pick a predefined target grid, and the reset
    buttons to reset a grid.

    Turn on `Animate` to warp each sprite to the other's grid and back.
  ''';

  SpriteWarpImage _image = image;
  WarpInterpolation _interpolation = interpolation;
  DefaultWarpTarget _defaultTarget = defaultTarget;
  bool _animate = animate;
  final List<Effect> _animations = [];

  /// The grids to restore when the animation stops.
  WarpGrid? _startGrid;
  WarpGrid? _targetGrid;

  late final _EditableWarpSprite _startSprite = _EditableWarpSprite(
    gridSize: gridSize,
    label: 'Start',
  );

  late final _EditableWarpSprite _targetSprite = _EditableWarpSprite(
    gridSize: gridSize,
    label: 'Target',
  );

  @override
  Future<void> onLoad() async {
    _applyInterpolation();
    _targetSprite.warpGrid = _defaultTarget.grid(gridSize);
    world.addAll([_startSprite, _targetSprite]);
    await _showImage();
    _updateAnimation();
  }

  /// Shows [image] on both sprites.
  void setImage(SpriteWarpImage image) {
    if (image == _image) {
      return;
    }
    _image = image;
    loaded.then((_) => _showImage());
  }

  Future<void> _showImage() async {
    final image = _image;
    final sprite = await loadSprite('assets/images/${image.path}');
    if (image != _image) {
      // Superseded by a newer image.
      return;
    }
    final scale = min(
      size.x * 0.35 / sprite.srcSize.x,
      size.y * 0.6 / sprite.srcSize.y,
    );
    final spriteSize = sprite.srcSize * scale;
    _startSprite
      ..sprite = sprite
      ..size = spriteSize
      ..position = Vector2(-spriteSize.x * 0.75, 0);
    _targetSprite
      ..sprite = sprite
      ..size = spriteSize
      ..position = Vector2(spriteSize.x * 0.75, 0);
  }

  /// Sets how both grids are interpolated.
  set interpolation(WarpInterpolation value) {
    _interpolation = value;
    _applyInterpolation();
  }

  void _applyInterpolation() {
    _startSprite.warpInterpolation = _interpolation;
    _targetSprite.warpInterpolation = _interpolation;
  }

  /// Replaces the target grid with [value], unless animating.
  set defaultTarget(DefaultWarpTarget value) {
    if (value == _defaultTarget) {
      return;
    }
    _defaultTarget = value;
    resetTarget();
  }

  /// Starts or stops warping both sprites between the two grids.
  set animate(bool value) {
    if (value == _animate) {
      return;
    }
    _animate = value;
    loaded.then((_) => _updateAnimation());
  }

  void _updateAnimation() {
    for (final sprite in [_startSprite, _targetSprite]) {
      sprite
        ..editable = !_animate
        ..gridBehind = _animate;
    }
    if (!_animate) {
      if (_animations.isNotEmpty) {
        for (final animation in _animations) {
          // Paused, so that it doesn't apply again before its removal.
          animation
            ..pause()
            ..removeFromParent();
        }
        _animations.clear();
        _startSprite.warpGrid = _startGrid;
        _targetSprite.warpGrid = _targetGrid;
      }
      return;
    }
    if (_animations.isNotEmpty) {
      return;
    }
    _startGrid = _startSprite.warpGrid;
    _targetGrid = _targetSprite.warpGrid;
    final toTarget = WarpEffect.to(_targetGrid!, _animationController());
    final toStart = WarpEffect.to(_startGrid!, _animationController());
    _startSprite.add(toTarget);
    _targetSprite.add(toStart);
    _animations.addAll([toTarget, toStart]);
  }

  static EffectController _animationController() {
    return EffectController(
      duration: 1,
      reverseDuration: 1,
      infinite: true,
      curve: Curves.easeInOut,
    );
  }

  /// Removes any distortion from the start grid, unless animating.
  void resetStart() {
    loaded.then((_) {
      if (!_animate) {
        _startSprite.warpGrid = WarpGrid.identity(
          columns: gridSize,
          rows: gridSize,
        );
      }
    });
  }

  /// Resets the target grid to the default target, unless animating.
  void resetTarget() {
    loaded.then((_) {
      if (!_animate) {
        _targetSprite.warpGrid = _defaultTarget.grid(gridSize);
      }
    });
  }
}

/// A labeled [SpriteComponent] whose grid has handles on its vertices, which
/// can be dragged or double tapped while [editable].
class _EditableWarpSprite({
  required int gridSize,
  required String label,
}) extends SpriteComponent with HasWarpGrid {
  this : super(anchor: Anchor.center) {
    warpGrid = WarpGrid.identity(columns: gridSize, rows: gridSize);
    final text = TextComponent(text: label, anchor: Anchor.center);
    addAll([text, _overlay]);
    size.addListener(
      () => text.position = Vector2(size.x / 2, size.y * 1.2),
    );
  }

  final _WarpGridOverlay _overlay = _WarpGridOverlay();

  bool editable = true;

  /// Whether the grid is drawn behind the sprite, more transparent.
  bool get gridBehind => _gridBehind;
  bool _gridBehind = false;
  set gridBehind(bool value) {
    _gridBehind = value;
    _overlay._paint.color = Color(value ? 0x40FFFFFF : 0x80FFFFFF);
  }

  @override
  void render(Canvas canvas) {
    if (gridBehind) {
      super.renderChild(canvas, _overlay);
    }
    super.render(canvas);
  }

  @override
  void renderChild(Canvas canvas, Component child) {
    // When behind, [render] already rendered the overlay.
    if (!gridBehind || child != _overlay) {
      super.renderChild(canvas, child);
    }
  }
}

/// Draws the grid of its parent, and places the handles on its vertices.
class _WarpGridOverlay() extends Component with ParentIsA<_EditableWarpSprite> {
  // Updates after the effects on the parent, so that the handles follow them.
  this : super(priority: 1);

  /// Shared by the grid lines and the handles.
  final Paint _paint = Paint()
    ..color = const Color(0x80FFFFFF)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2;

  final List<_Handle> _handles = [];
  WarpGrid? _shownGrid;
  final Vector2 _shownSize = Vector2.zero();

  @override
  void onLoad() {
    for (var i = 0; i < parent.warpGrid!.vertexCount; i++) {
      _handles.add(_Handle(this, i));
    }
    addAll(_handles);
  }

  @override
  void update(double dt) {
    final grid = parent.warpGrid!;
    final size = parent.size;
    if (identical(grid, _shownGrid) && size == _shownSize) {
      return;
    }
    _shownGrid = grid;
    _shownSize.setFrom(size);
    final positions = grid.destinationPositions;
    for (var i = 0; i < _handles.length; i++) {
      _handles[i].position = positions[i]..multiply(size);
    }
  }

  /// Resets the vertex of [handle].
  void _reset(_Handle handle) {
    final grid = parent.warpGrid!;
    final stride = grid.columns + 1;
    _move(
      handle,
      Vector2(
        (handle._index % stride) / grid.columns,
        (handle._index ~/ stride) / grid.rows,
      )..multiply(parent.size),
    );
  }

  void _move(_Handle handle, Vector2 position) {
    if (!parent.editable) {
      return;
    }
    handle.position = position;
    final size = parent.size;
    parent.warpGrid = _shownGrid = parent.warpGrid!
        .replacingDestinationPositions([
          for (final handle in _handles) handle.position.clone()..divide(size),
        ]);
  }

  /// Connects each handle to its right and bottom neighbors.
  @override
  void render(Canvas canvas) {
    final grid = parent.warpGrid!;
    final stride = grid.columns + 1;
    for (var row = 0; row <= grid.rows; row++) {
      for (var column = 0; column <= grid.columns; column++) {
        final from = _handles[row * stride + column].position.toOffset();
        if (column < grid.columns) {
          final to = _handles[row * stride + column + 1].position;
          canvas.drawLine(from, to.toOffset(), _paint);
        }
        if (row < grid.rows) {
          final to = _handles[(row + 1) * stride + column].position;
          canvas.drawLine(from, to.toOffset(), _paint);
        }
      }
    }
  }
}

/// Moves the vertex at [_index] when dragged, and resets it when double
/// tapped.
class _Handle(final _WarpGridOverlay _overlay, final int _index)
    extends CircleComponent
    with DragCallbacks, DoubleTapCallbacks {
  this : super(radius: 8, anchor: Anchor.center, paint: _overlay._paint);

  @override
  void onDragUpdate(DragUpdateEvent event) =>
      _overlay._move(this, position + event.localDelta);

  @override
  void onDoubleTapDown(DoubleTapDownEvent event) => _overlay._reset(this);
}
