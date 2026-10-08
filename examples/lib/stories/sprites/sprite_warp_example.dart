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
}

/// Hosts a [SpriteWarpExample] and shows the given [image] on it, so that
/// changing the image or [animate] keeps the current warp, while changing the
/// [gridSize] creates a new game. Every change of [resets] resets the grid.
class const SpriteWarpStory({
  required final int gridSize,
  required final SpriteWarpImage image,
  final bool animate = false,
  final int resets = 0,
  super.key,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _SpriteWarpGame(
      gridSize: gridSize,
      image: image,
      animate: animate,
      resets: resets,
      key: ValueKey(gridSize),
    );
  }
}

class const _SpriteWarpGame({
  required final int gridSize,
  required final SpriteWarpImage image,
  required final bool animate,
  required final int resets,
  super.key,
}) extends StatefulWidget {
  @override
  State<_SpriteWarpGame> createState() => _SpriteWarpGameState();
}

class _SpriteWarpGameState() extends State<_SpriteWarpGame> {
  late final SpriteWarpExample _game = SpriteWarpExample(
    gridSize: widget.gridSize,
    image: widget.image,
    animate: widget.animate,
  );

  @override
  void didUpdateWidget(_SpriteWarpGame oldWidget) {
    super.didUpdateWidget(oldWidget);
    _game
      ..setImage(widget.image)
      ..animate = widget.animate;
    if (widget.resets != oldWidget.resets) {
      _game.resetGrid();
    }
  }

  @override
  Widget build(BuildContext context) => GameWidget(game: _game);
}

