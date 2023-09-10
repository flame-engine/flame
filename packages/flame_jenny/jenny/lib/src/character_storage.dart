import 'package:jenny/src/character.dart';
import 'package:meta/meta.dart';

/// The **CharacterStorage** is a cache for all [Character]s defined in your
/// yarn scripts. This container is populated from the `<<character>>`
/// commands as the YarnProject parses the input scripts.
class CharacterStorage {
  final Map<String, Character> _cache = {};

  bool get isEmpty => _cache.isEmpty;
  bool get isNotEmpty => _cache.isNotEmpty;

  /// Returns `true` if a character with the given name or alias was defined.
  bool contains(String name) => _cache.containsKey(name);

  /// Retrieves the character with the given name/alias, or returns `null` if
  /// such character was not present.
  Character? operator [](String name) => _cache[name];

  /// Adds a new [character] to the container.
  ///
  /// This is intended for internal use; in yarn scripts use command
  /// `<<character>>` to declare characters.
  @internal
  void add(Character character) {
    _cache[character.name] = character;
    for (final alias in character.aliases) {
      _cache[alias] = character;
    }
  }

  /// Clear all characters from storage.
  ///
  /// This could be used between scenes in preparation for loading a new
  /// set of characters. It would not generally be used while a dialog is
  /// in progress.
  void clear() {
    _cache.clear();
  }

  /// Remove a character by name. Its aliases will also be removed.
  ///
  /// This could be used if you are certain a character is no longer required.
  /// It would not generally be used while a dialog is in progress.
  void remove(String name) {
    final character = _cache[name];
    if (character != null) {
      for (final alias in character.aliases) {
        _cache.remove(alias);
      }
      _cache.remove(character.name);
    }
  }
}
