/// A [Character] represents a particular person who is speaking a line in a
/// dialogue. All characters must be declared with the help of the
/// `<<character>>` command.
class Character {
  Character(this.name, {List<String>? aliases}) : aliases = aliases ?? [];

  Map<String, dynamic>? _data;

  /// The canonical name of the character
  final String name;

  /// The list of aliases
  final List<String> aliases;

  /// Additional information associated with this character.
  ///
  /// You can store any key-value pairs here that you want, or nothing at all.
  Map<String, dynamic> get data => _data ??= <String, dynamic>{};

  @override
  String toString() => 'Character($name)';
}
