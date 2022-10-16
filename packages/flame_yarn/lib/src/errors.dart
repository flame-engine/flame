class SyntaxError implements Exception {
  SyntaxError([this.message]);

  final String? message;

  @override
  String toString() => 'SyntaxError: $message';
}

/// This error is emitted when accessing an unknown name, such as: undefined
/// variable name, unknown node title, unrecognized function, unspecified
/// command, etc.
class NameError implements Exception {
  NameError([this.message]);

  final String? message;

  @override
  String toString() => 'NameError: $message';
}
