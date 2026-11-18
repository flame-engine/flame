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
class GlbParser() extends ModelParser {
  @override
  Future<Model> parseModel(String filePath) async {
    final root = await parseRoot(filePath);
    return root.toFlameModel();
  }

  Future<GltfRoot> parseRoot(String filePath) async {
    final glb = await parseGlb(filePath);
    return await glb.parse();
  }

  Future<Glb> parseGlb(String filePath) async {
    final content = await Flame.assets.readBinaryFile(filePath);
    return parseGlbBytes(content, prefix: ModelParser.prefix(filePath));
  }

  /// Parses an in-memory `.glb` binary buffer into its header and [GlbChunk]s.
  Glb parseGlbBytes(Uint8List content, {String prefix = ''}) {
    if (content.length < 12) {
      throw FormatException('GLB buffer too short: ${content.length} bytes');
    }
    var cursor = 0;
    Uint8List read(int bytes) {
      cursor += bytes;
      return Uint8List.sublistView(content, cursor - bytes, cursor);
    }

    final magic = _parseString(read(4));
    if (magic != 'glTF') {
      throw FormatException('Invalid magic number $magic');
    }

    final version = _parseInt(read(4));
    if (version != 2) {
      throw FormatException('Invalid version $version');
    }

    final length = _parseInt(read(4));

    final chunks = <GlbChunk>[];
    while (cursor + 8 <= content.length) {
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
      prefix: prefix,
      version: version,
      length: length,
      chunks: chunks,
    );
  }
}

class Glb({
  required final String prefix,
  required final int version,
  required final int length,
  required final List<GlbChunk> chunks,
}) {
  Map<String, Object?> jsonChunk() {
    final chunk = chunks.firstWhere((GlbChunk chunk) => chunk.type == 'JSON');
    return jsonDecode(utf8.decode(chunk.data)) as Map<String, Object?>;
  }

  Iterable<GlbChunk> binaryChunks() {
    return chunks.where((GlbChunk chunk) => chunk.type == 'BIN\x00');
  }

  Future<GltfRoot> parse() async {
    final json = jsonChunk();
    final chunks = binaryChunks().toList();
    return await GltfRoot.from(
      prefix: prefix,
      json: json,
      chunks: chunks,
    );
  }
}

int _parseInt(Uint8List bytes) {
  final byteData = ByteData.sublistView(bytes);
  return ComponentType.unsignedInt.parseData(byteData).toInt();
}

String _parseString(Uint8List bytes) {
  return String.fromCharCodes(bytes);
}
