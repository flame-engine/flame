import 'dart:ui';

import 'package:flame_3d/game.dart';
import 'package:flame_3d/graphics.dart';
import 'package:flame_3d/resources.dart';
import 'package:flutter_gpu/gpu.dart' as gpu;

class DefaultMaterial extends Material {
  DefaultMaterial({
    Texture? texture,
    Color colorDiffuse = const Color(0xFFFFFFFF),
  })  : _texture = texture ?? Texture.empty,
        _colorDiffuse = colorDiffuse,
        super(_library);

  final Texture _texture;

  final Color _colorDiffuse;

  @override
  void bind(GraphicsDevice device) {
    device.bindTexture(fragmentShader, 'texture0', _texture);
  }

  @override
  ShaderInfo getFragmentInfo() {
    return super.getFragmentInfo()
      ..addVector4(
        Vector4(
          _colorDiffuse.red / 255,
          _colorDiffuse.green / 255,
          _colorDiffuse.blue / 255,
          _colorDiffuse.alpha / 255,
        ),
      );
  }

  static final _library = gpu.ShaderLibrary.fromAsset(
    'packages/flame_3d/assets/shaders/default_material.shaderbundle',
  )!;
}
