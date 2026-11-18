import 'dart:io';
import 'dart:typed_data';

import 'package:flame_3d/graphics.dart';
import 'package:flame_3d/resources.dart';
import 'package:flame_3d/src/graphics/backend/flutter_gpu/shader_bundle_reflection.dart';
import 'package:flutter_test/flutter_test.dart';

Map<String, int> _vertexInputs(String bundle) {
  final bytes = File('assets/shaders/$bundle.shaderbundle').readAsBytesSync();
  final inputs = reflectShaderBundleInputs(ByteData.sublistView(bytes))!;
  return {
    for (final input in inputs['TextureVertex']!) input.name: input.components,
  };
}

void main() {
  final instanceInputs = {
    for (final a in VertexLayout.instanceAttributes) a.name: a.components,
  };

  group('StylizedMaterial shader bundles', () {
    test('the main variant reads the stylized layout', () {
      expect(_vertexInputs('stylized_material'), {
        for (final a in StylizedMaterial.vertexLayout.attributes)
          a.name: a.components,
        ...instanceInputs,
      });
    });

    test('the skinned variant reads the skinned layout', () {
      expect(_vertexInputs('stylized_material_skinned'), {
        for (final a in StylizedMaterial.skinnedVertexLayout.attributes)
          a.name: a.components,
        ...instanceInputs,
      });
    });

    test('the standard variant reads only standard attributes', () {
      final standard = {
        for (final a in VertexLayout.standard.attributes) a.name: a.components,
        ...instanceInputs,
      };
      final inputs = _vertexInputs('stylized_material_standard');

      expect(inputs.keys, isNot(contains(StylizedMaterial.masksAttribute)));
      for (final MapEntry(:key, :value) in inputs.entries) {
        expect(standard[key], value, reason: key);
      }
    });

    test('are native only: there is no WebGPU bundle', () {
      for (final name in [
        'stylized_material',
        'stylized_material_skinned',
        'stylized_material_standard',
      ]) {
        expect(File('assets/shaders/$name.wgslbundle').existsSync(), isFalse);
      }
    });
  });
}
