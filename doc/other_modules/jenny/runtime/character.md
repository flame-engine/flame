# Character

A **Character** represents a person who is speaking a particular line in a dialogue. This object
is available as the `.character` property of a [DialogueLine] delivered to your [DialogueView].


## Properties

**name** `String`
: The canonical name of the character, as declared by the [\<\<character\>\>] command.

**aliases** `List<String>`
: Additional names (IDs) that may be used for this character in yarn scripts.

**data** `Map<String, dynamic>`
: Extra information that you can associate with this character. This may include their short bio,
  portrait, affiliation, color, etc. This information must be stored for each character manually,
  and then it will be accessible from [DialogueView]s.


## See Also

- [CharacterStorage]: the container where all Character objects within a YarnProject are cached.


[\<\<character\>\>]: ../language/commands/character.md
[CharacterStorage]: character_storage.md
[DialogueView]: dialogue_view.md
[DialogueLine]: dialogue_line.md
