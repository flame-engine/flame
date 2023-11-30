# FunctionStorage

The **FunctionStorage** is a part of [YarnProject] responsible for storing all [user-defined
functions]. You can access it as the `YarnProject.functions` property.

The function storage can be used to register any number of custom functions, making them
available to use in yarn scripts. Such functions must be registered before parsing the yarn
scripts, or the compiler will throw an error that the function name is not recognized.

A Dart function can be registered as a user-defined function in Jenny, if it satisfies the
following requirements:

- its return type is one of `int`, `double`, `num`, `bool`, or `String`;
- all its arguments are positional, i.e. there are no named arguments;
- all its arguments have types `int`, `int?`, `double`, `double?`, `num`, `num?`, `bool`, `bool?`,
  `String`, or `String?`;
- the nullable arguments, if any, must come after the non-nullable ones. These arguments become
  optional in Yarn scripts, and if not provided they will be passed as `null` values;
- the first argument in a function can also be `YarnProject`. If such argument is present, then
  it will be passed automatically. For example, if you have a function `fn(YarnProject, int)`,
  then it can be invoked from the yarn script simply as `fn(1)`.

A Dart function can then be added using one of the methods `addFunction0`, ..., `addFunction4`,
depending on how many arguments the function has (this is a limitation of Dart's template language).
When registering a function, you give it a `name`, under this function will be known in Yarn
scripts. This name can be the same, or different from the real function's name. For example, you
may have a function `hasVisitedTheWizard()` in your game, but you'd register it under the name
`has_visited_the_wizard()` in your YarnProject.

Keep in mind that the name of the user-defined function must be:

- unique;
- a valid ID;
- cannot be the same as any built-in function.


## Methods

**hasFunction**(`String name`) → `bool`
: Returns the status of whether the function `name` has been already registered.

**addFunction0**(`String name`, `T0 Function() fn`)
: Registers a no-argument function `fn` as the user-defined function `name`.

**addFunction1**(`String name`, `T0 Function(T1) fn1`)
: Registers a single-argument function `fn1` under the name `name`.

**addFunction2**(`String name`, `T0 Function(T1, T2) fn2`)
: Registers a two-argument function `fn2` with the given `name`.

**addFunction3**(`String name`, `T0 Function(T1, T2, T3) fn3`)
: Registers a three-argument function `fn3` with the name `name`.

**addFunction4**(`String name`, `T0 Function(T1, T2, T3, T4) fn4`)
: Registers a four-argument function `fn4` as `name`.

**clear**
: Removes all user-defined functions

**remove**(`String name`)
: Removes the user-defined function with the specified `name`.


## Properties

**length** → `int`
: The number of user-defined functions registered so far.

**isEmpty** → `bool`
: Returns `true` if no user-defined functions were registered.

**isNotEmpty** → `bool`
: Has any functions been registered at all?


[user-defined functions]: ../language/expressions/functions/functions.md#user-defined-functions
