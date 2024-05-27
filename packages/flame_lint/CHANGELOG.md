## 1.2.0

 - **FEAT**: Expand flame_lint to respect required pub.dev checks ([#3139](https://github.com/flame-engine/flame/issues/3139)). ([6e80bf5e](https://github.com/flame-engine/flame/commit/6e80bf5e679d1cdeeb9362d4103690b0b381161d))

## 1.1.2

 - **FIX**: Minor issues due Flutter 3.16 ([#2856](https://github.com/flame-engine/flame/issues/2856)). ([d51cd584](https://github.com/flame-engine/flame/commit/d51cd584c71a27c242c2f4600282cf8359daaa17))

## 1.1.1

 - **REFACTOR**: Enable new DCM rule: avoid-cascade-after-if-null ([#2676](https://github.com/flame-engine/flame/issues/2676)). ([158fc34c](https://github.com/flame-engine/flame/commit/158fc34cae858cf8d0b5d3b5155763e02454779a))
 - **REFACTOR**: Enable DCM linting ([#2667](https://github.com/flame-engine/flame/issues/2667)). ([27a8fd61](https://github.com/flame-engine/flame/commit/27a8fd61cb7f62513e07a93ff61cf03b426353f2))

## 1.1.0

> Note: This release has breaking changes.

 - **BREAKING** **PERF**: Pool `CollisionProspect`s and remove some list creations from the collision detection ([#2625](https://github.com/flame-engine/flame/issues/2625)). ([e430b6cd](https://github.com/flame-engine/flame/commit/e430b6cdf2e6be52bf384efb3428bcb41ae13d30))

## 1.0.0

 - **FIX**: Update sdk constraints to >=3.0.0 ([#2554](https://github.com/flame-engine/flame/issues/2554)). ([2f71e06e](https://github.com/flame-engine/flame/commit/2f71e06eb86ffc65cd459c4d722eee2470be13e5))
 - **FIX**: Solve warnings from 3.10.0 analyzer ([#2532](https://github.com/flame-engine/flame/issues/2532)). ([b41622db](https://github.com/flame-engine/flame/commit/b41622db8faa7559328f83f8f1d93ec4c6386961))

## 0.2.0+2

 - **REFACTOR**: Add new lint rules ([#2477](https://github.com/flame-engine/flame/issues/2477)). ([dbda37b8](https://github.com/flame-engine/flame/commit/dbda37b81a9a7411559a6ba919ffbda6018b85c2))

## 0.2.0+1

 - **DOCS**: Update funding links ([#2420](https://github.com/flame-engine/flame/issues/2420)). ([8294a2a1](https://github.com/flame-engine/flame/commit/8294a2a15638c504aa2b77f967f5963af1f23c2c))
 - **DOCS**: Fix non-markdown section of README files ([#2406](https://github.com/flame-engine/flame/issues/2406)). ([426b3124](https://github.com/flame-engine/flame/commit/426b3124022e567633c76b80eb389ebce1772ca3))
 - **DOCS**: Update all README files for the bridge packages to be consistent and not broken ([#2402](https://github.com/flame-engine/flame/issues/2402)). ([5e8ecf54](https://github.com/flame-engine/flame/commit/5e8ecf5450688b1287368b3fbc7b0e718a29fce4))

## 0.2.0

 - Removed invariant_booleans

## 0.1.3

 - **FEAT**: Add avoid_final_parameters, depend_on_referenced_packages, unnecessary_to_list_in_spreads ([#1927](https://github.com/flame-engine/flame/issues/1927)). ([deccb434](https://github.com/flame-engine/flame/commit/deccb4349d38b6a91ccf5bdf229980b2a3296ce5))

## 0.1.2

 - **REFACTOR**: Move to package imports ([#1625](https://github.com/flame-engine/flame/issues/1625)). ([843ddc36](https://github.com/flame-engine/flame/commit/843ddc36249272fcb518b44672e1012307dfa1b5))
 - **REFACTOR**: Add a few more rules to flame_lint, including use_key_in_widget_constructors ([#1248](https://github.com/flame-engine/flame/issues/1248)). ([bac6c8a4](https://github.com/flame-engine/flame/commit/bac6c8a4469f2c5c2926335f2f589eec9b1a5b5b))
 - **FIX**: Upgrade dartdoc (upgrade analyzer transitive dependency) ([#1630](https://github.com/flame-engine/flame/issues/1630)). ([6da8adb2](https://github.com/flame-engine/flame/commit/6da8adb28cffd8fcb43e6bf8a33aae22578f1b40))
 - **FEAT**: Move to Flutter 3.0.0 and Dart 2.17.0 ([#1713](https://github.com/flame-engine/flame/issues/1713)). ([2a41d0d6](https://github.com/flame-engine/flame/commit/2a41d0d683391194b7209c47bde91199ab7a663e))
 - **FEAT**: Add more lint rules ([#1703](https://github.com/flame-engine/flame/issues/1703)). ([49252f8e](https://github.com/flame-engine/flame/commit/49252f8ef29aa6b77144dcb97c24346f2f39380b))
 - **FEAT**: Add non_constant_identifier_names rule ([#1656](https://github.com/flame-engine/flame/issues/1656)). ([1b40de09](https://github.com/flame-engine/flame/commit/1b40de094f4e66be7622d077a6e18cecf1964dde))
 - **FEAT**: Bump to Flutter 2.10.0 ([#1617](https://github.com/flame-engine/flame/issues/1617)). ([beac9013](https://github.com/flame-engine/flame/commit/beac901313456cf0b39b6f4e6459f0feed183614))
 - **DOCS**: Fix various dartdoc warnings ([#1353](https://github.com/flame-engine/flame/issues/1353)). ([9f096053](https://github.com/flame-engine/flame/commit/9f096053fd3c8ebd52d301710625a187db09704f))

## 0.1.1

 - **REFACTOR**: Move to package imports ([#1625](https://github.com/flame-engine/flame/issues/1625)). ([843ddc36](https://github.com/flame-engine/flame/commit/843ddc36249272fcb518b44672e1012307dfa1b5))
 - **REFACTOR**: Add a few more rules to flame_lint, including use_key_in_widget_constructors ([#1248](https://github.com/flame-engine/flame/issues/1248)). ([bac6c8a4](https://github.com/flame-engine/flame/commit/bac6c8a4469f2c5c2926335f2f589eec9b1a5b5b))
 - **FIX**: Upgrade dartdoc (upgrade analyzer transitive dependency) ([#1630](https://github.com/flame-engine/flame/issues/1630)). ([6da8adb2](https://github.com/flame-engine/flame/commit/6da8adb28cffd8fcb43e6bf8a33aae22578f1b40))
 - **FEAT**: Move to Flutter 3.0.0 and Dart 2.17.0 ([#1713](https://github.com/flame-engine/flame/issues/1713)). ([2a41d0d6](https://github.com/flame-engine/flame/commit/2a41d0d683391194b7209c47bde91199ab7a663e))
 - **FEAT**: Add more lint rules ([#1703](https://github.com/flame-engine/flame/issues/1703)). ([49252f8e](https://github.com/flame-engine/flame/commit/49252f8ef29aa6b77144dcb97c24346f2f39380b))
 - **FEAT**: Add non_constant_identifier_names rule ([#1656](https://github.com/flame-engine/flame/issues/1656)). ([1b40de09](https://github.com/flame-engine/flame/commit/1b40de094f4e66be7622d077a6e18cecf1964dde))
 - **FEAT**: Bump to Flutter 2.10.0 ([#1617](https://github.com/flame-engine/flame/issues/1617)). ([beac9013](https://github.com/flame-engine/flame/commit/beac901313456cf0b39b6f4e6459f0feed183614))
 - **DOCS**: Fix various dartdoc warnings ([#1353](https://github.com/flame-engine/flame/issues/1353)). ([9f096053](https://github.com/flame-engine/flame/commit/9f096053fd3c8ebd52d301710625a187db09704f))

# CHANGELOG

## [0.1.0]
 - Made the package publishable

## [0.0.1]
 - Initial release
