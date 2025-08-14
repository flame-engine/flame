# Remove Effect

This is a simple effect that can be attached to a component causing it to be removed from the game
tree after the specified delay has passed:

```{flutter-app}
:sources: ../flame/examples
:page: remove_effect
:show: widget code infobox
:width: 180
:height: 160
```


```dart
component.add(RemoveEffect(delay: 3.0));
```
