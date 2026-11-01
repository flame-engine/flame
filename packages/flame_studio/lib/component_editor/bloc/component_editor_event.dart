part of 'component_editor_bloc.dart';

/// Base class for [ComponentEditorBloc] events.
sealed class const ComponentEditorEvent() extends Equatable {
  /// Creates a [ComponentEditorEvent].
  this;

  @override
  List<Object> get props => [];
}

/// The editor opened: the other components of the project should be
/// loaded, so the names of children can be checked against their classes.
final class const ComponentEditorStarted() extends ComponentEditorEvent {
  /// Creates a [ComponentEditorStarted] event.
  this;
}

/// The user selected the node at [path] in the component tree.
final class const ComponentEditorNodeSelected(
  /// The path of the node, see [ComponentTree].
  final List<int> path,
) extends ComponentEditorEvent {
  /// Creates a [ComponentEditorNodeSelected] event.
  this;

  @override
  List<Object> get props => [path];
}

/// The user added a component of [type] inside the selected node.
///
/// Polygons start with the vertices of [polygonShape].
final class const ComponentEditorChildAdded(
  /// The type of the new component.
  final ComponentType type, {

  /// The shape of the new component, if it is a polygon.
  final PolygonShape polygonShape = PolygonShape.triangle,
}) extends ComponentEditorEvent {
  /// Creates a [ComponentEditorChildAdded] event.
  this;

  @override
  List<Object> get props => [type, polygonShape];
}

/// The user removed the node at [path] from the component tree.
///
/// The root cannot be removed.
final class const ComponentEditorNodeRemoved(
  /// The path of the node, see [ComponentTree].
  final List<int> path,
) extends ComponentEditorEvent {
  /// Creates a [ComponentEditorNodeRemoved] event.
  this;

  @override
  List<Object> get props => [path];
}

/// The user renamed the selected node.
///
/// The root can't be renamed, and names rejected by
/// [ComponentTree.validateChildName] are ignored.
final class const ComponentEditorNameChanged(
  /// The new name.
  final String name,
) extends ComponentEditorEvent {
  /// Creates a [ComponentEditorNameChanged] event.
  this;

  @override
  List<Object> get props => [name];
}

/// The user edited the position of the selected [PositionedComponent].
final class const ComponentEditorPositionChanged(
  /// The new position.
  final ComponentPosition position,
) extends ComponentEditorEvent {
  /// Creates a [ComponentEditorPositionChanged] event.
  this;

  @override
  List<Object> get props => [position];
}

/// The user edited the size of the selected [SizedComponent].
final class const ComponentEditorSizeChanged(
  /// The new size.
  final ComponentSize size,
) extends ComponentEditorEvent {
  /// Creates a [ComponentEditorSizeChanged] event.
  this;

  @override
  List<Object> get props => [size];
}

/// The user edited the anchor of the selected [AnchoredComponent].
final class const ComponentEditorAnchorChanged(
  /// The new anchor.
  final ComponentAnchor anchor,
) extends ComponentEditorEvent {
  /// Creates a [ComponentEditorAnchorChanged] event.
  this;

  @override
  List<Object> get props => [anchor];
}

/// The user edited the angle of the selected [RotatedComponent].
final class const ComponentEditorAngleChanged(
  /// The new angle.
  final ComponentAngle angle,
) extends ComponentEditorEvent {
  /// Creates a [ComponentEditorAngleChanged] event.
  this;

  @override
  List<Object> get props => [angle];
}

/// The user edited the radius of the selected [RadiusComponent].
final class const ComponentEditorRadiusChanged(
  /// The new radius.
  final ComponentRadius radius,
) extends ComponentEditorEvent {
  /// Creates a [ComponentEditorRadiusChanged] event.
  this;

  @override
  List<Object> get props => [radius];
}

/// The user edited the vertices of the selected [VerticesComponent].
final class const ComponentEditorVerticesChanged(
  /// The new vertices.
  final ComponentVertices vertices,
) extends ComponentEditorEvent {
  /// Creates a [ComponentEditorVerticesChanged] event.
  this;

  @override
  List<Object> get props => [vertices];
}

/// The user edited the paint of the selected [PaintedComponent].
final class const ComponentEditorPaintChanged(
  /// The new paint.
  final ComponentPaint paint,
) extends ComponentEditorEvent {
  /// Creates a [ComponentEditorPaintChanged] event.
  this;

  @override
  List<Object> get props => [paint];
}

/// The palette of the project changed, e.g. in the palette dialog.
final class const ComponentEditorPaletteChanged(
  /// The new palette.
  final Palette palette,
) extends ComponentEditorEvent {
  /// Creates a [ComponentEditorPaletteChanged] event.
  this;

  @override
  List<Object> get props => [palette];
}

/// The user edited the collision of the selected [HitboxComponent].
final class const ComponentEditorCollisionChanged(
  /// The new collision.
  final ComponentCollision collision,
) extends ComponentEditorEvent {
  /// Creates a [ComponentEditorCollisionChanged] event.
  this;

  @override
  List<Object> get props => [collision];
}

/// The user toggled the highlight of the selected node in the preview.
final class const ComponentEditorSelectionHighlightToggled()
    extends ComponentEditorEvent {
  /// Creates a [ComponentEditorSelectionHighlightToggled] event.
  this;
}

/// The user toggled the outlines of the hitboxes in the preview.
final class const ComponentEditorHitboxesVisibilityToggled()
    extends ComponentEditorEvent {
  /// Creates a [ComponentEditorHitboxesVisibilityToggled] event.
  this;
}

/// The user zoomed in the preview, to the next of
/// [ZoomLevels].
final class const ComponentEditorZoomedIn() extends ComponentEditorEvent {
  /// Creates a [ComponentEditorZoomedIn] event.
  this;
}

/// The user zoomed out the preview, to the previous of
/// [ZoomLevels].
final class const ComponentEditorZoomedOut() extends ComponentEditorEvent {
  /// Creates a [ComponentEditorZoomedOut] event.
  this;
}

/// The user reset the zoom of the preview to 100%.
final class const ComponentEditorZoomReset() extends ComponentEditorEvent {
  /// Creates a [ComponentEditorZoomReset] event.
  this;
}

/// The user asked to save the component.
final class const ComponentEditorSaveRequested() extends ComponentEditorEvent {
  /// Creates a [ComponentEditorSaveRequested] event.
  this;
}
