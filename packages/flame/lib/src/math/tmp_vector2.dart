import 'package:meta/meta.dart';
import 'package:vector_math/vector_math_64.dart';

/// Use internally when you need a temporary [Vector2] object but don't want to
/// instantiate a new one due to performance.
@internal
final Vector2 tmpVector2 = Vector2.zero();
