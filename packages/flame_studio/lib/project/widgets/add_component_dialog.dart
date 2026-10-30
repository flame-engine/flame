import 'package:flame_studio/repositories/repositories.dart';
import 'package:flutter/material.dart';

/// The name, type and, for polygons, shape entered in the
/// [AddComponentDialog].
typedef AddComponentResult = ({
  String name,
  ComponentType type,
  PolygonShape polygonShape,
});

/// {@template add_component_dialog}
/// Asks the user for the name and type of a new component, and for the
/// shape it starts with if it is a polygon.
///
/// Pops with the entered [AddComponentResult], or `null` if cancelled.
/// {@endtemplate}
class const AddComponentDialog({super.key}) extends StatefulWidget {
  /// {@macro add_component_dialog}
  this;

  /// Shows the dialog and returns the entered name and type, or `null` if
  /// cancelled.
  static Future<AddComponentResult?> show(BuildContext context) {
    return showDialog<AddComponentResult>(
      context: context,
      builder: (_) => const AddComponentDialog(),
    );
  }

  @override
  State<AddComponentDialog> createState() => _AddComponentDialogState();
}

class _AddComponentDialogState() extends State<AddComponentDialog> {
  final _controller = TextEditingController();
  ComponentType _type = ComponentType.values.first;
  PolygonShape _polygonShape = PolygonShape.triangle;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _controller.text.trim();
    if (name.isEmpty) {
      return;
    }
    Navigator.of(context)
        .pop((name: name, type: _type, polygonShape: _polygonShape));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add component'),
      content: SizedBox(
        width: 320,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 16,
          children: [
            TextField(
              controller: _controller,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Name',
                hintText: 'PlayerComponent',
              ),
              onSubmitted: (_) => _submit(),
            ),
            DropdownMenu<ComponentType>(
              label: const Text('Type'),
              expandedInsets: EdgeInsets.zero,
              initialSelection: _type,
              requestFocusOnTap: false,
              onSelected: (type) {
                if (type != null) {
                  setState(() => _type = type);
                }
              },
              dropdownMenuEntries: [
                // Hitboxes can only be children.
                for (final type in ComponentType.values)
                  if (!type.isHitbox)
                    DropdownMenuEntry(value: type, label: type.label),
              ],
            ),
            if (_type.hasVertices)
              DropdownMenu<PolygonShape>(
                label: const Text('Shape'),
                expandedInsets: EdgeInsets.zero,
                initialSelection: _polygonShape,
                requestFocusOnTap: false,
                onSelected: (shape) {
                  if (shape != null) {
                    setState(() => _polygonShape = shape);
                  }
                },
                dropdownMenuEntries: [
                  for (final shape in PolygonShape.values)
                    DropdownMenuEntry(value: shape, label: shape.label),
                ],
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ValueListenableBuilder(
          valueListenable: _controller,
          builder: (context, value, _) => FilledButton(
            onPressed: value.text.trim().isEmpty ? null : _submit,
            child: const Text('Create'),
          ),
        ),
      ],
    );
  }
}
