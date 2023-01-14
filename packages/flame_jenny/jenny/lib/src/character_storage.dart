import 'package:jenny/src/character.dart';

class CharacterStorage {
  final Map<String, Character> _cache = {};

  bool get isEmpty => _cache.isEmpty;
  bool get isNotEmpty => _cache.isNotEmpty;

  bool contains(String name) => _cache.containsKey(name);

  Character? operator [](String name) => _cache[name];

  void add(Character character) {
    _cache[character.name] = character;
    for (final alias in character.aliases) {
      _cache[alias] = character;
    }
  }
}
