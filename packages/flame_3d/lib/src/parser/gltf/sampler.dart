import 'package:flame_3d/resources.dart' as flame_3d;
import 'package:flame_3d/src/parser/gltf/gltf_node.dart';
import 'package:flame_3d/src/parser/gltf/gltf_root.dart';
import 'package:flame_3d/src/parser/gltf/mag_filter.dart';
import 'package:flame_3d/src/parser/gltf/min_filter.dart';
import 'package:flame_3d/src/parser/gltf/wrap_mode.dart';

/// Texture sampler properties for filtering and wrapping modes.
class Sampler({
  required super.root,
  required final MagFilter magFilter,
  required final MinFilter minFilter,
  required final WrapMode wrapS,
  required final WrapMode wrapT,
}) extends GltfNode {
  Sampler.parse(
    GltfRoot root,
    Map<String, Object?> map,
  ) : this(
        root: root,
        magFilter: MagFilter.parse(map, 'magFilter') ?? MagFilter.linear,
        minFilter:
            MinFilter.parse(map, 'minFilter') ?? MinFilter.nearestMipmapLinear,
        wrapS: WrapMode.parse(map, 'wrapS') ?? WrapMode.repeat,
        wrapT: WrapMode.parse(map, 'wrapT') ?? WrapMode.repeat,
      );

  flame_3d.TextureSampler toFlameSampler() {
    final mag = switch (magFilter) {
      MagFilter.nearest => flame_3d.TextureFilter.nearest,
      MagFilter.linear => flame_3d.TextureFilter.linear,
    };
    final (min, mip) = switch (minFilter) {
      MinFilter.nearest => (
        flame_3d.TextureFilter.nearest,
        flame_3d.TextureFilter.nearest,
      ),
      MinFilter.linear => (
        flame_3d.TextureFilter.linear,
        flame_3d.TextureFilter.nearest,
      ),
      MinFilter.nearestMipmapNearest => (
        flame_3d.TextureFilter.nearest,
        flame_3d.TextureFilter.nearest,
      ),
      MinFilter.linearMipmapNearest => (
        flame_3d.TextureFilter.linear,
        flame_3d.TextureFilter.nearest,
      ),
      MinFilter.nearestMipmapLinear => (
        flame_3d.TextureFilter.nearest,
        flame_3d.TextureFilter.linear,
      ),
      MinFilter.linearMipmapLinear => (
        flame_3d.TextureFilter.linear,
        flame_3d.TextureFilter.linear,
      ),
    };
    flame_3d.TextureWrap mapWrap(WrapMode w) => switch (w) {
      WrapMode.clampToEdge => flame_3d.TextureWrap.clamp,
      WrapMode.mirroredRepeat => flame_3d.TextureWrap.mirror,
      WrapMode.repeat => flame_3d.TextureWrap.repeat,
    };
    return flame_3d.TextureSampler(
      minFilter: min,
      magFilter: mag,
      mipFilter: mip,
      wrapU: mapWrap(wrapS),
      wrapV: mapWrap(wrapT),
    );
  }
}
