part of 'project_bloc.dart';

/// Base class for [ProjectBloc] events.
sealed class const ProjectEvent() extends Equatable {
  /// Creates a [ProjectEvent].
  this;

  @override
  List<Object> get props => [];
}

/// The project components should be (re)loaded.
final class const ProjectComponentsRequested() extends ProjectEvent {
  /// Creates a [ProjectComponentsRequested] event.
  this;
}

/// The user asked to create a component of [type] called [name].
///
/// Polygons start with the vertices of [polygonShape].
final class const ProjectComponentCreateRequested(
  /// The name of the component to create.
  final String name,

  /// The type of the component to create.
  final ComponentType type, {

  /// The shape of the component to create, if it is a polygon.
  final PolygonShape polygonShape = PolygonShape.triangle,
}) extends ProjectEvent {
  /// Creates a [ProjectComponentCreateRequested] event.
  this;

  @override
  List<Object> get props => [name, type, polygonShape];
}

/// The user confirmed that [component] should be deleted.
final class const ProjectComponentDeleteRequested(
  /// The component to delete.
  final Component component,
) extends ProjectEvent {
  /// Creates a [ProjectComponentDeleteRequested] event.
  this;

  @override
  List<Object> get props => [component];
}
