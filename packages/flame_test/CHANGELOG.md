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
