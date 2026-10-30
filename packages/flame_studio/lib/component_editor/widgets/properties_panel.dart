import 'package:flame_studio/component_editor/bloc/component_editor_bloc.dart';
import 'package:flame_studio/component_editor/widgets/preview/preview_hitboxes.dart';
import 'package:flame_studio/component_editor/widgets/property_editors/property_editors.dart';
import 'package:flame_studio/repositories/repositories.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// {@template properties_panel}
/// Lists an editor for every property of the node selected in the
/// component tree.
///
/// Editors are picked from the capabilities the node implements, so a new
/// component type gets them without changes here. The name, the position,
/// the anchor and the angle are only edited on children: the root name is
/// its file and class name, and the root is placed by whoever uses it.
/// {@endtemplate}
class const PropertiesPanel({super.key}) extends StatelessWidget {
  /// {@macro properties_panel}
  this;

  @override
  Widget build(BuildContext context) {
    final (component, selectedPath, palette) = context
        .select<ComponentEditorBloc, (Component, List<int>, Palette)>(
          (bloc) => (
            bloc.state.selectedNode,
            bloc.state.selectedPath,
            bloc.state.palette,
          ),
        );
    final bloc = context.read<ComponentEditorBloc>();
    final isRoot = selectedPath.isEmpty;

    return ListView(
      // Fresh fields for every node, so edits never leak between nodes.
      key: ValueKey(selectedPath.join('.')),
      children: [
        if (!isRoot)
          PropertySection(
            title: 'Name',
            children: [
              NameField(
                value: component.name,
                validator: (name) => _nameError(
                  bloc.state.component.validateChildName(
                    selectedPath,
                    name,
                    takenClassNames: bloc.state.takenClassNames.keys.toSet(),
                  ),
                ),
                onChanged: (name) => bloc.add(ComponentEditorNameChanged(name)),
              ),
            ],
          ),
        if (component case final PositionedComponent positioned when !isRoot)
          PositionEditor(
            value: positioned.position,
            onChanged: (position) =>
                bloc.add(ComponentEditorPositionChanged(position)),
          ),
        if (component case final AnchoredComponent anchored when !isRoot)
          AnchorEditor(
            value: anchored.anchor,
            onChanged: (anchor) =>
                bloc.add(ComponentEditorAnchorChanged(anchor)),
          ),
        if (component case final RotatedComponent rotated when !isRoot)
          AngleEditor(
            value: rotated.angle,
            onChanged: (angle) => bloc.add(ComponentEditorAngleChanged(angle)),
          ),
        if (component case final SizedComponent sized)
          SizeEditor(
            value: sized.size,
            onChanged: (size) => bloc.add(ComponentEditorSizeChanged(size)),
          ),
        if (component case final RadiusComponent round)
          RadiusEditor(
            value: round.radius,
            onChanged: (radius) =>
                bloc.add(ComponentEditorRadiusChanged(radius)),
          ),
        if (component case final VerticesComponent polygon)
          VerticesEditor(
            value: polygon.vertices,
            paint: switch (component) {
              PaintedComponent(:final paint) => paint.copyWith(
                color: paint.resolvedColor(palette),
              ),
              // Drawn like in the preview.
              HitboxComponent() => ComponentPaint(
                color: PreviewHitbox.color.toARGB32(),
                style: PaintStyle.stroke,
              ),
              _ => const ComponentPaint(),
            },
            onChanged: (vertices) =>
                bloc.add(ComponentEditorVerticesChanged(vertices)),
          ),
        if (component case final PaintedComponent painted)
          PaintEditor(
            value: painted.paint,
            palette: palette,
            onChanged: (paint) => bloc.add(ComponentEditorPaintChanged(paint)),
          ),
        if (component case final HitboxComponent hitbox)
          CollisionEditor(
            value: hitbox.collision,
            onChanged: (collision) =>
                bloc.add(ComponentEditorCollisionChanged(collision)),
          ),
      ],
    );
  }

  static String? _nameError(ChildNameError? error) {
    return switch (error) {
      null => null,
      ChildNameError.invalid =>
        'Use a valid Dart identifier: letters, digits and underscores, '
            'not starting with a digit, and not a keyword',
      ChildNameError.reserved =>
        'Already a member of the parent component in Flame',
      ChildNameError.duplicate => 'Another component already uses this name',
      ChildNameError.conflict =>
        'Generates the same class as a part of another component of the '
            'project',
    };
  }
}
