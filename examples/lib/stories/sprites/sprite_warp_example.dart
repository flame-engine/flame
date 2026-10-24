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
  mountain('parallax/mountain-far.png'),
}

/// Predefined target grids of the [SpriteWarpExample].
enum DefaultWarpTarget(final String label) {
  none('None'),
  wave('Wave'),
  crush('Crush'),
  deflate('Deflate'),
  inflate('Inflate'),
  implode('Implode'),
  explode('Explode');

  /// Returns this target for a grid of [gridSize] x [gridSize] cells.
  WarpGrid grid(int gridSize) {
    final identity = WarpGrid.identity(columns: gridSize, rows: gridSize);
    // Seeded, so that the crush always looks the same.
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
      crush => _crush(u, v, random),
      deflate => _towardsCenter(u, v, 0.35),
      inflate => _towardsCenter(u, v, -0.25),
      implode => _toCircle(u, v, 0.3),
      explode => _toCircle(u, v, 0.75),
    };
  }

  /// Dents the top-right corner inwards, crumpled by some jitter.
  static Vector2 _crush(double u, double v, Random random) {
    final corner = Vector2(1, 0);
    final distance = Vector2(u, v).distanceTo(corner) / sqrt2;
    final falloff = pow(max(0, 1 - distance / 0.55), 2).toDouble();
    final noise = Vector2(random.nextDouble(), random.nextDouble())
      ..sub(Vector2.all(0.5));
    final inwards = (Vector2.all(0.5) - corner)..normalize();
    return (inwards * 0.45 + noise * 0.15) * falloff;
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

/// Hosts a [SpriteWarpExample], recreated only when [gridSize] changes.
class const SpriteWarpStory({
  required final int gridSize,
  required final SpriteWarpImage image,
  required final WarpInterpolation interpolation,
  required final DefaultWarpTarget defaultTarget,
  final bool animate = false,
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
    Double tap a sprite away from the handles to reset its whole grid, and
    use `Default Target` to pick a predefined target grid.

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
    label: 'Start',
    initialGrid: () => WarpGrid.identity(columns: gridSize, rows: gridSize),
  );

  late final _EditableWarpSprite _targetSprite = _EditableWarpSprite(
    label: 'Target',
    initialGrid: () => _defaultTarget.grid(gridSize),
  );

  @override
  Future<void> onLoad() async {
    _applyInterpolation();
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
    _targetSprite.resetGrid();
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
    _startSprite.editable = !_animate;
    _targetSprite.editable = !_animate;
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
}

/// A labeled [SpriteComponent] whose grid has handles on its vertices, which
/// can be dragged or double tapped while [editable]. Double tapping the
/// sprite itself resets its grid to the one returned by [initialGrid].
class _EditableWarpSprite({
  required String label,
  required final WarpGrid Function() initialGrid,
}) extends SpriteComponent with HasWarpGrid, DoubleTapCallbacks {
  this : super(anchor: Anchor.center) {
    warpGrid = initialGrid();
    final text = TextComponent(text: label, anchor: Anchor.center);
    add(text);
    size.addListener(
      () => text.position = Vector2(size.x / 2, size.y * 1.2),
    );
  }

  /// Shared by the grid lines and the handles.
  final Paint _gridPaint = Paint()
    ..color = const Color(0x80FFFFFF)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2;

  final List<_Handle> _handles = [];
  WarpGrid? _shownGrid;
  final Vector2 _shownSize = Vector2.zero();

  /// Whether the grid can be edited. While not editable, the handles are
  /// hidden and the grid is drawn faintly behind the sprite.
  bool get editable => _editable;
  bool _editable = true;
  set editable(bool value) {
    _editable = value;
    _gridPaint.color = Color(value ? 0x80FFFFFF : 0x40FFFFFF);
  }

  @override
  void onLoad() {
    for (var i = 0; i < warpGrid!.vertexCount; i++) {
      _handles.add(_Handle(this, i));
    }
    addAll(_handles);
  }

  /// Resets the whole grid.
  void resetGrid() {
    if (editable) {
      warpGrid = initialGrid();
    }
  }

  @override
  void onDoubleTapDown(DoubleTapDownEvent event) => resetGrid();

  @override
  void update(double dt) {
    final grid = warpGrid!;
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

  @override
  void render(Canvas canvas) {
    if (!editable) {
      _renderGrid(canvas);
    }
    super.render(canvas);
    if (editable) {
      _renderGrid(canvas);
    }
  }

  /// Connects each vertex to its right and bottom neighbors.
  void _renderGrid(Canvas canvas) {
    final grid = warpGrid!;
    final points = [
      for (final position in grid.destinationPositions)
        (position..multiply(size)).toOffset(),
    ];
    final stride = grid.columns + 1;
    for (var row = 0; row <= grid.rows; row++) {
      for (var column = 0; column <= grid.columns; column++) {
        final from = points[row * stride + column];
        if (column < grid.columns) {
          canvas.drawLine(from, points[row * stride + column + 1], _gridPaint);
        }
        if (row < grid.rows) {
          canvas.drawLine(
            from,
            points[(row + 1) * stride + column],
            _gridPaint,
          );
        }
      }
    }
  }

  /// Resets the vertex of [handle].
  void _resetVertex(_Handle handle) {
    final grid = warpGrid!;
    final stride = grid.columns + 1;
    _moveVertex(
      handle,
      Vector2(
        (handle._index % stride) / grid.columns,
        (handle._index ~/ stride) / grid.rows,
      )..multiply(size),
    );
  }

  void _moveVertex(_Handle handle, Vector2 position) {
    if (!editable) {
      return;
    }
    handle.position = position;
    warpGrid = _shownGrid = warpGrid!.replacingDestinationPositions([
      for (final handle in _handles) handle.position.clone()..divide(size),
    ]);
  }
}

/// Moves the vertex at [_index] when dragged, and resets it when double
/// tapped. Hidden while the grid is not editable.
class _Handle(final _EditableWarpSprite _sprite, final int _index)
    extends CircleComponent
    with DragCallbacks, DoubleTapCallbacks {
  this : super(radius: 8, anchor: Anchor.center, paint: _sprite._gridPaint);

  @override
  void render(Canvas canvas) {
    if (_sprite.editable) {
      super.render(canvas);
    }
  }

  @override
  void onDragUpdate(DragUpdateEvent event) =>
      _sprite._moveVertex(this, position + event.localDelta);

  @override
  void onDoubleTapDown(DoubleTapDownEvent event) => _sprite._resetVertex(this);
}
