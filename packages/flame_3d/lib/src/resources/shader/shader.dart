import 'dart:typed_data';
import 'dart:ui';

import 'package:flame_3d/game.dart';
import 'package:flame_3d/graphics.dart';
import 'package:flame_3d/resources.dart';
import 'package:flutter_gpu/gpu.dart' as gpu;

/// {@template shader}
/// A shader [Resource] that represents a compiled shader program and the
/// uniform data that will be bound to it.
///
/// Uniform values are set by string key (`'VertexInfo.model'`,
/// `'Lights.positions[0]'`, `'someColor'`) and are automatically packed
/// into GPU buffers using shader reflection for layout.
///
/// Samplers are auto-detected at compile time via [gpu.UniformSlot.sizeInBytes]
/// returning `null` — no need to declare them separately.
/// {@endtemplate}
class Shader extends Resource<gpu.Shader> {
  /// Load a [Shader] from asset.
  Shader.fromAsset(
    String assetName, {
    required String entryPoint,
    List<String> slots = const [],
  }) : this._(
         _assetLibrary(assetName),
         entryPoint: entryPoint,
         slots: slots,
       );

  Shader._(
    this._getShader, {
    required this.entryPoint,
    required this.slots,
  });

  /// The shader entry point name within the bundle.
  final String entryPoint;

  /// Names of all uniform slots — both struct blocks and samplers.
  ///
  /// The type of each slot is auto-detected at compile time:
  /// struct blocks have a non-null [gpu.UniformSlot.sizeInBytes],
  /// samplers return `null`.
  final List<String> slots;

  final gpu.Shader Function(String key) _getShader;

  final Map<String, gpu.UniformSlot> _slots = {};
  final Map<String, _SlotBinding> _bindings = {};

  /// Set a [Texture] at the given [key].
  void setTexture(String key, Texture texture) {
    final binding = switch (_bindings.putIfAbsent(
      key,
      () => _TextureBinding(_slots[key]!, texture),
    )) {
      final _TextureBinding binding => binding,
      _ => throw StateError('Slot "$key" is a uniform block, not a sampler'),
    };

    binding.resource = texture;
  }

  /// Set a [Vector2] at the given [key].
  void setVector2(String key, Vector2 vector) => _set(key, vector.storage);

  /// Set a [Vector3] at the given [key].
  void setVector3(String key, Vector3 vector) => _set(key, vector.storage);

  /// Set a [Vector4] at the given [key].
  void setVector4(String key, Vector4 vector) => _set(key, vector.storage);

  /// Set an [int] (encoded as uint) at the given [key].
  void setUint(String key, int value) {
    _scalarData.setUint32(0, value, Endian.little);
    return _set(key, _scalarBuf);
  }

  /// Set a [double] at the given [key].
  void setFloat(String key, double value) {
    _scalarData.setFloat32(0, value, Endian.little);
    return _set(key, _scalarBuf);
  }

  /// Set a [Matrix2] at the given [key].
  void setMatrix2(String key, Matrix2 matrix) => _set(key, matrix.storage);

  /// Set a [Matrix3] at the given [key].
  void setMatrix3(String key, Matrix3 matrix) => _set(key, matrix.storage);

  /// Set a [Matrix4] at the given [key].
  void setMatrix4(String key, Matrix4 matrix) => _set(key, matrix.storage);

  /// Set a [Color] at the given [key].
  void setColor(String key, Color color) =>
      _set(key, _colorBytesCache.putIfAbsent(color, () => color.storage));

  /// Bind all uniform data and textures to the [device].
  void bind(GraphicsDevice device) {
    for (final MapEntry(:key, :value) in _bindings.entries) {
      switch (value) {
        case _UniformBinding(:final resource):
          device.bindUniform(_slots[key]!, resource);
        case _TextureBinding(:final resource):
          device.bindTexture(_slots[key]!, resource);
      }
    }
  }

