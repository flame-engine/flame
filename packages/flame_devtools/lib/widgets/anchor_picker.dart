import 'package:flame/widgets.dart';
import 'package:flame_devtools/material.dart';

/// A 3x3 grid of buttons for choosing one of the nine predefined anchors.
///
/// The currently selected anchor is highlighted and its name is shown next to
/// the grid. A custom anchor, which has no cell in the grid, is displayed as
/// text only, and no cell is highlighted until the user picks a predefined one.
class const AnchorPicker({
  required final String anchor,
  required final ValueChanged<String> onSelected,
  super.key,
}) extends StatelessWidget {
  static const _columns = 3;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < Anchor.values.length; i += _columns)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final name
                      in Anchor.values
                          .sublist(i, i + _columns)
                          .map((a) => a.name))
                    IconButton(
                      key: Key('anchor_cell_$name'),
                      tooltip: name,
                      visualDensity: VisualDensity.compact,
                      iconSize: 16,
                      isSelected: name == anchor,
                      icon: const Icon(Icons.circle_outlined),
                      selectedIcon: const Icon(Icons.circle),
                      onPressed: () => onSelected(name),
                    ),
                ],
              ),
          ],
        ),
        const SizedBox(width: 12),
        Flexible(child: Text(anchor, key: const Key('anchor_name'))),
      ],
    );
  }
}
