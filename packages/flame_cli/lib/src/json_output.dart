import 'dart:convert';

import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:io/io.dart';

const _encoder = JsonEncoder.withIndent('  ');

/// Encodes [value] as indented JSON, for the `--json` output of the commands.
String toJsonOutput(Object? value) => _encoder.convert(value);

/// The name of the flag that makes a command print its result as JSON.
const jsonFlag = 'json';

/// Adds the `--json` flag to [parser], which every command that prints a
/// result has.
void addJsonFlag(ArgParser parser) {
  parser.addFlag(
    jsonFlag,
    negatable: false,
    help:
        'Print the result, or the error if the command fails, as JSON '
        'instead of text.',
  );
}

/// The error that is printed as JSON instead of the message when a command
/// that was called with `--json` fails.
///
/// The `kind` in the JSON is the name of the [exitCode] in [ExitCode], such
/// as `usage` or `unavailable`, so that the error can be told apart without
/// looking up the number.
class const JsonError(final String message, final ExitCode exitCode) {
  Map<String, Object> toJson() {
    return {
      'error': {
        'message': message,
        'exitCode': exitCode.code,
        'kind': exitCodeName(exitCode),
      },
    };
  }
}

/// The name of [exitCode] as it is called in [ExitCode], for the exit codes
/// that the commands use, and `error` for the others.
String exitCodeName(ExitCode exitCode) {
  return switch (exitCode) {
    ExitCode.success => 'success',
    ExitCode.usage => 'usage',
    ExitCode.data => 'data',
    ExitCode.unavailable => 'unavailable',
    ExitCode.software => 'software',
    ExitCode.cantCreate => 'cantCreate',
    ExitCode.tempFail => 'tempFail',
    _ => 'error',
  };
}

/// A command with the `--json` flag from [addJsonFlag], which prints its
/// result either as text or as JSON.
mixin JsonOutput on Command<int> {
  /// Where the result is printed.
  StringSink get out;

  /// Whether the result should be printed as JSON.
  bool get jsonOutput => argResults!.flag(jsonFlag);

  /// Prints [result] as JSON when `--json` was passed, and [text] otherwise.
  void writeResult(Object? result, String text) {
    out.writeln(jsonOutput ? toJsonOutput(result) : text);
  }
}
