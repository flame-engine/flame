import 'package:flame_studio/repositories/repositories.dart';
import 'package:flame_studio/sprite_editor/bloc/sprite_editor_cubit.dart';
import 'package:flame_studio/sprite_editor/widgets/widgets.dart';
import 'package:flame_studio/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// {@template sprite_editor_view}
/// The content of the `SpriteEditorDialog`: the canvas showing the image,
/// where the region is selected, a side bar with the images of the project
/// and fields to type the exact region, the zoom of the canvas (also
/// Cmd/Ctrl + `=`, `-` and `0`) and the buttons that apply or discard the
/// changes.
/// {@endtemplate}
class const SpriteEditorView({super.key}) extends StatelessWidget {
  /// {@macro sprite_editor_view}
  this;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = context.watch<SpriteEditorCubit>().state;
    final cubit = context.read<SpriteEditorCubit>();

    return CallbackShortcuts(
      bindings: zoomShortcuts(
        onZoomIn: cubit.zoomedIn,
        onZoomOut: cubit.zoomedOut,
        onReset: cubit.zoomReset,
      ),
      child: Dialog(
        clipBehavior: Clip.antiAlias,
        child: SizedBox(
          width: 1080,
          height: 600,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 16, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Select sprite',
                        style: theme.textTheme.titleLarge,
                      ),
                    ),
                    ZoomControls(
                      zoom: state.zoom,
                      onZoomIn: state.canZoomIn ? cubit.zoomedIn : null,
                      onZoomOut: state.canZoomOut ? cubit.zoomedOut : null,
                      onReset: cubit.zoomReset,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Expanded(child: ClipRect(child: SpriteCanvas())),
                    const VerticalDivider(width: 1),
                    SizedBox(
                      width: 280,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Expanded(child: _ImageList()),
                          if (state.canApply) ...[
                            const Divider(height: 1),
                            const SpriteRegionFields(),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 12, 16, 16),
                child: Row(
                  spacing: 8,
                  children: [
                    Expanded(
                      child: Text(
                        'Drag on the image to select · drag the selection to '
                        'move it · drag its handles to resize · scroll to pan',
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                    FilledButton(
                      onPressed: state.canApply
                          ? () => Navigator.of(context).pop(state.sprite)
                          : null,
                      child: const Text('Apply'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The images of the project, the selected one being the sprite's.
class const _ImageList() extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final state = context.watch<SpriteEditorCubit>().state;
    final cubit = context.read<SpriteEditorCubit>();
    final message = switch (state.status) {
      SpriteEditorStatus.loading => null,
      SpriteEditorStatus.failure => 'The images could not be listed',
      SpriteEditorStatus.ready when state.images.isEmpty =>
        'No images found. Add them to the '
            '${ComponentRepository.assetsDirectory} folder of the project.',
      SpriteEditorStatus.ready => null,
    };
    if (message != null) {
      return Padding(padding: const EdgeInsets.all(16), child: Text(message));
    }
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        for (final image in state.images)
          ListTile(
            dense: true,
            leading: const Icon(Icons.image_outlined, size: 18),
            title: Text(image),
            selected: image == state.sprite.image,
            onTap: () => cubit.imageSelected(image),
          ),
      ],
    );
  }
}
