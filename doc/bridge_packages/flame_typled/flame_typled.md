# flame_typled

flame_typled provides integration between [Typled](https://pub.dev/packages/typled) sprite atlases
and Flame.

Import the `TypledSpriteAtlas` class from `'package:flame_typled/flame_typled.dart'` and load your
atlas:

```dart
final atlas = await TypledSpriteAtlas.load('assets/atlas.typled');
```

Then retrieve individual sprites by their typled id:

```dart
final mySprite = atlas.sprite('player_idle');
```

Note that this will create a new instance of Sprite, so you might want to save it.

Or create a `SpriteBatch` for efficient batch rendering:

```dart
final batch = atlas.toBatch(useAtlas: false);
```

By default, Flame Typled will add a Ghost Line busting padding of 1 pixel all around
(2 pixels total) for each tile. You can change this by passing `disablePadding: true`
to the `TypledSpriteAtlas.load()`.
