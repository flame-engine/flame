import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:material_ui/material_ui.dart';

class SpriteWarpExample({final int gridSize = 4})
    extends FlameGame
    with DoubleTapCallbacks {
  static const String description = '''
    In this example two `SpriteComponent`s share the same sprite and are
    warped by the same `WarpGrid`: the left one interpolates the grid
    bilinearly (like SpriteKit does), the right one with Catmull-Rom splines.

    The grid has NxN cells, and therefore (N+1)x(N+1) vertices: use the
    `Grid Size` knob to choose N between 3 and 8 (4 by default, i.e. 25
    vertices). Changing the size resets the grid.

    Drag the handles on the left sprite to move the vertices of the grid, and
    double tap to reset it.
  ''';

  late final SpriteComponent _bilinear;
  late final SpriteComponent _catmullRom;
  final List<_Handle> _handles = [];

  @override
  Future<void> onLoad() async {
    final sprite = await loadSprite('assets/images/flame.png');
    final scale = min(
      size.x * 0.35 / sprite.srcSize.x,
      size.y * 0.6 / sprite.srcSize.y,
    );
    final spriteSize = sprite.srcSize * scale;
    final grid = WarpGrid.identity(columns: gridSize, rows: gridSize);

    _bilinear = SpriteComponent(
      sprite: sprite,
      size: spriteSize,
      position: Vector2(-spriteSize.x * 0.75, 0),
      anchor: Anchor.center,
      warpGrid: grid,
    );
    _catmullRom = SpriteComponent(
      sprite: sprite,
      size: spriteSize,
      position: Vector2(spriteSize.x * 0.75, 0),
      anchor: Anchor.center,
      warpGrid: grid,
      warpInterpolation: WarpInterpolation.catmullRom,
    );

    for (final position in grid.destinationPositions) {
      _handles.add(
        _Handle(
          position: position..multiply(spriteSize),
          onMoved: _updateGrid,
        ),
      );
    }
    _bilinear
      ..add(_GridLines(_handles, gridSize))
      ..addAll(_handles);

    world.addAll([
      _bilinear,
      _catmullRom,
      _label('Bilinear', _bilinear),
      _label('Catmull-Rom', _catmullRom),
    ]);
  }

  TextComponent _label(String text, SpriteComponent component) {
    return TextComponent(
      text: text,
      position: component.position + Vector2(0, component.size.y * 0.7),
      anchor: Anchor.center,
    );
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
    final positions = identity.destinationPositions;
    for (var i = 0; i < _handles.length; i++) {
      _handles[i].position = positions[i]..multiply(_bilinear.size);
    }
    _bilinear.warpGrid = identity;
    _catmullRom.warpGrid = identity;
  }
}

final Paint _overlayPaint = Paint()
  ..color = const Color(0x80FFFFFF)
  ..style = PaintingStyle.stroke
  ..strokeWidth = 2;

class _Handle({
  required super.position,
  required final void Function() onMoved,
}) extends CircleComponent with DragCallbacks {
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
