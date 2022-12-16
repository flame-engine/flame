# MarkupAttribute

A **MarkupAttribute** is a descriptor of a subrange of text in a [line], demarcated with markup
tags. For example, in a `.yarn` line below there are two ranges of text surrounded by markup tags,
and therefore there will be two `MarkupAttribute`s associated with this line:

```yarn
[b]Jenny[/b] is a library based on \
    [link url="docs.yarnspinner.dev"]YarnSpinner[/link] for Unity.
```

These `MarkupAttribute`s can be found in the `.attributes` property of a [DialogueLine][line].


## Properties

**name** `String`
: The name of the markup tag. In the example above, the name of the first attribute is `"b"`, and
  the second is `"link"`.

**start**, **end** `int`
: The location of the marked-up span within the final text of the line. The first index is
  inclusive, while the second is exclusive. The `start` may be equal to `end` for a zero-width
  markup attribute.

**length** `int`
: The length of marked-up text. This is always equal to `end - start`.

**parameters** `Map<String, dynamic>`
: The set of parameters associated with this markup attribute. In the example above, the first
  markup attribute has no parameters, so this map will be empty. The second markup attribute has a
  single parameter, so this map will be equal to `{"url": "docs.yarnspinner.dev"}`.

  The type of each parameter will be either `String`, `num`, or `bool`, depending on the type of
  expression give in the `.yarn` script. The expressions for parameter values can be dynamic, that
  is they can be evaluated at runtime. In the example below, the parameter `color` will be equal to
  the value of the variable `$color`, which may change each time the line is run.

  ```yarn
  My [i]favorite[/i] color is [bb color=$color]{$color}[/bb].
  ```

[line]: dialogue_line.md
