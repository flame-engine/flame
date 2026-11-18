import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flame_3d/core.dart';
import 'package:flame_3d/graphics.dart';
import 'package:flame_3d/model.dart';
import 'package:flame_3d/resources.dart';
import 'package:flame_3d/src/parser/gltf/gltf_root.dart';
import 'package:flutter_test/flutter_test.dart';

Future<Uint8List> _makeTinyPng() async {
  final recorder = ui.PictureRecorder();
  ui.Canvas(recorder).drawRect(
    const ui.Rect.fromLTWH(0, 0, 4, 4),
    ui.Paint()..color = const ui.Color(0xFF8080FF),
  );
  final picture = recorder.endRecording();
  final image = picture.toImageSync(4, 4);
  picture.dispose();
  final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  image.dispose();
  return byteData!.buffer.asUint8List();
}

class _BinBuilder() {
  final BytesBuilder _bytes = BytesBuilder(copy: false);
  final List<Map<String, Object>> bufferViews = [];
  final List<Map<String, Object>> accessors = [];

  int _align4() {
    final rem = _bytes.length % 4;
    if (rem != 0) {
      _bytes.add(Uint8List(4 - rem));
    }
    return _bytes.length;
  }

  int addFloat32Accessor(
    List<double> values, {
    required String type,
    required int count,
  }) {
    final offset = _align4();
    final f32 = Float32List.fromList(values);
    final raw = f32.buffer.asUint8List();
    _bytes.add(raw);
    final bvIdx = bufferViews.length;
    bufferViews.add({
      'buffer': 0,
      'byteOffset': offset,
      'byteLength': raw.length,
    });
    final accIdx = accessors.length;
    accessors.add({
      'bufferView': bvIdx,
      'componentType': 5126, // FLOAT
      'count': count,
      'type': type,
    });
    return accIdx;
  }

  int addUint16Accessor(
    List<int> values, {
    required String type,
    required int count,
  }) {
    final offset = _align4();
    final u16 = Uint16List.fromList(values);
    final raw = u16.buffer.asUint8List();
    _bytes.add(raw);
    final bvIdx = bufferViews.length;
    bufferViews.add({
      'buffer': 0,
      'byteOffset': offset,
      'byteLength': raw.length,
    });
    final accIdx = accessors.length;
    accessors.add({
      'bufferView': bvIdx,
      'componentType': 5123, // UNSIGNED_SHORT
      'count': count,
      'type': type,
    });
    return accIdx;
  }

  int addBytesView(Uint8List data) {
    final offset = _align4();
    _bytes.add(data);
    final bvIdx = bufferViews.length;
    bufferViews.add({
      'buffer': 0,
      'byteOffset': offset,
      'byteLength': data.length,
    });
    return bvIdx;
  }

