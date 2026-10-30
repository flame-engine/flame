import 'dart:io';

import 'package:file_selector/file_selector.dart' as file_selector;

/// Signature of a function that opens a native directory picker and returns
/// the selected path, or `null` if the user cancelled.
typedef DirectoryPicker = Future<String?> Function();

/// {@template file_system_client}
/// A client for interacting with the local file system.
/// {@endtemplate}
class FileSystemClient({DirectoryPicker? directoryPicker}) {
  /// {@macro file_system_client}
  this;

  final DirectoryPicker _directoryPicker =
      directoryPicker ?? file_selector.getDirectoryPath;

  /// Opens a native dialog to pick a directory.
  ///
  /// Returns the selected path, or `null` if the dialog was cancelled.
  Future<String?> pickDirectory() => _directoryPicker();

  /// Whether a directory exists at [path].
  Future<bool> directoryExists(String path) async =>
      Directory(path).existsSync();

  /// Whether a file exists at [path].
  Future<bool> fileExists(String path) async => File(path).existsSync();

  /// Returns the paths of the files directly inside [directoryPath].
  ///
  /// When [extension] is given (e.g. `.json`), only files ending with it are
  /// returned. Returns an empty list if the directory does not exist.
  Future<List<String>> listFiles(
    String directoryPath, {
    String? extension,
  }) async {
    final directory = Directory(directoryPath);
    if (!directory.existsSync()) {
      return const [];
    }

    return [
      await for (final entity in directory.list())
        if (entity is File &&
            (extension == null || entity.path.endsWith(extension)))
          entity.path,
    ];
  }

  /// Reads the file at [path] as a string.
  Future<String> readFile(String path) => File(path).readAsString();

  /// Writes [contents] to the file at [path], creating any missing parent
  /// directories.
  Future<void> writeFile(String path, String contents) async {
    final file = File(path);
    await file.parent.create(recursive: true);
    await file.writeAsString(contents);
  }

  /// Deletes the file at [path].
  Future<void> deleteFile(String path) => File(path).delete();
}
