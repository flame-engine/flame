import 'package:flame_3d/src/parser/gltf/gltf_node.dart';
import 'package:flame_3d/src/parser/gltf/gltf_root.dart';
import 'package:flame_3d/src/parser/gltf/mag_filter.dart';
import 'package:flame_3d/src/parser/gltf/min_filter.dart';
import 'package:flame_3d/src/parser/gltf/wrap_mode.dart';

/// Texture sampler properties for filtering and wrapping modes.
class Sampler extends GltfNode {
  /// Magnification filter.
  final MagFilter magFilter;

  /// Minification filter.
  final MinFilter minFilter;

  /// The wrap mode for the s coordinate.
  final WrapMode wrapS;

  /// The wrap mode for the t coordinate.
  final WrapMode wrapT;

  Sampler({
    required super.root,
    required this.magFilter,
    required this.minFilter,
    required this.wrapS,
    required this.wrapT,
  });

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
