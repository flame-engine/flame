import 'dart:collection';
import 'dart:typed_data';

import 'package:flame_3d/graphics.dart';
import 'package:flame_3d/resources.dart';
import 'package:ordered_set/comparing.dart';

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
  ByteBuffer? get resource {
    if (super.resource == null) {
      var previousIndex = -1;

      final entries = _storage.entries.toList()
        ..sort(Comparing.on((c) => c.key));
      final data = entries.fold<List<double>>([], (p, e) {
        if (previousIndex + 1 != e.key) {
          final field =
              slot.fields.indexed.firstWhere((e) => e.$1 == previousIndex + 1);
          throw StateError('Uniform ${slot.name}.${field.$2} was not set');
        }
        previousIndex = e.key;
        return p..addAll(e.value.data);
      });

      super.resource = Float32List.fromList(data).buffer;
    }

    return super.resource;
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
    super.resource = null;
  }

  @override
  String makeKey(int? idx, String? field) {
    if (idx != null) {
      throw StateError('idx is not supported for ${slot.name}');
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
