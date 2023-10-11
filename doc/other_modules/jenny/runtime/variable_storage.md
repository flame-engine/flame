# VariableStorage

```{dartdoc}
:package: jenny
:symbol: VariableStorage
:file: src/variable_storage.dart
```


## Accessing variable storage

Variable storage is accessed via the [YarnProject].

```dart
final variables = yarnProject.variables;
```


## Removing variables

In most cases variables should be retained for the life of the [YarnProject]. However there may be
situations where variables need to be removed from storage. For example, in a game with many
scenes, variables specific to that scene could be removed if they are no longer required.

Remove all variables with `clear`. By default this will retain node visit counts, which are also
stored as variables. Node visit counts are used by Yarn for logic such as 'do this if the node has
already been visited', so it's best to leave these alone. However, to remove them as well set
`clearNodeVisits` to `true`.

```dart
/// Clear all variables except node visit counts.
yarnProject.variables.clear();

/// Clear all variables including node visit counts.
yarnProject.variables.clear(clearNodeVisits: true);
```

Use `remove` to remove a single variable.

```dart
yarnProject.variables.remove('money');
```

[YarnProject]: yarn_project.md
