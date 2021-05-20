# Flame fire atlas

Flame fire atlas is a texture atlas lib for Flame. Atlases can be created using the Fire Atlas Editor.

## How to use

Add the dependency on your pubspec

```
flame_fire_atlas: ^1.0.0-rc1
```

Load the atlas from your assets

```dart
// file at assets/atlas.fa
final atlas = await FireAtlas.loadAsset('atlas.fa');
```

or when inside a game instance, the `loadFireAtlas` can be used:

```dart
// file at assets/atlas.fa
final atlas = await loadFireAtlas('atlas.fa');
```

With the instance loaded you can now get sprites and animations like:

```dart
atlas.getAnimation('animation_name');
atlas.getSprite('sprite_name');
```
