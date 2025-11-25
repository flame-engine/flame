import 'dart:convert';
import 'dart:typed_data';

import 'package:flame/flame.dart';
import 'package:flame_3d/model.dart';
import 'package:flame_3d/src/parser/gltf/accessor.dart';
import 'package:flame_3d/src/parser/gltf/animation.dart';
import 'package:flame_3d/src/parser/gltf/buffer.dart';
import 'package:flame_3d/src/parser/gltf/buffer_view.dart';
import 'package:flame_3d/src/parser/gltf/camera.dart';
import 'package:flame_3d/src/parser/gltf/glb_chunk.dart';
import 'package:flame_3d/src/parser/gltf/gltf_node.dart';
import 'package:flame_3d/src/parser/gltf/gltf_node_with_data.dart';
import 'package:flame_3d/src/parser/gltf/gltf_ref.dart';
import 'package:flame_3d/src/parser/gltf/image.dart';
import 'package:flame_3d/src/parser/gltf/material.dart';
import 'package:flame_3d/src/parser/gltf/mesh.dart';
import 'package:flame_3d/src/parser/gltf/node.dart';
import 'package:flame_3d/src/parser/gltf/sampler.dart';
import 'package:flame_3d/src/parser/gltf/scene.dart';
import 'package:flame_3d/src/parser/gltf/skin.dart';
import 'package:flame_3d/src/parser/gltf/texture.dart';

/// The root schema of a GLTF file.
class GltfRoot {
  /// Path prefix used to resolve relative paths.
  final String _prefix;

  late final List<Buffer> buffers;
  late final List<BufferView> bufferViews;
  late final List<RawAccessor> accessors;

  late final int scene;
  late final List<Scene> scenes;

  late final List<Node> nodes;
  late final List<Camera> cameras;
  late final List<Skin> skins;
  late final List<Mesh> meshes;
  late final List<Material> materials;
  late final List<Texture> textures;
  late final List<Animation> animations;
  late final List<Sampler> samplers;
  late final List<Image> images;

  late final List<GlbChunk> chunks;

  GltfRoot._({
    required String prefix,
  }) : _prefix = prefix;

  Future<Uint8List> readChunk(GltfRef<Buffer> ref) async {
    if (chunks.isNotEmpty) {
      final chunk = chunks[ref.index];
      return chunk.data;
    }
    final buffer = ref.get();
    return readChunkFrom(buffer.uri!);
  }

  Future<Uint8List> readChunkFrom(String uri) async {
    if (uri.startsWith('data:')) {
      const prefixes = [
        'data:application/gltf-buffer;base64,',
        'data:application/octet-stream;base64,',
      ];
      for (final prefix in prefixes) {
        if (uri.startsWith(prefix)) {
          return base64Decode(uri.substring(prefix.length));
        }
      }
      throw Exception('Unsupported data URI: $uri');
    } else {
      final path = '$_prefix/$uri';
      return Flame.assets.readBinaryFile(path);
    }
  }

  T resolve<T extends GltfNode>(int index) {
    return switch (T) {
          const (Scene) => scenes[index],
          const (Node) => nodes[index],
          const (Mesh) => meshes[index],
          const (Material) => materials[index],
          const (Camera) => cameras[index],
          const (Skin) => skins[index],
          const (BufferView) => bufferViews[index],
          const (Buffer) => buffers[index],
          const (Texture) => textures[index],
          const (Animation) => animations[index],
          const (Sampler) => samplers[index],
          const (Image) => images[index],
          const (IntAccessor) => accessors[index].asInt(),
          const (FloatAccessor) => accessors[index].asFloat(),
          const (Vector2Accessor) => accessors[index].asVector2(),
          const (Vector3Accessor) => accessors[index].asVector3(),
          const (Vector4Accessor) => accessors[index].asVector4(),
          const (QuaternionAccessor) => accessors[index].asQuaternion(),
          const (Matrix4Accessor) => accessors[index].asMatrix4(),
          const (RawAccessor) => accessors[index],
          _ => throw UnimplementedError('Cannot resolve type $T'),
        }
        as T;
  }

  static Future<GltfRoot> from({
    required String prefix,
    required Map<String, dynamic> json,
    required List<GlbChunk> chunks,
  }) async {
    final root = GltfRoot._(prefix: prefix);
    root.chunks = chunks;

    Future<List<T>> parse<T>(
      String key,
      T Function(GltfRoot, Map<String, Object?>) parser,
    ) async {
      final objects = Parser.objectList(root, json, key, parser) ?? [];
      for (final object in objects) {
        if (object is GltfNodeWithData) {
          await object.init();
        }
      }
      return objects;
    }

    root.buffers = await parse('buffers', Buffer.parse);
    root.bufferViews = await parse('bufferViews', BufferView.parse);
    root.accessors = await parse('accessors', RawAccessor.parse);

    root.scenes = await parse('scenes', Scene.parse);
    root.scene = Parser.integer(json, 'scene')!;

    root.nodes = await parse('nodes', Node.parse);
    root.cameras = await parse('cameras', Camera.parse);
    root.skins = await parse('skins', Skin.parse);
    root.meshes = await parse('meshes', Mesh.parse);
    root.materials = await parse('materials', Material.parse);
    root.textures = await parse('textures', Texture.parse);
    root.animations = await parse('animations', Animation.parse);
    root.samplers = await parse('samplers', Sampler.parse);
    root.images = await parse('images', Image.parse);

    return root;
  }

  Map<int, ModelNode> toFlameNodes([int? scene]) {
    return scenes[scene ?? this.scene].toFlameNodes();
  }

  Model toFlameModel([int? scene]) {
    return Model(
      nodes: toFlameNodes(scene),
      animations: animations
          .map((animation) => animation.toFlameAnimation())
          .toList(),
    );
  }
}
