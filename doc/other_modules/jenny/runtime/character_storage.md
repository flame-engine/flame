# CharacterStorage

```{dartdoc}
:package: jenny
:symbol: CharacterStorage
:file: src/character_storage.dart
```


## Accessing character storage

Character storage is accessed via the [YarnProject].

```dart
final characters = yarnProject.characters;
```


## Removing characters

There may be situations where characters need to be removed from storage. For example, in a game
with many scenes, characters could be removed after a scene and new characters loaded for the next
scene.

Remove all characters with `clear`.

```dart
yarnProject.characters.clear();
```

Use `remove` to remove a single character. Pass in the name of the character or any of its
aliases. The character and all its aliases will be removed.

```dart
yarnProject.characters.remove('Jenny');
```

[YarnProject]: yarn_project.md
