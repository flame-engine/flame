import 'dart:math';

import 'package:flame/components.dart'
    show Component, HasPaint, HasVisibility, PositionComponent, TextComponent;
import 'package:flame_studio/src/core/inspector/inspector_property.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The inspectors used to build the sections of the Inspector panel.
final componentInspectorsProvider = Provider<List<ComponentInspector>>(
  (ref) => defaultComponentInspectors,
);

const List<ComponentInspector> defaultComponentInspectors = [
  inspectComponent,
  inspectPositionComponent,
  inspectRendering,
  inspectTextComponent,
];

InspectorSection inspectComponent(Component component) {
  return InspectorSection('Component', [
    StringProperty(
      'Type',
      () => component.runtimeType.toString(),
      description: 'The class of the component',
    ),
    StringProperty(
      'State',
      () => _lifecycleState(component),
      description: 'Where the component is in its lifecycle',
    ),
    IntProperty(
      'Priority',
      () => component.priority,
      setValue: (value) => component.priority = value,
      description:
          'The order of the component among its siblings. Components with a '
          'higher priority are updated and rendered after, so on top of, the '
          'ones with a lower priority',
    ),
    IntProperty(
      'Children',
      () => component.children.length,
      description: 'The number of direct children of the component',
    ),
    BoolProperty(
      'Debug mode',
      () => component.debugMode,
      // Children only inherit the debug mode of their parent when they are
      // mounted, so it is applied to the whole subtree here. Otherwise it would
      // have no visible effect on components that don't render anything, like
      // the game or the world.
      setValue: (value) {
        for (final descendant in component.descendants(includeSelf: true)) {
          descendant.debugMode = value;
        }
      },
      description:
          'Draws debug information, like the bounding box and position, for '
          'the component and all of its descendants',
    ),
  ]);
}

InspectorSection? inspectPositionComponent(Component component) {
  if (component is! PositionComponent) {
    return null;
  }
  return InspectorSection('Transform', [
    Vector2Property(
      'Position',
      () => component.position,
      setValue: (value) => component.position = value,
      description:
          "The position of the component's anchor, in the coordinate space of "
          'its parent',
    ),
    Vector2Property(
      'Size',
      () => component.size,
      setValue: (value) => component.size = value,
      description: 'The size of the component, before scaling',
    ),
    Vector2Property(
      'Scale',
      () => component.scale,
      setValue: (value) => component.scale = value,
      step: 0.01,
      description:
          'How much the component and its children are stretched along each '
          'of its axes. Negative values flip them',
    ),
    DoubleProperty(
      'Angle (°)',
      () => component.angle * 180 / pi,
      setValue: (value) => component.angle = value * pi / 180,
      description:
          'The rotation of the component around its anchor, clockwise, in '
          'degrees',
    ),
    AnchorProperty(
      'Anchor',
      () => component.anchor,
      setValue: (value) => component.anchor = value,
      description:
          'The point of the component that is placed at its position, and '
          'around which it rotates and scales',
    ),
  ]);
}

InspectorSection? inspectRendering(Component component) {
  final properties = <InspectorProperty<Object?>>[
    if (component is HasVisibility)
      BoolProperty(
        'Visible',
        () => component.isVisible,
        setValue: (value) => component.isVisible = value,
        description: 'Whether the component and its children are rendered',
      ),
    if (component is HasPaint)
      DoubleProperty(
        'Opacity',
        () => component.opacity,
        setValue: (value) => component.opacity = value,
        step: 0.01,
        min: 0,
        max: 1,
        description:
            'How opaque the paint of the component is, from 0 (invisible) to 1',
      ),
  ];
  return properties.isEmpty ? null : InspectorSection('Rendering', properties);
}

InspectorSection? inspectTextComponent(Component component) {
  if (component is! TextComponent) {
    return null;
  }
  return InspectorSection('Text', [
    StringProperty(
      'Text',
      () => component.text,
      setValue: (value) => component.text = value,
      description: 'The text that is rendered by the component',
    ),
  ]);
}

String _lifecycleState(Component component) {
  if (component.isRemoving) {
    return 'Removing';
  }
  if (component.isMounted) {
    return 'Mounted';
  }
  if (component.isLoaded) {
    return 'Loaded';
  }
  return component.isLoading ? 'Loading' : 'Detached';
}
