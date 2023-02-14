import 'package:jenny/jenny.dart';

/// A **Character** represents a person who is speaking a particular line in a
/// dialogue. This object is available as the `.character` property of a
/// [DialogueLine] delivered to your [DialogueView].
///
/// All characters must be declared with the help of the `<<character>>`
/// command, unless [YarnProject]'s setting `strictCharacterNames` is set to
/// false.
class Character {
  Character(this.name, {List<String>? aliases}) : aliases = aliases ?? [];

  Map<String, dynamic>? _data;

  /// The canonical name of the character, which was the first argument in the
  /// [<<character>>] command.
  final String name;

  /// Additional names (IDs) that may be used for this character in yarn
  /// scripts.
  final List<String> aliases;

  /// Additional information associated with this character. This may include
  /// their short bio, portrait, affiliation, color, etc. This information
  /// must be stored for each character manually, and then it will be
  /// accessible from [DialogueView]s.
  ///
  /// You can store any key-value pairs here that you want, or nothing at all.
  Map<String, dynamic> get data => _data ??= <String, dynamic>{};

  @override
  String toString() => 'Character($name)';
}
