## [next]
- Added default render function for Box2D ChainShape
- Adding TimerComponent
- Added particles subsystem (thanks @av)

## 0.17.0
- Fixing FlareAnimation API to match convention
- Fixing FlareComponent renderization
- New GestureDetector API to Game

## 0.16.1
- Added `Bgm` class for easy looping background music management.
- Added options for flip rendering of PositionComponents easily (horizontal and vertical).

## 0.16.0
- Improve our mixin structure (breaking change)
- Adds HasGameRef mixin
- Fixes for ComposedComponent (for tapables and other apis using preAdd)
- Added no-parameter alias functions for setting the game's orientation.
- Prevent double completion on onMetricsChanged callback

## 0.15.2
- Exposing tile objects on TiledComponent (thanks @renatoferreira656)
- Adding integrated API for taps on Game class and adding Tapeables mixin for PositionComponents

## 0.15.1
- Bumped version of svg dependency
- Fixed warnings

## 0.15.0
- Refactoring ParallaxComponent (thanks @spydon)
- Fixing flare animation with embed images
- Adding override paint parameter to Sprite, and refactoring it have named optional parameters

## 0.14.2
- Refactoring BaseGame debugMode
- Adding SpriteSheet class
- Adding Flame.util.spriteAsWidget
- Fixing AnimationComponent.empty()
- Fixing FlameAudio.loopLongAudio

## 0.14.1
- Fixed build on travis
- Updated readme badges
- Fixed changelog
- Fixed warning on audiopool, added audiopool example in docs

## 0.14.0
- Adding Timer#isRunning method
- Adding Timer#progress getter
- Updating Flame to work with Flutter >= 1.6.0

## 0.13.1
- Adding Timer utility class
- Adding `destroyOnFinish` flag for AnimationComponent
- Fixing release mode on examples that needed screen size
- Bumping dependencies versions (audioplayers and path_provider)

## 0.13.0
- Downgrading flame support to stable channel.

## 0.12.2
- Added more functionality to the Position class (thanks, @illiapoplawski)

## 0.12.1
- Fixed PositionComponent#setByRect to comply with toRect (thanks, @illiapoplawski)

## 0.12.0
- Updating flutter_svg and pubspec to support the latest flutter version (1.6.0)
- Adding Flare Support
- Fixing PositionComponent#toRect which was not considering the anchor property (thanks, @illiapoplawski)

## [0.11.2]
- Fixed bug on animatons with a single frame
- Fixed warning on using specific version o flutter_svg on pubspec
- ParallaxComponent is not abstract anymore, as it does not include any abstract method
- Added some functionality to Position class

## [0.11.1]
- Fixed lack of paint update when using AnimationAsWidget as pointed in #78
- Added travis (thanks, @renancarujo)

## [0.11.0]
- Implementing low latency api from audioplayers (breaking change)
- Improved examples by adding some instructions on how to run
- Add notice on readme about the channel
- Upgrade path_provider to fix conflicts

## [0.10.4]
- Fix breaking change on svg plugin

## [0.10.3]
- Svg support
- Adding `Animation#reversed` allowing a new reversed animation to be created from an existing animation.
- Fix games inside regular apps when the component is inside a sliver
- Support asesprite animations

## [0.10.2]
- Fixed some warnings and formatting

## [0.10.1]
- Fixes some typos
- Improved docs
- Extracted gamepads to a new lib, lots of improvements there (thanks, @erickzanardo)
- Added more examples and an article

## [0.10.0]
- Fixing a few minor bugs, typos, improving docs
- Adding the Palette concept: easy access to white and black colors/paints, create your palette to keep your game organized.
- Adding the Anchor concept: specify where thins should anchor, added to PositionComponent and to the new text releated features.
- Added a whole bunch of text related components: TextConfig allows you to easily define your typography information, TextComponent allows for easy rendering of stuff and TextBox can make sized texts and also typing effects.
- Improved Utils to have better and more concise APIs, removed unused stuff.
- Adding TiledComponent to integrate with tiled

## [0.9.5]
- Add `elapsed` property to Animation (thanks, @ianliu)
- Fixed minor typo on documentation

## [0.9.4]
- Bumps audioplayers version

## [0.9.3]
- Fixes issue when switching between games where new game would not attach

## [0.9.2]
- Fixes to work with Dart 2.1

## [0.9.1]
- Updated audioplayers and box2d to fix bugs

## [0.9.0]
- Several API changes, using new audioplayers 0.6.x

## [0.8.4]
- Added more consistent APIs and tests

## [0.8.3]
- Need to review audioplayers 0.5.x

## [0.8.2]
- Added better documentation, tutorials and examples
- Minor tweaks in the API
- New audioplayers version

## [0.8.1]
- The Components Overhaul Update: This is major update, even though we are keeping things in alpha (version 0.*)
- Several major upgrades regarding the component system, new component types, Sprites and SpriteSheets, better image caching, several improvements with structure, a BaseGame, a new Game as a widget, that allows you to embed inside apps and a stop method. More minor changes.

## [0.6.1]
 - Bump required dart version

## [0.6.0]
 - Adding audio suport for iOS (bumping audioplayers version)

## [0.5.0]
 - Adding a text method to Util to more easily render a Paragraph

## [0.4.0]
 - Upgraded AudioPlayers, added method to disable logging
 - Created PositionComponent with some useful methods
 - A few refactorings

## [0.3.0]
 - Added a pre-load method for Audio module

## [0.2.0]
 - Added a loop method for playing audio on loop
 - Added the option to make rectangular SpriteComponents, not just squares

## [0.1.0]
 - First release, basic utilities
