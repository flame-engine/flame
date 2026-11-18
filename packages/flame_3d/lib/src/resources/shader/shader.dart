import 'dart:typed_data';
import 'dart:ui';

import 'package:flame_3d/game.dart';
import 'package:flame_3d/graphics.dart';
import 'package:flame_3d/resources.dart';
import 'package:meta/meta.dart';

/// {@template shader}
/// A shader [Resource] that represents a compiled shader program and the
/// uniform data that will be bound to it.
///
/// Uniform values are set by string key (`'Material.albedoColor'`,
/// `'Lights.positions[0]'`, `'someColor'`) and are automatically packed
/// into GPU buffers using shader reflection for layout.
///
/// Samplers are auto-detected at compile time via [GpuUniformSlot.sizeInBytes]
/// returning `null` — no need to declare them separately.
///
/// Some uniform blocks are filled by the [RenderContext3D] instead of by the
/// material, once per render pass (see [RenderContext3D.passUniforms]): a
/// shader declares them like any other slot and does not set them.
/// {@endtemplate}
class Shader._(
  final GpuShader Function(String key) _getShader, {

  /// The shader entry point name within the bundle.
  required final String entryPoint,

  /// Names of all uniform slots — both struct blocks and samplers.
  ///
  /// The type of each slot is auto-detected at compile time:
  /// struct blocks have a non-null [GpuUniformSlot.sizeInBytes],
  /// samplers return `null`.
  required final List<String> slots,
}) extends Resource<GpuShader> {
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

  final Map<String, GpuUniformSlot> _slots = {};
  final Map<String, UniformBlock> _blocks = {};
  final Map<String, Texture> _textures = {};
  final Map<String, _UniformField> _fields = {};

  /// Incremented every time the shader resource is created, so that state
  /// derived from its slots can tell when it is stale.
  @internal
  int get generation => _generation;
  int _generation = 0;

  /// State the render context derives from this shader's slots.
  @internal
  Object? renderCache;

  /// The resolved slot named [name].
  ///
  /// Throws when [name] is not one of the declared [slots].
  GpuUniformSlot slot(String name) {
    resource;
    return _slots[name] ??
        (throw StateError('Shader "$entryPoint" has no slot "$name"'));
  }

  /// The uniform block named [name] holding this shader's own values,
  /// created the first time it is requested.
  UniformBlock block(String name) {
    resource;
    return _blocks[name] ??= UniformBlock(slot(name));
  }

  /// The texture set for the sampler [name], or `null` when none was set.
  Texture? texture(String name) => _textures[name];

  /// Set a [Texture] at the given [key].
  void setTexture(String key, Texture texture) {
    resource;
    final slot = _slots[key];
    if (slot == null) {
      throw StateError('Shader "$entryPoint" has no slot "$key"');
    }
    if (slot.sizeInBytes != null) {
      throw StateError('Slot "$key" is a uniform block, not a sampler');
    }
    _textures[key] = texture;
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
  void setColor(String key, Color color) {
    _colorBuf
      ..[0] = color.r
      ..[1] = color.g
      ..[2] = color.b
      ..[3] = color.a;
    return _set(key, _colorBuf);
  }

  /// Bind all uniform blocks and textures this shader has values for to the
  /// [device].
  ///
  /// Unchanged blocks are not uploaded again within a frame.
  void bind(GraphicsDevice device) {
    for (final block in _blocks.values) {
      device.bindUniformBlock(block);
    }
    for (final MapEntry(:key, value: texture) in _textures.entries) {
      device.bindTexture(_slots[key]!, texture);
    }
  }

  @override
  GpuShader createResource() {
    // Always clear up old data to prevent memory leaks.
    _slots.clear();
    _blocks.clear();
    _textures.clear();
    _fields.clear();
    _generation++;
    renderCache = null;

    final shader = _getShader(entryPoint);
    for (final name in slots) {
      _slots[name] = shader.getUniformSlot(name);
    }
    return shader;
  }

  void _set(String key, Float32List data) {
    (_fields[key] ?? _resolveField(key)).write(data);
  }

  _UniformField _resolveField(String key) {
    final (slotName, field, index) = parseKey(key);
    resource;
    final slot = _slots[slotName];
    if (slot == null) {
      throw StateError('Shader "$entryPoint" has no slot "$slotName"');
    }
    if (slot.sizeInBytes == null) {
      throw StateError('Slot "$key" is a sampler block, not a uniform');
    }
    final block = _blocks[slotName] ??= UniformBlock(slot);

    final int? offset;
    if (field != null) {
      offset = block.memberOffset(field);
      if (offset == null) {
        throw StateError('Field "$field" not found in uniform struct');
      }
    } else {
      offset = null;
    }
    return _fields[key] = _UniformField(block, offset, index);
  }

  /// Parse a uniform key into (structName, memberName, arrayIndex).
  ///
  /// Examples:
  /// - `'Material.albedoColor'` becomes `('Material', 'albedoColor', null)`
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

  static final _colorBuf = Float32List(4);

  static GpuShader Function(String key) _assetLibrary(String assetName) {
    return (key) => GpuBackend.instance.loadShaderLibrary(assetName)[key];
  }
}

/// A uniform key resolved once to the block and offset it writes to.
class _UniformField(
  final UniformBlock _block,
  final int? _memberOffset,
  final int? _index,
) {
  void write(Float32List data) {
    switch (_memberOffset) {
      case final offset?:
        _block.writeAt(
          switch (_index) {
            // Std140 array element stride: round up to a 16-byte boundary.
            final i? => offset + i * ((data.length + 3) & ~3),
            _ => offset,
          },
          data,
        );
      case null:
        _block.writeAt(0, data);
    }
  }
}
