import 'package:flame_studio/component_editor/widgets/property_editors/number_field.dart';
import 'package:flame_studio/component_editor/widgets/property_editors/property_section.dart';
import 'package:flame_studio/repositories/repositories.dart';
import 'package:flutter/material.dart';

/// {@template anchor_editor}
/// Edits a [ComponentAnchor]. Used by every [AnchoredComponent] inside
/// another component.
///
/// A 3x3 grid picks one of Flame's named anchors, and the X and Y fields
/// set a custom one.
/// {@endtemplate}
class const AnchorEditor({
  /// The current anchor.
  required final ComponentAnchor value,

  /// Called with the edited anchor.
  required final ValueChanged<ComponentAnchor> onChanged,
  super.key,
}) extends StatelessWidget {
  /// {@macro anchor_editor}
  this;

  @override
  Widget build(BuildContext context) {
    final presets = ComponentAnchor.presets.entries.toList();
    return PropertySection(
      title: 'Anchor',
      children: [
        Row(
          spacing: 12,
          children: [
            Column(
              children: [
                for (var row = 0; row < 3; row++)
                  Row(
                    children: [
                      for (final MapEntry(key: name, value: preset)
                          in presets.skip(row * 3).take(3))
                        _PresetButton(
                          name: name,
                          isSelected: preset == value,
                          onPressed: () => onChanged(preset),
                        ),
                    ],
                  ),
              ],
            ),
            Expanded(
              child: Column(
                spacing: 12,
                children: [
                  NumberField(
                    label: 'X',
                    value: value.x,
                    min: null,
                    onChanged: (x) => onChanged(value.copyWith(x: x)),
                  ),
                  NumberField(
                    label: 'Y',
                    value: value.y,
                    min: null,
                    onChanged: (y) => onChanged(value.copyWith(y: y)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class const _PresetButton({
  required final String name,
  required final bool isSelected,
  required final VoidCallback onPressed,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: name,
      isSelected: isSelected,
      visualDensity: VisualDensity.compact,
      iconSize: 16,
      icon: const Icon(Icons.circle_outlined),
      selectedIcon: const Icon(Icons.circle),
      onPressed: onPressed,
    );
  }
}
