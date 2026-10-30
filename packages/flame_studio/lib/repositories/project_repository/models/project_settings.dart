import 'package:equatable/equatable.dart';

/// {@template project_settings}
/// The settings of a project.
/// {@endtemplate}
class const ProjectSettings({
  /// Folder, relative to the project folder, where the generated Dart source
  /// code is written.
  final String outputPath = defaultOutputPath,
}) extends Equatable {
  /// {@macro project_settings}
  this;

  /// Creates a [ProjectSettings] from its JSON representation.
  ///
  /// Missing or invalid values fall back to their defaults.
  factory fromJson(Map<String, dynamic> json) {
    final outputPath = json['outputPath'];
    return ProjectSettings(
      outputPath: outputPath is String ? outputPath : defaultOutputPath,
    );
  }

  /// The default [outputPath].
  static const defaultOutputPath = 'lib/components';

  /// Returns a copy of these settings with the given fields replaced.
  ProjectSettings copyWith({String? outputPath}) {
    return ProjectSettings(outputPath: outputPath ?? this.outputPath);
  }

  /// Converts these settings to their JSON representation.
  Map<String, dynamic> toJson() => {'outputPath': outputPath};

  @override
  List<Object> get props => [outputPath];
}
