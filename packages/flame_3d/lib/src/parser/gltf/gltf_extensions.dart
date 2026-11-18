import 'dart:math' as math;
import 'dart:ui' show Color;

import 'package:flame_3d/core.dart';
import 'package:flame_3d/src/parser/gltf/gltf_node.dart';

/// Parsed `KHR_texture_transform` extension payload on a glTF `TextureInfo`.
class KhrTextureTransform({
  required final Vector2 offset,
  required final Vector2 scale,
  final double rotation = 0.0,
  final int? texCoord,
}) {
  KhrTextureTransform.parse(Map<String, Object?> map)
    : this(
        offset: _parseVec2(map, 'offset', defaultValue: 0.0),
        scale: _parseVec2(map, 'scale', defaultValue: 1.0),
        rotation: Parser.float(map, 'rotation') ?? 0.0,
        texCoord: Parser.integer(map, 'texCoord'),
      );

  static Vector2 _parseVec2(
    Map<String, Object?> map,
    String key, {
    required double defaultValue,
  }) {
    final values = Parser.floatList(map, key);
    if (values != null && values.length >= 2) {
      return Vector2(values[0], values[1]);
    }
    return Vector2.all(defaultValue);
  }
}

/// Punctual light kind defined by the `KHR_lights_punctual` glTF 2.0 extension.
enum KhrPunctualLightType(final String value) {
  directional('directional'),
  point('point'),
  spot('spot');

  static KhrPunctualLightType valueOf(String value) {
    return values.firstWhere(
      (e) => e.value == value,
      orElse: () => throw FormatException('Unknown punctual light type $value'),
    );
  }
}

/// Light definition inside top-level `extensions.KHR_lights_punctual.lights`.
class KhrPunctualLight({
  required final KhrPunctualLightType type,
  final String? name,
  final Color color = const Color(0xFFFFFFFF),
  final double intensity = 1.0,
  final double? range,
  final double innerConeAngle = 0.0,
  final double outerConeAngle = math.pi / 4.0,
}) {
  KhrPunctualLight.parse(Map<String, Object?> map)
    : this(
        name: Parser.string(map, 'name'),
        type: KhrPunctualLightType.valueOf(Parser.string(map, 'type')!),
        color: _parseRgbColor(map),
        intensity: Parser.float(map, 'intensity') ?? 1.0,
        range: _parsePositiveRange(map),
        innerConeAngle: _parseSpotAngle(map, 'innerConeAngle', 0.0),
        outerConeAngle: _parseSpotAngle(map, 'outerConeAngle', math.pi / 4.0),
      );

  static Color _parseRgbColor(Map<String, Object?> map) {
    final rgb = Parser.floatList(map, 'color');
    if (rgb == null || rgb.length < 3) {
      return const Color(0xFFFFFFFF);
    }
    return Color.fromARGB(
      255,
      (rgb[0].clamp(0.0, 1.0) * 255).round(),
      (rgb[1].clamp(0.0, 1.0) * 255).round(),
      (rgb[2].clamp(0.0, 1.0) * 255).round(),
    );
  }

  static double? _parsePositiveRange(Map<String, Object?> map) {
    final r = Parser.float(map, 'range');
    return r != null && r > 0.0 ? r : null;
  }

  static double _parseSpotAngle(
    Map<String, Object?> map,
    String key,
    double fallback,
  ) {
    final spot = map['spot'];
    if (spot is Map<String, Object?>) {
      return Parser.float(spot, key) ?? fallback;
    }
    return fallback;
  }

  /// Parses `extensions.KHR_lights_punctual.lights` from a root `extensions`
  /// map.
  static List<KhrPunctualLight> parseRootLights(
    Map<String, Object?>? extensions,
  ) {
    final ext = extensions?['KHR_lights_punctual'];
    if (ext is! Map<String, Object?>) {
      return const [];
    }
    final rawLights = ext['lights'];
    if (rawLights is! List<Object?> || rawLights.isEmpty) {
      return const [];
    }
    return List<KhrPunctualLight>.unmodifiable([
      for (final entry in rawLights)
        if (entry is Map<String, Object?>) KhrPunctualLight.parse(entry),
    ]);
  }
}
