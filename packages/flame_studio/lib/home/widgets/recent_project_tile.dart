import 'package:flame_studio/repositories/repositories.dart';
import 'package:flutter/material.dart';

/// {@template recent_project_tile}
/// A list entry for a recently opened [Project].
/// {@endtemplate}
class const RecentProjectTile({
  /// The project shown by this tile.
  required final Project project,

  /// Called when the tile is tapped.
  required final VoidCallback onTap,
  super.key,
}) extends StatelessWidget {
  /// {@macro recent_project_tile}
  this;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.folder_outlined),
      title: Text(project.name),
      subtitle: Text(project.path),
      onTap: onTap,
    );
  }
}
