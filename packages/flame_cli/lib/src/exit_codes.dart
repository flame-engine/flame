/// The exit codes used by the `flame` command, following the common Unix
/// conventions for exit codes.
abstract final class ExitCodes {
  static const success = 0;

  /// The command was used incorrectly, for example with a missing option.
  static const usage = 64;

  /// The requested data, for example a component, could not be found.
  static const data = 65;

  /// The game could not be reached, or it does not support the command.
  static const unavailable = 69;

  /// The game reported an error while running the command.
  static const software = 70;
}
