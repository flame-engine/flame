import 'dart:ui';

import 'package:flame_3d/game.dart';
import 'package:flame_3d/graphics.dart';
import 'package:flame_3d/resources.dart';
import 'package:flutter_gpu/gpu.dart' as gpu;

class DefaultMaterial extends Material {
  DefaultMaterial({
    Texture? texture,
    Color? albedoColor,
  })  : texture = texture ?? Texture.empty,
        _albedoColorCache = Vector4.zero(),
        super(_library) {
    this.albedoColor = albedoColor ?? const Color(0xFFFFFFFF);
  }

  Texture texture;

  Color get albedoColor => _albedoColor;
  set albedoColor(Color color) {
    _albedoColor = color;
    _albedoColorCache.setValues(
      color.red / 255,
      color.green / 255,
      color.blue / 255,
      color.alpha / 255,
    );
  }

  late Color _albedoColor;
  final Vector4 _albedoColorCache;

  @override
  void bind(GraphicsDevice device) {
    device.bindTexture(fragmentShader, 'texture0', texture);
  }

  @override
  ShaderInfo getFragmentInfo() {
    return super.getFragmentInfo()..addVector4(_albedoColorCache);
  }

  static final _library = gpu.ShaderLibrary.fromAsset(
    'packages/flame_3d/assets/shaders/default_material.shaderbundle',
  )!;
}
