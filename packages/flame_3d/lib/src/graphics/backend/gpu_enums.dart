/// How a GPU resource's memory is allocated and accessed.
enum GpuStorageMode {
  /// Memory visible to the host (CPU): used for resources written from Dart.
  hostVisible,

  /// Memory private to the device (GPU): fastest for GPU-only resources.
  devicePrivate,

  /// Transient device memory whose contents need not survive a render pass.
  deviceTransient,
}

/// Pixel layout of a GPU texture.
enum GpuPixelFormat {
  /// 8 bits per channel, RGBA order.
  rgba8888,

  /// 8 bits per channel, BGRA order.
  bgra8888,

  /// 32-bit float per channel, RGBA order.
  rgbaFloat32,

  /// The backend's default depth/stencil format.
  depthStencil,
}

/// Width of the integers stored in an index buffer.
enum GpuIndexType {
  /// 16-bit unsigned indices.
  uint16,

  /// 32-bit unsigned indices.
  uint32,
}

/// Color blending mode for a render pass output.
enum BlendState {
  /// No blending, source overwrites destination.
  opaque,

  /// Standard premultiplied-alpha blending:
  /// `color = src * 1 + dst * (1 - srcAlpha)`.
  alphaBlend,

  /// Additive blending: `color = src * 1 + dst * 1`.
  additive,
}

/// Depth buffer behavior for a render pass.
enum DepthStencilState {
  /// Depth test and write enabled (normal opaque 3D rendering).
  /// Fragments closer than the stored depth pass and update the buffer.
  standard,

  /// Depth test enabled, write disabled (transparent objects).
  /// Fragments are tested against existing depth but don't update it.
  depthRead,

  /// No depth testing, all fragments pass regardless of depth.
  none,
}

/// Face culling mode. Controls which triangle faces are discarded before
/// rasterization.
enum CullMode {
  /// No culling, both front and back faces are rendered.
  none,

  /// Cull front-facing triangles (render only back faces).
  frontFace,

  /// Cull back-facing triangles (render only front faces).
  backFace,
}
