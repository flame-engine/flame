import 'dart:typed_data';
import 'dart:ui';

import 'package:flame/extensions.dart';
import 'package:flame_tiled/flame_tiled.dart';

Future<Uint8List> renderMapToPng(
  TiledComponent component,
) async {
  final canvasRecorder = PictureRecorder();
  final canvas = Canvas(canvasRecorder);
  component.tileMap.render(canvas);
  final picture = canvasRecorder.endRecording();

  final size = component.size;
  // Map size is now 320 wide, but it has 1 extra tile of height because
  // its actually double-height tiles.
  final image = await picture.toImageSafe(size.x.toInt(), size.y.toInt());
  return imageToPng(image);
}

Future<Uint8List> imageToPng(Image image) async =>
    (await image.toByteData(format: ImageByteFormat.png))!.buffer.asUint8List();
