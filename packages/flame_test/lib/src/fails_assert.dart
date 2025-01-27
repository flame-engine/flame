import 'package:test/test.dart';

/// Matcher that can be used in a test that expects an assertion error.
///
/// This is similar to standard `throwsAssertionError` matcher, but also
/// allows an optional message string to verify that the assertion has the
/// expected message.
///
/// For example:
/// ```dart
/// expect(
///   () => PositionedComponent(size: Vector2.all(-1)),
///   failsAssert('size of a PositionedComponent cannot be negative'),
/// )
/// ```
Matcher failsAssert([String? message]) {
  var typeMatcher = isA<AssertionError>();
  if (message != null) {
    typeMatcher = typeMatcher.having((e) => e.message, 'message', message);
  }
  return throwsA(typeMatcher);
}
