import 'dart:io';
import 'dart:ui';

Future<Image> loadImage(String fileName) async {
  final bytes = await File('test/_resources/$fileName').readAsBytes();
  final codec = await instantiateImageCodec(bytes);
  final frameInfo = await codec.getNextFrame();
  return frameInfo.image;
}
