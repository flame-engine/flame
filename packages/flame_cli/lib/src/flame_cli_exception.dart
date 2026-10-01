import 'package:io/io.dart';

/// An error that stops a command, with a message that is meant to be shown to
/// the user and the [exitCode] that the process should exit with.
class const FlameCliException(
  final String message, {
  final ExitCode exitCode = ExitCode.software,
}) implements Exception {
  @override
  String toString() => message;
}
