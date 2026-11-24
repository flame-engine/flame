import 'dart:ui';

import 'package:vector_math/vector_math.dart';

// Extensions that set the name-based uniform slots of a [FragmentShader],
// such as `shader.getUniformVec2('uSize')`, from Flame's types.
//
// Look a slot up once, for example in `onLoad`, and set it every frame.
// Looking it up again every frame searches the uniforms of the shader each
// time.

/// Sets a `vec2` uniform from a [Vector2], [Size] or [Offset].
///
/// ```dart
/// final size = shader.getUniformVec2('uSize');
/// size.setVector(Vector2(320, 180));
/// ```
extension UniformVec2SlotExtension on UniformVec2Slot {
  /// Sets the uniform to `vec2(vector.x, vector.y)`.
  void setVector(Vector2 vector) => set(vector.x, vector.y);

  /// Sets the uniform to `vec2(size.width, size.height)`.
  void setSize(Size size) => set(size.width, size.height);

  /// Sets the uniform to `vec2(offset.dx, offset.dy)`.
  void setOffset(Offset offset) => set(offset.dx, offset.dy);
}

/// Sets a `vec3` uniform from a [Vector3].
extension UniformVec3SlotExtension on UniformVec3Slot {
  /// Sets the uniform to `vec3(vector.x, vector.y, vector.z)`.
  void setVector(Vector3 vector) => set(vector.x, vector.y, vector.z);
}

/// Sets a `vec4` uniform from a [Vector4] or a [Color].
///
/// ```dart
/// final color = shader.getUniformVec4('uColor');
/// color.setColor(Colors.red);
/// ```
extension UniformVec4SlotExtension on UniformVec4Slot {
  /// Sets the uniform to `vec4(vector.x, vector.y, vector.z, vector.w)`.
  void setVector(Vector4 vector) {
    set(vector.x, vector.y, vector.z, vector.w);
  }

  /// Sets the uniform to `vec4(color.r, color.g, color.b, color.a)`, with
  /// every channel between 0 and 1.
  ///
  /// If [premultiply] is true, the red, green and blue channels are
  /// multiplied by the alpha of the color.
  void setColor(Color color, {bool premultiply = false}) {
    final multiplier = premultiply ? color.a : 1.0;
    set(
      color.r * multiplier,
      color.g * multiplier,
      color.b * multiplier,
      color.a,
    );
  }
}

/// Sets a `mat2` uniform from a [Matrix2].
extension UniformMat2SlotExtension on UniformMat2Slot {
  /// Sets the uniform to [matrix], so `uniform[i][j]` in the shader is the
  /// entry in column `i` and row `j` of [matrix].
  void setMatrix(Matrix2 matrix) {
    final m = matrix.storage;
    set(m[0], m[1], m[2], m[3]);
  }
}

/// Sets a `mat3` uniform from a [Matrix3].
extension UniformMat3SlotExtension on UniformMat3Slot {
  /// Sets the uniform to [matrix], so `uniform[i][j]` in the shader is the
  /// entry in column `i` and row `j` of [matrix].
  void setMatrix(Matrix3 matrix) {
    final m = matrix.storage;
    set(m[0], m[1], m[2], m[3], m[4], m[5], m[6], m[7], m[8]);
  }
}

/// Sets a `mat4` uniform from a [Matrix4].
extension UniformMat4SlotExtension on UniformMat4Slot {
  /// Sets the uniform to [matrix], so `uniform[i][j]` in the shader is the
  /// entry in column `i` and row `j` of [matrix].
  void setMatrix(Matrix4 matrix) {
    final m = matrix.storage;
    set(
      m[0],
      m[1],
      m[2],
      m[3],
      m[4],
      m[5],
      m[6],
      m[7],
      m[8],
      m[9],
      m[10],
      m[11],
      m[12],
      m[13],
      m[14],
      m[15],
    );
  }
}
