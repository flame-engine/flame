import 'package:flame_studio/component_editor/bloc/component_editor_bloc.dart';
import 'package:flame_studio/repositories/repositories.dart';
import 'package:flame_studio/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// {@template editor_toolbar}
/// The bar above the preview, with the preview options: the selection
/// highlight, the hitboxes outlines and the zoom.
/// {@endtemplate}
class const EditorToolbar({super.key}) extends StatelessWidget {
  /// {@macro editor_toolbar}
  this;

  /// Height of the toolbar.
  static const height = 40.0;

  @override
  Widget build(BuildContext context) {
    final isSelectionHighlighted = context.select<ComponentEditorBloc, bool>(
      (bloc) => bloc.state.isSelectionHighlighted,
    );
    final areHitboxesVisible = context.select<ComponentEditorBloc, bool>(
      (bloc) => bloc.state.areHitboxesVisible,
    );
    final bloc = context.read<ComponentEditorBloc>();
    final colorScheme = Theme.of(context).colorScheme;
    return ColoredBox(
      color: colorScheme.surfaceContainer,
      child: SizedBox(
        height: height,
        // Scrolls rather than overflows when the preview is narrow.
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: constraints.maxWidth),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        _ToolbarToggle(
                          tooltip: 'Highlight selection',
                          icon: Icons.highlight_alt,
                          isSelected: isSelectionHighlighted,
                          onPressed: () => bloc.add(
                            const ComponentEditorSelectionHighlightToggled(),
                          ),
                        ),
                        _ToolbarToggle(
                          tooltip: 'Show hitboxes',
                          icon: Icons.border_style,
                          isSelected: areHitboxesVisible,
                          onPressed: () => bloc.add(
                            const ComponentEditorHitboxesVisibilityToggled(),
                          ),
                        ),
                      ],
                    ),
                    const _EditorZoomControls(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class const _ToolbarToggle({
  required final String tooltip,
  required final IconData icon,
  required final bool isSelected,
  required final VoidCallback onPressed,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return IconButton(
      tooltip: tooltip,
      iconSize: 20,
      isSelected: isSelected,
      icon: Icon(icon),
      // Selected toggles get a filled background, so it's clear at a glance
      // whether they are on.
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? colorScheme.primaryContainer
              : null,
        ),
        foregroundColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? colorScheme.onPrimaryContainer
              : colorScheme.onSurfaceVariant,
        ),
      ),
      onPressed: onPressed,
    );
  }
}

class const _EditorZoomControls() extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final zoom = context.select<ComponentEditorBloc, double>(
      (bloc) => bloc.state.zoom,
    );
    final bloc = context.read<ComponentEditorBloc>();
    return ZoomControls(
      zoom: zoom,
      onZoomOut: ZoomLevels.previous(zoom) == null
          ? null
          : () => bloc.add(const ComponentEditorZoomedOut()),
      onZoomIn: ZoomLevels.next(zoom) == null
          ? null
          : () => bloc.add(const ComponentEditorZoomedIn()),
      onReset: () => bloc.add(const ComponentEditorZoomReset()),
    );
  }
}
