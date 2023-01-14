/// A [Character] represents a particular person who is speaking a line in a
/// dialogue. All characters must be declared with the help of the
/// `<<character>>` command.
class Character {
  Character(this.name, {List<String>? aliases}) : aliases = aliases ?? [];

  /// The canonical name of the character
  final String name;

  /// The list of aliases
  final List<String> aliases;
  Map<String, dynamic>? _data;

  Map<String, dynamic> get data => _data ??= <String, dynamic>{};

  @override
  String toString() => 'Character($name)';
}
