# User-defined commands

In addition to the built-in commands, you can also declare your own **user-defined commands** for
use in your yarn scripts. Typically, these commands would perform some in-game action that can be
viewed as a natural part of the dialogue. For example, you can create commands for such action as
`<<wave>>`, `<<smile>>`, `<<frown>>`, `<<moveCamera>>`, `<<zoom>>`, `<<shakeCamera>>`,
`<<fadeOut>>`, `<<walk>>`, `<<give>>`, `<<take>>`, `<<achievement>>`, `<<GainExperience>>`,
`<<startQuest>>`, `<<finishQuest>>`, `<<openTrade>>`, `<<drawWeapon>>`, and so on.

In many cases, the commands will need to take arguments. The arguments of a user-defined command
are processed according to the following rules:

- First, all content after the command name and until the closing `>>` is parsed according to the
  rules of regular line parsing, where interpolated expressions are allowed but markup and hashtags
  are not.
- At runtime, the content of that line is evaluated, meaning that we substitute the values of all
  expressions.
- The evaluated argument string is then broken into individual arguments at whitespace, and the
  types of these arguments are checked against the signature of the backing function.
- Then, the backing function is called with the parsed arguments.
- Lastly, all dialogue views in the dialogue runner receive the `onCommand()` event.

As a concrete example, consider the following command:

```yarn
<<give Gold {round(100 * $multiplier)}>>
```

First note that, unlike builtin commands, the arguments of the command are treated as text, and any
expressions need to be placed in curly brackets.

Then, at runtime the expression is evaluated, and (assuming `$multiplier` is 1.5) the command's
argument string becomes `"Gold 150"`. The string is then broken at white spaces and each argument
is parsed according to its type in the backing Dart function. For example, if the function's
signature is `void give(String item, int amount)`, then it will be invoked as `give("Gold", 150)`.
If, on the other hand, the number or types of arguments do not match the expected signature, then
a `DialogueException` will be raised.
