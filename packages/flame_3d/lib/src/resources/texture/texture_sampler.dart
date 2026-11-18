import 'package:meta/meta.dart';

/// How a texture is filtered when it is sampled between texels, or between
/// mip levels.
enum TextureFilter() {
  /// The nearest texel (or mip level): crisp, blocky pixels.
  nearest,

  /// A linear blend of the nearest texels (or of the two nearest mip levels).
  linear,
}

/// How texture coordinates outside `[0, 1]` map onto a texture.
enum TextureWrap() {
  /// Coordinates are clamped, repeating the edge texels.
  clamp,

  /// The texture tiles.
  repeat,

  /// The texture tiles, mirrored at every whole coordinate.
  mirror,
}

/// {@template texture_sampler}
/// How a texture is sampled: its filtering when magnified ([magFilter]),
/// minified ([minFilter]) and between mip levels ([mipFilter], for textures
/// that have mipmaps), and how coordinates outside `[0, 1]` wrap ([wrapU]
/// horizontally and [wrapV] vertically).
///
/// Samplers are values: the GPU backends create one sampler object per
/// distinct value and reuse it for every bind.
/// {@endtemplate}
@immutable
class const TextureSampler({
  /// The filter used where the texture is drawn smaller than its size.
  final TextureFilter minFilter = TextureFilter.nearest,

  /// The filter used where the texture is drawn larger than its size.
  final TextureFilter magFilter = TextureFilter.nearest,

  /// The filter between mip levels, for textures that have mipmaps.
  final TextureFilter mipFilter = TextureFilter.nearest,

  /// How horizontal texture coordinates outside `[0, 1]` wrap.
  final TextureWrap wrapU = TextureWrap.clamp,

  /// How vertical texture coordinates outside `[0, 1]` wrap.
  final TextureWrap wrapV = TextureWrap.clamp,
}) {
  /// {@macro texture_sampler}
  ///
  /// Uses the same [filter] for magnification, minification and mip levels,
  /// and the same [wrap] in both directions.
  const TextureSampler.all({
    TextureFilter filter = TextureFilter.nearest,
    TextureWrap wrap = TextureWrap.clamp,
  }) : this(
         minFilter: filter,
         magFilter: filter,
         mipFilter: filter,
         wrapU: wrap,
         wrapV: wrap,
       );

  /// Nearest filtering, clamped coordinates: the default.
  static const TextureSampler nearest = TextureSampler();

  /// Linear filtering (trilinear for textures with mipmaps), clamped
  /// coordinates.
  static const TextureSampler linear = TextureSampler.all(
    filter: TextureFilter.linear,
  );

  /// The number of distinct samplers, see [key].
  static const int keyCount = 128;

  /// A number from `0` to [keyCount] (excluded) identifying this sampler's
  /// options, used by the GPU backends to look up their sampler objects.
  int get key =>
      minFilter.index |
      magFilter.index << 1 |
      mipFilter.index << 2 |
      wrapU.index << 3 |
      wrapV.index << 5;

  /// A copy of this sampler with the given options changed.
  TextureSampler copyWith({
    TextureFilter? minFilter,
    TextureFilter? magFilter,
    TextureFilter? mipFilter,
    TextureWrap? wrapU,
    TextureWrap? wrapV,
  }) {
    return TextureSampler(
      minFilter: minFilter ?? this.minFilter,
      magFilter: magFilter ?? this.magFilter,
      mipFilter: mipFilter ?? this.mipFilter,
      wrapU: wrapU ?? this.wrapU,
      wrapV: wrapV ?? this.wrapV,
    );
  }

  @override
  bool operator ==(Object other) => other is TextureSampler && other.key == key;

  @override
  int get hashCode => key;

  @override
  String toString() =>
      'TextureSampler(min: ${minFilter.name}, mag: ${magFilter.name}, '
      'mip: ${mipFilter.name}, wrapU: ${wrapU.name}, wrapV: ${wrapV.name})';
}
