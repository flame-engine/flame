import 'dart:typed_data';

import 'package:flame_3d/core.dart';
import 'package:flame_3d/resources.dart';
import 'package:flame_3d/src/graphics/prefixed_uniform_block.dart';
import 'package:flutter_test/flutter_test.dart';

import '../_fakes/fake_gpu_backend.dart';

void main() {
  group('PrefixedUniformBlock', () {
    late FakeUniformSlot slot;
    late UniformBlock parent;

    setUp(() {
      // Members 1024 bytes (256 floats) apart, in the order they are asked
      // for.
      slot = FakeUniformSlot('Parent', 8 * 1024)
        ..missing.addAll(['Lights_ranges', 'Lights_unknown']);
      parent = UniformBlock(slot);
    });

    test('writes the prefixed members of its parent', () {
      final view = PrefixedUniformBlock(parent, 'Lights_');
      final numLights = parent.memberOffset('Lights_numLights')!;
      final positions = parent.memberOffset('Lights_positions')!;

      view
        ..setFloat('numLights', 2)
        ..setVector3('positions', Vector3(1, 2, 3), index: 1);

      expect(identical(view.data, parent.data), isTrue);
      expect(view.memberOffset('numLights'), numLights);
      expect(parent.data[numLights], 2);
      // The second element, 4 floats (std140) after the first.
      expect(parent.data.sublist(positions + 4, positions + 7), [1, 2, 3]);
    });

    test('ignores the members its parent does not have', () {
      final view = PrefixedUniformBlock(parent, 'Lights_');
      final before = Float32List.fromList(parent.data);

      view
        ..setFloat('ranges', 4)
        ..setFloat('unknown', 5);

      expect(view.memberOffset('ranges'), isNull);
      expect(parent.data, before);
    });

    test('marks its parent as changed', () {
      final view = PrefixedUniformBlock(parent, 'Camera_');
      parent.markUploaded(0, FakeBuffer(16), 0);
      expect(parent.isDirty, isFalse);

      view.setVector3('position', Vector3(0, 0, 4));

      expect(parent.isDirty, isTrue);
      final position = parent.memberOffset('Camera_position')!;
      expect(parent.data.sublist(position, position + 3), [0, 0, 4]);
    });
  });
}
