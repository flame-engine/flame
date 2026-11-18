import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flame_3d/src/graphics/backend/flutter_gpu/shader_bundle_reflection.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../bin/_build_wgslbundle.dart' as wgsl;

const _standardInputs = [
  ('vertexPosition', 3),
  ('vertexTexCoord', 2),
  ('vertexColor', 4),
  ('vertexNormal', 3),
  ('vertexJoints', 4),
  ('vertexWeights', 4),
  ('instanceModel0', 4),
  ('instanceModel1', 4),
  ('instanceModel2', 4),
  ('instanceModel3', 4),
  ('instanceColor', 4),
  ('instanceData', 4),
];

void main() {
  test('reflection gives up on data that is not a shader bundle', () {
    expect(reflectShaderBundleInputs(ByteData(64)), isNull);
    expect(reflectShaderBundleInputs(ByteData(2)), isNull);
  });

  for (final name in ['spatial_material', 'unlit_material']) {
    group(name, () {
      test('shader bundle reflects the vertex inputs in order', () {
        final bytes = File('assets/shaders/$name.shaderbundle')
            .readAsBytesSync();
        final inputs = reflectShaderBundleInputs(ByteData.sublistView(bytes))!;

        expect(
          [
            for (final input in inputs['TextureVertex']!)
              (input.name, input.components),
          ],
          _standardInputs,
        );
        expect(
          [for (final input in inputs['TextureVertex']!) input.location],
          [for (var i = 0; i < _standardInputs.length; i++) i],
        );
        expect(inputs['TextureFragment'], isEmpty);
      });

      // The WebGPU bundles are generated with `naga`; check that they match
      // the GLSL sources they were built from.
      test('web bundle matches its GLSL sources', () {
        final bundle = jsonDecode(
          File('assets/shaders/$name.wgslbundle').readAsStringSync(),
        ) as Map<String, dynamic>;
        final vertexSource = _resolve(
          File('shaders/$name.vert').readAsStringSync(),
        );
        final fragmentSource = _resolve(
          File('shaders/$name.frag').readAsStringSync(),
        );

        final inputs = (bundle['inputs'] as List).cast<Map<String, dynamic>>();
        expect(inputs, wgsl.reflectInputs(vertexSource));

        final vertex = bundle['vertex'] as String;
        for (final input in inputs) {
          expect(
            vertex,
            contains('@location(${input['location']}) ${input['name']}:'),
          );
        }

        final slots = (bundle['slots'] as Map).cast<String, dynamic>();
        final blocks = {
          ..._uniformBlocks(vertexSource),
          ..._uniformBlocks(fragmentSource),
        };
        expect(slots.keys.toSet(), {
          ...blocks.keys,
          ..._samplers(fragmentSource),
        });
        for (final MapEntry(key: block, value: members) in blocks.entries) {
          final slot = slots[block] as Map<String, dynamic>;
          expect(
            (slot['memberOffsets'] as Map).keys.toSet(),
            members.toSet(),
            reason: 'members of $block',
          );
        }

        // What the vertex stage outputs, the fragment stage reads.
        final outputs = RegExp(
          r'@location\((\d+)\) (\w+): ',
        ).allMatches(vertex.substring(vertex.indexOf('struct VertexOutput')));
        final fragment = bundle['fragment'] as String;
        final main = fragment.substring(fragment.indexOf('@fragment'));
        for (final output in outputs.take(_varyings(vertexSource))) {
          expect(main, contains('@location(${output[1]}) ${output[2]}:'));
        }
      });
    });
  }
}

/// Inlines the `#include`s of [source] from the package's `shaders/`.
String _resolve(String source) {
  return source.replaceAllMapped(
    RegExp(r'^#include <([^>]+)>$', multiLine: true),
    (match) => File('shaders/${match[1]}').readAsStringSync(),
  );
}

Map<String, List<String>> _uniformBlocks(String glsl) {
  return {
    for (final match in RegExp(
      r'uniform\s+(\w+)\s*\{([^}]*)\}',
    ).allMatches(glsl))
      match[1]!: [
        for (final member in RegExp(
          r'\w+\s+(\w+)(?:\[\w+\])?\s*;',
        ).allMatches(match[2]!))
          member[1]!,
      ],
  };
}

Iterable<String> _samplers(String glsl) {
  return RegExp(
    r'uniform\s+sampler2D\s+(\w+);',
  ).allMatches(glsl).map((m) => m[1]!);
}

int _varyings(String vertexGlsl) {
  return RegExp(
    r'^out\s+\w+\s+\w+;',
    multiLine: true,
  ).allMatches(vertexGlsl).length;
}
