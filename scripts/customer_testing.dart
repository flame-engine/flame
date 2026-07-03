// This file is invoked by the flutter/tests registry entry for Flame
// (https://github.com/flutter/tests/blob/main/registry/flame.test) to run
// Flame's tests as a presubmit against flutter/flutter framework changes.
// Changes here are only honored after the commit hash in that registry entry
// is updated.

import 'dart:io';

Future<void> main() async {
  await _run('flutter', ['analyze', '--no-fatal-infos']);

  // Golden and rendering tests are platform-sensitive, so the full per-package
  // test suites only run on Linux, where the golden files are generated.
  if (!Platform.isLinux) {
    return;
  }

  final packages =
      Directory('packages')
          .listSync()
          .whereType<Directory>()
          .where(
            (directory) => Directory('${directory.path}/test').existsSync(),
          )
          .toList()
        ..sort((a, b) => a.path.compareTo(b.path));

  for (final package in packages) {
    stdout.writeln('Running tests in ${package.path}');
    await _run('flutter', ['test'], workingDirectory: package.path);
  }
}

Future<void> _run(
  String executable,
  List<String> arguments, {
  String? workingDirectory,
}) async {
  final process = await Process.start(
    executable,
    arguments,
    workingDirectory: workingDirectory,
    mode: ProcessStartMode.inheritStdio,
    runInShell: true,
  );
  final exitCode = await process.exitCode;
  if (exitCode != 0) {
    exit(exitCode);
  }
}
