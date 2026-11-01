import 'package:flame_studio/repositories/repositories.dart';
import 'package:flutter/material.dart';

/// {@template component_tile}
/// A list entry for a project [Component], with edit and delete actions.
/// {@endtemplate}
class const ComponentTile({
  /// The component shown by this tile.
  required final Component component,

  /// Called when the user wants to edit the component.
  required final VoidCallback onEdit,

  /// Called when the user wants to delete the component.
  required final VoidCallback onDelete,
  super.key,
}) extends StatelessWidget {
  /// {@macro component_tile}
  this;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.widgets_outlined),
      title: Text(component.name),
      onTap: onEdit,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            tooltip: 'Edit',
            icon: const Icon(Icons.edit_outlined),
            onPressed: onEdit,
          ),
          IconButton(
            tooltip: 'Delete',
            icon: const Icon(Icons.delete_outline),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}
