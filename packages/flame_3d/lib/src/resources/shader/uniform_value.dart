import 'dart:collection';
import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:flame_3d/graphics.dart';
import 'package:flame_3d/resources.dart';

/// {@template uniform_value}
/// Instance of a uniform value. Represented by a [ByteBuffer].
///
/// The `[]` operator can be used to set the raw data of a field. If the data is
/// different from the last set it will recalculated the [resource].
/// {@endtemplate}
class UniformValue extends UniformInstance<String, ByteBuffer> {
  /// {@macro uniform_value}
  UniformValue(super.slot);

  final Map<int, ({int hash, Float32List data})> _storage = HashMap();

  @override
  ByteBuffer createResource() {
    var previousIndex = -1;
    final entries = _storage.entries.sortedBy((c) => c.key);

    final packed = <double>[];
    var offsetBytes = 0; // current write cursor in bytes

    for (final e in entries) {
      if (previousIndex + 1 != e.key) {
        final field = slot.fields.indexed.firstWhere(
          (e) => e.$1 == previousIndex + 1,
        );
        throw StateError('Uniform ${slot.name}.${field.$2} was not set');
      }
      previousIndex = e.key;

      final values = e.value.data; // original component values
      final componentCount = values.length;

      final type = _UniformValueType.fromComponentCount(componentCount);

      // align current offset
      final aligned = type.align(offsetBytes);
      if (aligned != offsetBytes) {
        final padFloats = (aligned - offsetBytes) ~/ 4;
        for (var i = 0; i < padFloats; i++) {
          packed.add(0.0);
        }
        offsetBytes = aligned;
      }

      packed.addAll(values);
      // add padding if needed
      final paddingNeeded = type.paddedComponentCount - componentCount;
      for (var i = 0; i < paddingNeeded; i++) {
        packed.add(0.0);
      }

      offsetBytes += type.sizeBytes;
    }

    return Float32List.fromList(packed).buffer;
  }

  Float32List? operator [](String key) => _storage[slot.indexOf(key)]?.data;

  void operator []=(String key, Float32List data) {
    final index = slot.indexOf(key);

    // Ensure that we are only setting new data if the hash has changed.
    final hash = Object.hashAll(data);
    if (_storage[index]?.hash == hash) {
      return;
    }

    // Store the storage at the given slot index.
    _storage[index] = (data: data, hash: hash);

    // Clear the cache.
    recreateResource = true;
  }

  @override
  String makeKey(int? index, String? field) {
    if (index != null) {
      throw StateError('index is not supported for ${slot.name}');
    }
    if (field == null) {
      throw StateError('field is required for ${slot.name}');
    }

    return field;
  }

  @override
  void bind(GraphicsDevice device) {
    device.bindUniform(slot.resource!, resource!);
  }

  @override
  void set(String key, ByteBuffer value) {
    if (!slot.fields.contains(key)) {
      throw StateError('Field "$key" is unmapped for "${slot.name}"');
    }
    this[key] = value.asFloat32List();
  }
}

/// According to std140 packing, we might need to add additional padding
/// bytes depending on the data type of each field.
/// We infer the data type by the component count of the provided field.
enum _UniformValueType {
  float(
    componentCount: 1,
    baseAlignmentBytes: 4,
    sizeBytes: 4,
    paddedComponentCount: 1,
  ),
  vec2(
    componentCount: 2,
    baseAlignmentBytes: 8,
    sizeBytes: 8,
    paddedComponentCount: 2,
  ),
  vec3(
    componentCount: 3,
    baseAlignmentBytes: 16,
    sizeBytes: 16,
    paddedComponentCount: 4, // padded to 4 according to std140
  ),
  vec4(
    componentCount: 4,
    baseAlignmentBytes: 16,
    sizeBytes: 16,
    paddedComponentCount: 4,
  ),
  mat4(
    componentCount: 16,
    baseAlignmentBytes: 16,
    sizeBytes: 64,
    paddedComponentCount: 16,
  );

  const _UniformValueType({
    required this.componentCount,
    required this.baseAlignmentBytes,
    required this.sizeBytes,
    required this.paddedComponentCount,
  });

  final int componentCount;
  final int baseAlignmentBytes;
  final int sizeBytes;
  final int paddedComponentCount;

  int align(int offset) {
    return (offset + baseAlignmentBytes - 1) & ~(baseAlignmentBytes - 1);
  }

  static _UniformValueType fromComponentCount(int count) {
    return _UniformValueType.values.firstWhere(
      (e) => e.componentCount == count,
      orElse: () => throw StateError(
        'Unsupported uniform field component count $count',
      ),
    );
  }
}
