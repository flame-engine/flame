import 'package:flame_studio/component_editor/widgets/property_editors/number_field.dart';
import 'package:flame_studio/component_editor/widgets/property_editors/property_section.dart';
import 'package:flame_studio/repositories/repositories.dart';
import 'package:flutter/material.dart';

/// {@template size_editor}
/// Edits a [ComponentSize]. Used by every [SizedComponent].
/// {@endtemplate}
class const SizeEditor({
  /// The current size.
  required final ComponentSize value,

  /// Called with the edited size.
  required final ValueChanged<ComponentSize> onChanged,
  super.key,
}) extends StatelessWidget {
  /// {@macro size_editor}
  this;

  @override
  Widget build(BuildContext context) {
    return PropertySection(
      title: 'Size',
      children: [
        Row(
          spacing: 12,
          children: [
            Expanded(
              child: NumberField(
                label: 'Width',
                value: value.width,
                onChanged: (width) => onChanged(value.copyWith(width: width)),
              ),
            ),
            Expanded(
              child: NumberField(
                label: 'Height',
                value: value.height,
                onChanged: (height) =>
                    onChanged(value.copyWith(height: height)),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
