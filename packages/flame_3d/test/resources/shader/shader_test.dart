import 'package:flame_3d/resources.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Shader', () {
    test('can create vertex shader with uniforms', () {
      final shader = VertexShader.fromAsset(
        'none',
        uniforms: ['VertexInfo', 'JointMatrices'],
      );

      expect(shader.entryPoint, 'TextureVertex');
      expect(shader.uniforms, ['VertexInfo', 'JointMatrices']);
      expect(shader.samplers, isEmpty);
    });

    test('can create fragment shader with uniforms and samplers', () {
      final shader = FragmentShader.fromAsset(
        'none',
        uniforms: ['Material', 'Camera'],
        samplers: ['albedoTexture'],
      );

      expect(shader.entryPoint, 'TextureFragment');
      expect(shader.uniforms, ['Material', 'Camera']);
      expect(shader.samplers, ['albedoTexture']);
    });

    test('parses keys correctly', () {
      expect(Shader.parseKey('Foo.bar'), ('Foo', 'bar', null));

      expect(Shader.parseKey('Foo.bar[2]'), ('Foo', 'bar', 2));

      expect(Shader.parseKey('Foo'), ('Foo', null, null));
    });
  });
}