class SpriteWarpExample({
  final int gridSize = 4,
  SpriteWarpImage image = SpriteWarpImage.flame,
  bool animate = false,
}) extends FlameGame with DoubleTapCallbacks {
  static const String description = '''
    In this example two `SpriteComponent`s with the `HasWarpGrid` mixin share
    the same sprite and are warped by the same `WarpGrid`: the left one
    interpolates the grid bilinearly (like SpriteKit does), the right one
    with Catmull-Rom splines.

    The grid has NxN cells, and therefore (N+1)x(N+1) vertices: use the
    `Grid Size` knob to choose N between 3 and 8 (4 by default, i.e. 25
    vertices). Changing the size resets the grid.

    Use the `Image` knob to choose the sprite: the current warp is kept.

    Turn on the `Animate` knob to make the grid wave back and forth with a
    `WarpEffect`. The effect changes the grid incrementally, so dragging the
    handles keeps working while it runs.

    Drag the handles on the left sprite to move the vertices of the grid, and
    double tap or press the `Reset` knob button to reset it (both are
    disabled while the animation runs).
  ''';

  SpriteWarpImage _image = image;
  bool _animate = animate;
  Effect? _animation;
  WarpGrid? _shownGrid;
  late final _WarpedSprite _bilinear;
  late final _WarpedSprite _catmullRom;
  late final TextComponent _bilinearLabel;
  late final TextComponent _catmullRomLabel;
  final List<_Handle> _handles = [];

  @override
  Future<void> onLoad() async {
    final grid = WarpGrid.identity(columns: gridSize, rows: gridSize);
    _bilinear = _WarpedSprite()..warpGrid = grid;
    _catmullRom = _WarpedSprite()
      ..warpGrid = grid
      ..warpInterpolation = WarpInterpolation.catmullRom;
    for (var i = 0; i < grid.vertexCount; i++) {
      _handles.add(_Handle(onMoved: _updateGrid));
    }
    _bilinear
      ..add(_GridLines(_handles, gridSize))
      ..addAll(_handles);
    _bilinearLabel = _label('Bilinear');
    _catmullRomLabel = _label('Catmull-Rom');

    world.addAll([_bilinear, _catmullRom, _bilinearLabel, _catmullRomLabel]);
    await _showImage(_image);
    _updateAnimation();
  }

  /// Starts or stops waving the grid.
  set animate(bool value) {
    if (value == _animate) {
      return;
    }
    _animate = value;
    loaded.then((_) => _updateAnimation());
  }

  void _updateAnimation() {
    if (!_animate) {
      // The grid stays as it is when the animation stops.
      _animation?.removeFromParent();
      _animation = null;
      return;
    }
    if (_animation != null) {
      return;
    }
    // Rows sway horizontally and columns vertically, the outer edges stay.
    final offsets = [
      for (var row = 0; row <= gridSize; row++)
        for (var column = 0; column <= gridSize; column++)
          Vector2(
            0.1 * sin(2 * pi * row / gridSize),
            0.1 * sin(2 * pi * column / gridSize),
          ),
    ];
    _bilinear.add(
      _animation = WarpEffect.by(
        offsets,
        EffectController(
          duration: 1,
          reverseDuration: 1,
          infinite: true,
          curve: Curves.easeInOut,
        ),
      ),
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!isLoaded) {
      return;
    }
    // Drags and the animation change the grid of the left sprite: mirror it
    // on the right sprite and on the handles.
    final grid = _bilinear.warpGrid!;
    if (!identical(grid, _shownGrid)) {
      _shownGrid = grid;
      _catmullRom.warpGrid = grid;
      _placeHandles(grid);
    }
  }

  /// Shows [image] on both sprites, keeping the current warp.
  void setImage(SpriteWarpImage image) {
    if (image == _image) {
      return;
    }
    _image = image;
    loaded.then((_) => _showImage(image));
  }

  Future<void> _showImage(SpriteWarpImage image) async {
    final sprite = await loadSprite('assets/images/${image.path}');
    if (image != _image) {
      // A newer image was chosen while this one was loading.
      return;
    }
    final scale = min(
      size.x * 0.35 / sprite.srcSize.x,
      size.y * 0.6 / sprite.srcSize.y,
    );
    final spriteSize = sprite.srcSize * scale;
    _bilinear
      ..sprite = sprite
      ..size = spriteSize
      ..position = Vector2(-spriteSize.x * 0.75, 0);
    _catmullRom
      ..sprite = sprite
      ..size = spriteSize
      ..position = Vector2(spriteSize.x * 0.75, 0);
    final labelOffset = Vector2(0, spriteSize.y * 0.7);
    _bilinearLabel.position = _bilinear.position + labelOffset;
    _catmullRomLabel.position = _catmullRom.position + labelOffset;
    _placeHandles(_bilinear.warpGrid!);
  }

  TextComponent _label(String text) {
    return TextComponent(text: text, anchor: Anchor.center);
  }

  /// Moves the handles to the destination positions of [grid].
  void _placeHandles(WarpGrid grid) {
    final positions = grid.destinationPositions;
    for (var i = 0; i < _handles.length; i++) {
      _handles[i].position = positions[i]..multiply(_bilinear.size);
    }
  }

  void _updateGrid() {
    final size = _bilinear.size;
    _bilinear.warpGrid = _bilinear.warpGrid!.replacingDestinationPositions([
      for (final handle in _handles) handle.position.clone()..divide(size),
    ]);
  }

  /// Removes any distortion from the grid.
  void resetGrid() {
    loaded.then((_) {
      _bilinear.warpGrid = WarpGrid.identity(columns: gridSize, rows: gridSize);
    });
  }

  @override
  void onDoubleTapDown(DoubleTapDownEvent event) {
    // Like the `Reset` knob button, resetting is disabled while animating.
    if (!_animate) {
      resetGrid();
    }
  }
}

class _WarpedSprite() extends SpriteComponent with HasWarpGrid {
  this : super(anchor: Anchor.center);
}

final Paint _overlayPaint = Paint()
  ..color = const Color(0x80FFFFFF)
  ..style = PaintingStyle.stroke
  ..strokeWidth = 2;

class _Handle({required final void Function() onMoved})
    extends CircleComponent
    with DragCallbacks {
  this : super(radius: 8, anchor: Anchor.center, paint: _overlayPaint);

  @override
  void onDragUpdate(DragUpdateEvent event) {
    position += event.localDelta;
    onMoved();
  }
}

/// Connects each handle to its right and bottom neighbors.
class _GridLines(final List<_Handle> _handles, final int _gridSize)
    extends Component {
  @override
  void render(Canvas canvas) {
    final stride = _gridSize + 1;
    for (var row = 0; row <= _gridSize; row++) {
      for (var column = 0; column <= _gridSize; column++) {
        final from = _handles[row * stride + column].position.toOffset();
        if (column < _gridSize) {
          final to = _handles[row * stride + column + 1].position;
          canvas.drawLine(from, to.toOffset(), _overlayPaint);
        }
        if (row < _gridSize) {
          final to = _handles[(row + 1) * stride + column].position;
          canvas.drawLine(from, to.toOffset(), _overlayPaint);
        }
      }
    }
  }
}
