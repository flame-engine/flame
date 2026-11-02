import 'package:flame_studio/repositories/repositories.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';

/// {@template color_field}
/// Shows a color swatch and its hex code; tapping it opens a color picker.
///
/// When [onPaletteColorSelected] is given and the [palette] has colors, a
/// button next to it lists them, so a palette color can be picked instead.
/// A [paletteColor] in use is shown by name.
///
/// Colors are 32 bit ARGB values.
/// {@endtemplate}
class const ColorField({
  /// The field label.
  required final String label,

  /// The current color, as a 32 bit ARGB value.
  ///
  /// When [paletteColor] is in the [palette], its value is shown instead.
  required final int value,

  /// Called with the color the user picked by hand.
  required final ValueChanged<int> onChanged,

  /// The colors that can be picked by name.
  final Palette palette = const Palette(),

  /// The name of the [palette] color in use, if any.
  final String? paletteColor,

  /// Called with the name of the [palette] color the user picked.
  final ValueChanged<String>? onPaletteColorSelected,
  super.key,
}) extends StatelessWidget {
  /// {@macro color_field}
  this;

  int get _color => palette.colorOf(paletteColor) ?? value;

  Future<void> _pick(BuildContext context) async {
    final color = await showColorPickerDialog(
      context,
      Color(_color),
      title: Text(label),
      pickersEnabled: const {
        ColorPickerType.primary: true,
        ColorPickerType.accent: false,
        ColorPickerType.wheel: true,
      },
      enableOpacity: true,
      showColorCode: true,
      colorCodeHasColor: true,
      constraints: const BoxConstraints(minWidth: 320, maxWidth: 320),
    );
    // A cancelled picker returns the color it opened with, so the same
    // color is no change (and keeps the palette color).
    final picked = color.toARGB32();
    if (picked != _color) {
      onChanged(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _color;
    final hex = '#${_hex(color)}';
    final name = palette.contains(paletteColor) ? paletteColor : null;
    final onPaletteColorSelected = this.onPaletteColorSelected;
    return Row(
      children: [
        Expanded(
          child: InkWell(
            onTap: () => _pick(context),
            borderRadius: BorderRadius.circular(4),
            child: InputDecorator(
              decoration: InputDecoration(labelText: label, isDense: true),
              child: Row(
                spacing: 8,
                children: [
                  ColorSwatchBox(color: color),
                  Flexible(
                    child: Text(
                      name == null ? hex : '$name · $hex',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (onPaletteColorSelected != null && palette.colors.isNotEmpty)
          MenuAnchor(
            menuChildren: [
              for (final PaletteColor(name: colorName, :color)
                  in palette.colors)
                MenuItemButton(
                  leadingIcon: ColorSwatchBox(color: color),
                  trailingIcon: colorName == name
                      ? const Icon(Icons.check, size: 18)
                      : null,
                  onPressed: () => onPaletteColorSelected(colorName),
                  child: Text(colorName),
                ),
            ],
            builder: (context, controller, _) => IconButton(
              tooltip: 'Pick from palette',
              icon: const Icon(Icons.palette_outlined),
              onPressed: () =>
                  controller.isOpen ? controller.close() : controller.open(),
            ),
          ),
      ],
    );
  }

  static String _hex(int color) =>
      color.toRadixString(16).padLeft(8, '0').toUpperCase();
}

/// {@template color_swatch_box}
/// A small rounded square filled with [color].
/// {@endtemplate}
class const ColorSwatchBox({
  /// The color, as a 32 bit ARGB value.
  required final int color,
  super.key,
}) extends StatelessWidget {
  /// {@macro color_swatch_box}
  this;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        color: Color(color),
        border: Border.all(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
