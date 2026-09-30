import 'dart:io';

import 'package:path/path.dart' as p;

/// The path, relative to the project directory, of the file that `flame run`
/// writes the Dart VM Service URI of the running game to.
final vmServiceUriFilePath = p.join('.dart_tool', 'flame', 'vm_service_uri');

/// The file that `flame run` writes the Dart VM Service URI to, when it is
/// started in [projectDirectory].
File vmServiceUriFile(Directory projectDirectory) {
  return File(p.join(projectDirectory.path, vmServiceUriFilePath));
}

/// Finds the file that `flame run` wrote the Dart VM Service URI to, by
/// looking in [directory] and then in each of its parents.
///
/// Returns null if no game that was started with `flame run` is found.
File? findVmServiceUriFile(Directory directory) {
  var current = directory.absolute;
  while (true) {
    final file = vmServiceUriFile(current);
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
