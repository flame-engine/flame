import 'dart:typed_data';
import 'dart:ui';

import 'package:flame_3d/core.dart';
import 'package:flame_3d/graphics.dart';
import 'package:flame_3d/resources.dart';
import 'package:flame_3d/src/resources/texture/mipmaps.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../_fakes/fake_gpu_backend.dart';

ByteData _bytes(List<int> values) {
  return ByteData.sublistView(Uint8List.fromList(values));
}

List<int> _list(ByteData data) {
  return data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
}

void main() {
  group('Mipmaps', () {
    test('halves each level down to one pixel', () {
      expect(Mipmaps.levelSize(8, 2, 0), (8, 2));
      expect(Mipmaps.levelSize(8, 2, 1), (4, 1));
      expect(Mipmaps.levelSize(8, 2, 2), (2, 1));
      expect(Mipmaps.levelSize(5, 5, 1), (2, 2));
      expect(Mipmaps.levelSize(5, 5, 3), (1, 1));
    });

    test('averages 2x2 pixels', () {
      // 2x2 pixels: red, green / blue, white.
      final level = Mipmaps.downsample(
        _bytes([
          255, 0, 0, 255, 0, 255, 0, 255, //
          0, 0, 255, 255, 255, 255, 255, 255, //
        ]),
        2,
        2,
        PixelFormat.rgba8888,
      );

      // (255 + 255 + 2) >> 2 = 128.
      expect(_list(level), [128, 128, 128, 255]);
    });

    test('covers the first 2x2 pixels of odd sizes, rounding down', () {
      // 3x1 pixels: 0, 100, 200 (grey, opaque).
      final level = Mipmaps.downsample(
        _bytes([
          0, 0, 0, 255, 100, 100, 100, 255, 200, 200, 200, 255, //
        ]),
        3,
        1,
        PixelFormat.rgba8888,
      );

      // 3x1 becomes 1x1, covering the first two pixels (a single row is
      // averaged with itself).
      expect(_list(level), [50, 50, 50, 255]);
    });

    test('averages float pixels', () {
      final source = Float32List.fromList([
        1, 0, 0, 1, 0, 1, 0, 1, //
        0, 0, 1, 1, 1, 1, 1, 0, //
      ]);
      final level = Mipmaps.downsample(
        ByteData.sublistView(source),
        2,
        2,
        PixelFormat.rgbaFloat32,
      );

      expect(level.buffer.asFloat32List(), [0.5, 0.5, 0.5, 0.75]);
    });
  });

  group('TextureSampler', () {
    test('every combination of options has its own key', () {
      final keys = <int>{};
      for (final min in TextureFilter.values) {
        for (final mag in TextureFilter.values) {
          for (final mip in TextureFilter.values) {
            for (final u in TextureWrap.values) {
              for (final v in TextureWrap.values) {
                final key = TextureSampler(
                  minFilter: min,
                  magFilter: mag,
                  mipFilter: mip,
                  wrapU: u,
                  wrapV: v,
                ).key;
                expect(key, inInclusiveRange(0, TextureSampler.keyCount - 1));
                keys.add(key);
              }
            }
          }
        }
      }
      expect(keys, hasLength(2 * 2 * 2 * 3 * 3));
    });

    test('compares by value', () {
      const sampler = TextureSampler.all(
        filter: TextureFilter.linear,
        wrap: TextureWrap.repeat,
      );

      expect(
        sampler,
        const TextureSampler(
          minFilter: TextureFilter.linear,
          magFilter: TextureFilter.linear,
          mipFilter: TextureFilter.linear,
          wrapU: TextureWrap.repeat,
          wrapV: TextureWrap.repeat,
        ),
      );
      expect(
        TextureSampler.linear.copyWith(wrapU: TextureWrap.mirror),
        isNot(TextureSampler.linear),
      );
      expect(TextureSampler.nearest.hashCode, TextureSampler.nearest.key);
    });
  });

  group('Texture', () {
    late FakeGpuBackend backend;

    setUp(() => backend = FakeGpuBackend());

    test('uploads only its pixels without mipmaps', () {
      final texture = Texture(
        _bytes(List.filled(16 * 4, 7)),
        width: 4,
        height: 4,
      )..resource;

      final created = backend.textures.single;
      expect(created.mipLevelCount, 1);
      expect(created.writes.map((w) => w.$1), [0]);
      expect(texture.mipLevelCount, 1);
    });

    test('uploads every mip level it builds', () {
      final pixels = [
        for (var i = 0; i < 16; i++) ...[i * 16, 255 - i * 16, 0, 255],
      ];
      final texture = Texture(
        _bytes(pixels),
        width: 4,
        height: 4,
        mipmaps: true,
      )..resource;

      final created = backend.textures.single;
      // 4x4, 2x2 and 1x1.
      expect(created.mipLevelCount, 3);
      expect(texture.mipLevelCount, 3);
      expect(created.writes.map((w) => w.$1), [0, 1, 2]);
      expect(created.writes[0].$2, pixels);
      final level1 = Mipmaps.downsample(
        _bytes(pixels),
        4,
        4,
        PixelFormat.rgba8888,
      );
      expect(created.writes[1].$2, _list(level1));
      expect(
        created.writes[2].$2,
        _list(Mipmaps.downsample(level1, 2, 2, PixelFormat.rgba8888)),
      );
    });

    test('uploads one level where the backend cannot sample more', () {
      backend.maxMipLevels = 1;
      Texture(
        _bytes(List.filled(16 * 4, 7)),
        width: 4,
        height: 4,
        mipmaps: true,
      ).resource;

      expect(backend.textures.single.writes.map((w) => w.$1), [0]);
    });

    test('wraps a GPU texture instead of uploading', () {
      final gpuTexture = FakeTexture(2, 2, 1);
      final texture = Texture(
        null,
        width: 2,
        height: 2,
        gpuTexture: gpuTexture,
        mipmaps: true,
      );

      expect(identical(texture.resource, gpuTexture), isTrue);
      expect(backend.textures, isEmpty);
      expect(gpuTexture.writes, isEmpty);
    });

    test('is bound with its sampler', () {
      final device = GraphicsDevice(backend: backend);
      final context = RenderContext3D(device);
      final texture = ColorTexture(const Color(0xFF00FF00))
        ..sampler = const TextureSampler.all(wrap: TextureWrap.repeat);
      final material = UnlitMaterial(albedoTexture: texture);
      final surface = Surface(
        vertices: [
          Vertex(position: Vector3.zero(), texCoord: Vector2.zero()),
          Vertex(position: Vector3(1, 0, 0), texCoord: Vector2.zero()),
          Vertex(position: Vector3(0, 1, 0), texCoord: Vector2.zero()),
        ],
        indices: [0, 1, 2],
        material: material,
      );

      void draw() {
        device.begin();
        context.setCamera(Matrix4.identity(), Matrix4.identity());
        device.beginPass(const Size(8, 8));
        context
          ..drawSurface(surface)
          ..flush();
        device
          ..endPass()
          ..end();
      }

      draw();
      expect(
        backend.textureBindings['albedoTexture']!.$2,
        const TextureSampler.all(wrap: TextureWrap.repeat),
      );

      texture.sampler = TextureSampler.linear;
      draw();
      expect(
        backend.textureBindings['albedoTexture']!.$2,
        TextureSampler.linear,
      );
    });
  });
}
