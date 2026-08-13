// This file is invoked by the flutter/tests registry entry for Flame
// (https://github.com/flutter/tests/blob/main/registry/flame.test) to run
// Flame's tests as a presubmit against flutter/flutter framework changes.
// Changes here are only honored after the commit hash in that registry entry
// is updated.

import 'dart:io';

// flame_3d builds on the experimental flutter_gpu library, whose API changes
// frequently in flutter/flutter's presubmit. Analyzing it here would block
// framework changes on an unstable dependency that is not representative of
// Flame, so it is excluded from this run.
//
// flame_forge2d depends on forge2d, which compiles Box2D from source through
// the Dart build hooks and therefore needs a C toolchain and working native
// asset support on the runner. That is a property of the runner rather than
// of the framework change under test, so it is excluded as well.
const _excludedPackages = {'flame_3d', 'flame_forge2d'};

Future<void> main() async {
  final packages =
      Directory('packages')
          .listSync()
          .whereType<Directory>()
          .where(
            (directory) => !_excludedPackages.contains(_packageName(directory)),
          )
          .toList()
        ..sort((a, b) => a.path.compareTo(b.path));

  await _run('flutter', [
    'analyze',
    '--no-fatal-infos',
    'doc',
    ...packages.map((directory) => directory.path),
  ]);

  // Golden and rendering tests are platform-sensitive, so the full per-package
  // test suites only run on Linux, where the golden files are generated.
  if (!Platform.isLinux) {
    return;
  }

  for (final package in packages.where(
    (directory) => Directory('${directory.path}/test').existsSync(),
  )) {
    stdout.writeln('Running tests in ${package.path}');
    await _run('flutter', ['test'], workingDirectory: package.path);
  }
}

String _packageName(Directory directory) =>
    directory.path.split(Platform.pathSeparator).last;

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
