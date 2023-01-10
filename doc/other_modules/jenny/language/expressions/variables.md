# Variables

A **variable** is a place to store some piece of information -- it is the same notion as in any
other programming language. Each variable has a **name**, **value**, **type**, and a **scope**.


## Name

The **name** of a variable is how you refer to it in a `.yarn` script. The names of all variables
start with a `$` sign, followed by a letter or an underscore, and then by any number of letters,
digits, or underscores. Thus, the following are all valid variables names:

```text
$i
$WARNING
$_secret_
$door10
$climbed_over_wall_and_avoided_all_guard_patrols
$DoorPassword
```

while the following are NOT valid names:

```text
$2000_years
$[main]
@today
victory
```


## Type

Each variable has a certain **type** associated with it. The type of a variable is determined when
the variable is first declared, and it never changes afterwards.

There are three types of variables in YarnSpinner: `string`, `number`, and `bool`.

- `bool` variables can store either `true` or `false` and nothing else;
- `number` variables may contain either integer or decimal numbers, such as `0`, `42`, `2.5`;
- `string` variables contain arbitrary text, for example `"the most random number is 4"`.

```yarn
// Creates a variable $money of type number, and gives it initial value of 100
<<declare $money = 100>>

// Creates variable $name of type string, the initial value will be ""
<<declare $name as String>>
```


## Value

Each variable stores a single **value**. This value can be replaced with another value at any time,
but the type of the new value must be the same.

Each variable will have an initial value assigned to it when the variable is first created, and
then new values can be assigned with the [\<\<set\>\>][set] command.

```yarn
<<set $money += 10>>  // increases the value of $money by 10
```


## Scope

The **scope** of a variable is where exactly it can be accessed. In YarnSpinner, the variables can
be either global or local.

- The **global** variables are introduced via the [\<\<declare\>\>][declare] command, and once
  created can be accessed anywhere. The names of all global variables are unique.
- The **local** variables are created with the [\<\<local\>\>][local] command, and can only be used
  within the node where they were created. It is possible to have a local variable with the same
  name in different nodes, and they will be considered different variables.

```yarn
<<declare $global_variable = 0>>

title: MyNode
---
<<local $local_variable = 1>>
===
```


[declare]: ../commands/declare.md
[local]: ../commands/local.md
[set]: ../commands/set.md
