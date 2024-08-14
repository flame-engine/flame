import 'dart:collection';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flame_3d/game.dart';
import 'package:flame_3d/graphics.dart';
import 'package:flame_3d/resources.dart';
import 'package:flutter_gpu/gpu.dart' as gpu;

/// {@template shader}
///
/// {@endtemplate}
class Shader extends Resource<gpu.Shader> {
  /// {@macro shader}
  Shader(
    super.resource, {
    List<UniformSlot> slots = const [],
  })  : _slots = slots,
        _instances = {} {
    for (final slot in slots) {
      slot.resource = resource.getUniformSlot(slot.name);
    }
  }

  final List<UniformSlot> _slots;

  final Map<String, UniformInstance> _instances;

  /// Set a [Texture] at the given [key] on the buffer.
  void setTexture(String key, Texture texture) => _setSampler(key, texture);

  /// Set a [Vector2] at the given [key] on the buffer.
  void setVector2(String key, Vector2 vector) => _setValue(key, vector.storage);

  /// Set a [Vector3] at the given [key] on the buffer.
  void setVector3(String key, Vector3 vector) => _setValue(key, vector.storage);

  /// Set a [Vector4] at the given [key] on the buffer.
  void setVector4(String key, Vector4 vector) => _setValue(key, vector.storage);

  /// Set an [int] (encoded as uint) at the given [key] on the buffer.
  void setUInt(String key, int value) {
    _setValue(key, _encodeUint32(value, Endian.little));
  }

  /// Set a [double] at the given [key] on the buffer.
  void setFloat(String key, double value) {
    _setValue(key, [value]);
  }

  /// Set a [Matrix2] at the given [key] on the buffer.
  void setMatrix2(String key, Matrix2 matrix) => _setValue(key, matrix.storage);

  /// Set a [Matrix3] at the given [key] on the buffer.
  void setMatrix3(String key, Matrix3 matrix) => _setValue(key, matrix.storage);

  /// Set a [Matrix4] at the given [key] on the buffer.
  void setMatrix4(String key, Matrix4 matrix) => _setValue(key, matrix.storage);

  void setColor(String key, Color color) => _setValue(key, color.storage);

  void bind(GraphicsDevice device) {
    for (final slot in _slots) {
      _instances[slot.name]?.bind(device);
    }
  }

  /// Set the [data] to the [UniformSlot] identified by [key].
  void _setValue(String key, List<double> data) {
    final (uniform, field) = _getInstance<UniformValue>(key);
    uniform[field!] = data;
  }

  void _setSampler(String key, Texture data) {
    final (uniform, _) = _getInstance<UniformSampler>(key);
    uniform.resource = data;
  }

  /// Get the slot for the [key], it only calculates it once for every unique
  /// [key].
  (T, String?) _getInstance<T extends UniformInstance>(String key) {
    final keys = key.split('.');

    // Check if we already have a uniform instance created.
    if (!_instances.containsKey(keys.first)) {
      // If the slot or it's property isn't mapped in the uniform it will be
      // enforced.
      final slot = _slots.firstWhere(
        (e) => e.name == keys.first,
        orElse: () => throw StateError('Uniform "$key" is unmapped'),
      );

      final instance = slot.create();
      if (instance is UniformValue &&
          keys.length > 1 &&
          !slot.fields.contains(keys[1])) {
        throw StateError('Field "${keys[1]}" is unmapped for "${keys.first}"');
      }

      _instances[slot.name] = instance;
    }

    return (_instances[keys.first], keys.elementAtOrNull(1)) as (T, String?);
  }

  static Float32List _encodeUint32(int value, Endian endian) {
    return (ByteData(16)..setUint32(0, value, endian)).buffer.asFloat32List();
  }
}