  @override
  gpu.Shader createResource() {
    // Always clear up old data to prevent memory leaks.
    _slots.clear();
    _bindings.clear();

    final shader = _getShader(entryPoint);
    for (final name in slots) {
      _slots[name] = shader.getUniformSlot(name);
    }
    return shader;
  }

  void _set(String key, Float32List data) {
    final (slot, field, index) = parseKey(key);

    final binding = switch (_bindings.putIfAbsent(
      slot,
      () => _UniformBinding(_slots[slot]!),
    )) {
      final _UniformBinding binding => binding,
      _ => throw StateError('Slot "$key" is a sampler block, not a uniform'),
    };

    return switch (field) {
      final field? => binding.setField(field, index, data),
      _ => binding.setRaw(data),
    };
  }

  /// Parse a uniform key into (structName, memberName, arrayIndex).
  ///
  /// Examples:
  /// - `'VertexInfo.model'` becomes `('VertexInfo', 'model', null)`
  /// - `'Lights.positions[0]'` becomes `('Lights', 'positions', 0)`
  /// - `'albedoTexture'` becomes `('albedoTexture', null, null)`
  static (String, String?, int?) parseKey(String key) {
    final match = _keyMatches.putIfAbsent(key, () {
      final match = _keyRegex.firstMatch(key);
      if (match == null) {
        throw StateError('Invalid uniform key: "$key"');
      }
      return match;
    });

    final struct = match.group(1)!;
    final member = match.group(2);
    final index = match.group(3);
    return (struct, member, index != null ? int.parse(index) : null);
  }

  static final _keyRegex = RegExp(r'^(\w+)(?:\.(\w+))?(?:\[(\d+)\])?$');
  static final _keyMatches = <String, RegExpMatch>{};

  static final _scalarData = ByteData(4);
  static final _scalarBuf = _scalarData.buffer.asFloat32List();

  static final Map<Color, Float32List> _colorBytesCache = {};

  static gpu.Shader Function(String key) _assetLibrary(String assetName) {
    return (key) {
      final shader = gpu.ShaderLibrary.fromAsset(assetName)![key];
      if (shader == null) {
        throw StateError(
          'Shader "$key" not found in library "$assetName"',
        );
      }
      return shader;
    };
  }
}

sealed class _SlotBinding<T> {
  _SlotBinding(this.slot);

  final gpu.UniformSlot slot;

  T get resource;
}

class _UniformBinding extends _SlotBinding<ByteBuffer> {
  _UniformBinding(super.slot)
    : _data = Float32List(slot.sizeInBytes! ~/ Float32List.bytesPerElement);

  @override
  ByteBuffer get resource => _data.buffer;

  final Float32List _data;
  final Map<String, int> _memberOffsets = {};

  /// Write a struct member (optionally array-indexed) directly into the buffer.
  void setField(String member, int? index, Float32List data) {
    final baseOffset = _memberOffsets.putIfAbsent(
      member,
      () {
        final bytes = slot.getMemberOffsetInBytes(member);
        if (bytes == null) {
          throw StateError('Field "$member" not found in uniform struct');
        }
        return bytes ~/ Float32List.bytesPerElement;
      },
    );

    final offset = switch (index) {
      final i? => baseOffset + i * _std140ArrayStride(data.length),
      _ => baseOffset,
    };

    _data.setRange(offset, offset + data.length, data);
  }

  /// Write raw data for a standalone (non-struct) uniform.
  void setRaw(Float32List data) {
    _data.setRange(0, data.length, data);
  }

  /// Std140 array element stride in floats: round up to 4-float (16-byte)
  /// boundary.
  static int _std140ArrayStride(int elementFloats) {
    return (elementFloats + 3) & ~3;
  }
}

class _TextureBinding extends _SlotBinding<Texture> {
  _TextureBinding(super.slot, this.resource);

  @override
  Texture resource;
}
