import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:material_ui/material_ui.dart';

class SpriteWarpExample() extends FlameGame with DoubleTapCallbacks {
  static const String description = '''
    In this example two `SpriteComponent`s share the same sprite and are
    warped by the same `WarpGrid` of 4x4 cells, which has 5x5 = 25 vertices:
    the left one interpolates the grid bilinearly (like SpriteKit does), the
    right one with Catmull-Rom splines.

    Drag the 25 handles on the left sprite to move the vertices of the grid,
    and double tap to reset it.
  ''';

  static const int _columns = 4;
  static const int _rows = 4;

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
    final grid = WarpGrid.identity(columns: _columns, rows: _rows);

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
    _bilinear.addAll(_handles);

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
    final identity = WarpGrid.identity(columns: _columns, rows: _rows);
    final positions = identity.destinationPositions;
    for (var i = 0; i < _handles.length; i++) {
      _handles[i].position = positions[i]..multiply(_bilinear.size);
    }
    _bilinear.warpGrid = identity;
    _catmullRom.warpGrid = identity;
  }
}

class _Handle({
  required super.position,
  required final void Function() onMoved,
}) extends CircleComponent with DragCallbacks {
  this
    : super(
        radius: 8,
        anchor: Anchor.center,
        paint: Paint()..color = const Color(0xCCFF00FF),
      );

  @override
  void onDragUpdate(DragUpdateEvent event) {
    position += event.localDelta;
    onMoved();
  }
}
