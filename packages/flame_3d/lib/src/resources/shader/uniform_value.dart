import 'dart:collection';
import 'dart:typed_data';

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

  final Map<String, ({int hash, Float32List data})> _storage = HashMap();

  @override
  ByteBuffer createResource() {
    final gpuSlot = slot.resource!;
    final sizeInBytes = gpuSlot.sizeInBytes;
    if (sizeInBytes == null) {
      throw StateError('Uniform struct "${slot.name}" not found in shader');
    }

    final buffer = ByteData(sizeInBytes);
    for (final MapEntry(key: field, value: entry) in _storage.entries) {
      final offset = gpuSlot.getMemberOffsetInBytes(field);
      if (offset == null) {
        throw StateError('Field "$field" not found in uniform "${slot.name}"');
      }

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
    assert(
      slot.resource == null ||
          slot.resource!.getMemberOffsetInBytes(key) != null,
      'Field "$key" not found in uniform "${slot.name}"',
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
    this[key] = value.asFloat32List();
  }
}
