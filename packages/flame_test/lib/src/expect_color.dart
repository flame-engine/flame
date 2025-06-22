import 'dart:ui' show Color;
import 'package:test/test.dart';

/// A test helper function that compares two [Color] objects for equality with
/// floating-point tolerance.
///
/// Each color component (red, green, blue, alpha) is compared using [closeTo]
/// matcher with a configurable epsilon value (default 0.000001) to account for
/// floating-point precision differences that can occur due to binary
/// representation and endianness when colors are stored/retrieved.
///
/// Example usage:
/// ```dart
/// test('color matching', () {
///   final actual = Paint()..color = Color.fromRGBO(255, 0, 0, 0.5);
///   final expected = Color.fromRGBO(255, 0, 0, 0.5);
///   expectColor(actual.color, expected, reason: 'paint color should be red');
/// });
/// ```
///
/// Parameters:
/// - [actual]: The Color being tested
/// - [expected]: The Color to test against
/// - [reason]: Optional description that will be included in the failure
///   message to provide context about what was being tested. If omitted, uses
///   'color' as the default context.
/// - [delta]: Optional tolerance value for floating-point comparison. Defaults
///   to 0.000001.
void expectColor(
  Color actual,
  Color expected, {
  String? reason,
  double delta = 0.0000001,
}) {
  expect(
    actual.r,
    closeTo(expected.r, delta),
    reason: '${reason ?? 'color'} red value is wrong',
  );
  expect(
    actual.g,
    closeTo(expected.g, delta),
    reason: '${reason ?? 'color'} green value is wrong',
  );
  expect(
    actual.b,
    closeTo(expected.b, delta),
    reason: '${reason ?? 'color'} blue value is wrong',
  );
  expect(
    actual.a,
    closeTo(expected.a, delta),
    reason: '${reason ?? 'color'} alpha value is wrong',
  );
}

/// A test helper function that compares only the alpha component of two [Color]
/// objects with floating-point tolerance.
///
/// The alpha component is compared using [closeTo] matcher with a configurable
/// epsilon value (default 0.000001) to account for floating-point precision
/// differences that can occur due to binary representation and endianness when
/// colors are stored/retrieved.
///
/// Example usage:
/// ```dart
/// test('alpha matching', () {
///   final actual = Paint()..color = Color.fromRGBO(255, 0, 0, 0.5);
///   final expected = Color.fromRGBO(0, 255, 0, 0.5);
///   expectColorAlpha(
///     actual.color,
///     expected,
///     reason: 'paint alpha should match',
///   );
/// });
/// ```
///
/// Parameters:
/// - [actual]: The Color being tested
/// - [expected]: The Color to test against
/// - [reason]: Optional description that will be included in the failure
///   message to provide context about what was being tested. If omitted, uses
///   'color' as the default context.
/// - [delta]: Optional tolerance value for floating-point comparison.
///   Defaults to 0.000001.
void expectColorAlpha(
  Color actual,
  Color expected, {
  String? reason,
  double delta = 0.0000001,
}) {
  expect(
    actual.a,
    closeTo(expected.a, delta),
    reason: '${reason ?? 'color'} alpha value is wrong',
  );
}
