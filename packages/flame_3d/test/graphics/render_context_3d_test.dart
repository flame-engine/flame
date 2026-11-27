import 'dart:typed_data';

import 'package:flame_3d/core.dart';
import 'package:flame_3d/graphics.dart';
import 'package:flame_3d/resources.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RenderContext3D.flush', () {
    late _Device device;
    late RenderContext3D context;
    final log = <String>[];

    setUp(() {
      log.clear();
      device = _Device(log);
      context = RenderContext3D(device)
        ..setCamera(Matrix4.identity(), Matrix4.identity());
    });

    void submit(String name, double z, Material material, {double? scale}) {
      (material as _Material)
        ..name = name
        ..log = log;
      context.submitMesh(
        PlaneMesh(size: Vector2.all(1), material: material),
        Matrix4.translationValues(0, 0, z)..scaleByDouble(scale ?? 1, 1, 1, 1),
      );
    }

    test('draws opaque, then the depth pre-pass, then blended', () {
      submit('alphaFar', 5, _Material(Transparency.alpha));
      submit('opaqueFar', 5, _Material(Transparency.disabled));
      submit('prePass', 3, _Material(Transparency.alphaDepthPrePass));
      submit('alphaNear', 1, _Material(Transparency.alpha));
      submit('scissorNear', 1, _Material(Transparency.alphaScissor));

      context.flush();

      expect(log, [
        'state opaque standard',
        'opaque scissorNear',
        'opaque opaqueFar',
        'state noColor standard',
        'depthPrePass prePass',
        'state alphaBlend depthRead',
        'blend alphaFar',
        'blend prePass',
        'blend alphaNear',
      ]);
      expect(context.drawCount, 5);
    });

    test('renderPriority wins over distance', () {
      submit('near', 1, _Material(Transparency.alpha)..renderPriority = 1);
      submit('far', 5, _Material(Transparency.alpha));

      context.flush();

      expect(log.where((e) => e.startsWith('blend')), [
        'blend far',
        'blend near',
      ]);
    });

    test('a mirrored transform swaps the culled face', () {
      submit(
        'mirrored',
        1,
        _Material(Transparency.disabled)..cullMode = CullMode.backFace,
        scale: -1,
      );

      context.flush();

      expect(device.cullModes, [CullMode.frontFace]);
    });
  });
}

class _Material(Transparency transparency) extends Material {
  this
    : super(
        vertexShader: VertexShader.fromAsset('test', slots: []),
        fragmentShader: FragmentShader.fromAsset('test', slots: []),
        transparency: transparency,
      );

  String name = '';
  List<String> log = [];

  @override
  void apply(covariant RenderContext3D context) {
    log.add('${context.passKind.name} $name');
  }
}

class _Device(final List<String> log) extends GraphicsDevice {
  this : super(backend: _Backend());

  final cullModes = <CullMode>[];

  @override
  void setPassState(BlendState blend, DepthStencilState depthStencil) {
    log.add('state ${blend.name} ${depthStencil.name}');
  }

  @override
  void clearBindings() {}

  @override
  void bindPipeline(GpuPipeline pipeline, CullMode cullMode) {
    cullModes.add(cullMode);
  }

  @override
  void bindGeometry(Surface surface) {}

  @override
  void bindUniform(GpuUniformSlot slot, ByteBuffer buffer) {}

  @override
  void bindTexture(GpuUniformSlot slot, Texture texture) {}
}

final class _Backend() extends GpuBackend {
  @override
  GpuShaderLibrary loadShaderLibrary(String assetName) => _Library();

  @override
  GpuPipeline createPipeline({
    required GpuShader vertexShader,
    required GpuShader fragmentShader,
  }) => _Pipeline();

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnsupportedError('${invocation.memberName}');
}

class _Library() implements GpuShaderLibrary {
  @override
  GpuShader operator [](String entryPoint) => _Shader();
}

class _Shader() implements GpuShader {
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnsupportedError('${invocation.memberName}');
}

class _Pipeline() implements GpuPipeline;
