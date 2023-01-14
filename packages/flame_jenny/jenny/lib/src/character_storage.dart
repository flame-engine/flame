import 'package:jenny/src/character.dart';

/// The container for all [Character]s defined in your yarn scripts. This
/// container is populated as the YarnProject parses the input scripts.
class CharacterStorage {
  final Map<String, Character> _cache = {};

  bool get isEmpty => _cache.isEmpty;
  bool get isNotEmpty => _cache.isNotEmpty;

  /// Was the character with the given name or alias added to this container?
  bool contains(String name) => _cache.containsKey(name);

  /// Retrieves the character given its name/alias, or returns `null` if such
  /// character is not present.
  Character? operator [](String name) => _cache[name];

  /// Adds a new [character] to the container.
  ///
  /// This is mostly intended for internal use; in yarn scripts use command
  /// `<<character>>` to declare characters.
  void add(Character character) {
    _cache[character.name] = character;
    for (final alias in character.aliases) {
      _cache[alias] = character;
    }
  }
}
