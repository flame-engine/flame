import 'dart:math';

import 'package:flame_devtools/widgets/incremental_number_form_field.dart';
import 'package:flutter/material.dart';

/// The number of decimals that an angle is shown with, in degrees.
///
/// Rounding hides the floating point error of converting between radians and
/// degrees, so that an angle typed as `30` is shown as `30.0` again when it is
/// read back from the game, and not as `29.999999999999996`.
const _fractionDigits = 4;

/// Converts [radians] to degrees, rounded to the precision that the
/// [AngleFormField] shows.
double radiansToDisplayDegrees(double radians) {
  final degrees = radians * 180 / pi;
  return double.parse(degrees.toStringAsFixed(_fractionDigits));
}

/// Converts [degrees] to radians.
double degreesToRadians(double degrees) => degrees * pi / 180;

/// A form field that shows and edits an angle in degrees.
///
/// The [radians] and the value passed to [onChanged] are in radians, which is
/// what the game uses, so only the UI works with degrees.
class const AngleFormField({
  required final double radians,
  required final void Function(double radians) onChanged,
  super.key,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return IncrementalNumberFormField<double>(
      label: 'Degrees',
      initialValue: radiansToDisplayDegrees(radians),
      onChanged: (degrees) => onChanged(degreesToRadians(degrees)),
    );
  }
}
