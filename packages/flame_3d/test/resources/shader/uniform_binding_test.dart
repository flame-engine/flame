import 'dart:typed_data';

import 'package:flame_3d/core.dart';
import 'package:flame_3d/resources.dart';
import 'package:flame_3d/src/resources/shader.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('uniform bindings', () {
    test('can bind a vec3 a slot', () {
      final slot = UniformSlot.value('Vertex', {'position'});
      final shader = createShader([slot]);

      shader.setVector3('Vertex.position', Vector3(7, 8, 9));

      final bytes = shader.instances['Vertex']!.resource as ByteBuffer;
      final result = Vector3.fromBuffer(bytes, 0);
      expect(result, Vector3(7, 8, 9));
    });

    test('can bind multiple vector slots', () {
      final slot = UniformSlot.value('AmbientLight', {'color', 'position'});
      final shader = createShader([slot]);

      shader.setVector3('AmbientLight.position', Vector3(7, 8, 9));
      shader.setVector4('AmbientLight.color', Vector4(4, 3, 2, 1));

      final bytes = shader.instances['AmbientLight']!.resource as ByteBuffer;

      final color = Vector4.fromBuffer(bytes, 0);
      expect(color, Vector4(4, 3, 2, 1));

      final position = Vector3.fromBuffer(bytes, color.storage.lengthInBytes);
      expect(position, Vector3(7, 8, 9));
    });

    test('can bind a mat4 a slot', () {
      final slot = UniformSlot.value('Vertex', {'camera'});
      final shader = createShader([slot]);

      shader.setMatrix4('Vertex.camera', Matrix4.identity());

      final bytes = shader.instances['Vertex']!.resource as ByteBuffer;
      final result = Matrix4.fromBuffer(bytes, 0);
      expect(result, Matrix4.identity());
    });

    test('can bind a vec3 to an array slot', () {
      final slot = UniformSlot.array('Light', {'position'});
      final shader = createShader([slot]);

      shader.setVector3('Light[0].position', Vector3(7, 8, 9));

      final bytes = shader.instances['Light']!.resource as ByteBuffer;
      final result = Vector3.fromBuffer(bytes, 0);

      expect(result, Vector3(7, 8, 9));
    });

    test('can bind multiple slots', () {
      final slots = [
        UniformSlot.value('Vertex', {'position'}),
        UniformSlot.value('Material', {'color', 'metallic'}),
        UniformSlot.array('Light', {'position', 'color'}),
      ];
      final shader = createShader(slots);

      shader.setVector3('Vertex.position', Vector3(1, 2, 3));
      shader.setVector4('Material.color', Vector4(4, 3, 2, 1));
      shader.setFloat('Material.metallic', 0.5);
      shader.setVector3('Light[0].position', Vector3(11, 12, 13));
      shader.setVector4('Light[0].color', Vector4(14, 15, 16, 17));
      shader.setVector3('Light[1].position', Vector3(-1, -2, -3));
      shader.setVector4('Light[1].color', Vector4(-11, -12, -13, -14));

      final vertex = shader.instances['Vertex']!.resource as ByteBuffer;
      final vertexResult = Vector3.fromBuffer(vertex, 0);
      expect(vertexResult, Vector3(1, 2, 3));

      final material = shader.instances['Material']!.resource as ByteBuffer;
      final color = Vector4.fromBuffer(material, 0);
      expect(color, Vector4(4, 3, 2, 1));
      final metallic = Float32List.view(material, color.storage.lengthInBytes);
      expect(metallic[0], 0.5);

      final light = shader.instances['Light']!.resource as ByteBuffer;

      var cursor = 0;

      final light0Position = Vector3.fromBuffer(light, cursor);
      expect(light0Position, Vector3(11, 12, 13));
      cursor += light0Position.storage.lengthInBytes;

      final light0Color = Vector4.fromBuffer(light, cursor);
      expect(light0Color, Vector4(14, 15, 16, 17));
      cursor += light0Color.storage.lengthInBytes;

      final light1Position = Vector3.fromBuffer(light, cursor);
      expect(light1Position, Vector3(-1, -2, -3));
      cursor += light1Position.storage.lengthInBytes;

      final light1Color = Vector4.fromBuffer(light, cursor);
      expect(light1Color, Vector4(-11, -12, -13, -14));
    });
  });
}

Shader createShader(List<UniformSlot> slots) {
  return Shader(
    name: '-test-',
    slots: slots,
  );
}
