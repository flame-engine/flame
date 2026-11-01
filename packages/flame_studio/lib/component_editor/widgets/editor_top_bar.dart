import 'package:flame_studio/component_editor/bloc/component_editor_bloc.dart';
import 'package:flame_studio/palette/palette.dart';
import 'package:flame_studio/repositories/repositories.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// {@template editor_top_bar}
/// The bar below the app bar, above the editor panels, with the actions
/// that concern the whole project, such as managing its palette.
/// {@endtemplate}
class const EditorTopBar({
  /// The project the edited component belongs to.
  required final Project project,
  super.key,
}) extends StatelessWidget {
  /// {@macro editor_top_bar}
  this;

  /// Height of the bar.
  static const height = 40.0;

  Future<void> _openPalette(BuildContext context) async {
    final bloc = context.read<ComponentEditorBloc>();
    final palette = await PaletteDialog.show(
      context,
      project: project,
      component: bloc.state.component,
    );
    // The editor may have been closed meanwhile.
    if (palette != null && context.mounted) {
      bloc.add(ComponentEditorPaletteChanged(palette));
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return ColoredBox(
      color: colorScheme.surfaceContainer,
      child: SizedBox(
        height: height,
        child: Row(
          children: [
            const SizedBox(width: 8),
            IconButton(
              tooltip: 'Palette',
              iconSize: 20,
              color: colorScheme.onSurfaceVariant,
              icon: const Icon(Icons.palette_outlined),
              onPressed: () => _openPalette(context),
            ),
          ],
        ),
      ),
    );
  }
}
