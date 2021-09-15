# CHANGELOG

## [Next]
 - The rendering of `BodyComponent` is now inline with the Flame coordinate system
 - Moved `BodyComponent` base from `BaseComponent` to `Component`

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
