import 'dart:typed_data';
import 'dart:ui';

import 'package:flame_3d/game.dart';
import 'package:flame_3d/graphics.dart';
import 'package:flame_3d/resources.dart';
import 'package:flutter_gpu/gpu.dart' as gpu;

/// {@template shader}
///
/// {@endtemplate}
class ShaderResource extends Resource<gpu.Shader> {
  final Shader shader;

  /// {@macro shader}
  ShaderResource(
    super.resource, {
    required String name,
    List<UniformSlot> slots = const [],
  }) : shader = Shader(name: name, slots: slots) {
    for (final slot in slots) {
      slot.resource = resource.getUniformSlot(slot.name);
    }
  }

  factory ShaderResource.create({
    required String name,
    required List<UniformSlot> slots,
  }) {
    final shader = _library[name];
    if (shader == null) {
      throw StateError('Shader "$name" not found in library');
    }
    return ShaderResource(shader, name: name, slots: slots);
  }

  static final _library = gpu.ShaderLibrary.fromAsset(
    'packages/flame_3d/assets/shaders/spatial_material.shaderbundle',
  )!;
}

class Shader {
  final String name;
  final List<UniformSlot> slots;
  final Map<String, UniformInstance> instances = {};

  Shader({
    required this.name,
    required this.slots,
  });

  /// Set a [Texture] at the given [key] on the buffer.
  void setTexture(String key, Texture texture) => _setTypedValue(key, texture);

  /// Set a [Vector2] at the given [key] on the buffer.
  void setVector2(String key, Vector2 vector) => _setValue(key, vector.storage);

  /// Set a [Vector3] at the given [key] on the buffer.
  void setVector3(String key, Vector3 vector) => _setValue(key, vector.storage);

  /// Set a [Vector4] at the given [key] on the buffer.
  void setVector4(String key, Vector4 vector) => _setValue(key, vector.storage);

  /// Set an [int] (encoded as uint) at the given [key] on the buffer.
  void setUint(String key, int value) {
    _setValue(key, _encodeUint32(value, Endian.little));
  }

  /// Set a [double] at the given [key] on the buffer.
  void setFloat(String key, double value) {
    _setValue(key, _encodeFloat32(value));
  }

  /// Set a [Matrix2] at the given [key] on the buffer.
  void setMatrix2(String key, Matrix2 matrix) => _setValue(key, matrix.storage);

  /// Set a [Matrix3] at the given [key] on the buffer.
  void setMatrix3(String key, Matrix3 matrix) => _setValue(key, matrix.storage);

  /// Set a [Matrix4] at the given [key] on the buffer.
  void setMatrix4(String key, Matrix4 matrix) => _setValue(key, matrix.storage);

  void setColor(String key, Color color) => _setValue(key, color.storage);

  void bind(GraphicsDevice device) {
    for (final slot in slots) {
      instances[slot.name]?.bind(device);
    }
  }

  /// Set the [data] to the [UniformSlot] identified by [key].
  void _setValue(String key, Float32List data) {
    _setTypedValue(key, data.buffer);
  }

  List<String?> parseKey(String key) {
    // examples: albedoTexture, Light[2].position, or Foo.bar
    final regex = RegExp(r'^(\w+)(?:\[(\d+)\])?(?:\.(\w+))?$');
    return regex.firstMatch(key)?.groups([1, 2, 3]) ?? [];
  }

  /// Get the slot for the [key], it only calculates it once for every unique
  /// [key].
  void _setTypedValue<K, T>(String key, T value) {
    final groups = parseKey(key);

    final object = groups[0]; // e.g. Light, albedoTexture
    final idx = _maybeParseInt(groups[1]); // e.g. 2 (optional)
    final field = groups[2]; // e.g. position (optional)

    if (object == null) {
      throw StateError('Uniform "$key" is missing an object');
    }

    final instance = instances.putIfAbsent(object, () {
      final slot = slots.firstWhere(
        (e) => e.name == object,
        orElse: () => throw StateError('Uniform "$object" is unmapped'),
      );
      return slot.create();
    }) as UniformInstance<K, T>;

    final k = instance.makeKey(idx, field);
    instance.set(k, value);
  }

  static Float32List _encodeUint32(int value, Endian endian) {
    return (ByteData(16)..setUint32(0, value, endian)).buffer.asFloat32List();
  }

  static Float32List _encodeFloat32(double value) {
    return Float32List.fromList([value]);
  }

  static int? _maybeParseInt(String? value) {
    if (value == null) {
      return null;
    }
    return int.parse(value);
  }

  ShaderResource compile() {
    return ShaderResource.create(name: name, slots: slots);
  }
}
