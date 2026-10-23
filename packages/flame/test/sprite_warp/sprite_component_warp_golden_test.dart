import 'dart:math';
import 'dart:typed_data';

import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

/// A 64x64 checkerboard with dark grid lines, a red top-left corner and a
/// blue bottom-right corner.
Future<Image> _checkerboard() {
  const size = 64;
  final pixels = Uint8List(size * size * 4);
  for (var y = 0; y < size; y++) {
    for (var x = 0; x < size; x++) {
      final i = 4 * (y * size + x);
      final (r, g, b) = switch ((x, y)) {
        _ when x < 8 && y < 8 => (255, 0, 0),
        _ when x >= size - 8 && y >= size - 8 => (0, 0, 255),
        _ when x % 8 == 0 || y % 8 == 0 => (0, 0, 0),
        _ when (x ~/ 8 + y ~/ 8).isEven => (255, 255, 255),
        _ => (176, 208, 240),
      };
      pixels[i] = r;
      pixels[i + 1] = g;
      pixels[i + 2] = b;
      pixels[i + 3] = 255;
    }
  }
  return ImageExtension.fromPixels(pixels, size, size);
}

WarpGrid _centerPull() {
  final grid = WarpGrid.identity(columns: 2, rows: 2);
  return grid.replacingDestinationPositions(
    grid.destinationPositions..[grid.vertexIndex(1, 1)] = Vector2(0.7, 0.3),
  );
}

WarpGrid _wave() {
  final grid = WarpGrid.identity(columns: 4, rows: 4);
  return grid.replacingDestinationPositions([
    for (final p in grid.destinationPositions)
      p + Vector2(0.08 * sin(2 * pi * p.y), 0),
  ]);
}

WarpGrid _inflate() {
  final grid = WarpGrid.identity(columns: 2, rows: 2);
  final positions = grid.destinationPositions;
  positions[grid.vertexIndex(1, 0)].y -= 0.15;
  positions[grid.vertexIndex(1, 2)].y += 0.15;
  positions[grid.vertexIndex(0, 1)].x -= 0.15;
  positions[grid.vertexIndex(2, 1)].x += 0.15;
  return grid.replacingDestinationPositions(positions);
}

class _WarpedSprite({
  super.sprite,
  super.position,
  super.size,
}) extends SpriteComponent with HasWarpGrid;

_WarpedSprite _panel(
  Image image,
  int index,
  WarpGrid grid, {
  WarpInterpolation interpolation = WarpInterpolation.bilinear,
}) {
  return _WarpedSprite(
      sprite: Sprite(image),
      position: Vector2(30 + index * 160.0, 30),
      size: Vector2.all(120),
    )
    ..warpGrid = grid
    ..warpInterpolation = interpolation;
}

void main() {
  group('SpriteComponent warping', () {
    testGolden(
      'bilinear and Catmull-Rom interpolation',
      (game, tester) async {
        final image = await _checkerboard();
        game.world.addAll([
          _panel(image, 0, _centerPull()),
          _panel(
            image,
            1,
            _centerPull(),
            interpolation: WarpInterpolation.catmullRom,
          ),
          _panel(
            image,
            2,
            _wave(),
            interpolation: WarpInterpolation.catmullRom,
          ),
        ]);
        game.camera.viewfinder.anchor = Anchor.topLeft;
      },
      size: Vector2(480, 180),
      goldenFile: '../_goldens/sprite_component_warp_interpolation.png',
    );

    testGolden(
      'paint effects',
      (game, tester) async {
        final image = await _checkerboard();
        game.world.addAll([
          _panel(image, 0, _inflate())..opacity = 0.5,
          _panel(image, 1, _inflate())..tint(const Color(0x8000FF00)),
          _panel(image, 2, _inflate())..bleed = 10,
        ]);
        game.camera.viewfinder.anchor = Anchor.topLeft;
      },
      size: Vector2(480, 180),
      goldenFile: '../_goldens/sprite_component_warp_paint.png',
    );
  });
}
