import 'package:flame/game.dart';
import 'package:flame_studio/component_editor/bloc/component_editor_bloc.dart';
import 'package:flame_studio/component_editor/widgets/preview/preview.dart';
import 'package:flame_studio/repositories/repositories.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// {@template component_preview}
/// Renders the component being edited with Flame, at
/// [ComponentEditorState.zoom], highlighting the selected node unless
/// [ComponentEditorState.isSelectionHighlighted] is off, and outlining the
/// hitboxes unless [ComponentEditorState.areHitboxesVisible] is off.
///
/// Paints that use palette colors are drawn with their current value in
/// [ComponentEditorState.palette].
/// {@endtemplate}
class const ComponentPreview({super.key}) extends StatefulWidget {
  /// {@macro component_preview}
  this;

  @override
  State<ComponentPreview> createState() => _ComponentPreviewState();
}

class _ComponentPreviewState() extends State<ComponentPreview> {
  late final ComponentPreviewGame _game = _createGame(
    context.read<ComponentEditorBloc>().state,
  );

  static ComponentPreviewGame _createGame(ComponentEditorState state) {
    return ComponentPreviewGame(
      component: _previewed(state),
      highlightedPath: _highlightedPath(state),
      zoom: state.zoom,
      areHitboxesVisible: state.areHitboxesVisible,
    );
  }

  static Component _previewed(ComponentEditorState state) =>
      state.component.withPaletteColorsResolved(state.palette);

  static List<int>? _highlightedPath(ComponentEditorState state) =>
      state.isSelectionHighlighted ? state.selectedPath : null;

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<ComponentEditorBloc, ComponentEditorState>(
          listenWhen: (previous, current) => previous.zoom != current.zoom,
          listener: (context, state) => _game.zoom = state.zoom,
        ),
        BlocListener<ComponentEditorBloc, ComponentEditorState>(
          listenWhen: (previous, current) =>
              previous.areHitboxesVisible != current.areHitboxesVisible,
          listener: (context, state) =>
              _game.areHitboxesVisible = state.areHitboxesVisible,
        ),
        BlocListener<ComponentEditorBloc, ComponentEditorState>(
          listenWhen: (previous, current) =>
              previous.component != current.component ||
              previous.palette != current.palette ||
              previous.selectedPath != current.selectedPath ||
              previous.isSelectionHighlighted != current.isSelectionHighlighted,
          // A single call, so a removed node and the new selection are shown
          // together.
          listener: (context, state) => _game.show(
            _previewed(state),
            highlightedPath: _highlightedPath(state),
          ),
        ),
      ],
      // The preview takes no keyboard input; without this the game widget
      // would grab focus and swallow the editor shortcuts (e.g. Cmd+S).
      child: GameWidget(game: _game, autofocus: false),
    );
  }
}
