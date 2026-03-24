import 'dart:collection';
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
/// {@endtemplate}
class Shader extends Resource<gpu.Shader> {
  /// Load a [Shader] from asset.
  Shader.fromAsset(
    String assetName, {
    required String entryPoint,
    List<String> uniforms = const [],
    List<String> samplers = const [],
  }) : this._(
         _assetLibrary(assetName),
         entryPoint: entryPoint,
         uniforms: uniforms,
         samplers: samplers,
       );

  Shader._(
    this._getShader, {
    required this.entryPoint,
    required this.uniforms,
    required this.samplers,
  });

  /// The shader entry point name within the bundle.
  final String entryPoint;

  /// Names of struct uniform blocks (e.g., `['VertexInfo', 'Material']`).
  final List<String> uniforms;

  /// Names of sampler uniforms (e.g., `['albedoTexture']`).
  final List<String> samplers;

  final gpu.Shader Function(String key) _getShader;

  final Map<String, gpu.UniformSlot> _slots = {};
  final Map<String, _UniformData> _uniforms = {};
  final Map<String, Texture> _textures = {};

  /// Set a [Texture] at the given [key].
  void setTexture(String key, Texture texture) => _textures[key] = texture;

  /// Set a [Vector2] at the given [key].
  void setVector2(String key, Vector2 vector) => _set(key, vector.storage);

  /// Set a [Vector3] at the given [key].
  void setVector3(String key, Vector3 vector) => _set(key, vector.storage);

  /// Set a [Vector4] at the given [key].
  void setVector4(String key, Vector4 vector) => _set(key, vector.storage);

  /// Set an [int] (encoded as uint) at the given [key].
  void setUint(String key, int value) => _set(
    key,
    (ByteData(4)..setUint32(0, value, Endian.little)).buffer.asFloat32List(),
  );

  /// Set a [double] at the given [key].
  void setFloat(String key, double value) =>
      _set(key, Float32List.fromList([value]));

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
    for (final name in uniforms) {
      final data = _uniforms[name];
      if (data != null) {
        device.bindUniform(_slots[name]!, data.toByteBuffer());
      }
    }

    for (final name in samplers) {
      final texture = _textures[name];
      if (texture != null) {
        device.bindTexture(_slots[name]!, texture);
      }
    }
  }

  @override
  gpu.Shader createResource() {
    // Always clear up old data to prevent memory leaks.
    _slots.clear();
    _uniforms.clear();
    _textures.clear();

    final shader = _getShader(entryPoint);
    for (final name in [...uniforms, ...samplers]) {
      _slots[name] = shader.getUniformSlot(name);
    }
    return shader;
  }

  void _set(String key, Float32List data) {
    final (slot, field, index) = parseKey(key);
    final uniform = _uniforms.putIfAbsent(
      slot,
      () => _UniformData(_slots[slot]!),
    );

    return switch (field) {
      final field? => uniform.setField(
        index != null ? '$field[$index]' : field,
        data,
      ),
      _ => uniform.setRaw(data),
    };
  }

  /// Parse a uniform key into (structName, memberName, arrayIndex).
  ///
  /// Examples:
  /// - `'VertexInfo.model'` becomes `('VertexInfo', 'model', null)`
  /// - `'Lights.positions[0]'` becomes `('Lights', 'positions', 0)`
  /// - `'albedoTexture'` becomes `('albedoTexture', null, null)`
  static (String, String?, int?) parseKey(String key) {
    final match = RegExp(r'^(\w+)(?:\.(\w+))?(?:\[(\d+)\])?$').firstMatch(key);
    if (match == null) {
      throw StateError('Invalid uniform key: "$key"');
    }

    final struct = match.group(1)!;
    final member = match.group(2);
    final index = match.group(3);
    return (struct, member, index != null ? int.parse(index) : null);
  }

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

class _UniformData {
  _UniformData(this.slot);

  final gpu.UniformSlot slot;
  final Map<String, ({int hash, Float32List data})> _fields = HashMap();
  ({int hash, Float32List data})? _raw;
  ByteBuffer? _cached;

  void setRaw(Float32List data) {
    final hash = Object.hashAll(data);
    if (_raw?.hash == hash) {
      return;
    }

    _raw = (hash: hash, data: data);
    _cached = null;
  }

  void setField(String key, Float32List data) {
    final hash = Object.hashAll(data);
    if (_fields[key]?.hash == hash) {
      return;
    }

    _fields[key] = (hash: hash, data: data);
    _cached = null;
  }

  ByteBuffer toByteBuffer() {
    if (_cached != null) {
      return _cached!;
    }

    // If not null, it is a standalone uniform.
    if (_raw case final raw?) {
      return _cached = raw.data.buffer;
    }

    final sizeInBytes = slot.sizeInBytes;
    if (sizeInBytes == null) {
      throw StateError('Uniform struct not found in shader');
    }

    final buffer = ByteData(sizeInBytes);
    for (final MapEntry(:key, value: entry) in _fields.entries) {
      final (member, arrayIndex) = _parseMemberKey(key);
      final memberOffset = slot.getMemberOffsetInBytes(member);
      if (memberOffset == null) {
        throw StateError('Field "$member" not found in uniform struct');
      }

      final stride = _std140ArrayStride(entry.data.lengthInBytes);
      final offset = switch (arrayIndex) {
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

    return _cached = buffer.buffer;
  }

  /// Parse `"positions[0]"` → `("positions", 0)`,
  /// `"numLights"` → `("numLights", null)`.
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
