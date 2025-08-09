import 'dart:typed_data';

class GlbChunk {
  final int length;
  final String type;
  final Uint8List data;

  GlbChunk({
    required this.length,
    required this.type,
    required this.data,
  });
}
