import 'package:flame_studio/palette/palette.dart';
import 'package:flame_studio/repositories/repositories.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// {@template palette_dialog}
/// A dialog to manage the [Palette] of a [Project].
/// {@endtemplate}
class const PaletteDialog({
  /// The project whose palette is edited.
  required final Project project,

  /// The component being edited.
  required final Component component,
  super.key,
}) extends StatelessWidget {
  /// {@macro palette_dialog}
  this;

  /// Shows the palette dialog of [project], opened while editing
  /// [component], whose unsaved palette colors count as used.
  ///
  /// Returns the saved palette, or `null` if it was not saved.
  static Future<Palette?> show(
    BuildContext context, {
    required Project project,
    required Component component,
  }) {
    return showDialog<Palette>(
      context: context,
      builder: (_) => PaletteDialog(project: project, component: component),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PaletteBloc(
        project: project,
        editedComponent: component,
        componentRepository: context.read(),
        projectRepository: context.read(),
      )..add(const PaletteStarted()),
      child: const PaletteView(),
    );
  }
}
