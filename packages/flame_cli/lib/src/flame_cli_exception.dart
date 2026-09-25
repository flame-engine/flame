import 'package:flame_cli/src/exit_codes.dart';

/// An error that stops a command, with a message that is meant to be shown to
/// the user and the [exitCode] that the process should exit with.
class FlameCliException implements Exception {
  const FlameCliException(
    this.message, {
    this.exitCode = ExitCodes.software,
  });

  final String message;
  final int exitCode;

  @override
  String toString() => message;
}
