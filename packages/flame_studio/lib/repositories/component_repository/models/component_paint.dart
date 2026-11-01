import 'package:equatable/equatable.dart';
import 'package:flame_studio/repositories/repositories.dart';

/// {@template component_paint}
/// The paint property shared by every component that draws with a paint.
///
/// Its color is either picked by hand or a [paletteColor] of the project's
/// [Palette], in which case [color] keeps its last known value, used when
/// the palette doesn't have it.
/// {@endtemplate}
class const ComponentPaint({
  /// The color as a 32 bit ARGB value.
  ///
  /// When [paletteColor] is set, the value it had when it was last picked.
  final int color = defaultColor,

  /// Whether the shape is filled or stroked.
  final PaintStyle style = PaintStyle.fill,

  /// The name of the [Palette] color this paint uses, or `null` when its
  /// [color] was picked by hand.
  final String? paletteColor,
}) extends Equatable {
  /// {@macro component_paint}
  this;

  /// Creates a [ComponentPaint] from its JSON representation.
  ///
  /// Missing or invalid values fall back to their defaults.
  factory fromJson(Object? json) {
    final map = json is Map ? json : const <String, dynamic>{};
    final color = map['color'];
    final paletteColor = map['paletteColor'];
    return ComponentPaint(
      color: color is int ? color : defaultColor,
      style: PaintStyle.fromName(map['style']) ?? PaintStyle.fill,
      paletteColor: paletteColor is String ? paletteColor : null,
    );
  }

  /// The default [color]: opaque white.
  static const defaultColor = 0xFFFFFFFF;

  /// The color to draw with: the [paletteColor] in [palette], or [color]
  /// when there is none.
  int resolvedColor(Palette palette) => palette.colorOf(paletteColor) ?? color;

  /// Returns a copy of this paint with the given fields replaced.
  ComponentPaint copyWith({int? color, PaintStyle? style}) {
    return ComponentPaint(
      color: color ?? this.color,
      style: style ?? this.style,
      paletteColor: paletteColor,
    );
  }

  /// Returns a copy of this paint with [color] picked by hand, which no
  /// longer uses a palette color.
  ComponentPaint withColor(int color) {
    return ComponentPaint(color: color, style: style);
  }

  /// Returns a copy of this paint that uses the palette color called
  /// [name], whose current value is [color].
  ComponentPaint withPaletteColor(String name, int color) {
    return ComponentPaint(color: color, style: style, paletteColor: name);
  }

  /// Converts this paint to its JSON representation.
  Map<String, dynamic> toJson() => {
    'color': color,
    'style': style.name,
    'paletteColor': ?paletteColor,
  };

  @override
  List<Object?> get props => [color, style, paletteColor];
}
