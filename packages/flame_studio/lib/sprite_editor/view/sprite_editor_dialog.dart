import 'dart:async';

import 'package:flame_studio/repositories/repositories.dart';
import 'package:flame_studio/sprite_editor/bloc/sprite_editor_cubit.dart';
import 'package:flame_studio/sprite_editor/view/sprite_editor_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// {@template sprite_editor_dialog}
/// A dialog to pick an image of a [Project] and select the region of it
/// that a sprite draws.
/// {@endtemplate}
class const SpriteEditorDialog({
  /// The project whose images can be picked.
  required final Project project,

  /// The sprite the dialog opens with.
  required final ComponentSprite sprite,
  super.key,
}) extends StatelessWidget {
  /// {@macro sprite_editor_dialog}
  this;

  /// Shows the dialog editing [sprite], with the images of [project], and
  /// returns the applied sprite, or `null` if the user cancelled.
  static Future<ComponentSprite?> show(
    BuildContext context, {
    required Project project,
    required ComponentSprite sprite,
  }) {
    return showDialog<ComponentSprite>(
      context: context,
      builder: (_) => SpriteEditorDialog(project: project, sprite: sprite),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final cubit = SpriteEditorCubit(
          project: project,
          sprite: sprite,
          componentRepository: context.read(),
        );
        unawaited(cubit.started());
        return cubit;
      },
      child: const SpriteEditorView(),
    );
  }
}
