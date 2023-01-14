# CharacterStorage

The **CharacterStorage** object is a cache of all [Character]s declared in yarn scripts. Typically,
this cache will be populated with the help of the [\<\<character\>\>] commands. Adding characters
manually is possible but not recommended.


## Methods

**contains**(`String name`) → `bool`
: Returns `true` if a character with the given name or alias was defined.

**operator[]**(`String name`) → `Character?`
: Returns the [Character] object with the given name/alias, or `null` if this character was not
  defined.

**add**(`Character character`)
: Adds a new `Character` object into the storage.


[\<\<character\>\>]: ../language/commands/character.md
[Character]: character.md
