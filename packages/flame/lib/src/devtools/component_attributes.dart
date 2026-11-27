import 'package:flame/components.dart';

/// The attributes of [component] that are reported to the devtools extension
/// and the Flame CLI, as JSON compatible values.
///
/// Every component has a `priority`, a [PositionComponent] additionally has
/// its `position`, `size`, `angle`, `scale` and `anchor`, and a
/// [TextComponent] also has its `text`.
Map<String, dynamic> componentAttributes(Component component) {
  return {
    'priority': component.priority,
    if (component is PositionComponent) ...{
      'position': [component.x, component.y],
      'size': [component.width, component.height],
      'angle': component.angle,
      'scale': [component.scale.x, component.scale.y],
      'anchor': component.anchor.toString(),
    },
    if (component is TextComponent) 'text': component.text,
  };
}
