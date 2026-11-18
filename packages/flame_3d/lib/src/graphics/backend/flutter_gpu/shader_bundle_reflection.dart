import 'dart:convert';
import 'dart:typed_data';

import 'package:flame_3d/src/graphics/backend/gpu_handles.dart';

/// Reads the vertex inputs of every shader in an `impellerc` shader bundle.
///
/// Flutter GPU binds vertex attributes by input name but does not expose the
/// inputs a shader declares. They are needed to build a vertex layout that
/// feeds exactly those inputs, so they are read from the bundle itself: a
/// flatbuffer (`impeller/shader_bundle/shader_bundle.fbs`, file identifier
/// `IPSB`) holding, for each shader and backend, the reflected inputs.
///
/// Returns a map from shader name (the bundle's entry point key) to its inputs
/// ordered by location, or `null` when [bytes] is not a shader bundle this
/// reader understands.
Map<String, List<GpuShaderInput>>? reflectShaderBundleInputs(ByteData bytes) {
  try {
    return _FlatBufferReader(bytes)._readBundle();
    // The bundle format is private to the engine: anything unexpected means
    // reflection is unavailable rather than an error.
    // ignore: avoid_catches_without_on_clauses
  } catch (_) {
    return null;
  }
}

class _FlatBufferReader(final ByteData _data) {
  // Field indices, in declaration order of the schema.
  static const _bundleShaders = 0;
  static const _shaderName = 0;
  // `vulkan`, `metal_desktop`, `metal_ios`, `opengl_es`, `opengl_desktop`.
  static const _shaderBackends = [5, 2, 1, 3, 4];
  static const _backendInputs = 2;
  static const _inputName = 0;
  static const _inputLocation = 1;
  static const _inputType = 4;
  static const _inputVecSize = 6;
  static const _inputColumns = 7;

  // `InputDataType.kFloat`.
  static const _floatType = 9;

  Map<String, List<GpuShaderInput>>? _readBundle() {
    if (_data.lengthInBytes < 8 ||
        String.fromCharCodes([
              for (var i = 4; i < 8; i++) _data.getUint8(i),
            ]) !=
            'IPSB') {
      return null;
    }
    final root = _u32(0);
    final result = <String, List<GpuShaderInput>>{};
    for (final shader in _tables(root, _bundleShaders)) {
      final name = _string(shader, _shaderName);
      if (name == null) {
        continue;
      }
      // Every backend reflects the same inputs, use the first one present.
      for (final index in _shaderBackends) {
        final backend = _table(shader, index);
        if (backend == null) {
          continue;
        }
        final inputs = <GpuShaderInput>[];
        for (final input in _tables(backend, _backendInputs)) {
          final inputName = _string(input, _inputName);
          if (inputName == null) {
            return null;
          }
          final type = _scalar32(input, _inputType);
          final columns = _scalar64(input, _inputColumns, fallback: 1);
          inputs.add(
            GpuShaderInput(
              name: inputName,
              location: _scalar64(input, _inputLocation),
              // Non-float and matrix inputs cannot be fed by a float layout;
              // a component count of 0 marks them as such.
              components: type == _floatType && columns <= 1
                  ? _scalar64(input, _inputVecSize)
                  : 0,
            ),
          );
        }
        inputs.sort((a, b) => a.location.compareTo(b.location));
        result[name] = inputs;
        break;
      }
    }
    return result;
  }

  int _u32(int position) => _data.getUint32(position, Endian.little);

  /// The absolute position of field [index] of the table at [table], or `-1`
  /// when the field is absent.
  int _field(int table, int index) {
    final vtable = table - _data.getInt32(table, Endian.little);
    final vtableSize = _data.getUint16(vtable, Endian.little);
    final entry = 4 + index * 2;
    if (entry >= vtableSize) {
      return -1;
    }
    final offset = _data.getUint16(vtable + entry, Endian.little);
    return offset == 0 ? -1 : table + offset;
  }

  int _deref(int position) => position + _u32(position);

  int? _table(int table, int index) {
    final field = _field(table, index);
    return field < 0 ? null : _deref(field);
  }

  List<int> _tables(int table, int index) {
    final field = _field(table, index);
    if (field < 0) {
      return const [];
    }
    final vector = _deref(field);
    final length = _u32(vector);
    return [
      for (var i = 0; i < length; i++) _deref(vector + 4 + i * 4),
    ];
  }

  String? _string(int table, int index) {
    final field = _field(table, index);
    if (field < 0) {
      return null;
    }
    final string = _deref(field);
    return utf8.decode(
      _data.buffer.asUint8List(
        _data.offsetInBytes + string + 4,
        _u32(string),
      ),
    );
  }

  int _scalar32(int table, int index) {
    final field = _field(table, index);
    return field < 0 ? 0 : _u32(field);
  }

  int _scalar64(int table, int index, {int fallback = 0}) {
    final field = _field(table, index);
    if (field < 0) {
      return fallback;
    }
    // Values are small, the high word is always zero.
    return _u32(field);
  }
}
