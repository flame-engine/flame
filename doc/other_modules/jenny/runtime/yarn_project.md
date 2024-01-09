# Yarn Project

A **YarnProject** is the central hub for all yarn scripts and the accompanying information.
Generally, there would be a single `YarnProject` in a game, though it is also possible to make
several yarn projects if their content is completely independent.

The standard sequence of initializing a `YarnProject` is the following:

- link user-defined functions;
- link user-defined commands;
- set the locale (if different from `en`);
- parse a `.yarn` script containing declarations of global variables and characters;
- parse all other `.yarn` scripts;
- restore the variables from a save-game storage.

For example:

```dart
final yarn = YarnProject()
  ..functions.addFunction0('money', player.getMoney)
  ..commands.addCommand1('achievement', player.earnAchievement)
  ..parse(readFile('project.yarn'))
  ..parse(readFile('chapter1.yarn'))
  ..parse(readFile('chapter2.yarn'));
```


## Properties

**locale** `String`
: The language used in this `YarnProject` (the default is `'en'`). Selecting a different language
  changes the builtin `plural()` function.

**random** `Random`
: The random number generator. This can be replaced with a different generator, if, for example,
  you need to control the seed.

**nodes** `Map<String, Node>`
: All [Node]s loaded into the project, keyed by their titles.

**variables** `VariableStorage`
: The container for all global variables used in this yarn project. There could be several reasons
  to access this storage:

  <!-- markdownlint-disable MD006 MD007 -->
  - to change the value of a yarn variable from the game. This enables you to pass the information
    from the game into the dialogue. For example, your dialogue may have variable `$gold`, which
    you may want to update whenever the player's amount of money changes within the game.
  - to store the values of all yarn variables during the save game, and to restore them when
    loading the game.
  <!-- markdownlint-enable MD006 MD007 -->

**functions** `FunctionStorage`
: The [container][FunctionStorage] for all user-defined functions linked into the project. The main
  reason to access this property is to register new custom function to be available at runtime.

  Note that all custom functions must be added to the `YarnProject` before they can be used in a
  dialogue script -- otherwise a compile error will occur when encountering an unknown function.

**commands** `CommandStorage`
: The [container][CommandStorage] for all user-defined commands linked into the project. The main
  reason to access this container is to register new custom commands.

  All custom commands must be added before they can be used in the dialogue script.

**characters** `CharacterStorage`
: The [container][CharacterStorage] for all [Character] objects declared in your yarn scripts.

**strictCharacterNames** `bool`
: If `true` (default), the validity of character names will be strictly enforced. That is, all
  characters must be declared before they can be used, using the [\<\<character\>\>] commands. If
  this property is set to false, then new [Character] objects will be created automatically as
  they are encountered in scripts.

**trueValues**, **falseValues** `Set<String>`
: The strings that can be recognized as `true`/`false` values respectively.

**variables** `VariableStorage`
: The [container][VariableStorage] for all variables declared and manipulated in your yarn scripts.
  This is also used for maintaining the visit counts for nodes that the user has visited. To
  implement a 'save game' feature it is possible to save the variables from
  `VariableStorage.variables` and later restore them again.


## Methods

**parse**(`String text`)
: Parses and compiles the `text` of a yarn script. After this command, the nodes contained within
  the script will be runnable.

  This method can be executed multiple times, and each time the new nodes will be added to the
  existing ones.


[\<\<character\>\>]: ../language/commands/character.md
[Character]: character.md
[CharacterStorage]: character_storage.md
[CommandStorage]: command_storage.md
[FunctionStorage]: function_storage.md
[Node]: node.md
[VariableStorage]: variable_storage.md
