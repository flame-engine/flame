part of 'palette_bloc.dart';

/// An event of the [PaletteBloc].
sealed class const PaletteEvent() extends Equatable {
  /// Creates a [PaletteEvent].
  this;

  @override
  List<Object?> get props => [];
}

/// The palette dialog was opened.
final class const PaletteStarted() extends PaletteEvent {
  /// Creates a [PaletteStarted] event.
  this;
}

/// The user added a color.
final class const PaletteColorAdded() extends PaletteEvent {
  /// Creates a [PaletteColorAdded] event.
  this;
}

/// The user renamed the color of the entry with [id].
final class const PaletteColorRenamed(
  /// The [PaletteEntry.id] of the color.
  final int id,

  /// The new name.
  final String name,
) extends PaletteEvent {
  /// Creates a [PaletteColorRenamed] event.
  this;

  @override
  List<Object> get props => [id, name];
}

/// The user changed the value of the color of the entry with [id].
final class const PaletteColorValueChanged(
  /// The [PaletteEntry.id] of the color.
  final int id,

  /// The new value, as a 32 bit ARGB value.
  final int color,
) extends PaletteEvent {
  /// Creates a [PaletteColorValueChanged] event.
  this;

  @override
  List<Object> get props => [id, color];
}

/// The user removed the color of the entry with [id].
final class const PaletteColorRemoved(
  /// The [PaletteEntry.id] of the color.
  final int id,
) extends PaletteEvent {
  /// Creates a [PaletteColorRemoved] event.
  this;

  @override
  List<Object> get props => [id];
}

/// The user asked to save the palette.
final class const PaletteSaveRequested() extends PaletteEvent {
  /// Creates a [PaletteSaveRequested] event.
  this;
}
