import 'package:flame_3d/resources.dart';
import 'package:flutter_gpu/gpu.dart' as gpu;

/// {@template uniform_slot}
/// Class that maps a uniform slot in such a way that it is easier to do memory
/// allocation.
///
/// This allows the [Shader] to create [UniformInstance]s that bind themselves
/// to the shader without the shader needing to the inner workings.
/// {@endtemplate}
class UniformSlot extends Resource<gpu.UniformSlot?> {
  UniformSlot._(this.name, this.fields, this._instanceCreator)
    : _fieldIndices = {for (var (index, key) in fields.indexed) key: index};

  /// {@macro uniform_slot}
  ///
  /// Used for struct uniforms in shaders.
  ///
  /// The [fields] should be defined in order as they appear in the struct.
  UniformSlot.value(String name, Set<String> fields)
    : this._(name, fields, UniformValue.new);

  /// {@macro uniform_slot}
  ///
  /// Used for array uniforms in shaders.
  ///
  /// The [fields] should be defined in order as they appear in the struct.
  UniformSlot.array(String name, Set<String> fields)
    : this._(name, fields, UniformArray.new);

  /// {@macro uniform_slot}
  ///
  /// Used for sampler uniforms in shaders.
  UniformSlot.sampler(String name) : this._(name, {}, UniformSampler.new);

  /// The uniform slot's name.
  final String name;

  /// The fields in the uniform and the order in which the memory should be
  /// allocated.
  ///
  /// This is empty if the slot is a sampler.
  final Set<String> fields;

  /// Cache of the fields mapped to their index.
  final Map<String, int> _fieldIndices;

  final UniformInstance Function(UniformSlot) _instanceCreator;

  int indexOf(String field) => _fieldIndices[field]!;

  UniformInstance create() => _instanceCreator.call(this);

  gpu.UniformSlot? _uniformSlot;

  set uniformSlot(gpu.UniformSlot value) {
    _uniformSlot = value;
    recreateResource = true;
  }

  @override
  gpu.UniformSlot? createResource() => _uniformSlot;
}
