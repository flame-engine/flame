import 'package:flame_3d/src/parser/gltf/gltf_node.dart';

/// The material's alpha rendering mode enumeration specifying the
/// interpretation of the alpha value of the base color.
enum AlphaMode {
  /// The alpha value is ignored, and the rendered output is fully opaque.
  opaque('OPAQUE'),

  /// The rendered output is either fully opaque or fully transparent depending
  /// on the alpha value and the specified `alphaCutoff` value;
  /// the exact appearance of the edges **MAY** be subject to
  /// implementation-specific techniques such as "Alpha-to-Coverage"
  mask('MASK'),

  /// The alpha value is used to composite the source and destination areas.
  /// The rendered output is combined with the background using the normal
  /// painting operation (i.e. the Porter and Duff over operator).
  blend('BLEND');

  final String value;

  const AlphaMode(this.value);

  static AlphaMode valueOf(String value) {
    return values.firstWhere((e) => e.value == value);
  }

  static AlphaMode? parse(Map<String, Object?> map, String key) {
    return Parser.stringEnum(map, key, valueOf);
  }
}
