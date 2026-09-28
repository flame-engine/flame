import 'package:io/io.dart';

/// An error that stops a command, with a message that is meant to be shown to
/// the user and the [exitCode] that the process should exit with.
class FlameCliException implements Exception {
  const FlameCliException(
    this.message, {
    this.exitCode = ExitCode.software,
  });

  final String message;
  final ExitCode exitCode;

  @override
  String toString() => message;
}
