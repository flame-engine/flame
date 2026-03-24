import 'package:flame_3d/resources.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Shader', () {
    test('can create vertex shader with slots', () {
      final shader = VertexShader.fromAsset(
        'none',
        slots: ['VertexInfo', 'JointMatrices'],
      );

      expect(shader.entryPoint, 'TextureVertex');
      expect(shader.slots, ['VertexInfo', 'JointMatrices']);
    });

    test('can create fragment shader with slots', () {
      final shader = FragmentShader.fromAsset(
        'none',
        slots: ['Material', 'Camera', 'albedoTexture'],
      );

      expect(shader.entryPoint, 'TextureFragment');
      expect(shader.slots, ['Material', 'Camera', 'albedoTexture']);
    });

    test('parses keys correctly', () {
      expect(Shader.parseKey('Foo.bar'), ('Foo', 'bar', null));

      expect(Shader.parseKey('Foo.bar[2]'), ('Foo', 'bar', 2));

      expect(Shader.parseKey('Foo'), ('Foo', null, null));
    });
  });
}
