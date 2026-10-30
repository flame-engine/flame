import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flame_studio/repositories/repositories.dart';

part 'palette_event.dart';
part 'palette_state.dart';

/// {@template palette_bloc}
/// Loads, edits and saves the [Palette] of a [Project].
///
/// Saving also generates the Dart code of the palette in the output folder
/// of the project settings.
///
/// Colors used by a component, including the unsaved changes of the
/// [Component] being edited, can't be renamed or removed; their value can
/// still change.
/// {@endtemplate}
class PaletteBloc({
  required final Project _project,
  required final Component _editedComponent,
  required final ComponentRepository _componentRepository,
  required final ProjectRepository _projectRepository,
}) extends Bloc<PaletteEvent, PaletteState> {
  /// {@macro palette_bloc}
  this : super(const PaletteState()) {
    on<PaletteStarted>(_onStarted);
    on<PaletteColorAdded>(_onColorAdded);
    on<PaletteColorRenamed>(_onColorRenamed);
    on<PaletteColorValueChanged>(_onColorValueChanged);
    on<PaletteColorRemoved>(_onColorRemoved);
    on<PaletteSaveRequested>(_onSaveRequested);
  }

  /// The next [PaletteEntry.id].
  int _nextId = 0;

  Future<void> _onStarted(
    PaletteStarted event,
    Emitter<PaletteState> emit,
  ) async {
    emit(state.copyWith(status: PaletteStatus.loading));
    try {
      final palette = await _componentRepository.getPalette(_project.path);
      final components = [
        for (final component in await _componentRepository.getComponents(
          _project.path,
        ))
          if (component.name != _editedComponent.name) component,
        _editedComponent,
      ]..sort((a, b) => a.name.compareTo(b.name));
      final usage = <String, List<String>>{};
      for (final component in components) {
        for (final color in component.usedPaletteColors) {
          (usage[color] ??= []).add(component.name);
        }
      }
      emit(
        state.copyWith(
          status: PaletteStatus.ready,
          savedPalette: palette,
          usage: usage,
          entries: [
            for (final color in palette.colors)
              PaletteEntry(id: _nextId++, color: color, savedName: color.name),
          ],
        ),
      );
    } on Exception {
      emit(state.copyWith(status: PaletteStatus.failure));
    }
  }

  void _onColorAdded(PaletteColorAdded event, Emitter<PaletteState> emit) {
    if (!state.isEditable) {
      return;
    }
    final color = PaletteColor(
      name: state.palette.uniqueColorName(),
      color: ComponentPaint.defaultColor,
    );
    emit(
      state.copyWith(
        status: PaletteStatus.ready,
        entries: [
          ...state.entries,
          PaletteEntry(id: _nextId++, color: color),
        ],
      ),
    );
  }

  void _onColorRenamed(PaletteColorRenamed event, Emitter<PaletteState> emit) {
    // Invalid names are kept, so the user can fix them; they prevent saving.
    _editEntry(emit, event.id, (entry) {
      if (state.usersOf(entry).isNotEmpty) {
        return entry;
      }
      return entry.copyWith(color: entry.color.copyWith(name: event.name));
    });
  }

  void _onColorValueChanged(
    PaletteColorValueChanged event,
    Emitter<PaletteState> emit,
  ) {
    _editEntry(
      emit,
      event.id,
      (entry) =>
          entry.copyWith(color: entry.color.copyWith(color: event.color)),
    );
  }

  void _onColorRemoved(PaletteColorRemoved event, Emitter<PaletteState> emit) {
    if (!state.isEditable) {
      return;
    }
    final entries = [
      for (final entry in state.entries)
        if (entry.id != event.id || state.usersOf(entry).isNotEmpty) entry,
    ];
    if (entries.length == state.entries.length) {
      return;
    }
    emit(state.copyWith(status: PaletteStatus.ready, entries: entries));
  }

  void _editEntry(
    Emitter<PaletteState> emit,
    int id,
    PaletteEntry Function(PaletteEntry entry) edit,
  ) {
    if (!state.isEditable) {
      return;
    }
    final entries = state.entries
        .map((entry) => entry.id == id ? edit(entry) : entry)
        .toList();
    emit(state.copyWith(status: PaletteStatus.ready, entries: entries));
  }

  Future<void> _onSaveRequested(
    PaletteSaveRequested event,
    Emitter<PaletteState> emit,
  ) async {
    if (!state.canSave) {
      return;
    }
    final palette = state.palette;
    emit(state.copyWith(status: PaletteStatus.saving));
    try {
      await _componentRepository.savePalette(_project.path, palette);
    } on Exception {
      emit(state.copyWith(status: PaletteStatus.failure));
      return;
    }

    // Saved colors are now referenced by their current name.
    void emitSaved(PaletteStatus status) {
      emit(
        state.copyWith(
          status: status,
          savedPalette: palette,
          entries: [
            for (final entry in state.entries)
              PaletteEntry(
                id: entry.id,
                color: entry.color,
                savedName: entry.color.name,
              ),
          ],
        ),
      );
    }

    try {
      final settings = await _projectRepository.getSettings(_project);
      await _componentRepository.writePaletteCode(
        _project.path,
        settings.outputPath,
        palette,
      );
      emitSaved(PaletteStatus.saved);
    } on GeneratedFileConflictException {
      emitSaved(PaletteStatus.codeConflict);
    } on Exception {
      emitSaved(PaletteStatus.codeFailure);
    }
  }
}
