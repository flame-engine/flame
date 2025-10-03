import 'dart:typed_data';
import 'dart:ui';

import 'package:flame/extensions.dart';
import 'package:flame_tiled/flame_tiled.dart';

Future<Uint8List> renderMapToPng(
  TiledComponent component, {
  bool? useGameCamera,
}) async {
  final canvasRecorder = PictureRecorder();
  late final Canvas canvas;

  final Vector2 size;
  if (useGameCamera ?? false) {
    final game = component.game;
    final camera = game.camera;
    final viewport = camera.viewport;
    canvas = Canvas(canvasRecorder);

    canvas.translate(
      -(viewport.position.x - viewport.anchor.x * viewport.size.x),
      -(viewport.position.y - viewport.anchor.y * viewport.size.y),
    );

    //final oldPos = camera.viewfinder.position;
    //camera.viewfinder.position = -oldPos;
    canvas.transform2D(camera.viewfinder.transform.inverse());
    //camera.viewfinder.position = oldPos;

    camera.renderTree(canvas);
    size = component.size;
  } else {
    canvas = Canvas(canvasRecorder);
    component.tileMap.renderTree(canvas);
    size = component.size;
  }
  final picture = canvasRecorder.endRecording();
  final image = await picture.toImageSafe(size.x.toInt(), size.y.toInt());
  return imageToPng(image);
}

Future<Uint8List> imageToPng(Image image) async =>
    (await image.toByteData(format: ImageByteFormat.png))!.buffer.asUint8List();
