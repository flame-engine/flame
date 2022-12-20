# UserDefinedCommand

The **UserDefinedCommand** class represents a single invocation of a custom (non-built-in) command
within a yarn script. Objects of this type will be delivered to a [DialogueView] in its
`.onCommand()` method.


## Properties

**name** `String`
: The name of the command, without the angle brackets. For example, if the command is `<<smile>>`
  in the yarn script, then its name will be `"smile"`.

**argumentString** `String`
: Command arguments, as a single string. For example, if the command is `<<move Hippo {$delta}>>`,
  and the value of variable `$delta` is `3.17`, then the argument string will be `"Hippo 3.17"`.

  The `argumentString` is re-evaluated every time the command is executed, however, it is an error
  to access this property before the command was executed by the dialogue runner.

**arguments** `List<dynamic>?`
: Command arguments, as a list of parsed values. This property will be null if the command was
  declared without a signature (i.e. as an "orphaned command"). However, if the command was linked
  as an external function, then the number and types of arguments in the list will correspond to
  the arguments of that function.

  In the same example as above, the `arguments` will be `['Hippo', 3.17]`, assuming the linked Dart
  function is `move(String target, double distance)`.


## See also

- The description of [User-defined Commands] in the YarnSpinner language.
- The guide on how to register a new custom command in the [CommandStorage] document.


[CommandStorage]: command_storage.md
[DialogueView]: dialogue_view.md
[User-defined Commands]: ../language/commands/user_defined_commands.md
