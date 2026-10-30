import 'package:flutter/material.dart';

/// {@template enum_field}
/// Picks one of [values] with a segmented button.
/// {@endtemplate}
class const EnumField<T extends Enum>({
  /// The field label.
  required final String label,

  /// The values to choose from.
  required final List<T> values,

  /// The selected value.
  required final T value,

  /// Returns the text shown for a value.
  required final String Function(T value) labelOf,

  /// Called with the value the user picked.
  required final ValueChanged<T> onChanged,
  super.key,
}) extends StatelessWidget {
  /// {@macro enum_field}
  this;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 4,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodySmall),
        SegmentedButton<T>(
          showSelectedIcon: false,
          segments: [
            for (final value in values)
              ButtonSegment(value: value, label: Text(labelOf(value))),
          ],
          selected: {value},
          onSelectionChanged: (selection) => onChanged(selection.single),
        ),
      ],
    );
  }
}
