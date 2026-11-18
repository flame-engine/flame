/// A compiled vertex + fragment WGSL pair with its binding reflection.
class const WebShaderBundle({
  /// The vertex stage WGSL source.
  required final String vertex,

  /// The fragment stage WGSL source.
  required final String fragment,

  /// Binding reflection, keyed by uniform block or texture slot name.
  required final Map<String, WebShaderSlot> slots,

  /// The vertex stage inputs, or `null` for bundles built before inputs were
  /// recorded.
  final List<WebShaderInput>? inputs,
}) {
  /// Decodes a bundle from its `.wgslbundle` JSON representation.
  factory WebShaderBundle.fromJson(Map<String, dynamic> json) {
    final inputs = json['inputs'] as List?;
    return WebShaderBundle(
      vertex: json['vertex'] as String,
      fragment: json['fragment'] as String,
      slots: {
        for (final entry in (json['slots'] as Map).entries)
          entry.key as String: WebShaderSlot.fromJson(
            entry.value as Map<String, dynamic>,
          ),
      },
      inputs: inputs == null
          ? null
          : [
              for (final input in inputs)
                WebShaderInput.fromJson(input as Map<String, dynamic>),
            ],
    );
  }
}

/// A vertex input of a [WebShaderBundle]'s vertex stage.
class const WebShaderInput({
  /// The name of the input in the GLSL source.
  required final String name,

  /// The `@location` of the input.
  required final int location,

  /// The number of float components of the input.
  required final int components,
}) {
  /// Decodes an input from its `.wgslbundle` JSON representation.
  factory WebShaderInput.fromJson(Map<String, dynamic> json) {
    return WebShaderInput(
      name: json['name'] as String,
      location: json['location'] as int,
      components: json['components'] as int,
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
