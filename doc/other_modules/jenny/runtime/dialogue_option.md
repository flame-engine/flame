# DialogueOption

The **DialogueOption** class represents a single [Option] line in the `.yarn` script. Multiple
options will be grouped into [DialogueChoice] objects.


## Properties

**text** `String`
: The computed text of the option, after evaluating the inline expressions, stripping the markup,
  and processing the escape sequences.

**tags** `List<String>`
: The list of hashtags for this option. If there are no hashtags, the list will be empty. Each entry
  in the list will be a simple string starting with `#`.

**attributes** `List<MarkupAttribute>`
: The list of markup spans associated with the option. Each [MarkupAttribute] corresponds to a
  single span within the **text**, delineated with markup tags.

**isAvailable** `bool`
: The result of evaluating the *conditional* of this option. If the option has no conditional, this
  will return `true`.

**isDisabled** `bool`
: Same as `!isAvailable`.

[Option]: ../language/options.md
[DialogueChoice]: dialogue_choice.md
