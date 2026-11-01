import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flame_studio/repositories/repositories.dart';

part 'component_editor_event.dart';
part 'component_editor_state.dart';

/// {@template component_editor_bloc}
/// Edits a [Component] of a [Project], including the tree of components
/// inside it, and saves it.
///
/// Saving also generates the Dart code of the component in the output
/// folder of the project settings.
///
/// Property events edit the selected node of the tree (the root by
/// default). They are handled through the capability interfaces
/// ([PositionedComponent], [SizedComponent], [PaintedComponent], ...), so
/// they work for every component type that has that property.
/// {@endtemplate}
class ComponentEditorBloc({
  required final Project _project,
  required Component component,
  required final ComponentRepository _componentRepository,
  required final ProjectRepository _projectRepository,
  required final EditorPreferencesRepository _editorPreferencesRepository,
}) extends Bloc<ComponentEditorEvent, ComponentEditorState> {
  /// {@macro component_editor_bloc}
  this
    : super(
        ComponentEditorState(component: component, savedComponent: component),
      ) {
    on<ComponentEditorStarted>(_onStarted);
    on<ComponentEditorNodeSelected>(_onNodeSelected);
    on<ComponentEditorChildAdded>(_onChildAdded);
    on<ComponentEditorNodeRemoved>(_onNodeRemoved);
    on<ComponentEditorNameChanged>(_onNameChanged);
    on<ComponentEditorPositionChanged>(_onPositionChanged);
    on<ComponentEditorAnchorChanged>(_onAnchorChanged);
    on<ComponentEditorAngleChanged>(_onAngleChanged);
    on<ComponentEditorSizeChanged>(_onSizeChanged);
    on<ComponentEditorRadiusChanged>(_onRadiusChanged);
    on<ComponentEditorVerticesChanged>(_onVerticesChanged);
    on<ComponentEditorPaintChanged>(_onPaintChanged);
    on<ComponentEditorCollisionChanged>(_onCollisionChanged);
    on<ComponentEditorPaletteChanged>(_onPaletteChanged);
    on<ComponentEditorSelectionHighlightToggled>(_onSelectionHighlightToggled);
    on<ComponentEditorHitboxesVisibilityToggled>(_onHitboxesVisibilityToggled);
    on<ComponentEditorZoomedIn>(_onZoomedIn);
    on<ComponentEditorZoomedOut>(_onZoomedOut);
    on<ComponentEditorZoomReset>(_onZoomReset);
    on<ComponentEditorSaveRequested>(_onSaveRequested);
  }

  /// How many saves were requested, so slower work started before a save
  /// doesn't overwrite what the save found.
  int _saves = 0;

  /// Whether a [ComponentEditorPaletteChanged] was handled.
  bool _isPaletteChanged = false;

  /// Whether the user zoomed, so the stored zoom loaded on start doesn't
  /// replace the newer one.
  bool _isZoomChanged = false;

  /// The status after an edit: edits are allowed while saving, but must not
  /// end the save, or another save could run at the same time.
  ComponentEditorStatus get _editedStatus =>
      state.status == ComponentEditorStatus.saving
      ? ComponentEditorStatus.saving
      : ComponentEditorStatus.ready;

  Future<void> _onStarted(
    ComponentEditorStarted event,
    Emitter<ComponentEditorState> emit,
  ) async {
    // A save that started meanwhile loads the same things again, and its
    // results are newer.
    final saves = _saves;
    bool isSaving() =>
        _saves != saves || state.status == ComponentEditorStatus.saving;

    try {
      final zoom = await _editorPreferencesRepository.getComponentZoom(
        projectPath: _project.path,
        componentName: state.component.name,
      );
      if (!_isZoomChanged && zoom != state.zoom) {
        emit(state.copyWith(zoom: zoom));
      }
    } on Exception {
      // The preview keeps the default zoom.
    }

    try {
      final palette = await _componentRepository.getPalette(_project.path);
      // A palette changed meanwhile is newer.
      if (!_isPaletteChanged && palette != state.palette) {
        emit(state.copyWith(palette: palette));
      }
    } on Exception {
      // Paints keep the last known value of their palette colors.
    }

    try {
      final taken = await _loadTakenClassNames();
      if (isSaving()) {
        return;
      }
      emit(state.copyWith(takenClassNames: taken));
      // Clashes from before names were checked across components.
      if (state.conflictingClassNames.isNotEmpty) {
        emit(state.copyWith(status: ComponentEditorStatus.classConflict));
      }
    } on Exception {
      // Names are still validated inside the tree, and against the other
      // components when saving.
    }

    try {
      final settings = await _projectRepository.getSettings(_project);
      final isUpToDate = await _componentRepository.isComponentCodeUpToDate(
        _project.path,
        settings.outputPath,
        state.savedComponent,
      );
      if (isSaving()) {
        return;
      }
      emit(state.copyWith(isCodeOutdated: !isUpToDate));
    } on Exception {
      // Saving still needs changes then.
    }
  }

  /// The [ComponentTree.generatedClassNames] of the other components of
  /// the project, with the component that generates each one.
  Future<Map<String, Component>> _loadTakenClassNames() async {
    final components = await _componentRepository.getComponents(_project.path);
    final name = state.component.name;
    return {
      for (final other in components)
        if (other.name != name)
          for (final className in other.generatedClassNames) className: other,
    };
  }

  void _onNodeSelected(
    ComponentEditorNodeSelected event,
    Emitter<ComponentEditorState> emit,
  ) {
    if (!state.component.hasNodeAt(event.path)) {
      return;
    }
    emit(state.copyWith(selectedPath: event.path));
  }

  void _onChildAdded(
    ComponentEditorChildAdded event,
    Emitter<ComponentEditorState> emit,
  ) {
    // Hitboxes can't have children.
    if (state.selectedNode is HitboxComponent) {
      return;
    }
    final component = state.component;
    final parentPath = state.selectedPath;
    final child = Component.create(
      component.uniqueChildName(
        event.type,
        takenClassNames: state.takenClassNames.keys.toSet(),
      ),
      event.type,
      polygonShape: event.polygonShape,
    );
    emit(
      state.copyWith(
        status: _editedStatus,
        component: component.addChildAt(parentPath, child),
        selectedPath: [
          ...parentPath,
          component.nodeAt(parentPath).children.length,
        ],
      ),
    );
  }

  void _onNodeRemoved(
    ComponentEditorNodeRemoved event,
    Emitter<ComponentEditorState> emit,
  ) {
    final path = event.path;
    if (path.isEmpty || !state.component.hasNodeAt(path)) {
      return;
    }
    emit(
      state.copyWith(
        status: _editedStatus,
        component: state.component.removeNodeAt(path),
        selectedPath: path.sublist(0, path.length - 1),
      ),
    );
  }

  void _onNameChanged(
    ComponentEditorNameChanged event,
    Emitter<ComponentEditorState> emit,
  ) {
    final path = state.selectedPath;
    if (path.isEmpty) {
      return;
    }
    final error = state.component.validateChildName(
      path,
      event.name,
      takenClassNames: state.takenClassNames.keys.toSet(),
    );
    if (error != null) {
      return;
    }
    _editSelected(emit, (node) => node.copyWithName(event.name));
  }

  void _onPositionChanged(
    ComponentEditorPositionChanged event,
    Emitter<ComponentEditorState> emit,
  ) {
    _editSelected(emit, (node) {
      if (node case final PositionedComponent node) {
        return node.copyWithPosition(event.position);
      }
      return node;
    });
  }

  void _onAnchorChanged(
    ComponentEditorAnchorChanged event,
    Emitter<ComponentEditorState> emit,
  ) {
    _editSelected(emit, (node) {
      if (node case final AnchoredComponent node) {
        return node.copyWithAnchor(event.anchor);
      }
      return node;
    });
  }

  void _onAngleChanged(
    ComponentEditorAngleChanged event,
    Emitter<ComponentEditorState> emit,
  ) {
    _editSelected(emit, (node) {
      if (node case final RotatedComponent node) {
        return node.copyWithAngle(event.angle);
      }
      return node;
    });
  }

  void _onSizeChanged(
    ComponentEditorSizeChanged event,
    Emitter<ComponentEditorState> emit,
  ) {
    _editSelected(emit, (node) {
      if (node case final SizedComponent node) {
        return node.copyWithSize(event.size);
      }
      return node;
    });
  }

  void _onRadiusChanged(
    ComponentEditorRadiusChanged event,
    Emitter<ComponentEditorState> emit,
  ) {
    _editSelected(emit, (node) {
      if (node case final RadiusComponent node) {
        return node.copyWithRadius(event.radius);
      }
      return node;
    });
  }

  void _onVerticesChanged(
    ComponentEditorVerticesChanged event,
    Emitter<ComponentEditorState> emit,
  ) {
    _editSelected(emit, (node) {
      if (node case final VerticesComponent node) {
        return node.copyWithVertices(event.vertices);
      }
      return node;
    });
  }

  void _onPaintChanged(
    ComponentEditorPaintChanged event,
    Emitter<ComponentEditorState> emit,
  ) {
    _editSelected(emit, (node) {
      if (node case final PaintedComponent node) {
        return node.copyWithPaint(event.paint);
      }
      return node;
    });
  }

  void _onCollisionChanged(
    ComponentEditorCollisionChanged event,
    Emitter<ComponentEditorState> emit,
  ) {
    _editSelected(emit, (node) {
      if (node case final HitboxComponent node) {
        return node.copyWithCollision(event.collision);
      }
      return node;
    });
  }

  void _onPaletteChanged(
    ComponentEditorPaletteChanged event,
    Emitter<ComponentEditorState> emit,
  ) {
    _isPaletteChanged = true;
    emit(state.copyWith(palette: event.palette));
  }

  /// Replaces the selected node with the result of [edit].
  void _editSelected(
    Emitter<ComponentEditorState> emit,
    Component Function(Component node) edit,
  ) {
    final component = state.component.updateNodeAt(state.selectedPath, edit);
    if (component == state.component) {
      return;
    }
    emit(state.copyWith(status: _editedStatus, component: component));
  }

  void _onSelectionHighlightToggled(
    ComponentEditorSelectionHighlightToggled event,
    Emitter<ComponentEditorState> emit,
  ) {
    emit(state.copyWith(isSelectionHighlighted: !state.isSelectionHighlighted));
  }

  void _onHitboxesVisibilityToggled(
    ComponentEditorHitboxesVisibilityToggled event,
    Emitter<ComponentEditorState> emit,
  ) {
    emit(state.copyWith(areHitboxesVisible: !state.areHitboxesVisible));
  }

  Future<void> _onZoomedIn(
    ComponentEditorZoomedIn event,
    Emitter<ComponentEditorState> emit,
  ) async {
    final zoom = state.nextZoom;
    if (zoom != null) {
      await _zoom(emit, zoom);
    }
  }

  Future<void> _onZoomedOut(
    ComponentEditorZoomedOut event,
    Emitter<ComponentEditorState> emit,
  ) async {
    final zoom = state.previousZoom;
    if (zoom != null) {
      await _zoom(emit, zoom);
    }
  }

  Future<void> _onZoomReset(
    ComponentEditorZoomReset event,
    Emitter<ComponentEditorState> emit,
  ) => _zoom(emit, EditorPreferencesRepository.defaultZoom);

  /// Shows the preview at [zoom] and remembers it for this component.
  Future<void> _zoom(Emitter<ComponentEditorState> emit, double zoom) async {
    _isZoomChanged = true;
    emit(state.copyWith(zoom: zoom));
    try {
      await _editorPreferencesRepository.setComponentZoom(
        projectPath: _project.path,
        componentName: state.component.name,
        zoom: zoom,
      );
    } on Exception {
      // The zoom is only a convenience: it is just not remembered.
    }
  }

  Future<void> _onSaveRequested(
    ComponentEditorSaveRequested event,
    Emitter<ComponentEditorState> emit,
  ) async {
    if (!state.canSave) {
      return;
    }
    _saves++;
    final component = state.component;
    emit(state.copyWith(status: ComponentEditorStatus.saving));

    // Names are validated as they are typed, but the other components may
    // not have been loaded yet, or may clash with this one already. A
    // component whose classes clash is not saved: its code wouldn't
    // compile, and its file would reserve classes other components own.
    final Map<String, Component> taken;
    try {
      taken = await _loadTakenClassNames();
    } on Exception {
      emit(state.copyWith(status: ComponentEditorStatus.failure));
      return;
    }
    if (component.generatedClassNames.any(taken.containsKey)) {
      final conflict = state.copyWith(
        status: ComponentEditorStatus.classConflict,
        takenClassNames: taken,
      );
      // Clashing children may have been renamed while loading.
      emit(
        conflict.conflictingClassNames.isEmpty
            ? conflict.copyWith(status: ComponentEditorStatus.ready)
            : conflict,
      );
      return;
    }

    try {
      await _componentRepository.saveComponent(_project.path, component);
    } on Exception {
      emit(
        state.copyWith(
          status: ComponentEditorStatus.failure,
          takenClassNames: taken,
        ),
      );
      return;
    }

    // The component is saved even if its code can't be generated; it can
    // then be saved again, without changes, to generate the code. States
    // are built from the current state, which keeps edits made while
    // saving.
    void emitSaved(ComponentEditorStatus status) {
      emit(
        state.copyWith(
          status: status,
          savedComponent: component,
          takenClassNames: taken,
          isCodeOutdated: status != ComponentEditorStatus.saved,
        ),
      );
    }

    try {
      final settings = await _projectRepository.getSettings(_project);
      await _componentRepository.writeComponentCode(
        _project.path,
        settings.outputPath,
        component,
      );
      emitSaved(ComponentEditorStatus.saved);
    } on GeneratedFileConflictException {
      emitSaved(ComponentEditorStatus.codeConflict);
    } on Exception {
      emitSaved(ComponentEditorStatus.codeFailure);
    }
  }
}
