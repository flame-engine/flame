import 'dart:typed_data';

/// Each data chunk in a GLB file.
class GlbChunk({
  required final int length,
  required final String type,
  required final Uint8List data,
});
