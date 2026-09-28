import 'dart:typed_data';
import 'dart:ui';

import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flame_tiled/flame_tiled.dart';

Future<Uint8List> renderMapToPng(
  TiledComponent component,
) async {
  final canvasRecorder = PictureRecorder();
  final canvas = Canvas(canvasRecorder);
  component.tileMap.renderTree(canvas);
  final picture = canvasRecorder.endRecording();

  final size = component.size;
  // Map size is now 320 wide, but it has 1 extra tile of height because
  // its actually double-height tiles.
  final image = await picture.toImageSafe(size.x.toInt(), size.y.toInt());
  return imageToPng(image);
}

/// Renders the part of [map] inside [region], which is given in map pixels.
///
/// Unlike [renderMapToPng] this can capture content at negative coordinates,
/// which infinite maps have when tiles are placed left of or above the origin.
Future<Uint8List> renderMapRegionToPng(
  RenderableTiledMap map,
  Rect region,
) async {
  final canvasRecorder = PictureRecorder();
  final canvas = Canvas(canvasRecorder);
  canvas.translate(-region.left, -region.top);
  map.renderTree(canvas);
  final picture = canvasRecorder.endRecording();

  final image = await picture.toImageSafe(
    region.width.toInt(),
    region.height.toInt(),
  );
  return imageToPng(image);
}

/// Renders the [game] the way it is shown on the screen, through its camera.
Future<Uint8List> renderGameToPng(FlameGame game) async {
  final canvasRecorder = PictureRecorder();
  final canvas = Canvas(canvasRecorder);
  game.render(canvas);
  final picture = canvasRecorder.endRecording();

  final size = game.canvasSize;
  final image = await picture.toImageSafe(size.x.toInt(), size.y.toInt());
  return imageToPng(image);
}

Future<Uint8List> imageToPng(Image image) async =>
    (await image.toByteData(format: ImageByteFormat.png))!.buffer.asUint8List();
