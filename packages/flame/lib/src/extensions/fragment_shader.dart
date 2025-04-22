import 'dart:ui' as ui;

import 'package:flutter/animation.dart';
import 'package:flutter/foundation.dart';
import 'package:vector_math/vector_math.dart';

/// This code was originally from the flutter_shaders package.
/// https://pub.dev/packages/flutter_shaders

/// A helper extension on [ui.FragmentShader] that allows you to set uniforms
/// in a more convenient way. Without having to manage indices.
///
/// Example:
/// ```dart
/// shader.setFloatUniforms((setter) {
///  setter.setFloat(1.0);
///  setter.setFloats([1.0, 2.0, 3.0]);
///  setter.setSize(const Size(1.0, 2.0));
///  setter.setSizes([const Size(1.0, 2.0), const Size(3.0, 4.0)]);
///  setter.setOffset(const Offset(1.0, 2.0));
///  setter.setOffsets([const Offset(1.0, 2.0), const Offset(3.0, 4.0)]);
///  setter.setMatrix(Matrix4.identity());
///  setter.setMatrices([Matrix4.identity(), Matrix4.identity()]);
///  setter.setColor(Colors.red);
///  setter.setColors([Colors.red, Colors.green]);
/// });
/// ```
///
/// The receiving end of this script should be:
/// ```glsl
/// uniform float u0; // 1.0
/// uniform float[3] uFloats; // float[3](1.0, 2.0, 3.0)
/// uniform vec2 size; // vec2(1.0, 2.0)
/// uniform vec2[2] sizes; // vec2[2](vec2(1.0, 2.0), vec2(3.0, 4.0))
/// uniform vec2 offset; // vec2(1.0, 2.0)
/// uniform vec2[2] offsets; // vec2[2](vec2(1.0, 2.0), vec2(3.0, 4.0))
/// uniform mat4 matrix; // mat4(1.0)
/// uniform mat4[2] matrices; // mat4[2](mat4(1.0), mat4(1.0))
/// uniform vec4 color; // vec4(1.0, 0.0, 0.0, 1.0)
/// uniform vec4[2] colors; // vec4[2](vec4(1.0, 0.0, 0.0, 1.0), vec4(0.0, 1.0, 0.0, 1.0))
/// ```
extension FragmentShaderExtension on ui.FragmentShader {
  /// Sets the uniforms of the shader using the provided [callback].
  ///
  /// The [initialIndex] parameter allows you to set the index of the first
  /// uniform. Defaults to 0.
  ///
  /// Returns the index of the last uniform that was set.
  int setFloatUniforms(
    ValueSetter<UniformsSetter> callback, {
    int initialIndex = 0,
  }) {
    final setter = UniformsSetter(this, initialIndex);
    callback(setter);
    return setter._index;
  }
}

/// A helper class that allows you to set uniforms in a more convenient way.
class UniformsSetter {
  UniformsSetter(this.shader, this._index);

  int _index;
  final ui.FragmentShader shader;

  void setFloat(double value) {
    shader.setFloat(_index++, value);
  }

  void setFloats(List<double> values) {
    for (final value in values) {
      setFloat(value);
    }
  }

  void setSize(Size size) {
    shader
      ..setFloat(_index++, size.width)
      ..setFloat(_index++, size.height);
  }

  void setSizes(List<Size> sizes) {
    for (final size in sizes) {
      setSize(size);
    }
  }

  void setColor(Color color, {bool premultiply = false}) {
    final double multiplier;
    if (premultiply) {
      multiplier = color.a;
    } else {
      multiplier = 1.0;
    }

    setFloat(color.r / 255 * multiplier);
    setFloat(color.g / 255 * multiplier);
    setFloat(color.b / 255 * multiplier);
    setFloat(color.a);
  }

  void setColors(List<Color> colors, {bool premultiply = false}) {
    for (final color in colors) {
      setColor(color, premultiply: premultiply);
    }
  }

  void setOffset(Offset offset) {
    shader
      ..setFloat(_index++, offset.dx)
      ..setFloat(_index++, offset.dy);
  }

  void setOffsets(List<Offset> offsets) {
    for (final offset in offsets) {
      setOffset(offset);
    }
  }

  void setVector(Vector vector) {
    setFloats(vector.storage);
  }

  void setVectors(List<Vector> vectors) {
    for (final vector in vectors) {
      setVector(vector);
    }
  }

  void setMatrix2(Matrix2 matrix2) {
    setFloats(matrix2.storage);
  }

  void setMatrix2s(List<Matrix2> matrix2s) {
    for (final matrix2 in matrix2s) {
      setMatrix2(matrix2);
    }
  }

  void setMatrix3(Matrix3 matrix3) {
    setFloats(matrix3.storage);
  }

  void setMatrix3s(List<Matrix3> matrix3s) {
    for (final matrix3 in matrix3s) {
      setMatrix3(matrix3);
    }
  }

  void setMatrix4(Matrix4 matrix4) {
    setFloats(matrix4.storage);
  }

  void setMatrix4s(List<Matrix4> matrix4s) {
    for (final matrix4 in matrix4s) {
      setMatrix4(matrix4);
    }
  }
}
