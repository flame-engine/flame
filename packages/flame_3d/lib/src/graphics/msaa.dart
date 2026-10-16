/// The multisample anti-aliasing configuration.
enum Msaa(final int sampleCount) {
  /// Multisample anti-aliasing is off (the per-pixel sample count is `1`).
  off(1),

  /// Multisample anti-aliasing with four samples per pixel.
  sample4(4),
}
