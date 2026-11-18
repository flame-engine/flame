import 'dart:typed_data';
import 'dart:ui';

import 'package:flame_3d/graphics.dart';
import 'package:flame_3d/resources.dart';
import 'package:flutter_test/flutter_test.dart';

import '../_fakes/fake_gpu_backend.dart';

void main() {
  late FakeGpuBackend backend;
  late GraphicsDevice device;

  setUp(() {
    backend = FakeGpuBackend();
    device = GraphicsDevice(backend: backend);
  });

  UniformBlock block(String name, {int size = 64}) {
    return UniformBlock(FakeUniformSlot(name, size));
  }

  group('render targets', () {
    test('are sized to the nearest whole pixel', () {
      device
        ..begin()
        ..beginPass(const Size(1079.9999938964845, 2339.6))
        ..endPass()
        ..end();

      expect(backend.renderTargets, [(1080, 2340, 1)]);
      expect(device.renderTarget.width, 1080);
    });

    test('are at least one pixel', () {
      device
        ..begin()
        ..beginPass(const Size(0.2, 0))
        ..endPass()
        ..end();

      expect(backend.renderTargets, [(1, 1, 1)]);
    });

    test('are reused across frames and distinct within a frame', () {
      for (var frame = 0; frame < 3; frame++) {
        device.begin();
        for (var pass = 0; pass < 2; pass++) {
          device
            ..beginPass(const Size(32, 32), msaaSampleCount: 4)
            ..endPass();
        }
        device.end();
      }

      expect(backend.renderTargets, [(32, 32, 4), (32, 32, 4)]);
    });

    test('stay pooled for a while when their size is not used', () {
      void frame(double size) {
        device
          ..begin()
          ..beginPass(Size(size, size))
          ..endPass()
          ..end();
      }

      // A size used every other frame keeps its target.
      for (var i = 0; i < 10; i++) {
        frame(i.isEven ? 64 : 128);
      }
      expect(backend.renderTargets, [(64, 64, 1), (128, 128, 1)]);

      // A size unused for longer is released.
      for (var i = 0; i < GraphicsDevice.targetRetainFrames; i++) {
        frame(64);
      }
      frame(128);
      expect(backend.renderTargets, [
        (64, 64, 1),
        (128, 128, 1),
        (128, 128, 1),
      ]);
    });
  });

  group('transient data', () {
    test('is uploaded once per pass', () {
      device
        ..begin()
        ..beginPass(const Size(8, 8));
      for (var i = 0; i < 10; i++) {
        device.bindUniform(
          FakeUniformSlot('Block', 16),
          ByteData(16)..setFloat32(0, i.toDouble(), Endian.little),
        );
      }
      device
        ..bindInstances(
          Float32List(2 * VertexLayout.instanceStrideInFloats),
          2,
        )
        ..endPass()
        ..end();

      final buffer = backend.buffers.single;
      expect(buffer.writes, hasLength(1));
      expect(device.lastFrameStats.uniformUploads, 10);
      expect(device.lastFrameStats.uploadedBytes, 10 * 16 + 2 * 96);
      // Every uniform at its own aligned offset.
      for (var i = 0; i < 10; i++) {
        expect(buffer.contents.buffer.asFloat32List(i * 256, 1)[0], i);
      }
    });

    test('gathers instances in the given order as it uploads them', () {
      const stride = VertexLayout.instanceStrideInFloats;
      // Five instances whose floats are their index times 100 plus the
      // float's index.
      final instances = Float32List.fromList([
        for (var i = 0; i < 5; i++)
          for (var f = 0; f < stride; f++) i * 100.0 + f,
      ]);
      final order = Int32List.fromList([4, 0, 3, 1, 2]);
      final surface = Surface.fromBuffers(
        vertices: Float32List(VertexLayout.standard.strideInFloats * 3),
        indices: Uint16List.fromList([0, 1, 2]),
      );
      device
        ..begin()
        ..beginPass(const Size(8, 8))
        ..bindSurface(surface)
        ..bindInstancesOf(instances, order, 1, 3)
        ..drawSurface(surface, instanceCount: 3)
        ..endPass()
        ..end();

      final (buffer, offset, count) = backend.drawnInstances.single;
      expect(count, 3);
      expect(
        buffer.contents.buffer.asFloat32List(offset, 3 * stride),
        [
          for (final i in [0, 3, 1])
            for (var f = 0; f < stride; f++) i * 100.0 + f,
        ],
      );
      expect(device.lastFrameStats.uploadedBytes, 3 * stride * 4);
    });

    test('is not overwritten before the GPU completed its frame', () {
      void frame() {
        device
          ..begin()
          ..beginPass(const Size(8, 8))
          ..bindUniform(FakeUniformSlot('Block', 16), ByteData(16))
          ..endPass()
          ..end();
      }

      frame();
      frame();
      // The first frame's block is still in use: the second needs another.
      expect(backend.buffers, hasLength(2));

      backend.completePasses();
      frame();
      frame();
      expect(backend.buffers, hasLength(2));
    });

    test('uploads an unchanged uniform block once per frame', () {
      final data = block('Block')..setFloat('value', 1);
      device
        ..begin()
        ..beginPass(const Size(8, 8))
        ..bindUniformBlock(data)
        ..bindUniformBlock(data)
        ..bindUniformBlock(data);
      expect(device.stats.uniformUploads, 1);

      data.setFloat('value', 2);
      device.bindUniformBlock(data);
      expect(device.stats.uniformUploads, 2);
      device
        ..endPass()
        ..end();

      device
        ..begin()
        ..beginPass(const Size(8, 8))
        ..bindUniformBlock(data);
      expect(device.stats.uniformUploads, 1);
      device
        ..endPass()
        ..end();
    });
  });

  group('state', () {
    test('binding the same pipeline again is free', () {
      final material = UnlitMaterial();
      device
        ..begin()
        ..beginPass(const Size(8, 8));
      final pipeline = device.pipelineFor(
        material.vertexShader,
        material.fragmentShader,
        VertexLayout.standard,
      );
      final epoch = device.bindingEpoch;

      expect(device.bindPipeline(pipeline), isTrue);
      expect(device.bindPipeline(pipeline), isFalse);
      expect(device.bindingEpoch, epoch + 1);
      expect(backend.countCommands('bindPipeline'), 1);
      expect(backend.countCommands('clearBindings'), 0);
      device
        ..endPass()
        ..end();
    });

    test('returns the same pipeline for equal layouts', () {
      final material = UnlitMaterial();
      final layout = VertexLayout(const [VertexAttribute('vertexPosition', 3)]);
      final equal = VertexLayout(const [VertexAttribute('vertexPosition', 3)]);

      final first = device.pipelineFor(
        material.vertexShader,
        material.fragmentShader,
        layout,
      );
      expect(
        device.pipelineFor(
          UnlitMaterial().vertexShader,
          UnlitMaterial().fragmentShader,
          equal,
        ),
        same(first),
      );
      expect(
        device.pipelineFor(
          material.vertexShader,
          material.fragmentShader,
          VertexLayout.standard,
        ),
        isNot(same(first)),
      );
    });

    test('changes only the render state that differs', () {
      device
        ..begin()
        ..beginPass(const Size(8, 8))
        ..setRenderState(RenderState.opaque)
        ..setRenderState(const RenderState(cullMode: CullMode.backFace))
        ..setRenderState(
          const RenderState(cullMode: CullMode.backFace, depthWrite: false),
        )
        ..setRenderState(
          const RenderState(cullMode: CullMode.backFace, depthTest: false),
        )
        ..setFrontFace(WindingOrder.clockwise)
        ..setFrontFace(WindingOrder.clockwise)
        ..endPass()
        ..end();

      expect(backend.commands.where((c) => c.startsWith('set')), [
        'setCullMode backFace',
        'setDepthState less false',
        'setDepthState always true',
        'setWindingOrder clockwise',
      ]);
      expect(device.lastFrameStats.stateChanges, 4);
    });

    test('starts a mirrored pass with clockwise front faces', () {
      device
        ..begin()
        ..beginPass(const Size(8, 8), frontFace: WindingOrder.clockwise);

      expect(device.frontFace, WindingOrder.clockwise);
      expect(backend.commands.last, 'setWindingOrder clockwise');
    });

    test('requires a frame for a pass and a pass for bindings', () {
      expect(() => device.beginPass(const Size(8, 8)), throwsStateError);
      device.begin();
      expect(device.endPass, throwsStateError);
      expect(
        () => device.bindUniformBlock(block('Block')),
        throwsStateError,
      );
    });
  });
}