  Map<String, Object> toBufferJson() {
    final raw = _bytes.toBytes();
    return {
      'byteLength': raw.length,
      'uri': 'data:application/octet-stream;base64,${base64Encode(raw)}',
    };
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('glTF 2.0 materials, samplers, morphs & >64-joint splitting', () {
    test(
      'parses PBR maps, samplers, alphaMode, COLOR_0, morph targets '
      'and weights animation',
      () async {
        final pngBytes = await _makeTinyPng();
        final bin = _BinBuilder();
        final imgBv = bin.addBytesView(pngBytes);

        final posAcc = bin.addFloat32Accessor(
          const [0, 0, 0, 1, 0, 0, 0, 1, 0],
          type: 'VEC3',
          count: 3,
        );
        final normAcc = bin.addFloat32Accessor(
          const [0, 0, 1, 0, 0, 1, 0, 0, 1],
          type: 'VEC3',
          count: 3,
        );
        final uvAcc = bin.addFloat32Accessor(
          const [0, 0, 1, 0, 0, 1],
          type: 'VEC2',
          count: 3,
        );
        final colAcc = bin.addFloat32Accessor(
          const [1, 0.5, 0.25, 1, 1, 0.5, 0.25, 1, 1, 0.5, 0.25, 1],
          type: 'VEC4',
          count: 3,
        );
        final idxAcc = bin.addUint16Accessor(
          const [0, 1, 2],
          type: 'SCALAR',
          count: 3,
        );
        final morphPosAcc = bin.addFloat32Accessor(
          const [0, 2, 0, 0, 2, 0, 0, 2, 0],
          type: 'VEC3',
          count: 3,
        );
        final animTimeAcc = bin.addFloat32Accessor(
          const [0.0, 1.0],
          type: 'SCALAR',
          count: 2,
        );
        final animWeightAcc = bin.addFloat32Accessor(
          const [0.0, 1.0],
          type: 'SCALAR',
          count: 2,
        );

        final gltfJson = <String, dynamic>{
          'asset': {'version': '2.0'},
          'scene': 0,
          'scenes': [
            {
              'nodes': [0, 1],
            },
          ],
          'buffers': [bin.toBufferJson()],
          'bufferViews': bin.bufferViews,
          'accessors': bin.accessors,
          'images': [
            {'bufferView': imgBv, 'mimeType': 'image/png'},
          ],
          'samplers': [
            {
              'magFilter': 9728, // NEAREST
              'minFilter': 9987, // LINEAR_MIPMAP_LINEAR
              'wrapS': 33648, // MIRRORED_REPEAT
              'wrapT': 33071, // CLAMP_TO_EDGE
            },
          ],
          'textures': [
            {'sampler': 0, 'source': 0},
          ],
          'materials': [
            {
              'name': 'MaskPbr',
              'pbrMetallicRoughness': {
                'baseColorTexture': {'index': 0},
                'metallicRoughnessTexture': {'index': 0},
                'metallicFactor': 0.8,
                'roughnessFactor': 0.35,
              },
              'normalTexture': {'index': 0, 'scale': 1.4},
              'occlusionTexture': {'index': 0, 'strength': 0.65},
              'emissiveTexture': {'index': 0},
              'emissiveFactor': [0.5, 0.25, 1.0],
              'alphaMode': 'MASK',
              'alphaCutoff': 0.35,
              'doubleSided': true,
            },
            {
              'name': 'BlendPbr',
              'alphaMode': 'BLEND',
            },
          ],
          'meshes': [
            {
              'name': 'MorphedTri',
              'primitives': [
                {
                  'attributes': {
                    'POSITION': posAcc,
                    'NORMAL': normAcc,
                    'TEXCOORD_0': uvAcc,
                    'COLOR_0': colAcc,
                  },
                  'indices': idxAcc,
                  'material': 0,
                  'targets': [
                    {'POSITION': morphPosAcc},
                  ],
                },
              ],
            },
            {
              'name': 'GlassTri',
              'primitives': [
                {
                  'attributes': {'POSITION': posAcc},
                  'indices': idxAcc,
                  'material': 1,
                },
              ],
            },
          ],
          'nodes': [
            {'name': 'MaskNode', 'mesh': 0},
            {'name': 'BlendNode', 'mesh': 1},
          ],
          'animations': [
            {
              'name': 'MorphAnim',
              'samplers': [
                {
                  'input': animTimeAcc,
                  'output': animWeightAcc,
                  'interpolation': 'LINEAR',
                },
              ],
              'channels': [
                {
                  'sampler': 0,
                  'target': {'node': 0, 'path': 'weights'},
                },
              ],
            },
          ],
        };

        final root = await GltfRoot.from(
          prefix: '',
          json: gltfJson,
          chunks: const [],
        );
        final model = root.toFlameModel();

        final maskSurf = model.nodes[0]!.mesh!.surfaces.single;
        final maskMat = maskSurf.material as SpatialMaterial;
        expect(maskMat.normalTexture, isNotNull);
        expect(maskMat.normalScale, closeTo(1.4, 1e-5));
        expect(maskMat.metallicRoughnessTexture, isNotNull);
        expect(maskMat.occlusionTexture, isNotNull);
        expect(maskMat.occlusionStrength, closeTo(0.65, 1e-5));
        expect(maskMat.emissiveTexture, isNotNull);
        expect(maskMat.alphaCutoff, closeTo(0.35, 1e-5));
        expect(maskMat.doubleSided, isTrue);
        expect(maskMat.renderState.cullMode, CullMode.none);

        final sampler = maskMat.albedoTexture.sampler;
        expect(sampler.magFilter, TextureFilter.nearest);
        expect(sampler.wrapU, TextureWrap.mirror);
        expect(sampler.wrapV, TextureWrap.clamp);

        final verts = maskSurf.vertexData;
        expect(verts[5], closeTo(1.0, 1e-5));
        expect(verts[6], closeTo(0.5, 1e-5));
        expect(verts[7], closeTo(0.25, 1e-5));
        expect(maskSurf.morphTargets, hasLength(1));

        final blendMat =
            model.nodes[1]!.mesh!.surfaces.single.material as SpatialMaterial;
        expect(blendMat.renderState.translucent, isTrue);

        expect(model.animations.single.nodes[0]!.morphWeights, isNotNull);
      },
    );

    test(
      'auto-splits skinned primitives referencing >64 joints into '
      'compact <=64-joint surfaces',
      () async {
        const totalJoints = 72;
        final bin = _BinBuilder();

        final positions = <double>[];
        final joints = <int>[];
        final weights = <double>[];
        final indices = <int>[];
        final ibmFloats = <double>[];

        for (var t = 0; t < totalJoints; t++) {
          final base = t * 3;
          positions.addAll([
            t.toDouble(), 0, 0, //
            t + 0.5, 0, 0, //
            t.toDouble(), 0.5, 0, //
          ]);
          for (var v = 0; v < 3; v++) {
            joints.addAll([t, 0, 0, 0]);
            weights.addAll([1.0, 0.0, 0.0, 0.0]);
          }
          indices.addAll([base, base + 1, base + 2]);
          ibmFloats.addAll(Matrix4.identity().storage);
        }

        final posAcc = bin.addFloat32Accessor(
          positions,
          type: 'VEC3',
          count: totalJoints * 3,
        );
        final jointsAcc = bin.addUint16Accessor(
          joints,
          type: 'VEC4',
          count: totalJoints * 3,
        );
        final weightsAcc = bin.addFloat32Accessor(
          weights,
          type: 'VEC4',
          count: totalJoints * 3,
        );
        final idxAcc = bin.addUint16Accessor(
          indices,
          type: 'SCALAR',
          count: totalJoints * 3,
        );
        final ibmAcc = bin.addFloat32Accessor(
          ibmFloats,
          type: 'MAT4',
          count: totalJoints,
        );

        final gltfJson = <String, dynamic>{
          'asset': {'version': '2.0'},
          'scene': 0,
          'scenes': [
            {
              'nodes': [
                for (var j = 0; j <= totalJoints; j++) j,
              ],
            },
          ],
          'buffers': [bin.toBufferJson()],
          'bufferViews': bin.bufferViews,
          'accessors': bin.accessors,
          'meshes': [
            {
              'primitives': [
                {
                  'attributes': {
                    'POSITION': posAcc,
                    'JOINTS_0': jointsAcc,
                    'WEIGHTS_0': weightsAcc,
                  },
                  'indices': idxAcc,
                },
              ],
            },
          ],
          'skins': [
            {
              'inverseBindMatrices': ibmAcc,
              'joints': [for (var j = 0; j < totalJoints; j++) j],
            },
          ],
          'nodes': [
            for (var j = 0; j < totalJoints; j++) {'name': 'Joint_$j'},
            {'name': 'SkinnedMesh', 'mesh': 0, 'skin': 0},
          ],
        };

        final root = await GltfRoot.from(
          prefix: '',
          json: gltfJson,
          chunks: const [],
        );
        final model = root.toFlameModel();
        final skinnedNode = model.nodes[totalJoints]!;
        final mesh = skinnedNode.mesh!;

        expect(mesh.surfaces.length, 2);
        for (var s = 0; s < mesh.surfaces.length; s++) {
          expect(
            skinnedNode.orderedJointIndicesPerSurface[s]!.length,
            lessThanOrEqualTo(64),
          );
        }

        final workspace = ModelPoseWorkspace.forModel(model);
        model.evaluateInto(AnimationState(), workspace);
        expect(workspace.nodesByIndex[totalJoints]!.jointTransforms.length, 2);
      },
    );
  });
}
