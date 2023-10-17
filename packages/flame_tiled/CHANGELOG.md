## 1.15.0

 - **REFACTOR**: Remove unnecessary 'async' keyword across the codebase [DCM] ([#2803](https://github.com/flame-engine/flame/issues/2803)). ([2dfe0e5a](https://github.com/flame-engine/flame/commit/2dfe0e5a431213c7148ab6389e3e8c8dc49fbf3d))
 - **FIX**: Remove deprecations for 1.10.0 ([#2809](https://github.com/flame-engine/flame/issues/2809)). ([5b67b8f1](https://github.com/flame-engine/flame/commit/5b67b8f14ad4fdb38a249d0a41ecba49ba2fcc44))
 - **FIX**: Parallax offset calculations in flame_tiled don't scale properly ([#2766](https://github.com/flame-engine/flame/issues/2766)). ([89e8427a](https://github.com/flame-engine/flame/commit/89e8427a7a34258ec20276e4ec64d4a484277cdd))
 - **FEAT**(flame_tiled): Allowing tilesets with images in the same folder to load ([#2814](https://github.com/flame-engine/flame/issues/2814)). ([3b0d7e65](https://github.com/flame-engine/flame/commit/3b0d7e65c2bf158db378d66c4f7e687dd05b46e1))
 - **FEAT**: AssetsBundle can be customized in Images and AssetsCache. ([#2807](https://github.com/flame-engine/flame/issues/2807)). ([a23f80e9](https://github.com/flame-engine/flame/commit/a23f80e94a5d935fc8ba232956fe02e001d5a8f9))
 - **FEAT**: Add overriding of Images and Bundle in all classes ([#2806](https://github.com/flame-engine/flame/issues/2806)). ([2df90c9b](https://github.com/flame-engine/flame/commit/2df90c9ba8f2b1cc088c5270df571eee7e18bb57))

## 1.14.1

 - Update a dependency to the latest release.

## 1.14.0

> Note: This release has breaking changes.

 - **REFACTOR**: Enable DCM linting ([#2667](https://github.com/flame-engine/flame/issues/2667)). ([27a8fd61](https://github.com/flame-engine/flame/commit/27a8fd61cb7f62513e07a93ff61cf03b426353f2))
 - **FEAT**: Expose atlas limits for `TiledComponent` ([#2701](https://github.com/flame-engine/flame/issues/2701)). ([99a1016f](https://github.com/flame-engine/flame/commit/99a1016f72d02f4a989986f224e0e77cddd0dfa8))
 - **FEAT**: Added prefix parameter to TiledComponent.load to specify assets folder for tiled maps ([#2651](https://github.com/flame-engine/flame/issues/2651)). ([d08284dd](https://github.com/flame-engine/flame/commit/d08284ddcaf5d2ad6e5312336a71a113702dc241))
 - **DOCS**: Enable CSpell on tests ([#2723](https://github.com/flame-engine/flame/issues/2723)). ([e051298c](https://github.com/flame-engine/flame/commit/e051298cba76550229780438b1a589557c7b488d))
 - **BREAKING** **FEAT**: Add CameraComponent to FlameGame ([#2740](https://github.com/flame-engine/flame/issues/2740)). ([7c2f4000](https://github.com/flame-engine/flame/commit/7c2f4000761580dbabb5d73b27f64d5819b34e8d))

## 1.13.0

 - **FIX**: Compute scale in TileLayers based on native map tile size rather than image sizes to support oversized/undersized tiles. ([#2634](https://github.com/flame-engine/flame/issues/2634)). ([1c4d6cd0](https://github.com/flame-engine/flame/commit/1c4d6cd0654f133771a7af5795cc1de2343268c1))
 - **FEAT**: Possiblity to pass in FilterQuality to tiled layers ([#2627](https://github.com/flame-engine/flame/issues/2627)). ([f3de6650](https://github.com/flame-engine/flame/commit/f3de66507e623e2fe0100cfd4d002dea14f72470))

## 1.12.0

 - **FIX**: Tiled component orthogonal test ([#2549](https://github.com/flame-engine/flame/issues/2549)). ([34e5f0e4](https://github.com/flame-engine/flame/commit/34e5f0e443e21923c311120ce8634a14339bc71d))
 - **FIX**: Update sdk constraints to >=3.0.0 ([#2554](https://github.com/flame-engine/flame/issues/2554)). ([2f71e06e](https://github.com/flame-engine/flame/commit/2f71e06eb86ffc65cd459c4d722eee2470be13e5))
 - **FEAT**: TiledAtlas.clearCache function ([#2592](https://github.com/flame-engine/flame/issues/2592)). ([d40fefcf](https://github.com/flame-engine/flame/commit/d40fefcf08850a986304472d5369dcd74f2b9d4b))
 - **FEAT**: ComponentKey API ([#2566](https://github.com/flame-engine/flame/issues/2566)). ([b3efb612](https://github.com/flame-engine/flame/commit/b3efb612cb3cb77f69bc030e9ba71516348035d2))
 - **FEAT**: Add option for a custom image and asset loader ([#2569](https://github.com/flame-engine/flame/issues/2569)). ([dfe18251](https://github.com/flame-engine/flame/commit/dfe18251c1bac8aaca9bf146e03320efbbc3ce9c))

## 1.11.0

 - **FIX**: Tiled component orthogonal test ([#2549](https://github.com/flame-engine/flame/issues/2549)). ([34e5f0e4](https://github.com/flame-engine/flame/commit/34e5f0e443e21923c311120ce8634a14339bc71d))
 - **FIX**: Update sdk constraints to >=3.0.0 ([#2554](https://github.com/flame-engine/flame/issues/2554)). ([2f71e06e](https://github.com/flame-engine/flame/commit/2f71e06eb86ffc65cd459c4d722eee2470be13e5))
 - **FEAT**: Add option for a custom image and asset loader ([#2569](https://github.com/flame-engine/flame/issues/2569)). ([dfe18251](https://github.com/flame-engine/flame/commit/dfe18251c1bac8aaca9bf146e03320efbbc3ce9c))

## 1.10.2

 - **FIX**: Update sdk constraints to >=3.0.0 ([#2554](https://github.com/flame-engine/flame/issues/2554)). ([2f71e06e](https://github.com/flame-engine/flame/commit/2f71e06eb86ffc65cd459c4d722eee2470be13e5))
 - **FIX**: Solve warnings from 3.10.0 analyzer ([#2532](https://github.com/flame-engine/flame/issues/2532)). ([b41622db](https://github.com/flame-engine/flame/commit/b41622db8faa7559328f83f8f1d93ec4c6386961))

## 1.10.1

 - **REFACTOR**: Add new lint rules ([#2477](https://github.com/flame-engine/flame/issues/2477)). ([dbda37b8](https://github.com/flame-engine/flame/commit/dbda37b81a9a7411559a6ba919ffbda6018b85c2))

## 1.10.0

 - **REFACTOR**: Divide TileLayer by its Layer type ([#2326](https://github.com/flame-engine/flame/issues/2326)). ([0c14d4cb](https://github.com/flame-engine/flame/commit/0c14d4cb87ba81957221695547bc06111a28617a))
 - **FIX**: TiledComponent now can be safely loaded regardless of the order ([#2391](https://github.com/flame-engine/flame/issues/2391)). ([4ddc4bba](https://github.com/flame-engine/flame/commit/4ddc4bba2b67ebd8c9c0e9e761eee34d2a74f62b))
 - **FEAT**: Use cached image when creating single source TiledAtlas if available ([#2348](https://github.com/flame-engine/flame/issues/2348)). ([73467c94](https://github.com/flame-engine/flame/commit/73467c941d89f68598c6dc297937af9d9896a949))
 - **FEAT**: Add ability to opt-out flip ([#2316](https://github.com/flame-engine/flame/issues/2316)). ([34c3b6bd](https://github.com/flame-engine/flame/commit/34c3b6bdc4c570f4e8641b11b94efe19bdd1ef32))
 - **DOCS**: Update funding links ([#2420](https://github.com/flame-engine/flame/issues/2420)). ([8294a2a1](https://github.com/flame-engine/flame/commit/8294a2a15638c504aa2b77f967f5963af1f23c2c))
 - **DOCS**: Fix broken image link on flame_tiled pub ([#2407](https://github.com/flame-engine/flame/issues/2407)). ([0d24a6c8](https://github.com/flame-engine/flame/commit/0d24a6c8ed4a5d4de2e653a6430a635ef881ee2e))
 - **DOCS**: Fix non-markdown section of README files ([#2406](https://github.com/flame-engine/flame/issues/2406)). ([426b3124](https://github.com/flame-engine/flame/commit/426b3124022e567633c76b80eb389ebce1772ca3))
 - **DOCS**: Update all README files for the bridge packages to be consistent and not broken ([#2402](https://github.com/flame-engine/flame/issues/2402)). ([5e8ecf54](https://github.com/flame-engine/flame/commit/5e8ecf5450688b1287368b3fbc7b0e718a29fce4))

## 1.9.1

 - Update a dependency to the latest release.

## 1.9.0

 - **FEAT**: Rename internal classes clashes with Tiled ([#2139](https://github.com/flame-engine/flame/issues/2139)). ([2224eaac](https://github.com/flame-engine/flame/commit/2224eaac701414deb76bac7f7c40a56387cdf817))

## 1.8.0

 - **REFACTOR**: Split layers into files ([#1916](https://github.com/flame-engine/flame/issues/1916)). ([dac2ee13](https://github.com/flame-engine/flame/commit/dac2ee1375a0ed9535ccd5052e0960043ec8d3d2))
 - **FIX**: Take scale into account ([#1906](https://github.com/flame-engine/flame/issues/1906)). ([27ab12ff](https://github.com/flame-engine/flame/commit/27ab12ff6865e5d3d567c4714c4737cd7a0bc1fa))
 - **FEAT**: Animated tile support! ([#1930](https://github.com/flame-engine/flame/issues/1930)). ([6410dc75](https://github.com/flame-engine/flame/commit/6410dc753ce1d044e2d8ea8061186c88d80589e9))
 - **FEAT**: Add avoid_final_parameters, depend_on_referenced_packages, unnecessary_to_list_in_spreads ([#1927](https://github.com/flame-engine/flame/issues/1927)). ([deccb434](https://github.com/flame-engine/flame/commit/deccb4349d38b6a91ccf5bdf229980b2a3296ce5))
 - **FEAT**: Tiled component is positionable ([#1900](https://github.com/flame-engine/flame/issues/1900)). ([88cb2a05](https://github.com/flame-engine/flame/commit/88cb2a05c37535053ece3eb19311c4c78fac249c))
 - **FEAT**: Add support for isometric staggered maps ([#1895](https://github.com/flame-engine/flame/issues/1895)). ([96be8408](https://github.com/flame-engine/flame/commit/96be840899022a024cef1eb853818d8138592000))
 - **FEAT**: Adding support for Group layer nesting for RenderableTileMap ([#1886](https://github.com/flame-engine/flame/issues/1886)). ([5ed34547](https://github.com/flame-engine/flame/commit/5ed345471da0586a2a3071a523c4e5b6d7f184c0))
 - **FEAT**: Hexagonal maps ([#1892](https://github.com/flame-engine/flame/issues/1892)). ([29bda336](https://github.com/flame-engine/flame/commit/29bda336b8febe9cb08dc621da3dc0271c6d2802))
 - **FEAT**: Add isometric support for flame_tiled ([#1885](https://github.com/flame-engine/flame/issues/1885)). ([cf828823](https://github.com/flame-engine/flame/commit/cf82882390efc45a0b2323463b4b28e557f5df48))

## 1.7.2

 - **FIX**: Remove unnecessary x offset ([#1838](https://github.com/flame-engine/flame/issues/1838)). ([4ea12b72](https://github.com/flame-engine/flame/commit/4ea12b724e04843b3b7dcd02dc2fb5060c9cf283))

## 1.7.1

 - **FIX**: Remove unnecessary x offset ([#1838](https://github.com/flame-engine/flame/issues/1838)). ([4ea12b72](https://github.com/flame-engine/flame/commit/4ea12b724e04843b3b7dcd02dc2fb5060c9cf283))
 - **FEAT**: Adding support for additional layer rendering options ([#1794](https://github.com/flame-engine/flame/issues/1794)). ([112acf2a](https://github.com/flame-engine/flame/commit/112acf2aa70ded86e6c2b661f5d6a4855d043f99))

## 1.7.0

 - **FIX**: Correct flutter constraint ([#1731](https://github.com/flame-engine/flame/issues/1731)). ([c7383843](https://github.com/flame-engine/flame/commit/c738384314a1a5c3695d1c3adaebcb59604df83a))
 - **FIX**: tiled example size ([#1729](https://github.com/flame-engine/flame/issues/1729)). ([8306fc11](https://github.com/flame-engine/flame/commit/8306fc1104cb752ce71108abb3768f05ce1b1dac))
 - **FEAT**: Adding support for additional layer rendering options ([#1794](https://github.com/flame-engine/flame/issues/1794)). ([112acf2a](https://github.com/flame-engine/flame/commit/112acf2aa70ded86e6c2b661f5d6a4855d043f99))
 - **FEAT**: Move to Flutter 3.0.0 and Dart 2.17.0 ([#1713](https://github.com/flame-engine/flame/issues/1713)). ([2a41d0d6](https://github.com/flame-engine/flame/commit/2a41d0d683391194b7209c47bde91199ab7a663e))

## 1.6.0

 - **FIX**: Correct flutter constraint ([#1731](https://github.com/flame-engine/flame/issues/1731)). ([c7383843](https://github.com/flame-engine/flame/commit/c738384314a1a5c3695d1c3adaebcb59604df83a))
 - **FIX**: tiled example size ([#1729](https://github.com/flame-engine/flame/issues/1729)). ([8306fc11](https://github.com/flame-engine/flame/commit/8306fc1104cb752ce71108abb3768f05ce1b1dac))
 - **FEAT**: Move to Flutter 3.0.0 and Dart 2.17.0 ([#1713](https://github.com/flame-engine/flame/issues/1713)). ([2a41d0d6](https://github.com/flame-engine/flame/commit/2a41d0d683391194b7209c47bde91199ab7a663e))

## 1.5.0

 - **REFACTOR**: Move to package imports ([#1625](https://github.com/flame-engine/flame/issues/1625)). ([843ddc36](https://github.com/flame-engine/flame/commit/843ddc36249272fcb518b44672e1012307dfa1b5))
 - **FIX**: performance improvements on `SpriteBatch` APIs ([#1637](https://github.com/flame-engine/flame/issues/1637)). ([4b19a1b2](https://github.com/flame-engine/flame/commit/4b19a1b203c5cfca5bb412b91c795fe6a215506e))
 - **FIX**: Avoid leaks when using PictureRecorders ([#1643](https://github.com/flame-engine/flame/issues/1643)). ([d67065e5](https://github.com/flame-engine/flame/commit/d67065e52db453b0f4f190a7aec1bec6bc389e45))
 - **FIX**: Fix tile flips when using canvas.drawAtlas ([#1610](https://github.com/flame-engine/flame/issues/1610)). ([b4ad498f](https://github.com/flame-engine/flame/commit/b4ad498fe5488795deb2c2e098fcde357b448bf0))
 - **FIX**: Add centered anchor point for tile rotation ([#1570](https://github.com/flame-engine/flame/issues/1570)). ([f64d5264](https://github.com/flame-engine/flame/commit/f64d5264abb9e1548d26ae15269654e563cd0ee9))
 - **FEAT**: Add more lint rules ([#1703](https://github.com/flame-engine/flame/issues/1703)). ([49252f8e](https://github.com/flame-engine/flame/commit/49252f8ef29aa6b77144dcb97c24346f2f39380b))
 - **FEAT**: Bump to Flutter 2.10.0 ([#1617](https://github.com/flame-engine/flame/issues/1617)). ([beac9013](https://github.com/flame-engine/flame/commit/beac901313456cf0b39b6f4e6459f0feed183614))

## 1.4.0

 - **FEAT**: Possibility to create RenderableTiledMap from TiledMap (#1534). ([5ed08333](https://github.com/flame-engine/flame/commit/5ed08333215658b9eaca049f6ba16b6509901bb9))
 - **FEAT**: Added children parameter to Component constructor (#1525). ([f0b31fcf](https://github.com/flame-engine/flame/commit/f0b31fcfc0fc6b0f8f96895ef6a68fd5a30a3159))

## 1.3.0

 - Graduate package to a stable release. See pre-releases prior to this version for changelog entries.

## 1.3.0-releasecandidate.6

 - Update a dependency to the latest release.

## 1.3.0-releasecandidate.5

 - Update a dependency to the latest release.

## 1.3.0-releasecandidate.4

 - Update a dependency to the latest release.

## 1.3.0-releasecandidate.3

 - Update a dependency to the latest release.

## 1.3.0-releasecandidate.2

 - Update a dependency to the latest release.

## 1.3.0-releasecandidate.1

> Note: This release has breaking changes.

 - **FEAT**: Added getImageLayer to flame_tiled (#1405). ([a037ada5](https://github.com/flame-engine/flame/commit/a037ada5ea18b0d1b0be68f9b3d3cceabc8c3b2b))
 - **FEAT**: modifiable Layer and TileData in RenderableTileMap (#1324). ([b56d5f3c](https://github.com/flame-engine/flame/commit/b56d5f3cd7d87a07ab0063defbf14a56c0cca1a5))
 - **FEAT**: Expose priority for TiledComponent (#1259). ([f6be66ab](https://github.com/flame-engine/flame/commit/f6be66abd5321a8c48f7200d62bd9e35a5aa71ff))
 - **DOCS**: Fix various dartdoc warnings (#1353). ([9f096053](https://github.com/flame-engine/flame/commit/9f096053fd3c8ebd52d301710625a187db09704f))
 - **DOCS**: Update flame_tiled readme (#1286). ([ee7298cb](https://github.com/flame-engine/flame/commit/ee7298cbe5cd02825cd7246f86ccb0c3655985a0))
 - **DOCS**: Update contributions to flame_tiled (#1197). ([93b763e1](https://github.com/flame-engine/flame/commit/93b763e1c000b1ebc538e393723aae2a85eb4838))
 - **BREAKING** **FIX**: fix multiple external tilesets (#1344). ([80a483f8](https://github.com/flame-engine/flame/commit/80a483f80df57ce6339f84d03d836efcbbf09579))
 - **BREAKING** **FIX**: Change Tiled batched rendering to batched rendering per layer (#1317). ([30fce398](https://github.com/flame-engine/flame/commit/30fce398dbe397d4368a0f721b20afcd663c489f))

## 1.2.1

> Note: This release has breaking changes that were supposed to be in 1.2.0

 - **BREAKING** **FIX**: fix multiple external tilesets (#1344). ([80a483f8](https://github.com/flame-engine/flame/commit/80a483f80df57ce6339f84d03d836efcbbf09579))

## 1.2.0

 - **FEAT**: modifiable Layer and TileData in RenderableTileMap (#1324). ([b56d5f3c](https://github.com/flame-engine/flame/commit/b56d5f3cd7d87a07ab0063defbf14a56c0cca1a5))

## 1.1.0

 - Change Tiled batched rendering to batched rendering per layer.

## 1.0.0

 - Updated to Flame 1.0.0

## 1.0.0-releasecandidate.15

 - Upgrade to work with latest Flame version
 - Move to the mono-repo

## 0.1.0

 - Updated the Tiled class to use the SpriteBatch API for efficient drawing to canvas.

## 0.0.1

 - Moving code from main repository to its own package
