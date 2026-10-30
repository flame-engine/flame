import 'package:flame_studio/component_editor/widgets/property_editors/number_field.dart';
import 'package:flame_studio/component_editor/widgets/property_editors/property_section.dart';
import 'package:flame_studio/repositories/repositories.dart';
import 'package:flutter/material.dart';

/// {@template angle_editor}
/// Edits a [ComponentAngle], in degrees. Used by every [RotatedComponent]
/// inside another component.
/// {@endtemplate}
class const AngleEditor({
  /// The current angle.
  required final ComponentAngle value,

  /// Called with the edited angle.
  required final ValueChanged<ComponentAngle> onChanged,
  super.key,
}) extends StatelessWidget {
  /// {@macro angle_editor}
  this;

  @override
  Widget build(BuildContext context) {
    return PropertySection(
      title: 'Angle',
      children: [
        NumberField(
          label: 'Degrees',
          // Rounded, so that converting the typed degrees to radians and
          // back gives the same number, and the field keeps the user input.
          value: double.parse(value.degrees.toStringAsFixed(6)),
          min: null,
          onChanged: (degrees) =>
              onChanged(ComponentAngle.fromDegrees(degrees)),
        ),
      ],
    );
  }
}
