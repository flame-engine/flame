## 4.1.3

 - Update a dependency to the latest release.

## 4.1.2

 - Update a dependency to the latest release.

## 4.1.1

 - Update a dependency to the latest release.

## 4.1.0

 - **PERF**: Optimize `TexturePackerSprite` when sprites do not need to be rotated ([#3236](https://github.com/flame-engine/flame/issues/3236)). ([e9512e9b](https://github.com/flame-engine/flame/commit/e9512e9b28188476d5956e875430f1ef195f5882))
 - **FEAT**: Enhance TexturePackerSprite ([#3224](https://github.com/flame-engine/flame/issues/3224)). ([0b0a6c1b](https://github.com/flame-engine/flame/commit/0b0a6c1bacfca8772d1b9518e9433d994e68bae1))
 - **DOCS**: Add AI assist badge to readme(s) ([#3226](https://github.com/flame-engine/flame/issues/3226)). ([380d6aa9](https://github.com/flame-engine/flame/commit/380d6aa946d6b852c55f4ebbfce53d2087287fa2))

## 4.0.1

 - **FIX**: TexturePacker fixes the wrong path for the atlas file. ([#3124](https://github.com/flame-engine/flame/issues/3124)). ([69f5c388](https://github.com/flame-engine/flame/commit/69f5c388ce4e0a64ba5f7331a596777a9eab1e40))

## 4.0.0

> Note: This release has breaking changes.

 - **BREAKING** **FEAT**: Use `Flame.images` in flame_texturepacker ([#3103](https://github.com/flame-engine/flame/issues/3103)). ([418cc578](https://github.com/flame-engine/flame/commit/418cc578053d969a4a5c3789b1713b9e1a4b3bdd))

## 3.2.0

 - **REFACTOR**: Deprecate `fromAtlas` in favour of `atlasFromAssets` and `atlasFromStorage` ([#3098](https://github.com/flame-engine/flame/issues/3098)). ([6c8190b7](https://github.com/flame-engine/flame/commit/6c8190b7215671e7d6e1e271b6aac2a9723ec20d))
 - **FEAT**: Support for new atlas format and rotated sprites ([#3097](https://github.com/flame-engine/flame/issues/3097)). ([ed690b30](https://github.com/flame-engine/flame/commit/ed690b3048924749f829c7c44156e258bf4ab3e7))
 - **FEAT**(flame_texturepacker): Expose TexturePackerAtlas ([#3047](https://github.com/flame-engine/flame/issues/3047)). ([892052b9](https://github.com/flame-engine/flame/commit/892052b99a21a8e371c4163e1e1918fd187c6e11))

## 3.1.0

> Note: This release has breaking changes.

 - **BREAKING** **FIX**: Migrate from `RawKeyEvent` to `KeyEvent` ([#3002](https://github.com/flame-engine/flame/issues/3002)). ([330862c9](https://github.com/flame-engine/flame/commit/330862c98ecc7ed8d94e7cae0c34cd5781da0007))

## 3.0.0

> Note: This release has breaking changes.

 - **REFACTOR**: Update `flame_texturepacker`'s file structure ([#3014](https://github.com/flame-engine/flame/issues/3014)). ([982f2263](https://github.com/flame-engine/flame/commit/982f2263daae882fb456e750298c874b77c5471b))
 - **FEAT**: TexturePacker atlas can be generated from device's file ([#3006](https://github.com/flame-engine/flame/issues/3006)). ([4e6968a0](https://github.com/flame-engine/flame/commit/4e6968a05c659aae09e9f613870c6e5b326f4b44))
 - **BREAKING** **FEAT**: Transfer flame_texturepacker to monorepo ([#2987](https://github.com/flame-engine/flame/issues/2987)). ([45c87ddf](https://github.com/flame-engine/flame/commit/45c87ddfb668b035f095cdc17f1a4b7662a3ae11))

## 2.1.0

 - Load spritesheets as Map

## 1.0.0

 - Load spritesheets from TexturePacker
