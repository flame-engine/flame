import 'package:flame_studio/component_editor/widgets/property_editors/color_field.dart';
import 'package:flame_studio/component_editor/widgets/property_editors/enum_field.dart';
import 'package:flame_studio/component_editor/widgets/property_editors/property_section.dart';
import 'package:flame_studio/repositories/repositories.dart';
import 'package:flutter/material.dart';

/// {@template paint_editor}
/// Edits a [ComponentPaint]. Used by every [PaintedComponent].
///
/// Its color is picked by hand or from the [palette].
/// {@endtemplate}
class const PaintEditor({
  /// The current paint.
  required final ComponentPaint value,

  /// Called with the edited paint.
  required final ValueChanged<ComponentPaint> onChanged,

  /// The palette of the project.
  final Palette palette = const Palette(),
  super.key,
}) extends StatelessWidget {
  /// {@macro paint_editor}
  this;

  @override
  Widget build(BuildContext context) {
    return PropertySection(
      title: 'Paint',
      children: [
        ColorField(
          label: 'Color',
          value: value.color,
          palette: palette,
          paletteColor: value.paletteColor,
          onChanged: (color) => onChanged(value.withColor(color)),
          onPaletteColorSelected: (name) => onChanged(
            value.withPaletteColor(name, palette.colorOf(name) ?? value.color),
          ),
        ),
        EnumField<PaintStyle>(
          label: 'Style',
          values: PaintStyle.values,
          value: value.style,
          labelOf: (style) => switch (style) {
            PaintStyle.fill => 'Fill',
            PaintStyle.stroke => 'Stroke',
          },
          onChanged: (style) => onChanged(value.copyWith(style: style)),
        ),
      ],
    );
  }
}
