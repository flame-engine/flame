import 'package:flame_3d/graphics.dart';
import 'package:flame_3d/resources.dart';
import 'package:flutter_test/flutter_test.dart';

import '../_fakes/fake_gpu_backend.dart';

GpuShaderInput _input(String name, int location, int components) {
  return GpuShaderInput(name: name, location: location, components: components);
}

void main() {
  group('VertexLayout', () {
    test('packs attributes without padding', () {
      final layout = VertexLayout(const [
        VertexAttribute('vertexPosition', 3),
        VertexAttribute('vertexColor', 4),
        VertexAttribute('vertexShade', 1),
      ]);

      expect(layout.strideInFloats, 8);
      expect(layout.strideInBytes, 32);
      expect(layout.offsetOf('vertexPosition'), 0);
      expect(layout.offsetOf('vertexColor'), 3);
      expect(layout.offsetOf('vertexShade'), 7);
      expect(layout.offsetOf('missing'), isNull);
    });

    test('has a standard layout of 20 floats', () {
      expect(VertexLayout.standard.strideInFloats, 20);
      expect(VertexLayout.standard.offsetOf('vertexNormal'), 9);
    });

    test('compares by value', () {
      VertexLayout create() => VertexLayout(const [
        VertexAttribute('vertexPosition', 3),
        VertexAttribute('vertexColor', 4),
      ]);

      expect(create(), create());
      expect(create().hashCode, create().hashCode);
      expect(
        create(),
        isNot(VertexLayout(const [VertexAttribute('vertexPosition', 3)])),
      );
    });

    test('rejects duplicate and reserved attribute names', () {
      expect(
        () => VertexLayout(const [
          VertexAttribute('vertexPosition', 3),
          VertexAttribute('vertexPosition', 3),
        ]),
        throwsArgumentError,
      );
      expect(
        () => VertexLayout(const [VertexAttribute('instanceColor', 4)]),
        throwsArgumentError,
      );
    });
  });

  group('pipelines', () {
    GpuVertexLayout layoutFor(
      List<GpuShaderInput>? inputs,
      VertexLayout layout,
    ) {
      final backend = FakeGpuBackend(inputs: inputs);
      final material = UnlitMaterial();
      GraphicsDevice(
        backend: backend,
      ).pipelineFor(material.vertexShader, material.fragmentShader, layout);
      return backend.pipelines.single.vertexLayout!;
    }

    test('feed only the inputs the vertex shader declares', () {
      final layout = layoutFor([
        _input('vertexPosition', 0, 3),
        _input('vertexNormal', 1, 3),
        _input('instanceModel0', 2, 4),
        _input('instanceModel1', 3, 4),
        _input('instanceModel2', 4, 4),
        _input('instanceModel3', 5, 4),
        _input('instanceColor', 6, 4),
        _input('instanceData', 7, 4),
      ], VertexLayout.standard);

      final [vertices, instances] = layout.buffers;
      expect(vertices.strideInBytes, 80);
      expect(vertices.perInstance, isFalse);
      expect(
        [
          for (final a in vertices.attributes)
            (a.name, a.location, a.components, a.offsetInBytes),
        ],
        [('vertexPosition', 0, 3, 0), ('vertexNormal', 1, 3, 36)],
      );
      expect(instances.strideInBytes, 96);
      expect(instances.perInstance, isTrue);
      expect(
        [for (final a in instances.attributes) (a.name, a.offsetInBytes)],
        [
          ('instanceModel0', 0),
          ('instanceModel1', 16),
          ('instanceModel2', 32),
          ('instanceModel3', 48),
          ('instanceColor', 64),
          ('instanceData', 80),
        ],
      );
    });

    test('read a custom layout at its own stride', () {
      final layout = layoutFor(
        [_input('vertexPosition', 0, 3), _input('vertexShade', 1, 1)],
        VertexLayout(const [
          VertexAttribute('vertexShade', 1),
          VertexAttribute('vertexPosition', 3),
        ]),
      );

      final vertices = layout.buffers.single;
      expect(vertices.strideInBytes, 16);
      expect(
        [for (final a in vertices.attributes) (a.name, a.offsetInBytes)],
        [('vertexPosition', 4), ('vertexShade', 0)],
      );
    });

    test('feed the whole layout when inputs cannot be reflected', () {
      final layout = layoutFor(null, VertexLayout.standard);

      expect(layout.buffers[0].attributes, hasLength(6));
      expect(layout.buffers[1].attributes, hasLength(6));
    });

    test('know whether the shader reads its model from instances', () {
      DevicePipeline pipeline(List<GpuShaderInput> inputs) {
        final material = UnlitMaterial();
        return GraphicsDevice(
          backend: FakeGpuBackend(inputs: inputs),
        ).pipelineFor(
          material.vertexShader,
          material.fragmentShader,
          VertexLayout.standard,
        );
      }

      final instanced = pipeline([
        _input('vertexPosition', 0, 3),
        for (var i = 0; i < 4; i++) _input('instanceModel$i', 1 + i, 4),
      ]);
      final colored = pipeline([
        _input('vertexPosition', 0, 3),
        _input('instanceColor', 1, 4),
      ]);
      final plain = pipeline([_input('vertexPosition', 0, 3)]);

      expect((instanced.instanced, instanced.usesInstanceData), (true, true));
      expect((colored.instanced, colored.usesInstanceData), (false, true));
      expect((plain.instanced, plain.usesInstanceData), (false, false));
    });

    test('reject inputs the surface does not provide', () {
      expect(
        () => layoutFor(
          [_input('vertexPosition', 0, 3), _input('vertexTangent', 1, 4)],
          VertexLayout.standard,
        ),
        throwsA(
          isA<StateError>().having(
            (e) => e.message,
            'message',
            contains('vertexTangent'),
          ),
        ),
      );
    });

    test('reject a partial instance model matrix', () {
      expect(
        () => layoutFor([
          _input('vertexPosition', 0, 3),
          _input('instanceModel0', 1, 4),
        ], VertexLayout.standard),
        throwsStateError,
      );
    });
  });
}
