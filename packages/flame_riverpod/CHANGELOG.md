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
