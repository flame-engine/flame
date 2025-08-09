import 'dart:convert';
import 'dart:typed_data';

import 'package:flame/flame.dart';
import 'package:flame_3d/src/model/model.dart';
import 'package:flame_3d/src/parser/gltf/component_type.dart';
import 'package:flame_3d/src/parser/gltf/glb_chunk.dart';
import 'package:flame_3d/src/parser/gltf/gltf_root.dart';
import 'package:flame_3d/src/parser/model_parser.dart';

/// Parses GLB and GLTF file formats as per specified by:
/// https://registry.khronos.org/glTF/specs/2.0/glTF-2.0.pdf
class GlbParser extends ModelParser {
  @override
  Future<Model> parseModel(String filePath) async {
    final root = await parseRoot(filePath);
    return root.toFlameModel();
  }

  Future<GltfRoot> parseRoot(String filePath) async {
    final glb = await parseGlb(filePath);
    return glb.parse();
  }

  Future<Glb> parseGlb(String filePath) async {
    final content = await Flame.assets.readBinaryFile(filePath);

    var cursor = 0;
    Uint8List read(int bytes) {
      cursor += bytes;
      return content.sublist(cursor - bytes, cursor);
    }

    final magic = _parseString(read(4));
    if (magic != 'glTF') {
      throw Exception('Invalid magic number $magic');
    }

    final version = _parseInt(read(4));
    if (version != 2) {
      throw Exception('Invalid version $version');
    }

    final length = _parseInt(read(4));

    final chunks = <GlbChunk>[];
    while (cursor < content.length) {
      final chunkLength = _parseInt(read(4));
      final chunkType = _parseString(read(4));
      final chunkData = read(chunkLength);

      chunks.add(
        GlbChunk(
          length: chunkLength,
          type: chunkType,
          data: chunkData,
        ),
      );
    }

    return Glb(
      prefix: ModelParser.prefix(filePath),
      version: version,
      length: length,
      chunks: chunks,
    );
  }
}

class Glb {
  final String prefix;
  final int version;
  final int length;
  final List<GlbChunk> chunks;

  Glb({
    required this.prefix,
    required this.version,
    required this.length,
    required this.chunks,
  });

  Map<String, Object?> jsonChunk() {
    final chunk = chunks.firstWhere((GlbChunk chunk) => chunk.type == 'JSON');
    return jsonDecode(_parseString(chunk.data)) as Map<String, Object?>;
  }

  Iterable<GlbChunk> binaryChunks() {
    return chunks.where((GlbChunk chunk) => chunk.type == 'BIN\x00');
  }

  Future<GltfRoot> parse() async {
    final json = jsonChunk();
    final chunks = binaryChunks().toList();
    return GltfRoot.from(
      prefix: prefix,
      json: json,
      chunks: chunks,
    );
  }
}

int _parseInt(Uint8List bytes) {
  final byteData = ByteData.view(bytes.buffer);
  return ComponentType.unsignedInt.parseData(byteData).toInt();
}

String _parseString(Uint8List bytes) {
  return String.fromCharCodes(bytes);
}
