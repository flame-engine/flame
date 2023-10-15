# Miscellaneous functions


## if(condition, then, else)

This function implements the ternary-if condition, it is equivalent to the `?:` operator in Dart.

The function evaluates its `condition` (which must be a boolean), and then returns either the value
of `then` if the condition was `true`, or the value of `else` if the condition was `false`. The
types of arguments `then` and `else` must be the same.

Note: Only one of the `then`/`else` values will be evaluated, depending on the `condition`. This
may be important in cases when evaluating those expressions may produce a side-effect.

```yarn
title: Birth
---
Doctor: Congratulations, you have a { if($gender == "m", "boy", "girl") }!
===
```


## plural(x, words...)

Returns the correct plural form depending on the value of variable `x`.

This function is locale-dependent, and its implementation and signature changes depending on the
`locale` property in the `YarnProject`. In all cases, the first argument `x` must be numeric,
while all other arguments should be strings.

The purpose of this function is to form correct plural phrases, according to the rules of the
current language. For example, suppose you need to say `{$n} items`, where `$n` is a variable. If
you simply plug in the value of the variable like that, you'll end up getting phrases like
"23 items", or "1 items" -- which is not what you want. So instead, the `plural()` function can be
used, which will select the correct plural form of the word "item":

```yarn
I have {plural($n, "% item")}.
```

In English locale (`en`), the function `plural()` takes either 1 or 2 `word`s after the numeral
`$x`. The first word is the singular form, and the second is the plural. The second word can be
omitted if the singular form is simple enough that its plural form can be obtained by adding either
`-s` or `-es`. For example:

```yarn
// Here "foot" is an irregular noun, so its plural form must be specified
// explicitly. At the same time, "inch" is regular, and the function
// plural() will know to add "es" to make its plural form.
The distance is {plural($ft, "% foot", "% feet")} and {plural($in, "% inch")}.
```

In locales other than English, the number of plural words can be anywhere from 1 to 3. Usually,
the first word is the singular form, while others are different plurals -- their meaning would
depend on a particular language. For example, in Ukrainian locale (`uk`) the function `plural()`
requires 3 words: the singular form, the "few" plural form, and the "many" plural form:

<!--- cSpell:ignore мене монета монети монет -->
```yarn
// Assuming locale == 'uk'
У мене є {plural($coins, "% монета", "% монети", "% монет")}.

// Produces phrases like this:
//   У мене є 21 монета
//   У мене є 23 монети
//   У мене є 25 монет
```

Note that in all examples above the words contain the `%` sign. This is used as a placeholder where
the numeral itself should be placed. It is allowed for some (or all) of the `words` to not contain
the `%` sign.


## visit_count(node)

Returns the number of times that the `node` was visited.

A node is considered "visited" if the dialogue enters and then exits that node. The node can be
exited either through the normal dialogue flow, or via the [\<\<stop\>\>] command. However, if a
runtime exception occurs while running the node, then the visit will not count.

The `node` argument must be a string, and it must contain a valid node name. If a node with the
given name does not exist in the project, an exception will be thrown.

```yarn
title: LuckyWheel
---
<<if visit_count("LuckyWheel") < 5>>
  Clown: Would you like to spin a wheel and get fabulous prizes?
  -> I sure do!
     <<jump SpinLuckyWheel>>
  -> I don't talk to strangers...
     <<stop>>
<<else>>
  Clown: Sorry kid, we're all out of prizes for now.
<<endif>>
===
```

```{seealso}
- [`visited(node)`](#visitednode)
```


## visited(node)

Returns `true` if the node with the given title was visited, and `false` otherwise.

For a node to be considered "visited", the dialogue must enter and then exit the node at least
once. For example, within a node "X" the expression `visited("X")` will return `false` during the
first run of this node, and `true` upon all subsequent runs.

The `node` argument must be a string, and it must contain a valid node name. If a node with the
given name does not exist in the project, an exception will be thrown.

```yarn
title: MerchantDialogue
---
<<if not visited("MerchantDialogue")>>
  // This part of the dialogue will run only during the first interaction
  // with the merchant.
  Merchant: Greetings! My name is Linn.
  Merchant: I offer exquisite wares for the most fastidious customers!
  Player: Hi. I'm Bob. I like stuff.
<<endif>>
...
===
```

```{seealso}
- [`visit_count(node)`](#visit_countnode)
```


[\<\<stop\>\>]: ../../commands/stop.md
