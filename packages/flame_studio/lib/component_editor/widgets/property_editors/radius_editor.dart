import 'package:flame_studio/component_editor/widgets/property_editors/number_field.dart';
import 'package:flame_studio/component_editor/widgets/property_editors/property_section.dart';
import 'package:flame_studio/repositories/repositories.dart';
import 'package:flutter/material.dart';

/// {@template radius_editor}
/// Edits a [ComponentRadius]. Used by every [RadiusComponent].
/// {@endtemplate}
class const RadiusEditor({
  /// The current radius.
  required final ComponentRadius value,

  /// Called with the edited radius.
  required final ValueChanged<ComponentRadius> onChanged,
  super.key,
}) extends StatelessWidget {
  /// {@macro radius_editor}
  this;

  @override
  Widget build(BuildContext context) {
    return PropertySection(
      title: 'Radius',
      children: [
        NumberField(
          label: 'Radius',
          value: value.radius,
          onChanged: (radius) => onChanged(value.copyWith(radius: radius)),
        ),
      ],
    );
  }
}
