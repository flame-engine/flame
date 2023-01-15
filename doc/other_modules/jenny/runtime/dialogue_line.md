# DialogueLine

The **DialogueLine** class represents a single [Line] of text in the `.yarn` script. The
`DialogueLine` objects will be delivered to your `DialogueView` with the methods `onLineStart()`,
`onLineSignal()`, `onLineStop()`, and `onLineFinish()`.


## Properties

**character** `Character?`
: The name of the character who is speaking the line, or `null` if the line has no speaker.

**text** `String`
: The computed text of the line, after evaluating the inline expressions, stripping the markup,
  and processing the escape sequences.

**tags** `List<String>`
: The list of hashtags for this line. If there are no hashtags, the list will be empty. Each entry
  in the list will be a simple string starting with `#`.

**attributes** `List<MarkupAttribute>`
: The list of markup spans associated with the line. Each [MarkupAttribute] corresponds to a
  single span within the **text**, delineated with markup tags.

[Line]: ../language/lines.md
[MarkupAttribute]: markup_attribute.md
