import 'dart:convert';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flame_3d/camera.dart';
import 'package:flame_3d/components.dart';
import 'package:flame_3d/core.dart';
import 'package:flame_3d/graphics.dart';
import 'package:flame_3d/parser.dart';
import 'package:flame_3d/resources.dart';
import 'package:flutter_test/flutter_test.dart';

import '../_fakes/fake_gpu_backend.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<Uint8List> makeTinyPng() async {
    final recorder = ui.PictureRecorder();
    ui.Canvas(recorder).drawRect(
      const ui.Rect.fromLTWH(0, 0, 4, 4),
      ui.Paint()..color = const ui.Color(0xFF40A0FF),
    );
    final picture = recorder.endRecording();
    final image = picture.toImageSync(4, 4);
    picture.dispose();
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    return byteData!.buffer.asUint8List();
  }

  Uint8List packGlbBytes(Map<String, Object?> gltfJson, Uint8List binPayload) {
    final jsonRaw = utf8.encode(jsonEncode(gltfJson));
    final jsonPad = (4 - (jsonRaw.length % 4)) % 4;
    final jsonChunkLen = jsonRaw.length + jsonPad;

    final binPad = (4 - (binPayload.length % 4)) % 4;
    final binChunkLen = binPayload.length + binPad;

    final totalLen = 12 + 8 + jsonChunkLen + 8 + binChunkLen;
    final out = Uint8List(totalLen);
    final bd = ByteData.sublistView(out);

    // Header: 'glTF', version 2, totalLength
    out.setRange(0, 4, 'glTF'.codeUnits);
    bd
      ..setUint32(4, 2, Endian.little)
      ..setUint32(8, totalLen, Endian.little)
      // Chunk 0: JSON (padded with 0x20 spaces)
      ..setUint32(12, jsonChunkLen, Endian.little);
    out
      ..setRange(16, 20, 'JSON'.codeUnits)
      ..setRange(20, 20 + jsonRaw.length, jsonRaw)
      ..fillRange(20 + jsonRaw.length, 20 + jsonChunkLen, 0x20);

    // Chunk 1: BIN\x00 (padded with 0x00)
    final binHeaderOff = 20 + jsonChunkLen;
    bd.setUint32(binHeaderOff, binChunkLen, Endian.little);
    out
      ..setRange(binHeaderOff + 4, binHeaderOff + 8, 'BIN\x00'.codeUnits)
      ..setRange(
        binHeaderOff + 8,
        binHeaderOff + 8 + binPayload.length,
        binPayload,
      );
    return out;
  }

  ({
    int Function(
      TypedData typed, {
      required int componentType,
      required String type,
      required int count,
      bool normalized,
      int? byteStride,
    })
    addAccessor,
    int Function(Uint8List data) addBytesView,
    Uint8List Function() toBytes,
    Map<String, Object> Function() toDataUriBuffer,
    List<Map<String, Object>> bufferViews,
    List<Map<String, Object>> accessors,
  })
  createBinBuilder() {
    final bytes = BytesBuilder(copy: false);
    final bufferViews = <Map<String, Object>>[];
    final accessors = <Map<String, Object>>[];

    int align4() {
      final rem = bytes.length % 4;
      if (rem != 0) {
        bytes.add(Uint8List(4 - rem));
      }
      return bytes.length;
    }

    int addBytesView(Uint8List data) {
      final offset = align4();
      bytes.add(data);
      final idx = bufferViews.length;
      bufferViews.add({
        'buffer': 0,
        'byteOffset': offset,
        'byteLength': data.length,
      });
      return idx;
    }

    int addAccessor(
      TypedData typed, {
      required int componentType,
      required String type,
      required int count,
      bool normalized = false,
      int? byteStride,
    }) {
      final offset = align4();
      final raw = typed.buffer.asUint8List(
        typed.offsetInBytes,
        typed.lengthInBytes,
      );
      bytes.add(raw);
      // Pad bufferView to 4 bytes as real exporters do for quantized INT16/INT8.
      final pad = (4 - (raw.length % 4)) % 4;
      if (pad != 0) {
        bytes.add(Uint8List(pad));
      }
      final bvIdx = bufferViews.length;
      bufferViews.add({
        'buffer': 0,
        'byteOffset': offset,
        'byteLength': raw.length + pad,
        'byteStride': ?byteStride,
      });
      final accIdx = accessors.length;
      accessors.add({
        'bufferView': bvIdx,
        'componentType': componentType,
        'count': count,
        'type': type,
        if (normalized) 'normalized': true,
      });
      return accIdx;
    }

    Uint8List toBytes() {
      align4();
      return bytes.toBytes();
    }

    Map<String, Object> toDataUriBuffer() {
      final raw = toBytes();
      return {
        'byteLength': raw.length,
        'uri': 'data:application/octet-stream;base64,${base64Encode(raw)}',
      };
    }

    return (
      addAccessor: addAccessor,
      addBytesView: addBytesView,
      toBytes: toBytes,
      toDataUriBuffer: toDataUriBuffer,
      bufferViews: bufferViews,
      accessors: accessors,
    );
  }

  group('glTF 2.0 extensions & SceneLoader3D', () {
    test(
      'supports KHR_materials_unlit, KHR_materials_emissive_strength, '
      'KHR_texture_transform, and KHR_mesh_quantization',
      () async {
        final pngBytes = await makeTinyPng();
        final bin = createBinBuilder();
        final imgBv = bin.addBytesView(pngBytes);

        // Quantized normalized INT16 positions: 32767 -> 1.0, -32767 -> -1.0.
        final posInt16 = Int16List.fromList(const [
          0,
          0,
          0,
          32767,
          0,
          0,
          0,
          16384,
          -32767,
        ]);
        final posAcc = bin.addAccessor(
          posInt16,
          componentType: 5122, // SHORT
          type: 'VEC3',
          count: 3,
          normalized: true,
        );

        // Quantized normalized INT8 normals: (0, 0, 127) -> (0, 0, 1).
        final nrmInt8 = Int8List.fromList(const [
          0,
          0,
          127,
          0,
          0,
          127,
          0,
          0,
          127,
        ]);
        final nrmAcc = bin.addAccessor(
          nrmInt8,
          componentType: 5120, // BYTE
          type: 'VEC3',
          count: 3,
          normalized: true,
        );

        // Quantized normalized UINT16 UVs: 65535 -> 1.0, 32768 -> ~0.5.
        final uvUint16 = Uint16List.fromList(const [
          0,
          0,
          65535,
          0,
          32768,
          65535,
        ]);
        final uvAcc = bin.addAccessor(
          uvUint16,
          componentType: 5123, // UNSIGNED_SHORT
          type: 'VEC2',
          count: 3,
          normalized: true,
        );

        // Quantized normalized UINT8 RGBA colors.
        final colUint8 = Uint8List.fromList(const [
          255,
          128,
          0,
          255,
          255,
          128,
          0,
          255,
          255,
          128,
          0,
          255,
        ]);
        final colAcc = bin.addAccessor(
          colUint8,
          componentType: 5121, // UNSIGNED_BYTE
          type: 'VEC4',
          count: 3,
          normalized: true,
        );

        final idxAcc = bin.addAccessor(
          Uint16List.fromList(const [0, 1, 2]),
          componentType: 5123,
          type: 'SCALAR',
          count: 3,
        );

        final gltfJson = <String, dynamic>{
          'asset': {'version': '2.0'},
          'extensionsUsed': [
            'KHR_materials_unlit',
            'KHR_materials_emissive_strength',
            'KHR_texture_transform',
            'KHR_mesh_quantization',
          ],
          'extensions': {
            'custom_root': {'tag': 'demo'},
          },
          'extras': {'author': 'engine_test'},
          'scenes': [
            {
              'nodes': [0, 1],
            },
          ],
          'buffers': [bin.toDataUriBuffer()],
          'bufferViews': bin.bufferViews,
          'accessors': bin.accessors,
          'images': [
            {'bufferView': imgBv, 'mimeType': 'image/png'},
          ],
          'textures': [
            {'source': 0},
          ],
          'materials': [
            {
              'name': 'UnlitCard',
              'pbrMetallicRoughness': {
                'baseColorFactor': [0.2, 0.4, 0.8, 1.0],
                'baseColorTexture': {'index': 0},
              },
              'alphaMode': 'OPAQUE',
              'extensions': {'KHR_materials_unlit': <String, Object>{}},
              'extras': {'shaderHint': 'flat'},
            },
            {
              'name': 'GlowingTiledPbr',
              'pbrMetallicRoughness': {
                'baseColorTexture': {
                  'index': 0,
                  'extensions': {
                    'KHR_texture_transform': {
                      'offset': [0.25, 0.75],
                      'scale': [2.0, 3.5],
                    },
                  },
                },
              },
              'emissiveFactor': [1.0, 0.5, 0.2],
              'extensions': {
                'KHR_materials_emissive_strength': {'emissiveStrength': 4.5},
              },
            },
          ],
          'meshes': [
            {
              'primitives': [
                {
                  'attributes': {
                    'POSITION': posAcc,
                    'NORMAL': nrmAcc,
                    'TEXCOORD_0': uvAcc,
                    'COLOR_0': colAcc,
                  },
                  'indices': idxAcc,
                  'material': 0,
                },
              ],
            },
            {
              'primitives': [
                {
                  'attributes': {
                    'POSITION': posAcc,
                    'NORMAL': nrmAcc,
                    'TEXCOORD_0': uvAcc,
                  },
                  'indices': idxAcc,
                  'material': 1,
                },
              ],
            },
          ],
          'nodes': [
            {'name': 'UnlitQuantizedNode', 'mesh': 0},
            {'name': 'EmissiveTiledNode', 'mesh': 1},
          ],
        };

        final root = await GltfRoot.from(
          prefix: '',
          json: gltfJson,
          chunks: const [],
        );
        expect(root.extensions, isNotNull);
        expect((root.extras! as Map)['author'], 'engine_test');
        expect((root.materials[0].extras! as Map)['shaderHint'], 'flat');

        final model = root.toFlameModel();

        // 1. KHR_materials_unlit -> UnlitMaterial with RenderState.opaque.
        final surf0 = model.nodes[0]!.mesh!.surfaces.single;
        expect(surf0.material, isA<UnlitMaterial>());
        final unlitMat = surf0.material as UnlitMaterial;
        expect(unlitMat.renderState, RenderState.opaque);
        expect(unlitMat.albedoColor.b, closeTo(0.8, 0.02));

        // 2. KHR_mesh_quantization -> normalized INT16/INT8/UINT16/UINT8.
        final stride = surf0.layout.strideInFloats;
        final v = surf0.vertexData;
        // Vertex 1 position: (32767 / 32767, 0, 0) = (1, 0, 0)
        expect(v[stride], closeTo(1.0, 1e-4));
        // Vertex 2 position: (0, 16384 / 32767, -1)
        expect(v[2 * stride + 1], closeTo(16384 / 32767, 1e-4));
        expect(v[2 * stride + 2], closeTo(-1.0, 1e-4));
        // Vertex 2 UV: (32768 / 65535, 1.0)
        expect(v[2 * stride + 3], closeTo(32768 / 65535, 1e-4));
        expect(v[2 * stride + 4], closeTo(1.0, 1e-4));
        // Vertex 0 normal: (0, 0, 1) and color: (1, 128/255, 0, 1)
        expect(v[11], closeTo(1.0, 1e-4));
        expect(v[5], closeTo(1.0, 1e-4));
        expect(v[6], closeTo(128 / 255, 1e-3));

        // 3. KHR_materials_emissive_strength & KHR_texture_transform.
        final surf1 = model.nodes[1]!.mesh!.surfaces.single;
        final pbrMat = surf1.material as SpatialMaterial;
        expect(pbrMat.emissiveStrength, closeTo(4.5, 1e-5));
        expect(pbrMat.uvOffset.x, closeTo(0.25, 1e-5));
        expect(pbrMat.uvOffset.y, closeTo(0.75, 1e-5));
        expect(pbrMat.uvScale.x, closeTo(2.0, 1e-5));
        expect(pbrMat.uvScale.y, closeTo(3.5, 1e-5));
      },
    );

    test(
      'SceneLoader3D spawns KHR_lights_punctual, cameras, '
      'EXT_mesh_gpu_instancing, auto-batched InstancedGroup3D, '
      'ModelComponent, and extras hooks',
      () async {
        final bin = createBinBuilder();
        final posAcc = bin.addAccessor(
          Float32List.fromList(const [0, 0, 0, 1, 0, 0, 0, 1, 0]),
          componentType: 5126,
          type: 'VEC3',
          count: 3,
        );
        final idxAcc = bin.addAccessor(
          Uint16List.fromList(const [0, 1, 2]),
          componentType: 5123,
          type: 'SCALAR',
          count: 3,
        );

        // 4 GPU-instanced translations for mesh 0 (`GrassBlade`).
        final instTransAcc = bin.addAccessor(
          Float32List.fromList(const [
            1, 0, 0, //
            2, 0, 0, //
            3, 0, 0, //
            4, 0, 0, //
          ]),
          componentType: 5126,
          type: 'VEC3',
          count: 4,
        );
        final instScaleAcc = bin.addAccessor(
          Float32List.fromList(const [
            1, 2, 1, //
            1, 2, 1, //
            1, 2, 1, //
            1, 2, 1, //
          ]),
          componentType: 5126,
          type: 'VEC3',
          count: 4,
        );

        // Simple keyframe animation on node 7 (`AnimatedPlatform`).
        final animTimesAcc = bin.addAccessor(
          Float32List.fromList(const [0.0, 1.0]),
          componentType: 5126,
          type: 'SCALAR',
          count: 2,
        );
        final animValsAcc = bin.addAccessor(
          Float32List.fromList(const [0, 0, 0, 0, 5, 0]),
          componentType: 5126,
          type: 'VEC3',
          count: 2,
        );

        // Rotate -90 deg around X so local -Z points straight down (0, -1, 0).
        final downRot = Quaternion.axisAngle(Vector3(1, 0, 0), -math.pi / 2);

        final gltfJson = <String, dynamic>{
          'asset': {'version': '2.0'},
          'extensions': {
            'KHR_lights_punctual': {
              'lights': [
                {
                  'name': 'Sun',
                  'type': 'directional',
                  'color': [1.0, 0.95, 0.8],
                  'intensity': 2.5,
                },
                {
                  'name': 'Torch',
                  'type': 'point',
                  'color': [1.0, 0.5, 0.1],
                  'intensity': 6.0,
                  'range': 12.0,
                },
                {
                  'name': 'Flashlight',
                  'type': 'spot',
                  'color': [0.8, 0.9, 1.0],
                  'intensity': 4.0,
                  'range': 25.0,
                  'spot': {
                    'innerConeAngle': 0.2,
                    'outerConeAngle': 0.6,
                  },
                },
              ],
            },
          },
          'cameras': [
            {
              'type': 'perspective',
              'perspective': {
                'yfov': math.pi / 3, // 60 degrees
                'znear': 0.1,
                'zfar': 500.0,
              },
            },
          ],
          'meshes': [
            {
              // Mesh 0: EXT_mesh_gpu_instancing grass (4 instances)
              'primitives': [
                {
                  'attributes': {'POSITION': posAcc},
                  'indices': idxAcc,
                },
              ],
            },
            {
              // Mesh 1: Pillar placed on 3 separate static nodes -> auto-batch!
              'primitives': [
                {
                  'attributes': {'POSITION': posAcc},
                  'indices': idxAcc,
                },
              ],
            },
            {
              // Mesh 2: Single unique hero statue -> MeshComponent!
              'primitives': [
                {
                  'attributes': {'POSITION': posAcc},
                  'indices': idxAcc,
                },
              ],
            },
          ],
          'nodes': [
            // 0: Sun directional light
            {
              'name': 'SunNode',
              'rotation': [downRot.x, downRot.y, downRot.z, downRot.w],
              'extensions': {
                'KHR_lights_punctual': {'light': 0},
              },
            },
            // 1: Torch point light
            {
              'name': 'TorchNode',
              'translation': [3.0, 2.0, -4.0],
              'extensions': {
                'KHR_lights_punctual': {'light': 1},
              },
            },
            // 2: Flashlight spot light
            {
              'name': 'SpotNode',
              'translation': [0.0, 5.0, 0.0],
              'rotation': [downRot.x, downRot.y, downRot.z, downRot.w],
              'extensions': {
                'KHR_lights_punctual': {'light': 2},
              },
            },
            // 3: Camera node
            {
              'name': 'MainCam',
              'camera': 0,
              'translation': [0.0, 4.0, 10.0],
            },
            // 4: EXT_mesh_gpu_instancing grass patch
            {
              'name': 'GrassPatch',
              'mesh': 0,
              'translation': [10.0, 0.0, 0.0],
              'extensions': {
                'EXT_mesh_gpu_instancing': {
                  'attributes': {
                    'TRANSLATION': instTransAcc,
                    'SCALE': instScaleAcc,
                  },
                },
              },
            },
            // 5, 6, 7: Three static pillars sharing mesh 1
            {
              'name': 'PillarA',
              'mesh': 1,
              'translation': [-5.0, 0.0, 0.0],
            },
            {
              'name': 'PillarB',
              'mesh': 1,
              'translation': [0.0, 0.0, 0.0],
            },
            {
              'name': 'PillarC',
              'mesh': 1,
              'translation': [5.0, 0.0, 0.0],
            },
            // 8: Single static prop (mesh 2)
            {
              'name': 'Statue',
              'mesh': 2,
              'translation': [0.0, 0.0, -8.0],
            },
            // 9: Animated platform (mesh 2, animated -> ModelComponent!)
            {
              'name': 'AnimatedPlatform',
              'mesh': 2,
              'translation': [0.0, 1.0, 0.0],
            },
            // 10: Trigger volume empty node with custom Blender `extras`
            {
              'name': 'SpawnPoint_Alpha',
              'translation': [7.0, 0.5, -3.0],
              'extras': {'kind': 'spawn_point', 'team': 1},
            },
          ],
          'scenes': [
            {
              'nodes': [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10],
            },
          ],
          'animations': [
            {
              'name': 'Lift',
              'samplers': [
                {
                  'input': animTimesAcc,
                  'output': animValsAcc,
                  'interpolation': 'LINEAR',
                },
              ],
              'channels': [
                {
                  'sampler': 0,
                  'target': {'node': 9, 'path': 'translation'},
                },
              ],
            },
          ],
          'buffers': [
            {'byteLength': bin.toBytes().length},
          ],
          'bufferViews': bin.bufferViews,
          'accessors': bin.accessors,
        };

        final glbBytes = packGlbBytes(gltfJson, bin.toBytes());
        final extrasSeen = <String, Map<String, Object?>>{};
        final markerMesh = CuboidMesh(size: Vector3.all(0.5));

        final scene = await SceneLoader3D.loadGlbBytes(
          glbBytes,
          onNodeExtras: (ctx) {
            extrasSeen[ctx.name ?? ''] = {
              ...?ctx.extrasMap,
              'worldX': ctx.worldPosition.x,
              'worldZ': ctx.worldPosition.z,
            };
            ctx.addComponent(
              MeshComponent(mesh: markerMesh, position: ctx.worldPosition),
            );
          },
        );

        // 3 punctual lights: Directional, Point, Spot
        expect(scene.lights, hasLength(3));
        final dirLight = scene.lights[0].source as DirectionalLight;
        expect(dirLight.intensity, closeTo(2.5, 1e-5));
        expect(dirLight.direction!.y, closeTo(-1.0, 1e-4));

        final ptLight = scene.lights[1].source as PointLight;
        expect(ptLight.intensity, closeTo(6.0, 1e-5));
        expect(ptLight.range, closeTo(12.0, 1e-5));
        expect(scene.lights[1].position.x, closeTo(3.0, 1e-5));

        final spLight = scene.lights[2].source as SpotLight;
        expect(spLight.innerConeAngle, closeTo(0.2, 1e-5));
        expect(spLight.outerConeAngle, closeTo(0.6, 1e-5));
        expect(spLight.range, closeTo(25.0, 1e-5));
        expect(spLight.direction!.y, closeTo(-1.0, 1e-4));

        // Camera config
        expect(scene.cameras, hasLength(1));
        final camCfg = scene.cameras.single;
        expect(camCfg.fovYDegrees, closeTo(60.0, 1e-4));
        expect(camCfg.near, closeTo(0.1, 1e-5));
        expect(camCfg.far, closeTo(500.0, 1e-5));
        final camComp = camCfg.toCameraComponent();
        expect(camComp.position.z, closeTo(10.0, 1e-5));

        // 2 InstancedGroup3D batches:
        // - GrassPatch (`EXT_mesh_gpu_instancing`: 4 instances at x = 11..14)
        // - Pillars (3 static nodes sharing mesh 1 auto-coalesced!)
        expect(scene.instancedGroups, hasLength(2));
        final grassGroup = scene.instancedGroups.firstWhere(
          (g) => g.length == 4,
        );
        expect(
          grassGroup.instanceTransform(0).getTranslation().x,
          closeTo(11.0, 1e-5),
        );
        final pillarGroup = scene.instancedGroups.firstWhere(
          (g) => g.length == 3,
        );
        expect(pillarGroup.length, 3);

        // 1 single static MeshComponent (`Statue`) + 1 animated ModelComponent
        expect(scene.staticMeshes, hasLength(1));
        expect(scene.staticMeshes.single.position.z, closeTo(-8.0, 1e-5));
        expect(scene.models, hasLength(1));
        expect(scene.models.single.animationNames, contains('Lift'));

        // Custom `extras` callback & custom component mounting into World3D
        expect(extrasSeen['SpawnPoint_Alpha']?['kind'], 'spawn_point');
        expect(extrasSeen['SpawnPoint_Alpha']?['worldX'], closeTo(7.0, 1e-5));
        expect(scene.customComponents, hasLength(1));

        final world = World3D();
        scene.mountInto(world);
        expect(world.children.length, scene.allComponents.length);
      },
    );
  });

  group('AsyncModelLoader3D isolate streaming & AssetScope3D disposal', () {
    test(
      'parses GLB & OBJ in background isolates, builds BVHs/mipmaps, and '
      'ref-counts GPU resources in AssetScope3D',
      () async {
        final backend = FakeGpuBackend();
        final device = GraphicsDevice(backend: backend)..begin();

        final pngBytes = await makeTinyPng();
        final bin = createBinBuilder();
        final imgBv = bin.addBytesView(pngBytes);
        final posAcc = bin.addAccessor(
          Float32List.fromList(const [0, 0, 0, 2, 0, 0, 0, 2, 0]),
          componentType: 5126,
          type: 'VEC3',
          count: 3,
        );
        final idxAcc = bin.addAccessor(
          Uint16List.fromList(const [0, 1, 2]),
          componentType: 5123,
          type: 'SCALAR',
          count: 3,
        );
        final animT = bin.addAccessor(
          Float32List.fromList(const [0.0, 1.0]),
          componentType: 5126,
          type: 'SCALAR',
          count: 2,
        );
        final animV = bin.addAccessor(
          Float32List.fromList(const [0, 0, 0, 3, 0, 0]),
          componentType: 5126,
          type: 'VEC3',
          count: 2,
        );

        final glbBytes = packGlbBytes({
          'asset': {'version': '2.0'},
          'scenes': [
            {
              'nodes': [0],
            },
          ],
          'buffers': [
            {'byteLength': bin.toBytes().length},
          ],
          'bufferViews': bin.bufferViews,
          'accessors': bin.accessors,
          'images': [
            {'bufferView': imgBv, 'mimeType': 'image/png'},
          ],
          'textures': [
            {'source': 0},
          ],
          'materials': [
            {
              'pbrMetallicRoughness': {
                'baseColorTexture': {'index': 0},
              },
              'extensions': {
                'KHR_materials_emissive_strength': {'emissiveStrength': 2.0},
              },
            },
          ],
          'meshes': [
            {
              'primitives': [
                {
                  'attributes': {'POSITION': posAcc},
                  'indices': idxAcc,
                  'material': 0,
                },
              ],
            },
          ],
          'nodes': [
            {'name': 'AsyncTri', 'mesh': 0},
          ],
          'animations': [
            {
              'name': 'Slide',
              'samplers': [
                {'input': animT, 'output': animV},
              ],
              'channels': [
                {
                  'sampler': 0,
                  'target': {'node': 0, 'path': 'translation'},
                },
              ],
            },
          ],
        }, bin.toBytes());

        final scope = AssetScope3D();
        final glbModel = await AsyncModelLoader3D.parseGlbBytesAsync(
          glbBytes,
          scope: scope,
        );
        expect(glbModel.animationNames, contains('Slide'));
        expect(scope.refCountOf(glbModel), 1);

        final glbSurf = glbModel.nodes[0]!.mesh!.surfaces.single;
        final glbMat = glbSurf.material as SpatialMaterial;
        expect(glbMat.emissiveStrength, closeTo(2.0, 1e-5));

        // Force GPU buffer & texture creation on FakeGpuBackend.
        glbSurf.resource;
        glbMat.albedoTexture.resource;
        expect(glbSurf.hasResource, isTrue);
        expect(glbMat.albedoTexture.hasResource, isTrue);

        // Retain a second time: first release decrements 2 -> 1 without
        // disposing; second release decrements 1 -> 0 and disposes!
        scope.retain(glbModel);
        expect(scope.refCountOf(glbModel), 2);
        expect(scope.release(glbModel), isFalse);
        expect(glbSurf.hasResource, isTrue);

        expect(scope.release(glbModel), isTrue);
        expect(glbSurf.hasResource, isFalse);
        expect(glbMat.albedoTexture.hasResource, isFalse);

        // Parse quad OBJ + MTL in background isolate & build isolate BVHs.
        const objSrc = '''
# Quad floor in XZ
mtllib floor.mtl
usemtl BrickMat
v -1 0 -1
v  1 0 -1
v  1 0  1
v -1 0  1
vt 0 0
vt 1 0
vt 1 1
vt 0 1
f 1/1 2/2 3/3 4/4
''';
        const mtlSrc = '''
newmtl BrickMat
Kd 0.25 0.75 0.5
''';
        final objModel = await AsyncModelLoader3D.parseObjStringInIsolate(
          objSrc,
          mtlSources: const {'floor.mtl': mtlSrc},
          buildBvhs: false,
          scope: scope,
        );
        final objSurf = objModel.nodes[0]!.mesh!.surfaces.single;
        // 1 quad -> 2 triangles (6 indices, 4 deduplicated vertices).
        expect(objSurf.vertexCount, 4);
        expect(objSurf.indexCount, 6);

        final bvhList = await AsyncModelLoader3D.buildSurfaceBvhsInIsolate(
          objModel,
        );
        expect(bvhList, hasLength(1));
        expect(bvhList.single.triangleCount, 2);
        expect(bvhList.single.nodeCount, greaterThan(0));

        // Isolate RGBA8888 mipmap generator: 4x4 -> 2x2 -> 1x1 (3 levels).
        final mips = await AsyncModelLoader3D.generateMipmapsInIsolate(
          Uint8List(4 * 4 * 4)..fillRange(0, 64, 200),
          width: 4,
          height: 4,
        );
        expect(mips, hasLength(3));
        expect(mips.last.length, 4);
        expect(mips.last[0], 200);

        objSurf.resource;
        expect(objSurf.hasResource, isTrue);
        scope.disposeAll();
        expect(objSurf.hasResource, isFalse);
        expect(scope.trackedResourceCount, 0);

        device.end();
      },
    );
  });
}
