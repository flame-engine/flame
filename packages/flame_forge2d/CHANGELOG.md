## 0.11.0

> Note: This release has breaking changes.

 - **FEAT**: Bump forg2d version and have flame_forge2d examples use latest syntax (#1535). ([4f7a12eb](https://github.com/flame-engine/flame/commit/4f7a12eb2c00d370fd093de4af6a3f9f740aa03a))
 - **FEAT**: Added children parameter to Component constructor (#1525). ([f0b31fcf](https://github.com/flame-engine/flame/commit/f0b31fcfc0fc6b0f8f96895ef6a68fd5a30a3159))
 - **DOCS**: Fix flame_forge2d readme links (#1540). ([c51bc6db](https://github.com/flame-engine/flame/commit/c51bc6db5dbd32283a7e441b450e0dc4636891c6))
 - **BREAKING** **FEAT**: Flip gravity in flame_forge2d to be able to mix Forge2D and Flame components (#1506). ([bdb360f1](https://github.com/flame-engine/flame/commit/bdb360f18128f9305baa0e6ca77ee6fcad496bc7))

## 0.10.0

 - Bump "flame_forge2d" to `0.10.0`.

## 0.9.0

 - Graduate package to a stable release. See pre-releases prior to this version for changelog entries.

## 0.9.0-releasecandidate.6

 - **FEAT**: updating forge2d version (#1479). ([4678e21a](https://github.com/flame-engine/flame/commit/4678e21a0b714b8344ae2453b1ac6df68adfb4cd))
 - **FEAT**: Possibility to mark gesture events as handled (#1465). ([4c3960c3](https://github.com/flame-engine/flame/commit/4c3960c3418f8ff4d557c1764c6793468238a8da))

## 0.9.0-releasecandidate.5

 - **FEAT**: `BodyComponent` can properly have normal Flame component children (#1442). ([7fe8b6de](https://github.com/flame-engine/flame/commit/7fe8b6deb18b3579fecc99cc44e0ffea73be5f02))

## 0.9.0-releasecandidate.4

 - **FIX**: Don't use debug rendering by default in BodyComponent (#1439). ([33b725e8](https://github.com/flame-engine/flame/commit/33b725e8378d4060e726e99c0452b64f54ef8f67))

## 0.9.0-releasecandidate.3

 - Update a dependency to the latest release.

## 0.9.0-releasecandidate.2

 - **FIX**: PositionBodyComponent had an async onMount, without needing (#1424). ([7b0fd20a](https://github.com/flame-engine/flame/commit/7b0fd20a2c6d9f6cac0a88877c793608ab4d14c8))
 - **FEAT**: Make ContactCallback begin end methods optional overrides (#1415). ([29dd1891](https://github.com/flame-engine/flame/commit/29dd1891b6409ed71c54e05272100dbb180d18e7))

## 0.9.0-releasecandidate.1

> Note: This release has breaking changes.

 - **REFACTOR**: Remove Loadable, optional onLoads (#1333). ([05f7a4c3](https://github.com/flame-engine/flame/commit/05f7a4c3d6b1e3b67575c4ec920cf270691bbab4))
 - **REFACTOR**: Add a few more rules to flame_lint, including use_key_in_widget_constructors (#1248). ([bac6c8a4](https://github.com/flame-engine/flame/commit/bac6c8a4469f2c5c2926335f2f589eec9b1a5b5b))
 - **FIX**: Clone input vector before projecting it (#1255). ([d1d6ad4d](https://github.com/flame-engine/flame/commit/d1d6ad4d8c07a5c6895e6120871e336d447ee5a8))
 - **FEAT**: improving generics on position body component (#1397). ([7edbb299](https://github.com/flame-engine/flame/commit/7edbb299855a3926693e846bc1f8e0cbc4272629))
 - **FEAT**: Add missing optional priority to SpriteBodyComponent (#1404). ([a000eb11](https://github.com/flame-engine/flame/commit/a000eb1172ae06ea397d6233c96f2b0ee1f0d93d))
 - **FEAT**: Components are now always added in the correct order (#1337). ([c753fc46](https://github.com/flame-engine/flame/commit/c753fc4636d337d850a5a5cc684be8155f08b214))
 - **FEAT**: Allow to pass a camera to Forge2D Game (#1364). ([9890e9ca](https://github.com/flame-engine/flame/commit/9890e9caada0abc9cd8942b840d72f98853e0cba))
 - **DOCS**: Fix various dartdoc warnings (#1353). ([9f096053](https://github.com/flame-engine/flame/commit/9f096053fd3c8ebd52d301710625a187db09704f))
 - **DOCS**: Add Raycast example for flame_forge2d (#1253). ([994f27d5](https://github.com/flame-engine/flame/commit/994f27d54ccfaeb1251dd5e95e566611fc967022))
 - **BREAKING** **FIX**: Remove pointerId from Draggable callbacks (#1313). ([27adda17](https://github.com/flame-engine/flame/commit/27adda17b7b4d8c229cca53799826c7b854eae95))

# CHANGELOG

## [0.8.3]
 - Update to Flame 1.0.0

## [0.8.2-releasecandidate.17]
 - Arguments of `PositionBodyComponent` are now optional so that initialization can be done in `onLoad`

## [0.8.2-releasecandidate.15]
 - Destroy body before calling `super.onRemove`

## [0.8.1-releasecandidate.15]
 - The rendering of `BodyComponent` is now inline with the Flame coordinate system
 - Moved `BodyComponent` base from `BaseComponent` to `Component`
 - Pass `Forge2DCamera` to super class in `Forge2DGame`

## [0.8.1-releasecandidate.13]
 - Added physics tied to widgets example
 - Added basic joint example
 - Add generics passed to HasGameRef from PositionBodyComponent and SpriteBodyComponent

## [0.8.0-releasecandidate.13]
 - Update mechanism by which `BodyComponent`'s are disposed to use the `onRemove` method
 - Flip y-axis after translation of body position, so that normal flame components can be children
 - Update to Forge2D 0.8.0
 - Update to Flame 1.0.0-releasecandidate.13
 - Rename `prepareCanvas` to `preRender`

## [0.7.3-releasecandidate.12]
 - Fix prepareCanvas type error

## [0.7.2-releasecandidate.12]
 - Update to Forge2D 0.7.2
 - Update to Flame 1.0.0-releasecandidate.12
 - Use `Camera` from Flame instead of the old internal viewport module

## [0.7.1-rc8]
 - Take viewport yFlip into consideration on `cameraFollow`
 - Update to forge2d 0.7.1
 - Update to flame 1.0.0-rc8
 - Integrate Flame viewport and camera to replace own viewport

## [0.6.4-rc4]
 - Add PositionBodyComponent, keeps a PositionComponent on top of a BodyComponent
 - Update to forge2d 0.6.4

## [0.6.3-rc4]
 - Renamed the `prepare` method to `add` to be more inline with Flame Game naming.

## [0.6.3-rc3]
 - Added an example for MouseJoint
 - Update to forge2d 0.6.3

## [0.6.2-rc3]
 - BodyComponent should follow Forge2D game debug mode
 - Fix generics for BodyComponent
 - Align with Flame 1.0.0-rc6
 - Update to forge2d 0.6.2

## [0.6.0-rc2]
 - Align with Flame 1.0.0-rc5

## [0.6.0-rc1]
 - Align with Flame 1.0.0-rc4
 - Align with Forge2D 0.6.0

## [0.5.0-rc1]
 - Initial move of box2d related files
 - Move over to refactored box2d

## [0.0.1-rc1]
 - Empty release; in the future all flame box2d related code will live here.
