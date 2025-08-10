import 'dart:typed_data';
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

ByteData generatePNGByteData() => ByteData.sublistView(
  Uint8List.fromList([
    0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, // PNG file signature
    0x00, 0x00, 0x00, 0x0D, // IHDR chunk length
    0x49, 0x48, 0x44, 0x52, // IHDR chunk type
    0x00, 0x00, 0x00, 0x01, // Width: 1
    0x00, 0x00, 0x00, 0x01, // Height: 1
    0x08, // Bit depth: 8
    0x02, // Color type: Truecolor
    0x00, // Compression method: Deflate
    0x00, // Filter method: Adaptive
    0x00, // Interlace method: No interlace
    0x90, 0x77, 0x53, 0xDE, // CRC
    0x00, 0x00, 0x00, 0x0A, // IDAT chunk length
    0x49, 0x44, 0x41, 0x54, // IDAT chunk type
    0x08, 0xD7, 0x63, 0x60, 0x00, 0x00, 0x00, 0x02, 0x00, 0x01, 0xE2, 0x21,
    0xBC, 0x33, // IDAT data and CRC
    0x00, 0x00, 0x00, 0x00, // IEND chunk length
    0x49, 0x45, 0x4E, 0x44, // IEND chunk type
    0xAE, 0x42, 0x60, 0x82, // CRC
  ]),
);
