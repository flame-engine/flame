import 'package:flame_studio/component_editor/widgets/property_editors/property_section.dart';
import 'package:flame_studio/repositories/repositories.dart';
import 'package:flame_studio/sprite_editor/sprite_editor.dart';
import 'package:flutter/material.dart';

/// {@template sprite_editor}
/// Edits a [ComponentSprite] in a [SpriteEditorDialog]. Used by every
/// [SpritedComponent].
/// {@endtemplate}
class const SpriteEditor({
  /// The project whose images can be picked.
  required final Project project,

  /// The current sprite.
  required final ComponentSprite value,

  /// Called with the edited sprite.
  required final ValueChanged<ComponentSprite> onChanged,
  super.key,
}) extends StatelessWidget {
  /// {@macro sprite_editor}
  this;

  Future<void> _edit(BuildContext context) async {
    final sprite = await SpriteEditorDialog.show(
      context,
      project: project,
      sprite: value,
    );
    if (sprite != null && sprite != value) {
      onChanged(sprite);
    }
  }

  @override
  Widget build(BuildContext context) {
    final image = value.image;
    final position = value.srcPosition;
    final size = value.srcSize;
    return PropertySection(
      title: 'Sprite',
      children: [
        if (image == null)
          const Text('No image selected')
        else ...[
          Text(image),
          Text(
            '${_number(size.width)} × ${_number(size.height)} at '
            '(${_number(position.x)}, ${_number(position.y)})',
          ),
        ],
        OutlinedButton.icon(
          icon: const Icon(Icons.image_outlined),
          label: Text(image == null ? 'Select sprite' : 'Edit sprite'),
          onPressed: () => _edit(context),
        ),
      ],
    );
  }

  static String _number(double value) {
    return value == value.truncateToDouble()
        ? value.toInt().toString()
        : value.toStringAsFixed(1);
  }
}
