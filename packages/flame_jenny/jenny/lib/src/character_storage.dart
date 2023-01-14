class CharacterStorage {
  final Map<String, Character> _cache = {};

  bool get isEmpty => _cache.isEmpty;
  bool get isNotEmpty => _cache.isNotEmpty;

  bool contains(String name) => _cache.containsKey(name);

  Character? operator [](String name) => _cache[name];

  void add(Character character) {
    for (final alias in character.aliases) {
      _cache[alias] = character;
    }
  }
}

class Character {
  Character(this.name, {List<String>? aliases}) : aliases = aliases ?? [];

  final String name;
  final List<String> aliases;
  Map<String, dynamic>? _data;

  Map<String, dynamic> get data => _data ??= <String, dynamic>{};

  @override
  String toString() => 'Character($name)';
}
