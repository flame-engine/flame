/// How a GPU resource's memory is allocated and accessed.
enum GpuStorageMode() {
  /// Memory visible to the host (CPU): used for resources written from Dart.
  hostVisible,

  /// Memory private to the device (GPU): fastest for GPU-only resources.
  devicePrivate,

  /// Transient device memory whose contents need not survive a render pass.
  deviceTransient,
}

/// Pixel layout of a GPU texture.
enum GpuPixelFormat() {
  /// 8 bits per channel, RGBA order.
  rgba8888,

  /// 8 bits per channel, BGRA order.
  bgra8888,

  /// 32-bit float per channel, RGBA order.
  rgbaFloat32,

  /// A single 32-bit float channel (red), for instance depth written by a
  /// shader into a texture that later passes sample.
  r32Float,

  /// The backend's default depth/stencil format.
  depthStencil,
}

/// Width of the integers stored in an index buffer.
enum GpuIndexType(
  /// The size of a single index, in bytes.
  final int bytesPerIndex,
) {
  /// 16-bit unsigned indices.
  uint16(2),

  /// 32-bit unsigned indices.
  uint32(4),
}

/// How the color a draw outputs is combined with the color already in the
/// render target.
///
/// `src` is the fragment's output, `dst` the color in the render target.
enum BlendState() {
  /// No blending, the source overwrites the destination.
  opaque,

  /// Straight (non-premultiplied) alpha blending:
  /// `color = src * srcAlpha + dst * (1 - srcAlpha)`,
  /// `alpha = srcAlpha + dstAlpha * (1 - srcAlpha)`.
  alpha,

  /// Premultiplied alpha blending, for colors already multiplied by their
  /// alpha: `color = src + dst * (1 - srcAlpha)`.
  premultipliedAlpha,

  /// Additive blending: `color = src + dst`, `alpha = dstAlpha`.
  ///
  /// Added light covers nothing, so the alpha of the target is kept: where
  /// the target is transparent (a scene rendered into an image that is then
  /// drawn over 2D content, as `Scene3DComponent` does), the color is added
  /// to whatever is drawn behind the image.
  additive,

  /// No color is written: `color = dst`, `alpha = dstAlpha`.
  ///
  /// With depth writes on, a draw only fills the depth buffer: a depth
  /// prepass. Drawn right before the same object with a translucent material
  /// whose depth test passes on equal depths ([CompareFunction.lessEqual]),
  /// it leaves only the object's nearest surfaces to blend, so that the
  /// object fades as one piece instead of showing its own hidden parts.
  depthOnly,
}

/// A comparison between an incoming value and a stored one, used for the
/// depth test.
///
/// A fragment passes when `incoming <op> stored` holds.
enum CompareFunction() {
  /// The comparison never passes.
  never,

  /// Passes when the incoming value is less than the stored one.
  less,

  /// Passes when both values are equal.
  equal,

  /// Passes when the incoming value is less than or equal to the stored one.
  lessEqual,

  /// Passes when the incoming value is greater than the stored one.
  greater,

  /// Passes when both values differ.
  notEqual,

  /// Passes when the incoming value is greater than or equal to the stored
  /// one.
  greaterEqual,

  /// The comparison always passes.
  always,
}

/// Face culling mode. Controls which triangle faces are discarded before
/// rasterization.
enum CullMode() {
  /// No culling, both front and back faces are rendered.
  none,

  /// Cull front-facing triangles (render only back faces).
  frontFace,

  /// Cull back-facing triangles (render only front faces).
  backFace,
}

/// The vertex order, as seen on screen, that makes a triangle front-facing.
enum WindingOrder() {
  /// Triangles whose vertices appear clockwise on screen are front-facing.
  clockwise,

  /// Triangles whose vertices appear counter-clockwise on screen are
  /// front-facing.
  counterClockwise,
}
