import 'dart:math';

import 'package:flame_devtools/widgets/incremental_number_form_field.dart';
// ignore: deprecated_member_use
import 'package:flutter/material.dart';

/// A form field that shows and edits an angle in degrees.
///
/// The [radians] and the value passed to [onChanged] are in radians, which is
/// what the game uses, so only the UI works with degrees.
class const AngleFormField({
  required final double radians,
  required final void Function(double radians) onChanged,
  super.key,
}) extends StatelessWidget {
  /// The number of decimals that the angle is shown with, in degrees.
  ///
  /// Rounding hides the floating point error of converting between radians
  /// and degrees, so that an angle typed as `30` is shown as `30.0` again when
  /// it is read back from the game, and not as `29.999999999999996`.
  static const _fractionDigits = 4;

  static double _toDisplayDegrees(double radians) {
    final degrees = radians * 180 / pi;
    return double.parse(degrees.toStringAsFixed(_fractionDigits));
  }

  static double _toRadians(double degrees) => degrees * pi / 180;

  @override
  Widget build(BuildContext context) {
    return IncrementalNumberFormField<double>(
      label: 'Degrees',
      initialValue: _toDisplayDegrees(radians),
      onChanged: (degrees) => onChanged(_toRadians(degrees)),
    );
  }
}
