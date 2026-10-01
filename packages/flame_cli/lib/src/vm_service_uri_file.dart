import 'dart:io';

import 'package:flame_cli/src/flame_cli_exception.dart';
import 'package:flame_cli/src/project_files.dart';
import 'package:io/io.dart';
import 'package:path/path.dart' as p;

/// The path, relative to the project directory, of the file that `flame run`
/// writes the Dart VM Service URI of the running game to.
final vmServiceUriFilePath = p.join(flameDirectoryPath, vmServiceUriFileName);

/// The file that `flame run` writes the Dart VM Service URI to, when it is
/// started in [projectDirectory].
File vmServiceUriFile(Directory projectDirectory) {
  return projectFile(projectDirectory, vmServiceUriFileName);
}

/// Finds the file that `flame run` wrote the Dart VM Service URI to, by
/// looking in [directory] and then in each of its parents.
///
/// Returns null if no game that was started with `flame run` is found.
File? findVmServiceUriFile(Directory directory) {
  return findProjectFile(directory, vmServiceUriFileName);
}

/// Finds the Dart VM Service URI of the running game, which is [uriOption]
/// when it is given, and otherwise the URI that `flame run` wrote for the
/// project that [directory] is in.
///
/// Returns the URI together with the file that it was read from, which is
/// null when [uriOption] was used, and throws a [FlameCliException] when no
/// running game is found.
({String uri, File? file}) findVmServiceUri(
  Directory directory, {
  String? uriOption,
}) {
  if (uriOption != null) {
    return (uri: uriOption, file: null);
  }

  const noGameFound = FlameCliException(
    'No running game was found. Start the game with `flame run`, or pass '
    'the Dart VM Service URI of the game with --uri.',
    exitCode: ExitCode.unavailable,
  );
  final file = findVmServiceUriFile(directory);
  if (file == null) {
    throw noGameFound;
  }
  try {
    return (uri: file.readAsStringSync(), file: file);
  } on FileSystemException catch (_, stackTrace) {
    Error.throwWithStackTrace(noGameFound, stackTrace);
  }
}
