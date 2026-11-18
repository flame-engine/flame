import 'dart:typed_data';
import 'dart:ui';

import 'package:flame_3d/src/graphics/backend/gpu_backend.dart';
import 'package:flame_3d/src/graphics/backend/gpu_enums.dart';

/// Handle to a GPU texture.
abstract interface class GpuTexture() {
  /// The number of mip levels of the texture, `1` without mipmaps.
  int get mipLevelCount;

  /// Uploads [data] to the mip level [mipLevel] of the texture.
  ///
  /// [data] holds tightly packed rows of the level's pixels; a level is half
  /// the size of the previous one (rounded down, at least one pixel).
  void write(ByteData data, {int mipLevel = 0});

  /// Returns the texture's contents as an [Image].
  Image asImage();
}

/// Handle to a GPU buffer holding vertex, index, instance or uniform data.
abstract interface class GpuBuffer() {
  /// The size of the buffer in bytes.
  int get sizeInBytes;

  /// Uploads [data] into the buffer starting at [destinationOffsetInBytes].
  void write(ByteData data, {int destinationOffsetInBytes = 0});
}

/// A uniform or sampler slot within a [GpuShader].
///
/// Uniform blocks report a non-null [sizeInBytes] while samplers report `null`.
///
/// A backend returns the same object for the same slot of the same shader, so
/// a slot can be used as a map key.
abstract interface class GpuUniformSlot() {
  /// The name of the slot in the shader source.
  String get name;

  /// Size of the uniform block in bytes, or `null` when this slot is a
  /// sampler.
  int? get sizeInBytes;

  /// Byte offset of [member] within the uniform block, or `null` when the
  /// member does not exist.
  int? getMemberOffsetInBytes(String member);
}

/// A vertex input (`in` variable) of a vertex shader, as reflected from the
/// compiled shader.
class const GpuShaderInput({
  /// The name of the input in the shader source.
  required final String name,

  /// The input location assigned by the shader compiler.
  required final int location,

  /// The number of 32-bit components of the input, from 1 to 4.
  required final int components,
});

/// Handle to a compiled shader stage.
///
/// A backend returns the same object for the same entry point of the same
/// shader library, so a shader can be used as a map key.
abstract interface class GpuShader() {
  /// Looks up the uniform or sampler slot named [slot].
  GpuUniformSlot getUniformSlot(String slot);

  /// The vertex inputs of this shader, ordered by location, or `null` when the
  /// backend cannot reflect them.
  ///
  /// Fragment shaders report an empty list.
  List<GpuShaderInput>? get inputs;
}

/// A collection of compiled shaders loaded from a single asset bundle.
abstract interface class GpuShaderLibrary() {
  /// Retrieves the shader registered under [entryPoint].
  GpuShader operator [](String entryPoint);
}

/// Handle to a compiled render pipeline: a vertex and fragment shader linked
/// for one [GpuVertexLayout].
abstract interface class GpuPipeline();

/// A single 32-bit float vertex attribute of a [GpuVertexBufferLayout].
class const GpuVertexAttribute({
  /// The name of the vertex shader input this attribute feeds.
  required final String name,

  /// The location of the vertex shader input this attribute feeds.
  ///
  /// Backends that bind attributes by name may ignore it.
  required final int location,

  /// The number of 32-bit float components, from 1 to 4.
  required final int components,

  /// The byte offset of the attribute within one element of the buffer.
  required final int offsetInBytes,
});

/// One vertex buffer slot of a [GpuVertexLayout].
class const GpuVertexBufferLayout({
  /// The distance in bytes between two consecutive elements.
  required final int strideInBytes,

  /// The attributes read from each element.
  required final List<GpuVertexAttribute> attributes,

  /// Whether the buffer advances once per instance instead of once per
  /// vertex.
  final bool perInstance = false,
});

/// The vertex input layout of a [GpuPipeline]: the buffer bound at slot `i` is
/// described by `buffers[i]`.
class const GpuVertexLayout(
  /// The vertex buffer slots, in binding order.
  final List<GpuVertexBufferLayout> buffers,
);

/// Handle to a render target: the color, depth and (optional) multisample
/// attachments a render pass draws into.
abstract interface class GpuRenderTarget() {
  /// The width of the render target in pixels.
  int get width;

  /// The height of the render target in pixels.
  int get height;
}

/// A render target whose passes render into one color [texture] that later
/// passes of the same device sample, such as a shadow map, with a depth
/// attachment of its own.
///
/// Flutter never draws its texture: end its passes with
/// [GpuRenderPass.commit]. Each pass clears the texture and the depth first,
/// and the passes of a device run on the GPU in the order they are
/// committed or submitted, so a pass that samples the texture sees what the
/// last pass committed before it rendered.
abstract interface class GpuTextureTarget() implements GpuRenderTarget {
  /// The texture the passes render into, to bind to the samplers of later
  /// passes.
  GpuTexture get texture;

  /// The format of [texture].
  GpuPixelFormat get format;
}
