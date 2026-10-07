import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';

extension ButtonKnobBuilder on KnobsBuilder {
  /// Adds a button to the knobs panel, and returns how many times it has been
  /// pressed, so that a use case can react to presses by comparing the count
  /// with the previous one.
  int button({required String label, bool enabled = true}) {
    return onKnobAdded(ButtonKnob(label: label, enabled: enabled)) ?? 0;
  }
}

/// A knob that shows a button instead of a value, since Widgetbook doesn't
/// provide one. Its value is the number of times the button was pressed.
class ButtonKnob({
  required super.label,
  final bool enabled = true,
}) extends Knob<int?> {
  this : super(initialValue: 0);

  @override
  List<Field> get fields => [_ButtonField(name: label, enabled: enabled)];

  @override
  int? valueFromQueryGroup(Map<String, String> group) {
    return valueOf(label, group);
  }
}

class _ButtonField({
  required super.name,
  required final bool enabled,
}) extends Field<int> {
  this
    : super(
        type: FieldType.intInput,
        initialValue: 0,
        defaultValue: 0,
        codec: FieldCodec(
          toParam: (value) => value.toString(),
          toValue: (param) => param == null ? null : int.tryParse(param),
        ),
      );

  @override
  Widget toWidget(BuildContext context, String group, int? value) {
    return Align(
      alignment: Alignment.centerLeft,
      child: OutlinedButton(
        onPressed: enabled
            ? () => updateField(context, group, (value ?? 0) + 1)
            : null,
        child: Text(name),
      ),
    );
  }
}
