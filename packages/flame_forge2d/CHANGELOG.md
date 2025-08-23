## 0.19.0+5

 - Update a dependency to the latest release.

## 0.19.0+4

 - Update a dependency to the latest release.

## 0.19.0+3

 - Update a dependency to the latest release.

## 0.19.0+2

 - Update a dependency to the latest release.

## 0.19.0+1

 - Update a dependency to the latest release.

## 0.19.0

> Note: This release has breaking changes.

 - **BREAKING** **FIX**: Use 32bit Vector2 in Flame to be compatible with shaders and forge2d ([#3515](https://github.com/flame-engine/flame/issues/3515)). ([19dcecf5](https://github.com/flame-engine/flame/commit/19dcecf5df85345fd4fac168e1f360cee4665658))

## 0.18.3+1

 - **FIX**: Remove outdated deprecations ([#3541](https://github.com/flame-engine/flame/issues/3541)). ([b918e40d](https://github.com/flame-engine/flame/commit/b918e40d0ce14b89ba9b5c82aed8ff51d6f549c3))

## 0.18.3

 - **FIX**: Expose event dispatcher classes ([#3532](https://github.com/flame-engine/flame/issues/3532)). ([db8e0b20](https://github.com/flame-engine/flame/commit/db8e0b20746dc96a221dc4e85b09f5a35ecc7339))

## 0.18.2+7

 - **DOCS**: Fix workflow status badge paths ([#3517](https://github.com/flame-engine/flame/issues/3517)). ([149f16fe](https://github.com/flame-engine/flame/commit/149f16fe29f1fb14b3612964b2226c9c5c7daf95))

## 0.18.2+6

 - **FIX**: Use correct matrix indices in BodyComponent ([#3491](https://github.com/flame-engine/flame/issues/3491)). ([d6c83fab](https://github.com/flame-engine/flame/commit/d6c83fab6c5cf56b047dcd22b9f1f0a075c26201))
 - **DOCS**: Remove AI assist badges ([#3477](https://github.com/flame-engine/flame/issues/3477)). ([51d7fbc0](https://github.com/flame-engine/flame/commit/51d7fbc06d88adec2e0238c9c4738893b807ec80))

## 0.18.2+5

 - Update a dependency to the latest release.

## 0.18.2+4

 - **REFACTOR**: Fix lint issues from latest flutter release ([#3390](https://github.com/flame-engine/flame/issues/3390)). ([978ad31b](https://github.com/flame-engine/flame/commit/978ad31b429d1801097b0db385a600c85a157867))

## 0.18.2+3

 - Update a dependency to the latest release.

## 0.18.2+2

 - Update a dependency to the latest release.

## 0.18.2+1

 - Update a dependency to the latest release.

## 0.18.2

 - **DOCS**: Add AI assist badge to readme(s) ([#3226](https://github.com/flame-engine/flame/issues/3226)). ([380d6aa9](https://github.com/flame-engine/flame/commit/380d6aa946d6b852c55f4ebbfce53d2087287fa2))

## 0.18.1

 - **REFACTOR**: Modernize switch; use switch-expressions and no break; ([#3133](https://github.com/flame-engine/flame/issues/3133)). ([b283b82f](https://github.com/flame-engine/flame/commit/b283b82f6cfa7e7f2ce5ff7f657e6569667183d4))

## 0.18.0

 - **FIX**: Use camera argument name in Forge2DGame ([#3115](https://github.com/flame-engine/flame/issues/3115)). ([9d97b123](https://github.com/flame-engine/flame/commit/9d97b12348161b4b150ee4166ba552f28d5f9d8b))
 - **DOCS**: Upgrade dashbook version ([#3109](https://github.com/flame-engine/flame/issues/3109)). ([a717bcb4](https://github.com/flame-engine/flame/commit/a717bcb475a5604c5d8c66a3a5ac53f0dc173109))

## 0.17.1

 - **FIX**: Null gravity override by Forge2dGame ([#3092](https://github.com/flame-engine/flame/issues/3092)). ([3c35d59b](https://github.com/flame-engine/flame/commit/3c35d59b4a4ec064106d24a17e748005a20d9fde))

## 0.17.0

> Note: This release has breaking changes.

 - **FIX**: BodyComponent fixtures should test with global point ([#3042](https://github.com/flame-engine/flame/issues/3042)). ([7c3038be](https://github.com/flame-engine/flame/commit/7c3038becba91550eb47a033cbed7208d570e012))
 - **BREAKING** **FIX**: Migrate from `RawKeyEvent` to `KeyEvent` ([#3002](https://github.com/flame-engine/flame/issues/3002)). ([330862c9](https://github.com/flame-engine/flame/commit/330862c98ecc7ed8d94e7cae0c34cd5781da0007))

## 0.16.0+5

 - Update a dependency to the latest release.

## 0.16.0+4

 - **FIX**: Wake up bodies on gravity change ([#2954](https://github.com/flame-engine/flame/issues/2954)). ([4f58329c](https://github.com/flame-engine/flame/commit/4f58329ceacef84d91cd41019d72bc2351bc50cd))

## 0.16.0+3

 - Update a dependency to the latest release.

## 0.16.0+2

 - Update a dependency to the latest release.

## 0.16.0+1

 - Update a dependency to the latest release.

## 0.16.0
 - Updated to Forge2D 0.12.2

### Migration instructions

The gravity and bullet are now field setters and getters, so if you before had `setGravity(Vector2(0, -10))` then you now do `gravity = Vector2(0, -10);` and if you previously had `body.setBullet(true);` you now do `body.isBullet = true;`.

 - Updated to Forge2D 0.12.2

### Migration instructions

The gravity and bullet are now field setters and getters, so if you before had `setGravity(Vector2(0, -10))` then you now do `gravity = Vector2(0, -10);` and if you previously had `body.setBullet(true);` you now do `body.isBullet = true;`.

## 0.15.1

 - **FEAT**: Allow for bodyDef and fixtureDefs to be prepared earlier ([#2768](https://github.com/flame-engine/flame/issues/2768)). ([21357bca](https://github.com/flame-engine/flame/commit/21357bcac1e7e1cebfa6f2a496ec4b627d62d0e7))

## 0.15.0+1

 - Update a dependency to the latest release.

## 0.15.0

> Note: This release has breaking changes.

 - **REFACTOR**: Enable DCM linting ([#2667](https://github.com/flame-engine/flame/issues/2667)). ([27a8fd61](https://github.com/flame-engine/flame/commit/27a8fd61cb7f62513e07a93ff61cf03b426353f2))
 - **FIX**: Absolute angle takes into account BodyComponent ancestors too ([#2678](https://github.com/flame-engine/flame/issues/2678)). ([75aee767](https://github.com/flame-engine/flame/commit/75aee767811ef440841956d9e467be157c4ab880))
 - **FIX**: Proper Flame dependency in flame_forge2d ([#2644](https://github.com/flame-engine/flame/issues/2644)). ([9bbecb88](https://github.com/flame-engine/flame/commit/9bbecb88d86aa051626267fd69e5bf71fdca66d6))
 - **DOCS**: Enable CSpell on tests ([#2723](https://github.com/flame-engine/flame/issues/2723)). ([e051298c](https://github.com/flame-engine/flame/commit/e051298cba76550229780438b1a589557c7b488d))
 - **BREAKING** **FEAT**: Add CameraComponent to FlameGame ([#2740](https://github.com/flame-engine/flame/issues/2740)). ([7c2f4000](https://github.com/flame-engine/flame/commit/7c2f4000761580dbabb5d73b27f64d5819b34e8d))
 - **BREAKING** **FEAT**: Move `Forge2DGame` to use `CameraComponent` ([#2728](https://github.com/flame-engine/flame/issues/2728)). ([7a3d5126](https://github.com/flame-engine/flame/commit/7a3d5126a54d23cdebde20953772a53ba1a53204))

## 0.14.1+1

 - Update a dependency to the latest release.

## 0.14.1

 - **FIX**: Update sdk constraints to >=3.0.0 ([#2554](https://github.com/flame-engine/flame/issues/2554)). ([2f71e06e](https://github.com/flame-engine/flame/commit/2f71e06eb86ffc65cd459c4d722eee2470be13e5))
 - **FEAT**: ComponentKey API ([#2566](https://github.com/flame-engine/flame/issues/2566)). ([b3efb612](https://github.com/flame-engine/flame/commit/b3efb612cb3cb77f69bc030e9ba71516348035d2))
 - **DOCS**: Fix broken link on flame_forge2d readme ([#2588](https://github.com/flame-engine/flame/issues/2588)). ([45115bbf](https://github.com/flame-engine/flame/commit/45115bbff8539010f5d7bb7cf9479183b1a27cc8))

## 0.14.0

> Note: This release has breaking changes.

 - **FIX**: Update sdk constraints to >=3.0.0 ([#2554](https://github.com/flame-engine/flame/issues/2554)). ([2f71e06e](https://github.com/flame-engine/flame/commit/2f71e06eb86ffc65cd459c4d722eee2470be13e5))
 - **FIX**: Solve warnings from 3.10.0 analyzer ([#2532](https://github.com/flame-engine/flame/issues/2532)). ([b41622db](https://github.com/flame-engine/flame/commit/b41622db8faa7559328f83f8f1d93ec4c6386961))
 - **BREAKING** **REFACTOR**: Move `CameraComponent` and events out of experimental ([#2505](https://github.com/flame-engine/flame/issues/2505)). ([87b8a067](https://github.com/flame-engine/flame/commit/87b8a067f3e0096cebff3db4f5767e68616928fd))

## 0.13.0+1

 - **REFACTOR**: Add new lint rules ([#2477](https://github.com/flame-engine/flame/issues/2477)). ([dbda37b8](https://github.com/flame-engine/flame/commit/dbda37b81a9a7411559a6ba919ffbda6018b85c2))

## 0.13.0

> Note: This release has breaking changes.

 - **DOCS**: Update funding links ([#2420](https://github.com/flame-engine/flame/issues/2420)). ([8294a2a1](https://github.com/flame-engine/flame/commit/8294a2a15638c504aa2b77f967f5963af1f23c2c))
 - **DOCS**: Fix non-markdown section of README files ([#2406](https://github.com/flame-engine/flame/issues/2406)). ([426b3124](https://github.com/flame-engine/flame/commit/426b3124022e567633c76b80eb389ebce1772ca3))
 - **DOCS**: Update all README files for the bridge packages to be consistent and not broken ([#2402](https://github.com/flame-engine/flame/issues/2402)). ([5e8ecf54](https://github.com/flame-engine/flame/commit/5e8ecf5450688b1287368b3fbc7b0e718a29fce4))
 - **DOCS**: Added a page for Joints documentation + ConstantVolumeJoint doc and example ([#2362](https://github.com/flame-engine/flame/issues/2362)). ([957ad240](https://github.com/flame-engine/flame/commit/957ad2402af1c44aea500d77092d387ed463b7e0))
 - **BREAKING** **FEAT**: The `HasTappableComponents` mixin is no longer needed ([#2450](https://github.com/flame-engine/flame/issues/2450)). ([b5bdf4ec](https://github.com/flame-engine/flame/commit/b5bdf4ec173e87907a59a9f62fcdf35cc968af2a))

## 0.12.5

 - **FIX**: Depend on test: any for flame_test ([#2207](https://github.com/flame-engine/flame/issues/2207)). ([acfd418d](https://github.com/flame-engine/flame/commit/acfd418d882ee6872f3aa9961c39680ec123c2e6))

## 0.12.4

 - **FIX**: 🐛 unit test for `Forge2dGame` ([#2068](https://github.com/flame-engine/flame/issues/2068)). ([d659b85d](https://github.com/flame-engine/flame/commit/d659b85d090614ebb3df06fb68254c087f6f9dff))

## 0.12.3

 - **FEAT**: Allow flame_forge2d's followBodyComponent to follow centre of mass ([#1947](https://github.com/flame-engine/flame/issues/1947)) ([#1948](https://github.com/flame-engine/flame/issues/1948)). ([c4fd2ba5](https://github.com/flame-engine/flame/commit/c4fd2ba5402f42d5a333270f401bb7208e050986))
 - **DOCS**: Fix broken link in forge2d readme ([#1853](https://github.com/flame-engine/flame/issues/1853)). ([31d39f86](https://github.com/flame-engine/flame/commit/31d39f86708295ef19624554e636e1ddd4846c4d))

## 0.12.2

 - **FIX**: `renderChain` should allow open-ended chain drawing ([#1804](https://github.com/flame-engine/flame/issues/1804)). ([60daa196](https://github.com/flame-engine/flame/commit/60daa196a8b2f9d3b022bf4d25b0dc8af29f40b8))
 - **FIX**: Correct flutter constraint ([#1731](https://github.com/flame-engine/flame/issues/1731)). ([c7383843](https://github.com/flame-engine/flame/commit/c738384314a1a5c3695d1c3adaebcb59604df83a))
 - **FEAT**: Move to Flutter 3.0.0 and Dart 2.17.0 ([#1713](https://github.com/flame-engine/flame/issues/1713)). ([2a41d0d6](https://github.com/flame-engine/flame/commit/2a41d0d683391194b7209c47bde91199ab7a663e))

## 0.12.1

 - **FIX**: Correct flutter constraint ([#1731](https://github.com/flame-engine/flame/issues/1731)). ([c7383843](https://github.com/flame-engine/flame/commit/c738384314a1a5c3695d1c3adaebcb59604df83a))
 - **FEAT**: Move to Flutter 3.0.0 and Dart 2.17.0 ([#1713](https://github.com/flame-engine/flame/issues/1713)). ([2a41d0d6](https://github.com/flame-engine/flame/commit/2a41d0d683391194b7209c47bde91199ab7a663e))

## 0.12.0

> Note: This release has breaking changes.

 - **REFACTOR**: Move to package imports ([#1625](https://github.com/flame-engine/flame/issues/1625)). ([843ddc36](https://github.com/flame-engine/flame/commit/843ddc36249272fcb518b44672e1012307dfa1b5))
 - **FIX**: flips back defaultGravity on y axis ([#1585](https://github.com/flame-engine/flame/issues/1585)). ([6b217ac4](https://github.com/flame-engine/flame/commit/6b217ac466f7522772cf1f974b39af1392f5a807))
 - **FIX**: MouseJoint gets less and less reactive ([#1562](https://github.com/flame-engine/flame/issues/1562)). ([90747bf4](https://github.com/flame-engine/flame/commit/90747bf4a52bb4c82611fa1e9c50f0f11e309baa))
 - **FEAT**: Add more lint rules ([#1703](https://github.com/flame-engine/flame/issues/1703)). ([49252f8e](https://github.com/flame-engine/flame/commit/49252f8ef29aa6b77144dcb97c24346f2f39380b))
 - **FEAT**: allow controlling when a fixture is rendered ([#1648](https://github.com/flame-engine/flame/issues/1648)). ([1b59d801](https://github.com/flame-engine/flame/commit/1b59d801c6c1bcc325948ac4e18dfa536baa5a9c))
 - **FEAT**: Bump to Flutter 2.10.0 ([#1617](https://github.com/flame-engine/flame/issues/1617)). ([beac9013](https://github.com/flame-engine/flame/commit/beac901313456cf0b39b6f4e6459f0feed183614))
 - **FEAT**: allowed specifying renderBody via constructor ([#1548](https://github.com/flame-engine/flame/issues/1548)). ([ceb72666](https://github.com/flame-engine/flame/commit/ceb726666e39e20cd12786be86da60ab9cc61c9a))
 - **DOCS**: Move flame_forge2d examples to main examples ([#1588](https://github.com/flame-engine/flame/issues/1588)). ([6dd0a970](https://github.com/flame-engine/flame/commit/6dd0a970e6f106d8927b542d688f3bc9231e1b69))
 - **BREAKING** **FEAT**: enhance ContactCallback process ([#1547](https://github.com/flame-engine/flame/issues/1547)). ([a50d4a1e](https://github.com/flame-engine/flame/commit/a50d4a1e7d9eaf66726ed1bb9894c9d495547d8f))

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
