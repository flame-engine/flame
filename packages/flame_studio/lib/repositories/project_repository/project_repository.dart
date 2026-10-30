import 'dart:convert';

import 'package:flame_studio/clients/clients.dart';
import 'package:flame_studio/repositories/repositories.dart';
import 'package:path/path.dart' as p;

/// {@template project_not_found_exception}
/// Thrown when opening a [Project] whose folder no longer exists.
/// {@endtemplate}
class const ProjectNotFoundException(
  /// The project that could not be found.
  final Project project,
) implements Exception {
  /// {@macro project_not_found_exception}
  this;
}

/// {@template invalid_output_path_exception}
/// Thrown when an output path is not a folder inside the project.
/// {@endtemplate}
class const InvalidOutputPathException(
  /// The rejected path.
  final String path,
) implements Exception {
  /// {@macro invalid_output_path_exception}
  this;
}

/// {@template project_repository}
/// Opens projects, keeps track of the most recently opened ones and manages
/// their settings.
///
/// The settings of a project are stored in its [settingsFile].
/// {@endtemplate}
class ProjectRepository({
  required final KeyValueStorageClient _storage,
  required final FileSystemClient _fileSystem,
}) {
  /// {@macro project_repository}
  this;

  /// Storage key under which recent projects are persisted.
  static const recentProjectsKey = 'recent_projects';

  /// Maximum number of recent projects that are kept.
  static const maxRecentProjects = 10;

  /// File, relative to the project folder, where its settings are stored.
  static const settingsFile = '.flame_studio/settings.json';

  /// Returns the recently opened projects, most recent first.
  ///
  /// Returns an empty list if nothing was stored or the stored data is
  /// unreadable.
  Future<List<Project>> getRecentProjects() async {
    final raw = await _storage.read(recentProjectsKey);
    if (raw == null) {
      return const [];
    }
    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return [
        for (final json in decoded)
          Project.fromJson(json as Map<String, dynamic>),
      ];
    } on Object {
      return const [];
    }
  }

  /// Asks the user to pick a project folder.
  ///
  /// Returns `null` if the user cancelled.
  Future<Project?> pickProject() async {
    final path = await _fileSystem.pickDirectory();
    return path == null ? null : Project(path: path);
  }

  /// Opens [project], moving it to the top of the recent projects.
  ///
  /// Throws a [ProjectNotFoundException] if the project folder no longer
  /// exists, in which case it is removed from the recent projects.
  Future<void> openProject(Project project) async {
    final recentProjects = (await getRecentProjects())
        .where((recent) => recent != project)
        .toList();

    if (!await _fileSystem.directoryExists(project.path)) {
      await _saveRecentProjects(recentProjects);
      throw ProjectNotFoundException(project);
    }

    await _saveRecentProjects(
      [project, ...recentProjects].take(maxRecentProjects).toList(),
    );
  }

  /// Returns the settings of [project].
  ///
  /// Returns the default settings if none were saved or the stored data is
  /// unreadable.
  Future<ProjectSettings> getSettings(Project project) async {
    final path = _settingsPath(project);
    try {
      if (!await _fileSystem.fileExists(path)) {
        return const ProjectSettings();
      }
      final json = jsonDecode(await _fileSystem.readFile(path));
      return ProjectSettings.fromJson(json as Map<String, dynamic>);
    } on Object {
      return const ProjectSettings();
    }
  }

  /// Saves the [settings] of [project] and returns them normalized.
  ///
  /// Throws an [InvalidOutputPathException] if the output path is not a
  /// folder inside the project.
  Future<ProjectSettings> saveSettings(
    Project project,
    ProjectSettings settings,
  ) async {
    final normalized = settings.copyWith(
      outputPath: _normalizeOutputPath(settings.outputPath),
    );
    await _fileSystem.writeFile(
      _settingsPath(project),
      jsonEncode(normalized.toJson()),
    );
    return normalized;
  }

  /// Asks the user to pick the output folder of [project].
  ///
  /// Returns the picked folder relative to the project folder, or `null` if
  /// the user cancelled. Throws an [InvalidOutputPathException] if the picked
  /// folder is not inside the project.
  Future<String?> pickOutputPath(Project project) async {
    final picked = await _fileSystem.pickDirectory();
    if (picked == null) {
      return null;
    }
    if (!p.isWithin(project.path, picked)) {
      throw InvalidOutputPathException(picked);
    }
    return _normalizeOutputPath(p.relative(picked, from: project.path));
  }

  /// Normalizes a project-relative [path] using `/` as separator.
  ///
  /// Throws an [InvalidOutputPathException] if [path] is empty, absolute or
  /// points outside the project.
  String _normalizeOutputPath(String path) {
    final trimmed = path.trim();
    if (trimmed.isEmpty ||
        p.isAbsolute(trimmed) ||
        p.posix.isAbsolute(trimmed)) {
      throw InvalidOutputPathException(path);
    }
    final segments = p.split(p.normalize(trimmed));
    if (segments.first == '.' || segments.first == '..') {
      throw InvalidOutputPathException(path);
    }
    return segments.join('/');
  }

  String _settingsPath(Project project) => p.join(project.path, settingsFile);

  Future<void> _saveRecentProjects(List<Project> projects) {
    return _storage.write(
      recentProjectsKey,
      jsonEncode([for (final project in projects) project.toJson()]),
    );
  }
}
