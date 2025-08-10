import 'dart:typed_data';
import 'dart:ui' as dart;

import 'package:flame_3d/resources.dart' as flame3d;
import 'package:flame_3d/src/parser/gltf/buffer_view.dart';
import 'package:flame_3d/src/parser/gltf/gltf_node.dart';
import 'package:flame_3d/src/parser/gltf/gltf_node_with_data.dart';
import 'package:flame_3d/src/parser/gltf/gltf_ref.dart';
import 'package:flame_3d/src/parser/gltf/gltf_root.dart';
import 'package:flame_3d/src/parser/gltf/mime_type.dart';

/// Image data used to create a texture.
class Image extends GltfNode with GltfNodeWithData<flame3d.ImageTexture> {
  /// The URI (or IRI) of the image.
  ///
  /// Relative paths are relative to the current glTF asset.
  /// Instead of referencing an external file, this field **MAY** contain a
  /// `data:`-URI.
  /// This field **MUST NOT** be defined when `bufferView` is defined.
  final String? uri;

  /// The image's media type.
  ///
  /// This field **MUST** be defined when `bufferView` is defined.
  final MimeType? mimeType;

  /// The reference to the bufferView that contains the image.
  /// This field **MUST NOT** be defined when `uri` is defined.
  final GltfRef<BufferView>? bufferView;

  Image({
    required super.root,
    required this.uri,
    required this.mimeType,
    required this.bufferView,
  });

  Image.parse(
    GltfRoot root,
    Map<String, Object?> map,
  ) : this(
        root: root,
        uri: Parser.string(map, 'uri'),
        mimeType: MimeType.parse(map, 'mimeType'),
        bufferView: Parser.ref(root, map, 'bufferView'),
      );

  Future<Uint8List> data() async {
    final uri = this.uri;
    if (uri != null) {
      return root.readChunkFrom(uri);
    } else {
      final bufferView = this.bufferView?.get();
      if (bufferView == null) {
        throw Exception('Either `uri` or `bufferView` must be defined');
      }
      return bufferView.data();
    }
  }

  Future<dart.Image> parseDartImage() async {
    final bytes = await data();
    final codec = await dart.instantiateImageCodec(bytes);
    final frameInfo = await codec.getNextFrame();
    return frameInfo.image;
  }

  @override
  Future<flame3d.ImageTexture> loadData() async {
    return flame3d.ImageTexture.create(await parseDartImage());
  }

  flame3d.ImageTexture toFlameTexture() {
    return getData();
  }
}
