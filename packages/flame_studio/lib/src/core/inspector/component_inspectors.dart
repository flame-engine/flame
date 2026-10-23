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
    StringProperty('Type', () => component.runtimeType.toString()),
    StringProperty('State', () => _lifecycleState(component)),
    IntProperty(
      'Priority',
      () => component.priority,
      setValue: (value) => component.priority = value,
    ),
    IntProperty('Children', () => component.children.length),
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
    ),
    Vector2Property(
      'Size',
      () => component.size,
      setValue: (value) => component.size = value,
    ),
    Vector2Property(
      'Scale',
      () => component.scale,
      setValue: (value) => component.scale = value,
      step: 0.01,
    ),
    DoubleProperty(
      'Angle (°)',
      () => component.angle * 180 / pi,
      setValue: (value) => component.angle = value * pi / 180,
    ),
    AnchorProperty(
      'Anchor',
      () => component.anchor,
      setValue: (value) => component.anchor = value,
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
      ),
    if (component is HasPaint)
      DoubleProperty(
        'Opacity',
        () => component.opacity,
        setValue: (value) => component.opacity = value,
        step: 0.01,
        min: 0,
        max: 1,
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
