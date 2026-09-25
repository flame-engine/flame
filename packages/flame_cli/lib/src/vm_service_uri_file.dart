import 'dart:io';

import 'package:flame_cli/src/project_files.dart';
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
