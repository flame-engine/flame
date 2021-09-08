import 'mock_canvas.dart';

/// Similar to [MockCanvas], but only asserts that the provided list of expected
/// commands at least appear in the actual canvas.
/// Additional commands that the actual Canvas might have are ignored by this
/// Matcher.
class ContainsAtLeastMockCanvas extends MockCanvas {
  @override
  bool matches(covariant MockCanvas other, Map matchState) {
    return containsAtLeast(other, matchState);
  }
}
