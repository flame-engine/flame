import 'dart:async';
import 'dart:ui' as ui;

import 'package:flame/game.dart';
import 'package:flame_studio/component_editor/bloc/component_editor_bloc.dart';
import 'package:flame_studio/component_editor/widgets/preview/preview.dart';
import 'package:flame_studio/repositories/repositories.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// {@template component_preview}
/// Renders the component being edited with Flame, at
/// [ComponentEditorState.zoom], highlighting the selected node unless
/// [ComponentEditorState.isSelectionHighlighted] is off, and outlining the
/// hitboxes unless [ComponentEditorState.areHitboxesVisible] is off.
///
/// Paints that use palette colors are drawn with their current value in
/// [ComponentEditorState.palette], and sprites with their image in
/// [ComponentEditorState.spriteImages], once it is decoded.
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

  final Map<String, ui.Image> _images = {};
  final Set<String> _decoding = {};

  @override
  void initState() {
    super.initState();
    unawaited(
      _decodeImages(context.read<ComponentEditorBloc>().state.spriteImages),
    );
  }

  @override
  void dispose() {
    _isDisposed = true;
    for (final image in _images.values) {
      image.dispose();
    }
    super.dispose();
  }

  bool _isDisposed = false;

  /// Decodes the [images] that aren't decoded yet, for the game to draw.
  /// Files that aren't images are skipped: their sprites stay empty.
  Future<void> _decodeImages(Map<String, Uint8List> images) async {
    for (final MapEntry(key: path, value: bytes) in images.entries) {
      if (_images.containsKey(path) || !_decoding.add(path)) {
        continue;
      }
      try {
        final codec = await ui.instantiateImageCodec(bytes);
        final frame = await codec.getNextFrame();
        codec.dispose();
        if (_isDisposed) {
          frame.image.dispose();
          return;
        }
        _images[path] = frame.image;
        _game.spriteImages = Map.of(_images);
      } on Exception {
        continue;
      }
    }
  }

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
          listenWhen: (previous, current) =>
              previous.spriteImages != current.spriteImages,
          listener: (context, state) =>
              unawaited(_decodeImages(state.spriteImages)),
        ),
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
