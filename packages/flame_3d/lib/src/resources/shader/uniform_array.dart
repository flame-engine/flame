import 'dart:collection';
import 'dart:typed_data';

import 'package:flame_3d/graphics.dart';
import 'package:flame_3d/resources.dart';

typedef UniformArrayKey = ({int index, String field});

/// {@template uniform_value}
/// Instance of a uniform array. Represented by a [ByteBuffer].
/// {@endtemplate}
class UniformArray extends UniformInstance<UniformArrayKey, ByteBuffer> {
  /// {@macro uniform_value}
  UniformArray(super.slot);

  final List<Map<int, ({int hash, List<double> data})>> _storage = [];

  @override
  ByteBuffer createResource() {
    final data = <double>[];
    for (final element in _storage) {
      var previousIndex = -1;
      for (final entry in element.entries) {
        if (previousIndex + 1 != entry.key) {
          final field = slot.fields.indexed.firstWhere(
            (e) => e.$1 == previousIndex + 1,
          );
          throw StateError(
            'Uniform ${slot.name}.${field.$2} was not set',
          );
        }
        previousIndex = entry.key;
        data.addAll(entry.value.data);
      }
    }
    return Float32List.fromList(data).buffer;
  }

  Map<int, ({int hash, List<double> data})> _get(int index) {
    while (index >= _storage.length) {
      _storage.add(HashMap());
    }
    return _storage[index];
  }

  List<double>? get(int index, String key) {
    return _get(index)[slot.indexOf(key)]?.data;
  }

  @override
  void set(UniformArrayKey key, ByteBuffer buffer) {
    final storage = _get(key.index);
    final index = slot.indexOf(key.field);

    // Ensure that we are only setting new data if the hash has changed.
    final data = buffer.asFloat32List();
    final hash = Object.hashAll(data);
    if (storage[index]?.hash == hash) {
      return;
    }

    // Store the storage at the given slot index.
    storage[index] = (data: data, hash: hash);

    // Clear the cache.
    recreateResource = true;
  }

  @override
  UniformArrayKey makeKey(int? index, String? field) {
    if (index == null) {
      throw StateError('index is required for ${slot.name}');
    }
    if (field == null) {
      throw StateError('field is required for ${slot.name}');
    }

    return (index: index, field: field);
  }

  @override
  void bind(GraphicsDevice device) {
    device.bindUniform(slot.resource!, resource!);
  }
}
