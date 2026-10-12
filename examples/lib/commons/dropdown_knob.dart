import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';

extension DropdownKnobBuilder on KnobsBuilder {
  /// Adds a dropdown to the knobs panel like `object.dropdown`, which can
  /// also be disabled.
  T dropdown<T>({
    required String label,
    required List<T> options,
    required LabelBuilder<T> labelBuilder,
    T? initialOption,
    bool enabled = true,
  }) {
    final initialValue = initialOption ?? options.first;
    return onKnobAdded(
          DropdownKnob<T>(
            label: label,
            initialValue: initialValue,
            options: options,
            labelBuilder: labelBuilder,
            enabled: enabled,
          ),
        ) ??
        initialValue;
  }
}

/// A dropdown knob that can be disabled, since Widgetbook's one can't.
class DropdownKnob<T>({
  required super.label,
  required T super.initialValue,
  required final List<T> options,
  required final LabelBuilder<T> labelBuilder,
  final bool enabled = true,
}) extends Knob<T?> {
  @override
  List<Field> get fields => [
    _DropdownField<T>(
      name: label,
      values: options,
      initialValue: initialValue,
      labelBuilder: labelBuilder,
      enabled: enabled,
    ),
  ];

  @override
  T? valueFromQueryGroup(Map<String, String> group) {
    return valueOf(label, group);
  }
}

class _DropdownField<T>({
  required super.name,
  required super.values,
  required super.initialValue,
  required super.labelBuilder,
  required final bool enabled,
}) extends ObjectDropdownField<T> {
  @override
  Widget toWidget(BuildContext context, String group, T? value) {
    return DropdownMenu<T>(
      enabled: enabled,
      expandedInsets: EdgeInsets.zero,
      trailingIcon: const Icon(Icons.keyboard_arrow_down_rounded),
      selectedTrailingIcon: const Icon(Icons.keyboard_arrow_up_rounded),
      initialSelection: value,
      onSelected: (value) {
        if (value != null) {
          updateField(context, group, value);
        }
      },
      dropdownMenuEntries: [
        for (final value in values)
          DropdownMenuEntry(value: value, label: labelBuilder(value)),
      ],
    );
  }
}
