import 'dart:collection';
import 'dart:typed_data';

import 'package:flame_3d/graphics.dart';
import 'package:flame_3d/resources.dart';

/// {@template uniform_value}
/// Instance of a uniform value. Represented by a [ByteBuffer].
///
/// The `[]` operator can be used to set the raw data of a field. If the data is
/// different from the last set it will recalculated the [resource].
///
/// Both scalar fields (`'fieldName'`) and array elements (`'fieldName[index]'`)
/// are supported. Array element offsets are computed using std140 stride rules.
/// {@endtemplate}
class UniformValue extends UniformInstance<String, ByteBuffer> {
  /// {@macro uniform_value}
  UniformValue(super.slot);

  final Map<String, ({int hash, Float32List data})> _storage = HashMap();

  @override
  ByteBuffer createResource() {
    final gpuSlot = slot.resource!;
    final sizeInBytes = gpuSlot.sizeInBytes;
    if (sizeInBytes == null) {
      throw StateError('Uniform struct "${slot.name}" not found in shader');
    }

    final buffer = ByteData(sizeInBytes);
    for (final MapEntry(:key, value: entry) in _storage.entries) {
      final (field, index) = _parseMemberKey(key);

      final memberOffset = gpuSlot.getMemberOffsetInBytes(field);
      if (memberOffset == null) {
        throw StateError('Field "$field" not found in uniform "${slot.name}"');
      }

      final stride = _std140ArrayStride(entry.data.lengthInBytes);
      final offset = switch (index) {
        final i? => memberOffset + i * stride,
        _ => memberOffset,
      };

      final bytes = entry.data.buffer.asUint8List(
        entry.data.offsetInBytes,
        entry.data.lengthInBytes,
      );
      for (var i = 0; i < bytes.length; i++) {
        buffer.setUint8(offset + i, bytes[i]);
      }
    }

    return buffer.buffer;
  }

  Float32List? operator [](String key) => _storage[key]?.data;

  void operator []=(String key, Float32List data) {
    final (field, _) = _parseMemberKey(key);
    assert(
      !slot.isCompiled || slot.resource!.getMemberOffsetInBytes(field) != null,
      'Field "$field" not found in uniform "${slot.name}"',
    );

    final hash = Object.hashAll(data);
    if (_storage[key]?.hash == hash) {
      return;
    }

    _storage[key] = (data: data, hash: hash);
    recreateResource = true;
  }

  @override
  String makeKey(int? index, String? field) {
    if (field == null) {
      throw StateError('field is required for ${slot.name}');
    }
    if (index != null) {
      return '$field[$index]';
    }
    return field;
  }

  @override
  void bind(GraphicsDevice device) {
    device.bindUniform(slot.resource!, resource!);
  }

  @override
  void set(String key, ByteBuffer value) {
    this[key] = value.asFloat32List();
  }

  /// Parse a storage key into member name and the array index (if any):
  /// - `"positions[0]"` becomes `("positions", 0)`
  /// - `"numLights"` becomes `("numLights", null)`
  static (String name, int? index) _parseMemberKey(String key) {
    final bracket = key.indexOf('[');
    if (bracket == -1) {
      return (key, null);
    }

    final name = key.substring(0, bracket);
    final index = int.parse(key.substring(bracket + 1, key.length - 1));
    return (name, index);
  }

  /// Std140 array element stride: round up to 16-byte boundary.
  static int _std140ArrayStride(int elementBytes) {
    return (elementBytes + 15) & ~15;
  }
}
