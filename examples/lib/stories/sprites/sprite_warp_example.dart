import 'dart:math';

import 'package:flame/components.dart';
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
/// changing the image keeps the current warp, while changing the [gridSize]
/// creates a new game.
class const SpriteWarpStory({
  required final int gridSize,
  required final SpriteWarpImage image,
  super.key,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _SpriteWarpGame(
      gridSize: gridSize,
      image: image,
      key: ValueKey(gridSize),
    );
  }
}

class const _SpriteWarpGame({
  required final int gridSize,
  required final SpriteWarpImage image,
  super.key,
}) extends StatefulWidget {
  @override
  State<_SpriteWarpGame> createState() => _SpriteWarpGameState();
}

class _SpriteWarpGameState() extends State<_SpriteWarpGame> {
  late final SpriteWarpExample _game = SpriteWarpExample(
    gridSize: widget.gridSize,
    image: widget.image,
  );

  @override
  void didUpdateWidget(_SpriteWarpGame oldWidget) {
    super.didUpdateWidget(oldWidget);
    _game.setImage(widget.image);
  }

  @override
  Widget build(BuildContext context) => GameWidget(game: _game);
}

class SpriteWarpExample({
  final int gridSize = 4,
  SpriteWarpImage image = SpriteWarpImage.flame,
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

    Drag the handles on the left sprite to move the vertices of the grid, and
    double tap to reset it.
  ''';

  SpriteWarpImage _image = image;
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
    final grid = _bilinear.warpGrid!.replacingDestinationPositions([
      for (final handle in _handles) handle.position.clone()..divide(size),
    ]);
    _bilinear.warpGrid = grid;
    _catmullRom.warpGrid = grid;
  }

  @override
  void onDoubleTapDown(DoubleTapDownEvent event) {
    final identity = WarpGrid.identity(columns: gridSize, rows: gridSize);
    _placeHandles(identity);
    _bilinear.warpGrid = identity;
    _catmullRom.warpGrid = identity;
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
