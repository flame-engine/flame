part of 'project_bloc.dart';

/// The status of the [ProjectBloc].
enum ProjectStatus() {
  /// Nothing has been loaded yet.
  initial,

  /// The components are being loaded.
  loading,

  /// The components are loaded.
  ready,

  /// A component was created; see [ProjectState.createdComponent].
  created,

  /// The requested component name is not a valid identifier.
  invalidName,

  /// A component with the requested name already exists.
  alreadyExists,

  /// The class generated for the requested name is already generated for
  /// another component; see [ProjectState.conflictingComponent].
  classConflict,

  /// Something went wrong.
  failure,
}

/// {@template project_state}
/// The state of the [ProjectBloc].
/// {@endtemplate}
final class const ProjectState({
  /// The current status.
  final ProjectStatus status = ProjectStatus.initial,

  /// The project components, sorted by name.
  final List<Component> components = const [],

  /// The last created component.
  final Component? createdComponent,

  /// The name of the component that already generates the class of the
  /// last rejected name. Only set while the status is
  /// [ProjectStatus.classConflict].
  final String? conflictingComponent,
}) extends Equatable {
  /// {@macro project_state}
  this;

  /// Returns a copy of this state with the given fields replaced.
  ProjectState copyWith({
    ProjectStatus? status,
    List<Component>? components,
    Component? createdComponent,
    String? conflictingComponent,
  }) {
    return ProjectState(
      status: status ?? this.status,
      components: components ?? this.components,
      createdComponent: createdComponent ?? this.createdComponent,
      conflictingComponent:
          (status ?? this.status) == ProjectStatus.classConflict
          ? conflictingComponent ?? this.conflictingComponent
          : null,
    );
  }

  @override
  List<Object?> get props => [
    status,
    components,
    createdComponent,
    conflictingComponent,
  ];
}
