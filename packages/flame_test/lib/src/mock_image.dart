import 'dart:ui';

Future<Image> generateImage([int width = 1, int height = 1]) {
  final recorder = PictureRecorder();
  final canvas = Canvas(recorder);
  canvas.drawRect(
    Rect.fromLTWH(
      0,
      0,
      height.toDouble(),
      width.toDouble(),
    ),
    Paint()..color = const Color(0xFFFFFFFF),
  );

  final picture = recorder.endRecording();
  final image = picture.toImage(
    width,
    height,
  );
  return image;
}
