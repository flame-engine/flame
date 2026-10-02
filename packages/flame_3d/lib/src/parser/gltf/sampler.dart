import 'package:flame_3d/src/parser/gltf/gltf_node.dart';
import 'package:flame_3d/src/parser/gltf/gltf_root.dart';
import 'package:flame_3d/src/parser/gltf/mag_filter.dart';
import 'package:flame_3d/src/parser/gltf/min_filter.dart';
import 'package:flame_3d/src/parser/gltf/wrap_mode.dart';

/// Texture sampler properties for filtering and wrapping modes.
class Sampler({
  required super.root,

  /// Magnification filter.
  required final MagFilter magFilter,

  /// Minification filter.
  required final MinFilter minFilter,

  /// The wrap mode for the s coordinate.
  required final WrapMode wrapS,

  /// The wrap mode for the t coordinate.
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
}
