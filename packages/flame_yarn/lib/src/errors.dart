class SyntaxError implements Exception {
  SyntaxError([this.message]);

  final String? message;

  @override
  String toString() => 'SyntaxError: $message';
}
