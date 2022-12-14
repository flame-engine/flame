# DialogueChoice

The **DialogueChoice** class represents multiple [Option] lines in the `.yarn` script, which will be
presented to the user so that they can make a choice for how the dialogue should proceed. The
`DialogueChoice` objects will be delivered to your `DialogueView` with the method
`onChoiceStart()`.


## Properties

**options** `List<DialogueOption>`
: The list of [DialogueOption]s comprising this choice set.


[Option]: ../language/options.md
[DialogueOption]: dialogue_option.md
