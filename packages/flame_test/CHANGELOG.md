## 2.0.0

> Note: This release has breaking changes.

 - **BREAKING** **FEAT**: Pass `WidgetTester` for `testGolden` prepare function ([#3624](https://github.com/flame-engine/flame/issues/3624)). ([10509326](https://github.com/flame-engine/flame/commit/105093266431408db0f9e74042e03e2234d9b22e))

## 1.19.2

 - Update a dependency to the latest release.

## 1.19.1

 - Update a dependency to the latest release.

## 1.19.0

> Note: This release has breaking changes.

 - **BREAKING** **FIX**: Use 32bit Vector2 in Flame to be compatible with shaders and forge2d ([#3515](https://github.com/flame-engine/flame/issues/3515)). ([19dcecf5](https://github.com/flame-engine/flame/commit/19dcecf5df85345fd4fac168e1f360cee4665658))

## 1.18.3

 - Update a dependency to the latest release.

## 1.18.2

 - Update a dependency to the latest release.

## 1.18.1

 - **DOCS**: Fix workflow status badge paths ([#3517](https://github.com/flame-engine/flame/issues/3517)). ([149f16fe](https://github.com/flame-engine/flame/commit/149f16fe29f1fb14b3612964b2226c9c5c7daf95))

## 1.18.0

 - **FEAT**: Implement closeToVector4 and closeToQuaternion by extracing a generic CloseToVector base ([#3480](https://github.com/flame-engine/flame/issues/3480)). ([57e58514](https://github.com/flame-engine/flame/commit/57e58514091248884505d3936e3e0aa076efb30a))
 - **FEAT**: Add closeToMatrix4 test matcher ([#3478](https://github.com/flame-engine/flame/issues/3478)). ([8db2476e](https://github.com/flame-engine/flame/commit/8db2476e8c39723670641f1c2646ecf0d7bb09fb))
 - **DOCS**: Remove AI assist badges ([#3477](https://github.com/flame-engine/flame/issues/3477)). ([51d7fbc0](https://github.com/flame-engine/flame/commit/51d7fbc06d88adec2e0238c9c4738893b807ec80))

## 1.17.5

 - **FIX**: Don't use a future when assets for SpriteButton is already loaded (#3456).

## 1.17.4

 - **REFACTOR**: Fix lint issues from latest flutter release ([#3390](https://github.com/flame-engine/flame/issues/3390)). ([978ad31b](https://github.com/flame-engine/flame/commit/978ad31b429d1801097b0db385a600c85a157867))

## 1.17.3

 - Update a dependency to the latest release.

## 1.17.2

 - **FIX**: Widgets flickering ([#3343](https://github.com/flame-engine/flame/issues/3343)). ([ff170dc5](https://github.com/flame-engine/flame/commit/ff170dc5c2acc41190249b48e61767ea459fabb4))
 - **FIX**: Fix SpriteBatch to comply with new drawAtlas requirement ([#3338](https://github.com/flame-engine/flame/issues/3338)). ([a17fe4cd](https://github.com/flame-engine/flame/commit/a17fe4cdfaafa071cfd2ab8ef8279b26b79f00a7))

## 1.17.1

 - Update a dependency to the latest release.

## 1.17.0

 - **FEAT**: Add a closeToVector3 matcher to flame_test ([#3242](https://github.com/flame-engine/flame/issues/3242)). ([965b684a](https://github.com/flame-engine/flame/commit/965b684a286ae2e2a89ba303839004d0b12cb3ef))
 - **DOCS**: Add AI assist badge to readme(s) ([#3226](https://github.com/flame-engine/flame/issues/3226)). ([380d6aa9](https://github.com/flame-engine/flame/commit/380d6aa946d6b852c55f4ebbfce53d2087287fa2))

## 1.16.2

 - Update a dependency to the latest release.

## 1.16.1

 - Update a dependency to the latest release.

## 1.16.0

> Note: This release has breaking changes.

 - **BREAKING** **FIX**: Migrate from `RawKeyEvent` to `KeyEvent` ([#3002](https://github.com/flame-engine/flame/issues/3002)). ([330862c9](https://github.com/flame-engine/flame/commit/330862c98ecc7ed8d94e7cae0c34cd5781da0007))

## 1.15.4

 - **FIX**: Lifecycle completers to be called for FlameGame ([#3007](https://github.com/flame-engine/flame/issues/3007)). ([3804f524](https://github.com/flame-engine/flame/commit/3804f52434cf1bcaf28b501bf96858ecd3636164))

## 1.15.3

 - Update a dependency to the latest release.

## 1.15.2

 - Update a dependency to the latest release.

## 1.15.1

 - Update a dependency to the latest release.

## 1.15.0

 - **FIX**: Minor issues due Flutter 3.16 ([#2856](https://github.com/flame-engine/flame/issues/2856)). ([d51cd584](https://github.com/flame-engine/flame/commit/d51cd584c71a27c242c2f4600282cf8359daaa17))
 - **FEAT**: Expose addition test arguments on flame test ([#2832](https://github.com/flame-engine/flame/issues/2832)). ([08b4bd6d](https://github.com/flame-engine/flame/commit/08b4bd6d3f308013d18fec4eb126927239cd6481))

## 1.14.0

 - **FEAT**: Expose addition test arguments on flame test ([#2832](https://github.com/flame-engine/flame/issues/2832)). ([08b4bd6d](https://github.com/flame-engine/flame/commit/08b4bd6d3f308013d18fec4eb126927239cd6481))

## 1.13.2

 - **REFACTOR**: Remove unnecessary 'async' keyword across the codebase [DCM] ([#2803](https://github.com/flame-engine/flame/issues/2803)). ([2dfe0e5a](https://github.com/flame-engine/flame/commit/2dfe0e5a431213c7148ab6389e3e8c8dc49fbf3d))

## 1.13.1

 - Update a dependency to the latest release.

## 1.13.0

> Note: This release has breaking changes.

 - **REFACTOR**: Enable DCM linting ([#2667](https://github.com/flame-engine/flame/issues/2667)). ([27a8fd61](https://github.com/flame-engine/flame/commit/27a8fd61cb7f62513e07a93ff61cf03b426353f2))
 - **FIX**: HasGameReference should default to FlameGame ([#2710](https://github.com/flame-engine/flame/issues/2710)). ([93dcb3a1](https://github.com/flame-engine/flame/commit/93dcb3a117c365767e3f20569b2d82abc8a7b152))
 - **FEAT**: Add HoverCallbacks ([#2706](https://github.com/flame-engine/flame/issues/2706)). ([d460b846](https://github.com/flame-engine/flame/commit/d460b846c23fb1f67041469c99c81e4c78b89c2e))
 - **BREAKING** **REFACTOR**: Rename (Text) Elements, Nodes and Styles for clarity, add docs ([#2700](https://github.com/flame-engine/flame/issues/2700)). ([4b420b79](https://github.com/flame-engine/flame/commit/4b420b7952ab8d675140b9d8d132015ff2780f92))
 - **BREAKING** **REFACTOR**: Kill TextRenderer, Long Live TextRenderer ([#2683](https://github.com/flame-engine/flame/issues/2683)). ([a1cb9a06](https://github.com/flame-engine/flame/commit/a1cb9a06ada6f87bf22bc20e3c190ccd53517389))
 - **BREAKING** **REFACTOR**: Make TextElement more usable on its own ([#2679](https://github.com/flame-engine/flame/issues/2679)). ([1a64443c](https://github.com/flame-engine/flame/commit/1a64443ccaae32e71fe7d016ad1e8f18a75c93da))
 - **BREAKING** **FEAT**: Add CameraComponent to FlameGame ([#2740](https://github.com/flame-engine/flame/issues/2740)). ([7c2f4000](https://github.com/flame-engine/flame/commit/7c2f4000761580dbabb5d73b27f64d5819b34e8d))

## 1.12.1

 - Update a dependency to the latest release.

## 1.12.0

> Note: This release has breaking changes.

 - **FIX**: Set constraint for test dependency in flame_test ([#2558](https://github.com/flame-engine/flame/issues/2558)). ([aeef9464](https://github.com/flame-engine/flame/commit/aeef9464f6ca448e3aa2b578af8b3443cbbf6f71))
 - **FIX**: Update sdk constraints to >=3.0.0 ([#2554](https://github.com/flame-engine/flame/issues/2554)). ([2f71e06e](https://github.com/flame-engine/flame/commit/2f71e06eb86ffc65cd459c4d722eee2470be13e5))
 - **BREAKING** **FIX**: Convert PositionEvent.canvasPosition to local coordinates ([#2598](https://github.com/flame-engine/flame/issues/2598)). ([87139c85](https://github.com/flame-engine/flame/commit/87139c854534782638fe1b0c24d2dc92f98a3e59))

## 1.11.0

> Note: This release has breaking changes.

 - **FIX**: Update sdk constraints to >=3.0.0 ([#2554](https://github.com/flame-engine/flame/issues/2554)). ([2f71e06e](https://github.com/flame-engine/flame/commit/2f71e06eb86ffc65cd459c4d722eee2470be13e5))
 - **FIX**: Solve warnings from 3.10.0 analyzer ([#2532](https://github.com/flame-engine/flame/issues/2532)). ([b41622db](https://github.com/flame-engine/flame/commit/b41622db8faa7559328f83f8f1d93ec4c6386961))
 - **BREAKING** **REFACTOR**: Move `CameraComponent` and events out of experimental ([#2505](https://github.com/flame-engine/flame/issues/2505)). ([87b8a067](https://github.com/flame-engine/flame/commit/87b8a067f3e0096cebff3db4f5767e68616928fd))

## 1.10.1

 - **REFACTOR**: Add new lint rules ([#2477](https://github.com/flame-engine/flame/issues/2477)). ([dbda37b8](https://github.com/flame-engine/flame/commit/dbda37b81a9a7411559a6ba919ffbda6018b85c2))

## 1.10.0

> Note: This release has breaking changes.

 - **FIX**: Override `remove()` method to fix the functionality issue in the `FlameMultiBlocProvider` ([#2280](https://github.com/flame-engine/flame/issues/2280)). ([6a818464](https://github.com/flame-engine/flame/commit/6a818464f5f942ce25c3c3c59839b6bddaada386))
 - **DOCS**: Update funding links ([#2420](https://github.com/flame-engine/flame/issues/2420)). ([8294a2a1](https://github.com/flame-engine/flame/commit/8294a2a15638c504aa2b77f967f5963af1f23c2c))
 - **DOCS**: Fix non-markdown section of README files ([#2406](https://github.com/flame-engine/flame/issues/2406)). ([426b3124](https://github.com/flame-engine/flame/commit/426b3124022e567633c76b80eb389ebce1772ca3))
 - **DOCS**: Update all README files for the bridge packages to be consistent and not broken ([#2402](https://github.com/flame-engine/flame/issues/2402)). ([5e8ecf54](https://github.com/flame-engine/flame/commit/5e8ecf5450688b1287368b3fbc7b0e718a29fce4))
 - **BREAKING** **FEAT**: The `HasTappableComponents` mixin is no longer needed ([#2450](https://github.com/flame-engine/flame/issues/2450)). ([b5bdf4ec](https://github.com/flame-engine/flame/commit/b5bdf4ec173e87907a59a9f62fcdf35cc968af2a))

## 1.9.2

 - **FIX**: Only use initialized game for tests and remove setMount from onGameResize ([#2246](https://github.com/flame-engine/flame/issues/2246)). ([2a0f1d4b](https://github.com/flame-engine/flame/commit/2a0f1d4bdc2688e596481aad39762f94bf1cc8f1))
 - **FIX**: Depend on test: any for flame_test ([#2207](https://github.com/flame-engine/flame/issues/2207)). ([acfd418d](https://github.com/flame-engine/flame/commit/acfd418d882ee6872f3aa9961c39680ec123c2e6))
 - **FIX**: Depend on test: any for flame_test. ([fcf5521c](https://github.com/flame-engine/flame/commit/fcf5521ce4e975830f728481591a1731ce5edb77))

## 1.9.1

 - **FIX**: Depend on test: any for flame_test. ([fcf5521c](https://github.com/flame-engine/flame/commit/fcf5521ce4e975830f728481591a1731ce5edb77))

## 1.9.0

 - **FEAT**: Add support for styles propagating through the text node tree ([#1915](https://github.com/flame-engine/flame/issues/1915)). ([b5780d42](https://github.com/flame-engine/flame/commit/b5780d421234636144794e663559cec8987656a4))

## 1.8.0

> Note: This release has breaking changes.

 - **FEAT**: Add avoid_final_parameters, depend_on_referenced_packages, unnecessary_to_list_in_spreads ([#1927](https://github.com/flame-engine/flame/issues/1927)). ([deccb434](https://github.com/flame-engine/flame/commit/deccb4349d38b6a91ccf5bdf229980b2a3296ce5))
 - **FEAT**: Added DebugTextFormatter ([#1921](https://github.com/flame-engine/flame/issues/1921)). ([426827d1](https://github.com/flame-engine/flame/commit/426827d19e803158dab271dce1fbf93bd09f07de))
 - **BREAKING** **CHORE**: Remove functions/classes that were scheduled for removal in v1.3.0 ([#1867](https://github.com/flame-engine/flame/issues/1867)). ([00ab347c](https://github.com/flame-engine/flame/commit/00ab347c57b151c9232c85150e36a8a7781511a3))

## 1.7.0

> Note: This release has breaking changes.

 - **FIX**: Correct flutter constraint ([#1731](https://github.com/flame-engine/flame/issues/1731)). ([c7383843](https://github.com/flame-engine/flame/commit/c738384314a1a5c3695d1c3adaebcb59604df83a))
 - **FEAT**: Added size parameter for testGolden() ([#1780](https://github.com/flame-engine/flame/issues/1780)). ([8e41d83e](https://github.com/flame-engine/flame/commit/8e41d83ea4e057e1a428f0456450d697351683bf))
 - **FEAT**: Move to Flutter 3.0.0 and Dart 2.17.0 ([#1713](https://github.com/flame-engine/flame/issues/1713)). ([2a41d0d6](https://github.com/flame-engine/flame/commit/2a41d0d683391194b7209c47bde91199ab7a663e))
 - **BREAKING** **REFACTOR**: Matcher closeToVector() now accepts Vector2 as an argument ([#1761](https://github.com/flame-engine/flame/issues/1761)). ([c5083501](https://github.com/flame-engine/flame/commit/c5083501d54023f04d3f09e3358bce039ade9a20))

## 1.6.0

> Note: This release has breaking changes.

 - **FIX**: Correct flutter constraint ([#1731](https://github.com/flame-engine/flame/issues/1731)). ([c7383843](https://github.com/flame-engine/flame/commit/c738384314a1a5c3695d1c3adaebcb59604df83a))
 - **FEAT**: Added size parameter for testGolden() ([#1780](https://github.com/flame-engine/flame/issues/1780)). ([8e41d83e](https://github.com/flame-engine/flame/commit/8e41d83ea4e057e1a428f0456450d697351683bf))
 - **FEAT**: Move to Flutter 3.0.0 and Dart 2.17.0 ([#1713](https://github.com/flame-engine/flame/issues/1713)). ([2a41d0d6](https://github.com/flame-engine/flame/commit/2a41d0d683391194b7209c47bde91199ab7a663e))
 - **BREAKING** **REFACTOR**: Matcher closeToVector() now accepts Vector2 as an argument ([#1761](https://github.com/flame-engine/flame/issues/1761)). ([c5083501](https://github.com/flame-engine/flame/commit/c5083501d54023f04d3f09e3358bce039ade9a20))

## 1.5.0

 - **FEAT**: Add more lint rules ([#1703](https://github.com/flame-engine/flame/issues/1703)). ([49252f8e](https://github.com/flame-engine/flame/commit/49252f8ef29aa6b77144dcb97c24346f2f39380b))
 - **FEAT**: Callbacks in `HudButtonComponent` constructor and `ViewportMargin` mixin to avoid code duplication ([#1685](https://github.com/flame-engine/flame/issues/1685)). ([f55b2e0d](https://github.com/flame-engine/flame/commit/f55b2e0dc01c98718e4871430c6745472c221821))
 - **FEAT**: Aligned text in the TextBoxComponent ([#1620](https://github.com/flame-engine/flame/issues/1620)). ([c64aedae](https://github.com/flame-engine/flame/commit/c64aedaeb3fed908722b8872b71e288ff87bc761))
 - **FEAT**: add options to flutter test ([#1690](https://github.com/flame-engine/flame/issues/1690)). ([5dcf2664](https://github.com/flame-engine/flame/commit/5dcf26642363dd245f541c76d6190f8d523c1acb))
 - **FEAT**: Add helper function for creating golden tests ([#1623](https://github.com/flame-engine/flame/issues/1623)). ([d0faaada](https://github.com/flame-engine/flame/commit/d0faaada2bb971c2dde5a37dfa20d316c532ea28))
 - **FEAT**: Bump to Flutter 2.10.0 ([#1617](https://github.com/flame-engine/flame/issues/1617)). ([beac9013](https://github.com/flame-engine/flame/commit/beac901313456cf0b39b6f4e6459f0feed183614))

## 1.4.0

 - **FEAT**: Added closeToAabb() (#1531). ([f7b6cc69](https://github.com/flame-engine/flame/commit/f7b6cc69abd6af89cafd892c7f2518b9b7bf3fc6))
 - **FEAT**: flame tests can now generate golden tests (#1501). ([316a0b3b](https://github.com/flame-engine/flame/commit/316a0b3bb0996ed20a3b93175102524b38bfa3e2))

## 1.3.0

 - **FIX**: Fix calculation of AABB for `ShapeHitbox`es (#1481). ([a559d9a1](https://github.com/flame-engine/flame/commit/a559d9a12bfb42e161469745795fb91cdf161f8b))
 - **FEAT**: flame tests can now generate golden tests (#1501). ([316a0b3b](https://github.com/flame-engine/flame/commit/316a0b3bb0996ed20a3b93175102524b38bfa3e2))

## 1.2.0

 - Graduate package to a stable release. See pre-releases prior to this version for changelog entries.

## 1.2.0-releasecandidate.6

 - Update a dependency to the latest release.

## 1.2.0-releasecandidate.5

 - Update a dependency to the latest release.

## 1.2.0-releasecandidate.4

 - Update a dependency to the latest release.

## 1.2.0-releasecandidate.3

 - Update a dependency to the latest release.

## 1.2.0-releasecandidate.2

> Note: This release has breaking changes.

 - **REFACTOR**: Add a few more rules to flame_lint, including use_key_in_widget_constructors (#1248). ([bac6c8a4](https://github.com/flame-engine/flame/commit/bac6c8a4469f2c5c2926335f2f589eec9b1a5b5b))
 - **FIX**: remove vector_math dependency (#1361). ([56b33da2](https://github.com/flame-engine/flame/commit/56b33da29cfe547db75c89d97a09550a324fb0f5))
 - **FEAT**: Components are now always added in the correct order (#1337). ([c753fc46](https://github.com/flame-engine/flame/commit/c753fc4636d337d850a5a5cc684be8155f08b214))
 - **FEAT**: Added parameter repeatCount into function testRandom (#1265). ([49a2d0b9](https://github.com/flame-engine/flame/commit/49a2d0b9ec00fa9067756dd975e8b3ffd19de0bc))
 - **FEAT**: Added closeToVector in flame_test (#1245). ([af45ea6c](https://github.com/flame-engine/flame/commit/af45ea6cc4b5de80ecb27f07b827f55567cf602b))
 - **DOCS**: Upgrade documentation site (#1365). ([12cf8f70](https://github.com/flame-engine/flame/commit/12cf8f70963dc25b4e12182d0c7d80fe7d5a00e0))
 - **DOCS**: Fix various dartdoc warnings (#1353). ([9f096053](https://github.com/flame-engine/flame/commit/9f096053fd3c8ebd52d301710625a187db09704f))
 - **BREAKING** **FEAT**: Added SequenceEffect (#1218). ([7c6ae6de](https://github.com/flame-engine/flame/commit/7c6ae6def36ae5feb813fb2ba15d6fb3b9aaf341))

## 1.2.0-releasecandidate.1

> Note: This release has breaking changes.

 - **REFACTOR**: Add a few more rules to flame_lint, including use_key_in_widget_constructors (#1248). ([bac6c8a4](https://github.com/flame-engine/flame/commit/bac6c8a4469f2c5c2926335f2f589eec9b1a5b5b))
 - **FIX**: remove vector_math dependency (#1361). ([56b33da2](https://github.com/flame-engine/flame/commit/56b33da29cfe547db75c89d97a09550a324fb0f5))
 - **FEAT**: Components are now always added in the correct order (#1337). ([c753fc46](https://github.com/flame-engine/flame/commit/c753fc4636d337d850a5a5cc684be8155f08b214))
 - **FEAT**: Added parameter repeatCount into function testRandom (#1265). ([49a2d0b9](https://github.com/flame-engine/flame/commit/49a2d0b9ec00fa9067756dd975e8b3ffd19de0bc))
 - **FEAT**: Added closeToVector in flame_test (#1245). ([af45ea6c](https://github.com/flame-engine/flame/commit/af45ea6cc4b5de80ecb27f07b827f55567cf602b))
 - **DOCS**: Upgrade documentation site (#1365). ([12cf8f70](https://github.com/flame-engine/flame/commit/12cf8f70963dc25b4e12182d0c7d80fe7d5a00e0))
 - **DOCS**: Fix various dartdoc warnings (#1353). ([9f096053](https://github.com/flame-engine/flame/commit/9f096053fd3c8ebd52d301710625a187db09704f))
 - **BREAKING** **FEAT**: Added SequenceEffect (#1218). ([7c6ae6de](https://github.com/flame-engine/flame/commit/7c6ae6def36ae5feb813fb2ba15d6fb3b9aaf341))

## 1.1.0

 - Add `closeToVector` matcher.

## 1.0.1

 - Bump versions not to use paths

## 1.0.0

 - Fix tests with multiples futures finishing abruptly

## 1.0.0-releasecandidate.15

 - Add `pumpWidget` to flame widget test

## 0.1.1-releasecandidate.14

 - Add `flameTest` and `flameWidgetTest`

## 0.1.1-releasecandidate.13

 - Move dartdoc and dart_code_metrics to dev_dependencies

## 0.1.0-releasecandidate.13

 - Initial release containing classes to help testing classes using `Flame`
