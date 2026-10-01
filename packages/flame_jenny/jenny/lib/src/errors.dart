class SyntaxError(final String? message) implements Exception {
  @override
  String toString() => 'SyntaxError: $message';
}

/// This error is emitted when accessing an unknown name, such as: undefined
/// variable name, unknown node title, unrecognized function, unspecified
/// command, etc.
class NameError(final String? message) implements Exception {
  @override
  String toString() => 'NameError: $message';
}

class TypeError(final String? message) implements Exception {
  @override
  String toString() => 'TypeError: $message';
}

class DialogueError(final String? message) implements Exception {
  @override
  String toString() => 'DialogueError: $message';
}
