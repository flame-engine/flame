import 'dart:typed_data';
import 'dart:ui';

import 'package:flame_3d/graphics.dart';
import 'package:flame_3d/resources.dart';
import 'package:flutter_gpu/gpu.dart' as gpu;

class DefaultMaterial extends Material {
  DefaultMaterial({
    Texture? texture,
    Color colorDiffuse = const Color(0xFFFFFFFF),
  })  : _texture = texture ?? Texture.empty,
        _colorDiffuse = colorDiffuse,
        super(_library) {
    _deviceBuffer = gpu.gpuContext.createDeviceBuffer(
      gpu.StorageMode.hostVisible,
      4,
    );

    // TODO(wolfen): not working as expected
    final buffer = Float32List.fromList([
      _colorDiffuse.red / 255,
      _colorDiffuse.green / 255,
      _colorDiffuse.blue / 255,
      _colorDiffuse.alpha / 255,
    ]).buffer;

    _deviceBuffer?.overwrite(buffer.asByteData());
  }

  final Texture _texture;

  final Color _colorDiffuse;

  late final gpu.DeviceBuffer? _deviceBuffer;

  @override
  void bind(GraphicsDevice device) {
    device.bindTexture(fragmentShader, 'texture0', _texture);

    // TODO(wolfen): add support of color diffusing in the default shader.
    // pass.bindUniform(
    //   fragmentShader.getUniformSlot('colDiffuse')!,
    //   gpu.BufferView(_deviceBuffer!, offsetInBytes: 0, lengthInBytes: 4 * 4),
    // );
  }

  static final _library = gpu.ShaderLibrary.fromAsset(
    'packages/flame_3d/assets/shaders/default_material.shaderbundle',
  )!;
}
