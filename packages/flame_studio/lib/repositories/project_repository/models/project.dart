import 'package:equatable/equatable.dart';

/// {@template project}
/// A project opened in the editor, identified by its folder [path].
/// {@endtemplate}
class const Project({
  /// Absolute path to the project folder.
  required final String path,
}) extends Equatable {
  /// {@macro project}
  this;

  /// Creates a [Project] from its JSON representation.
  factory fromJson(Map<String, dynamic> json) {
    return Project(path: json['path'] as String);
  }

  /// The project name, which is the name of its folder.
  String get name {
    final segments = path
        .split(RegExp(r'[/\\]'))
        .where((segment) => segment.isNotEmpty);
    return segments.isEmpty ? path : segments.last;
  }

  /// Converts this project to its JSON representation.
  Map<String, dynamic> toJson() => {'path': path};

  @override
  List<Object> get props => [path];
}
