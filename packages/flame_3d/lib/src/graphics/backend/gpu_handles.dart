import 'dart:typed_data';
import 'dart:ui';

/// Handle to a GPU texture.
abstract interface class GpuTexture {
  /// Uploads [data] to the texture.
  void write(ByteData data);

  /// Returns the texture's contents as an [Image].
  Image asImage();
}

/// Handle to a GPU buffer holding vertex/index data.
abstract interface class GpuBuffer {
  /// Uploads [data] into the buffer starting at [destinationOffsetInBytes].
  void write(ByteData data, {int destinationOffsetInBytes = 0});
}

/// A windowed view over a region of a [GpuBuffer].
class GpuBufferView {
  /// Creates a view over [buffer] spanning [lengthInBytes] bytes starting at
  /// [offsetInBytes].
  const GpuBufferView(
    this.buffer, {
    required this.offsetInBytes,
    required this.lengthInBytes,
  });

  /// The buffer this view refers into.
  final GpuBuffer buffer;

  /// Byte offset of the view within [buffer].
  final int offsetInBytes;

  /// Length of the view in bytes.
  final int lengthInBytes;
}

/// A uniform or sampler slot within a [GpuShader].
///
/// Uniform blocks report a non-null [sizeInBytes] while samplers report `null`.
abstract interface class GpuUniformSlot {
  /// Size of the uniform block in bytes, or `null` when this slot is a
  /// sampler.
  int? get sizeInBytes;

  /// Byte offset of [member] within the uniform block, or `null` when the
  /// member does not exist.
  int? getMemberOffsetInBytes(String member);
}

/// Handle to a compiled shader stage.
abstract interface class GpuShader {
  /// Looks up the uniform or sampler slot named [slot].
  GpuUniformSlot getUniformSlot(String slot);
}

/// A collection of compiled shaders loaded from a single asset bundle.
abstract interface class GpuShaderLibrary {
  /// Retrieves the shader registered under [entryPoint].
  GpuShader operator [](String entryPoint);
}

/// Handle to a compiled render pipeline.
abstract interface class GpuPipeline {}

/// Handle to a render target.
abstract interface class GpuRenderTarget {
  /// The color attachment's texture, holding the rendered output.
  GpuTexture get colorTexture;
}
