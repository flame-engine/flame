import 'package:flutter/material.dart';

/// What the user chose in the [UnsavedChangesDialog].
enum UnsavedChangesDecision() {
  /// Stay in the editor.
  cancel,

  /// Leave without saving.
  discard,

  /// Save, then leave.
  save,
}

/// {@template unsaved_changes_dialog}
/// Asks the user what to do with unsaved changes when leaving the editor.
/// {@endtemplate}
class const UnsavedChangesDialog({super.key}) extends StatelessWidget {
  /// {@macro unsaved_changes_dialog}
  this;

  /// Shows the dialog and returns the user's decision.
  ///
  /// Dismissing the dialog counts as [UnsavedChangesDecision.cancel].
  static Future<UnsavedChangesDecision> show(BuildContext context) async {
    final decision = await showDialog<UnsavedChangesDecision>(
      context: context,
      builder: (_) => const UnsavedChangesDialog(),
    );
    return decision ?? UnsavedChangesDecision.cancel;
  }

  @override
  Widget build(BuildContext context) {
    void pop(UnsavedChangesDecision decision) =>
        Navigator.of(context).pop(decision);

    return AlertDialog(
      title: const Text('Unsaved changes'),
      content: const Text(
        'This component has changes that were not saved. '
        'Do you want to save them before leaving?',
      ),
      actions: [
        TextButton(
          onPressed: () => pop(UnsavedChangesDecision.cancel),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => pop(UnsavedChangesDecision.discard),
          child: const Text('Discard'),
        ),
        FilledButton(
          onPressed: () => pop(UnsavedChangesDecision.save),
          child: const Text('Save'),
        ),
      ],
    );
  }
}
