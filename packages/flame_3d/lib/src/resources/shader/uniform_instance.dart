import 'package:flame_3d/graphics.dart';
import 'package:flame_3d/resources.dart';

/// {@template uniform_instance}
/// An instance of a [UniformSlot] that can cache the [resource] that will be
/// bound to a [Shader].
/// {@endtemplate}
abstract class UniformInstance<T> extends Resource<T?> {
  /// {@macro uniform_instance}
  UniformInstance(this.slot) : super(null);

  /// The slot this instance belongs too.
  final UniformSlot slot;

  void bind(GraphicsDevice device);
}
