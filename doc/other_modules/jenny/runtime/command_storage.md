# CommandStorage

The **CommandStorage** is a part of [YarnProject] responsible for storing all [user-defined
commands]. You can access it as the `YarnProject.commands` property.

The command storage can be used to register any number of custom commands, making them available to
use in yarn scripts. Such commands must be registered before parsing the yarn scripts, or the
compiler will throw an error that the command is not recognized.

In order to register a function as a yarn command, the function must satisfy several requirements:

- The function's return value must be `void` or `Future<void>`. If the function returns a future,
  then that future will be awaited before proceeding to the next step of the dialogue. This makes it
  possible to create commands that take a certain time to unfold in the game, for example
  `<<walk>>`, `<<moveCamera>>`, or `<<prompt>>`.
- The function's arguments must be of types that are known to Yarn: `String`, `num`, `int`,
  `double`, or `bool`. All arguments must be positional, non-nullable and can't have any defaults.
- In order to register the function, use methods `addCommand0()` ... `addCommand5()`, according to
  the number of function's arguments.
- If the function's signature has 1 or more booleans at the end, then those arguments will be
  considered optional and will default to `false`.


## Methods

**hasCommand**(`String name`) → `bool`
: Returns the status of whether the command `name` has been added to the storage.

**addCommand0**(`String name`, `FutureOr<void> Function() fn`)
: Registers a no-argument function `fn` as the command `name`.

**addCommand1**(`String name`, `FutureOr<void> Function(T1) fn`)
: Registers a single-argument function `fn` as the command `name`.

**addCommand2**(`String name`, `FutureOr<void> Function(T1, T2) fn`)
: Registers a two-argument function `fn` as the command `name`.

**addCommand3**(`String name`, `FutureOr<void> Function(T1, T2, T3) fn`)
: Registers a three-argument function `fn` as the command `name`.

**addCommand4**(`String name`, `FutureOr<void> Function(T1, T2, T3, T4) fn`)
: Registers a four-argument function `fn` as the command `name`.

**addCommand5**(`String name`, `FutureOr<void> Function(T1, T2, T3, T4, T5) fn`)
: Registers a five-argument function `fn` as the command `name`.

**addOrphanedCommand**(`name`)
: Registers a command `name` which is not backed by any Dart function. Such command will still be
  delivered to [DialogueView]s via the `onCommand()` callback, but its arguments will not be parsed.

**clear**
: Removes all user-defined commands

**remove**(`String name`)
: Removes the user-defined command with the specified `name`.


## Properties

**length** → `int`
: The number of user-defined commands registered so far.

**isEmpty** → `bool`
: Returns `true` if no user-defined commands were registered.

**isNotEmpty** → `bool`
: Returns `true` if any commands have been registered


## Examples


### `<<StartQuest>>`

Suppose we want to have a yarn command `<<StartQuest>>`, which would initiate a quest. The command
would take the quest name and quest ID as arguments. Technically, just the ID should be enough --
but then it would be really difficult to read the yarn script and understand what quest is being
initiated. So, instead we'll pass both the ID and the name, and then check at runtime that the ID
of the quest matches its name.

A typical invocation of this command might look like this (note that the name of the quest is in
quotes, otherwise it would be parsed as four different arguments `"Get"`, `"rid"`, `"of"`, and
`"bandits"`):

```yarn
<<StartQuest Q037 "Get rid of bandits">>
```

In order to implement this command, we create a Dart function `startQuest()` with two string
arguments. The function will do a brief animated "Started quest X" message, but we don't want the
game dialogue to wait for that message, so we'll make the function return `void`, not a future.
Finally, we register the command with `commands.addCommand2()`.

```dart
class MyGame {
  late YarnProject yarnProject;

  void startQuest(String questId, String questName) {
    assert(quests.containsKey(questId));
    assert(quests[questId]!.name == questName);
    // ...
  }
  @override
  void onLoad() {
    yarnProject = YarnProject()
      ..commands.addCommand2('StartQuest', startQuest);
  }
}
```

Note that the name of the Dart function is different from the name of the command -- you can choose
whatever names suit your programming style best.


### `<<prompt>>`

The `<<prompt>>` function will open a modal dialogue and ask the user to enter their response. This
command will be waiting for the user's input, so it must return a future. Also, we want to return
the result of the prompt into the dialogue -- but, unfortunately, the commands are not expressions,
and are not supposed to return values. So instead we will write the result into a global variable
`$prompt`, and then the dialogue can access that variable in order to read the result of the prompt.

```dart
class MyGame {
  final YarnProject yarnProject = YarnProject();

  Future<void> prompt(String message) async {
    // This will wait until the modal dialog is popped from the router stack
    final name = await router.pushAndWait(KeyboardDialog(message));
    yarnProject.variables.setVariable(r'$prompt', name);
  }

  @override
  void onLoad() {
    yarnProject
      ..variables.setVariable(r'$prompt', '')
      ..commands.addCommand1('prompt', prompt);
  }
}
```

Then in a yarn script this command can be used like this:

```yarn
<<declare $name as String>>

title: Greeting
---
Guide: Hello, my name is Jenny, and you?
<<prompt "Enter your name:">>
<<set $player = $prompt>>  // Store the name for later
Guide: Nice to meet you, {$player}
===
```


### `<<give>>`

Suppose that we want to make a command that will give the player a certain item, or a number of
items. This command would take 3 arguments: the person who gives the items, the name of the item,
and the quantity. For example:

```yarn
<<give {$quest_reward} TraderJoe>>
```

Note that the quest reward variable will contain both the reward item and its amount, for example
it could be `"100 gold"`, `"5 potion_of_healing"`, or `'1 "Sword of Darkness"'`. When such
variable is substituted into the command at runtime, the command becomes equivalent to

```yarn
<<give 100 gold TraderJoe>>
<<give 5 potion_of_healing TraderJoe>>
<<give 1 "Sword of Darkness" TraderJoe>>
```

which will then be parsed as a regular 3-argument command corresponding to the following Dart
function:

```dart
/// Takes [amount] of [item]s from [source] and gives them to the player.
void give(int amount, String item, String source) {
  // ...
}
```


## See also

- The description of [user-defined commands] in the YarnSpinner language.
- The [UserDefinedCommand] class, which is used to inform a [DialogueView] that a custom command
  is being executed.


[DialogueView]: dialogue_view.md
[UserDefinedCommand]: user_defined_command.md
[YarnProject]: yarn_project.md
[user-defined commands]: ../language/commands/user_defined_commands.md
