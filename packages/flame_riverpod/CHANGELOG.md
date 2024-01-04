## 5.1.4

 - Update a dependency to the latest release.

## 5.1.3

 - **FIX**: Fix logic inside flame_riverpod persistent frame callback. ([#2950](https://github.com/flame-engine/flame/issues/2950)). ([230fb88f](https://github.com/flame-engine/flame/commit/230fb88fa9f9d82711461d10fe4aff9f8520cd29))

## 5.1.2

 - **FIX**: Package flame_riverpod, setState() or markNeedsBuild() called during build. ([#2943](https://github.com/flame-engine/flame/issues/2943)). ([54d0e95d](https://github.com/flame-engine/flame/commit/54d0e95d863cc40e95f0310b4964343085f422e9))

## 5.1.1

 - **FIX**: Add super constructor fields to RiverpodAwareGameWidget ([#2932](https://github.com/flame-engine/flame/issues/2932)). ([c2e6ea71](https://github.com/flame-engine/flame/commit/c2e6ea71e5c3c5f0d7ae6bc01a6c2f1f4d4d563b))

## 5.1.0

 - **FIX**: SpriteAnimationWidget was resetting the ticker even when the playing didn't changed ([#2891](https://github.com/flame-engine/flame/issues/2891)). ([9aed8b4d](https://github.com/flame-engine/flame/commit/9aed8b4dea3074c9ca708ad991cdc90b12707fbe))
 - **FEAT**: Integration of flame_riverpod ([#2367](https://github.com/flame-engine/flame/issues/2367)). ([0c74560b](https://github.com/flame-engine/flame/commit/0c74560b2e25e86163c6c678ef6515bc11f9c3e7))

## 5.0.0

* New API with breaking changes. Added [RiverpodAwareGameWidget], [RiverpodGameMixin], [RiverpodComponentMixin]. See the example for details.

## 4.0.0+2

* Miscellaneous format post-processing on the files. 

## 4.0.0+1

* Miscellaneous tidy-up of package internals.

## 4.0.0

* Made [WidgetRef] property on [ComponentRef] private. It should not be accessed directly. 
* Removed the [riverpodAwar`eGameProvider]. If required, this is better handled at the application-level.

## 3.0.0

* Changes to focus on [FlameGame].
  * [riverpodAwareGameProvider] now expects a [FlameGame].
  * Removed the [HasComponentRef] on Game.
  * Renamed [RiverpodComponentMixin] to [HasComponentRef]
* [HasComponentRef] now has a static setter for a WidgetRef. Components that use the new [HasComponentRef] mixin no
longer need to explicitly provide a [ComponentRef].
* Renamed the [WidgetRef] property on the [ComponentRef] to [widgetRef].
* Updated Example to reflect changes.
* Updated README to reflect changes.

## 2.0.0

* Pruned the public API, removing custom widget definitions (these have now been defined inside the example for 
reference)
* Renamed [RiverpodAwareGameMixin] -> [HasComponentRef] to bring closer to the Flame 'house-style' for mixins.

## 1.1.0+2

* Another correction to README and example code. onMount should not call super.onLoad.

## 1.1.0+1

* Correction to README to reflect API change.

## 1.1.0

* Added [RiverpodComponentMixin] to handle disposing of [ProviderSubscription]s.
* Correction to the [RiverpodGameWidget] initializeGame constructor - param is now 
 [RiverpodAwareGameMixin Function (ref)] as originally intended.

## 1.0.0+1

* Reduced package description length.
* Ran dart format.

## 1.0.0

* Initial release.
  * ComponentRef
  * riverpodAwareGameProvider
  * RiverpodAwareFlameGame
  * RiverpodAwareGame
  * RiverpodGameWidget
