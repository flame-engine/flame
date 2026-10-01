/// A compiled vertex + fragment WGSL pair with its binding reflection.
class const WebShaderBundle({
  /// The vertex stage WGSL source.
  required final String vertex,

  /// The fragment stage WGSL source.
  required final String fragment,

  /// Binding reflection, keyed by uniform block or texture slot name.
  required final Map<String, WebShaderSlot> slots,
}) {
  /// Decodes a bundle from its `.wgslbundle` JSON representation.
  factory WebShaderBundle.fromJson(Map<String, dynamic> json) {
    return WebShaderBundle(
      vertex: json['vertex'] as String,
      fragment: json['fragment'] as String,
      slots: {
        for (final entry in (json['slots'] as Map).entries)
          entry.key as String: WebShaderSlot.fromJson(
            entry.value as Map<String, dynamic>,
          ),
      },
    );
  }
}

/// Reflection for one uniform block or texture slot of a [WebShaderBundle].
class const WebShaderSlot({
  /// The `@group` the slot is bound to.
  required final int group,

  /// The `@binding` the slot is bound to.
  required final int binding,

  /// Size of the uniform block in bytes, or `null` for a texture slot.
  final int? sizeInBytes,

  /// The companion sampler's `@binding` for a texture slot, else `null`.
  final int? samplerBinding,

  /// Byte offset of each member within a uniform block.
  final Map<String, int> memberOffsets = const {},
}) {
  /// Decodes a slot from its `.wgslbundle` JSON representation.
  factory WebShaderSlot.fromJson(Map<String, dynamic> json) {
    return WebShaderSlot(
      group: json['group'] as int,
      binding: json['binding'] as int,
      sizeInBytes: json['sizeInBytes'] as int?,
      samplerBinding: json['samplerBinding'] as int?,
      memberOffsets: {
        for (final entry
            in ((json['memberOffsets'] as Map?) ?? const {}).entries)
          entry.key as String: entry.value as int,
      },
    );
  }
}
