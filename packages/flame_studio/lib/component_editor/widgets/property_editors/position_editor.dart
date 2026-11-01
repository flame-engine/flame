import 'package:flame_studio/component_editor/widgets/property_editors/number_field.dart';
import 'package:flame_studio/component_editor/widgets/property_editors/property_section.dart';
import 'package:flame_studio/repositories/repositories.dart';
import 'package:flutter/material.dart';

/// {@template position_editor}
/// Edits a [ComponentPosition]. Used by every [PositionedComponent] inside
/// another component.
/// {@endtemplate}
class const PositionEditor({
  /// The current position.
  required final ComponentPosition value,

  /// Called with the edited position.
  required final ValueChanged<ComponentPosition> onChanged,
  super.key,
}) extends StatelessWidget {
  /// {@macro position_editor}
  this;

  @override
  Widget build(BuildContext context) {
    return PropertySection(
      title: 'Position',
      children: [
        Row(
          spacing: 12,
          children: [
            Expanded(
              child: NumberField(
                label: 'X',
                value: value.x,
                min: null,
                onChanged: (x) => onChanged(value.copyWith(x: x)),
              ),
            ),
            Expanded(
              child: NumberField(
                label: 'Y',
                value: value.y,
                min: null,
                onChanged: (y) => onChanged(value.copyWith(y: y)),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
