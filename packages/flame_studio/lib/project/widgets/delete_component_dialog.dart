import 'package:flame_studio/repositories/repositories.dart';
import 'package:flutter/material.dart';

/// {@template delete_component_dialog}
/// Asks the user to confirm the deletion of a [Component].
///
/// Pops with `true` when confirmed.
/// {@endtemplate}
class const DeleteComponentDialog({
  /// The component to delete.
  required final Component component,
  super.key,
}) extends StatelessWidget {
  /// {@macro delete_component_dialog}
  this;

  /// Shows the dialog and returns whether the deletion was confirmed.
  static Future<bool> show(BuildContext context, Component component) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => DeleteComponentDialog(component: component),
    );
    return confirmed ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Delete component'),
      content: Text('Delete "${component.name}"? This cannot be undone.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.error,
            foregroundColor: Theme.of(context).colorScheme.onError,
          ),
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Delete'),
        ),
      ],
    );
  }
}
