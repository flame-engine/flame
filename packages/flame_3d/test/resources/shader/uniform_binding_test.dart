import 'package:flame_3d/core.dart';
import 'package:flame_3d/resources.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('uniform bindings', () {
    test('UniformSlot.value creates a UniformValue instance', () {
      final slot = UniformSlot.value('VertexInfo');
      final instance = slot.create();
      expect(instance, isA<UniformValue>());
    });

    test('UniformSlot.sampler creates a UniformSampler instance', () {
      final slot = UniformSlot.sampler('albedoTexture');
      final instance = slot.create();
      expect(instance, isA<UniformSampler>());
    });

    test('Shader can set values before compilation', () {
      final slot = UniformSlot.value('Vertex');
      final shader = Shader(
        asset: 'none',
        name: '-test-',
        slots: [slot],
      );

      // Setting values should not throw even without a compiled shader
      shader.setVector3('Vertex.position', Vector3(1, 2, 3));

      expect(shader.instances, contains('Vertex'));
    });

    test('Shader parses keys correctly', () {
      final shader = Shader(
        asset: 'none',
        name: '-test-',
        slots: [],
      );

      // Simple struct field
      expect(shader.parseKey('Foo.bar'), ['Foo', null, 'bar']);

      // Direct name (sampler)
      expect(shader.parseKey('albedoTexture'), ['albedoTexture', null, null]);
    });
  });
}
