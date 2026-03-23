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
  UniformSlot._(this.name, this._instanceCreator);

  /// {@macro uniform_slot}
  ///
  /// Used for struct uniforms in shaders.
  UniformSlot.value(String name) : this._(name, UniformValue.new);

  /// {@macro uniform_slot}
  ///
  /// Used for sampler uniforms in shaders.
  UniformSlot.sampler(String name) : this._(name, UniformSampler.new);

  /// The uniform slot's name.
  final String name;

  final UniformInstance Function(UniformSlot) _instanceCreator;

  UniformInstance create() => _instanceCreator.call(this);

  gpu.UniformSlot? _uniformSlot;

  bool get isCompiled => _uniformSlot != null;

  set uniformSlot(gpu.UniformSlot value) {
    _uniformSlot = value;
    recreateResource = true;
  }

  @override
  gpu.UniformSlot? createResource() => _uniformSlot;
}
