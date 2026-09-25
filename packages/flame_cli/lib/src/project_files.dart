import 'dart:io';

import 'package:path/path.dart' as p;

/// The name of the file that `flame run` writes the Dart VM Service URI of
/// the running game to.
const vmServiceUriFileName = 'vm_service_uri';

/// The name of the file that `flame run` writes the port to that it accepts
/// commands such as `reload` on.
const controlPortFileName = 'control_port';

/// The name of the file that `flame run` writes the output of `flutter run`
/// to.
const logFileName = 'log';

/// The directory inside the project, relative to the project directory, that
/// `flame run` keeps its files in.
final flameDirectoryPath = p.join('.dart_tool', 'flame');

/// The directory that `flame run` keeps its files in, for the project in
/// [projectDirectory].
Directory flameDirectory(Directory projectDirectory) {
  return Directory(p.join(projectDirectory.path, flameDirectoryPath));
}

/// The file with the given [name] that `flame run` keeps for the project in
/// [projectDirectory].
File projectFile(Directory projectDirectory, String name) {
  return File(p.join(flameDirectory(projectDirectory).path, name));
}

/// Finds the file with the given [name] that `flame run` keeps for a project,
/// by looking in [directory] and then in each of its parents.
///
/// Returns null if no such file is found.
File? findProjectFile(Directory directory, String name) {
  var current = directory.absolute;
  while (true) {
    final file = projectFile(current, name);
    if (file.existsSync()) {
      return file;
    }
    final parent = current.parent;
    if (parent.path == current.path) {
      return null;
    }
    current = parent;
  }
}
