/// The categories that group the commands in the output of `flame --help`.
///
/// The categories are shown in alphabetical order, which matches the order
/// in which they are typically used: create the game, launch it, look at it,
/// change it, play it.
abstract final class CommandCategories {
  static const creating = 'Creating a game';
  static const launching = 'Launching the game';
  static const observing = 'Observing the game';
  static const changing = 'Pausing and changing the game';
  static const playing = 'Playing the game';
}
