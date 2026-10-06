## 2.0.0-dev.1

 - **FIX**: Version flame_3d_component as a prerelease and move flame_lint to 1.5.0-dev.0 ([#4100](https://github.com/flame-engine/flame/issues/4100)). ([f3961dbe](https://github.com/flame-engine/flame/commit/f3961dbea689ca3b4ad89edee1fc3688286409f9))
 - **FIX**: Bump the minimum Flutter version to 3.47.0 and Dart to 3.13.0 ([#4087](https://github.com/flame-engine/flame/issues/4087)). ([53cea039](https://github.com/flame-engine/flame/commit/53cea039746da34187e3d0991e355647aa4ffdcc))

## 2.0.0-dev.0

> Note: This release has breaking changes.

 - **FIX**: Add a version constraint to the material_ui dependency ([#4075](https://github.com/flame-engine/flame/issues/4075)). ([7ce35d85](https://github.com/flame-engine/flame/commit/7ce35d85d160264a423bd493a06f4749c9d6263e))
 - **FIX**: Remove material_ui dependency where unnecesarry ([#4070](https://github.com/flame-engine/flame/issues/4070)). ([e682aba9](https://github.com/flame-engine/flame/commit/e682aba96290260ea7eac605f069594c26802bd4))
 - **FIX**: Adapt to Flutter 3.47 ([#3995](https://github.com/flame-engine/flame/issues/3995)). ([0453bad6](https://github.com/flame-engine/flame/commit/0453bad6e726ff90610baec86e5c24dc4c89a5a4))
 - **BREAKING** **REFACTOR**: Remove events handled property ([#3976](https://github.com/flame-engine/flame/issues/3976)). ([98e65544](https://github.com/flame-engine/flame/commit/98e65544152253a3facaae04e4a48780fa73f8a0))
 - **BREAKING** **FEAT**: Kill MouseMovementDetector and rename PointerMove* to MouseMove* ([#4011](https://github.com/flame-engine/flame/issues/4011)). ([7fd33dee](https://github.com/flame-engine/flame/commit/7fd33dee9b822bef7b3fbf0621d0f3ebdab39a5d))
 - **BREAKING** **FEAT**: Return a list instead of a set from the collision detection methods ([#4003](https://github.com/flame-engine/flame/issues/4003)). ([698f2619](https://github.com/flame-engine/flame/commit/698f2619ed741276898c8dd71d58c109cd347c5c))
 - **BREAKING** **FEAT**: Making add,addAll sync methods ([#3968](https://github.com/flame-engine/flame/issues/3968)). ([52710ca6](https://github.com/flame-engine/flame/commit/52710ca67ff2b6e6094e9814f2e869314e2b79e8))

## 1.4.0

 - **FEAT**(flame_behaviors): Add ScreenCollisionBehavior ([#3910](https://github.com/flame-engine/flame/issues/3910)). ([48894135](https://github.com/flame-engine/flame/commit/48894135587218690f7faa7382ba24d45658e235))

## 1.3.5

 - Update a dependency to the latest release.

## 1.3.4

 - **FIX**: Bump Flutter min version to 3.41.0 ([#3807](https://github.com/flame-engine/flame/issues/3807)). ([0d505304](https://github.com/flame-engine/flame/commit/0d50530485e5be9ce1c9138a5b437607c7c5c628))

## 1.3.3

 - Update a dependency to the latest release.

## 1.3.2

 - Update a dependency to the latest release.

## 1.3.1

 - Update a dependency to the latest release.

## 1.3.0

 - **FEAT**: Add flame_behaviors package ([#3717](https://github.com/flame-engine/flame/issues/3717)). ([e950d79e](https://github.com/flame-engine/flame/commit/e950d79e56bf5902f2a48367a1e899e9b8903dc4))

# [1.2.0](https://github.com/VeryGoodOpenSource/flame_behaviors/compare/flame_behaviors-v1.1.0...flame_behaviors-v1.2.0) (2024-08-27)

- chore: tighten dependencies ([#64](https://github.com/VeryGoodOpenSource/flame_behaviors/pull/64))
- feat: Flame 1.19 support ([#69](https://github.com/VeryGoodOpenSource/flame_behaviors/pull/69))

# [1.1.0](https://github.com/VeryGoodOpenSource/flame_behaviors/compare/flame_behaviors-v1.0.0...flame_behaviors-v1.1.0) (2024-01-11)

### Features

- add `priority` and `key` to the constructor ([#57](https://github.com/VeryGoodOpenSource/flame_behaviors/pull/57)) ([cc6cb4a](https://github.com/VeryGoodOpenSource/flame_behaviors/commit/cc6cb4a635109a74d5002d7e16d0e5b3d7e0dce6))

# [1.0.0](https://github.com/VeryGoodOpenSource/flame_behaviors/compare/v0.2.0...flame_behaviors-1.0.0) (2023-10-18)

### Breaking Changes

- migrate to flame v1.7.0 ([#43](https://github.com/VeryGoodOpenSource/flame_behaviors/pull/43)) ([08580f6](https://github.com/VeryGoodOpenSource/flame_behaviors/commit/08580f656abb12f38c1b16913c9cf5397e2b95a8))
- migrate to flame v1.10.0 ([#46](https://github.com/VeryGoodOpenSource/flame_behaviors/pull/46)) ([9963591](https://github.com/VeryGoodOpenSource/flame_behaviors/commit/9963591d4c0cc1da389ba8446740f8747549b775))

### Bug Fixes

- make `PropagatingCollisionBehavior` more open ([#42](https://github.com/VeryGoodOpenSource/flame_behaviors/pull/42)) ([4ae0553](https://github.com/VeryGoodOpenSource/flame_behaviors/commit/4ae05534458ec7b66caf04e87afc5e8c25fba9ae))

# [0.2.0](https://github.com/VeryGoodOpenSource/flame_behaviors/compare/v0.1.1...v0.2.0) (2023-01-23)

### Features

- add dependabot ([#31](https://github.com/VeryGoodOpenSource/flame_behaviors/issues/31)) ([4b601a1](https://github.com/VeryGoodOpenSource/flame_behaviors/commit/4b601a1ff3a516e36ae850857f5c5e5a9de7303f))
- update version constraints ([#26](https://github.com/VeryGoodOpenSource/flame_behaviors/issues/26)) ([05303be](https://github.com/VeryGoodOpenSource/flame_behaviors/commit/05303beeae80df6055f3b3fc8f5630f2643d40fe))

### Breaking Changes
- make the entity into a generic component ([#34](https://github.com/VeryGoodOpenSource/flame_behaviors/pull/34))([d09964](https://github.com/VeryGoodOpenSource/flame_behaviors/commit/d0996471370a0764331da82433a874a1edecba20))
- update flame dependency to v1.6.0  ([#35](https://github.com/VeryGoodOpenSource/flame_behaviors/pull/35))([867d7a](https://github.com/VeryGoodOpenSource/flame_behaviors/commit/867d7a283980a643bd5c49eae4be147d4df3469e))

## [0.1.1](https://github.com/VeryGoodOpenSource/flame_behaviors/compare/v0.1.0...v0.1.1) (2022-06-20)

### Bug Fixes

- `PropagatingCollisionBehavior` should also work for non entity components ([#20](https://github.com/VeryGoodOpenSource/flame_behaviors/issues/20)) ([ca5fc6c](https://github.com/VeryGoodOpenSource/flame_behaviors/commit/ca5fc6c2862d58348a7b2a72814f58d370161982))

# [0.1.0](https://github.com/VeryGoodOpenSource/flame_behaviors/compare/v0.0.1-dev.1...v0.1.0) (2022-06-13)

### Bug Fixes

- entity behavior cache is never cleared ([#10](https://github.com/VeryGoodOpenSource/flame_behaviors/issues/10)) ([6751ae8](https://github.com/VeryGoodOpenSource/flame_behaviors/commit/6751ae85eefdc848dd8f4c6c221c3f5d49303aed))
- missing arguments on entity ([#8](https://github.com/VeryGoodOpenSource/flame_behaviors/issues/8)) ([e161daf](https://github.com/VeryGoodOpenSource/flame_behaviors/commit/e161daf360f49423355b4822ff4342bad00c6977))

### Features

- add `hasBehavior` method ([#11](https://github.com/VeryGoodOpenSource/flame_behaviors/issues/11)) ([fb36bc6](https://github.com/VeryGoodOpenSource/flame_behaviors/commit/fb36bc67c152d17fa98b56f88f42b1d86452c4ab))
- add touch based behaviors ([#7](https://github.com/VeryGoodOpenSource/flame_behaviors/issues/7)) ([f7f3d35](https://github.com/VeryGoodOpenSource/flame_behaviors/commit/f7f3d35cade614ca404dc84937777752dca3f5be))
- initial `flame_behaviors` implementation ([#2](https://github.com/VeryGoodOpenSource/flame_behaviors/issues/2)) ([766ebe6](https://github.com/VeryGoodOpenSource/flame_behaviors/commit/766ebe6f398cdb96e93425d86713760c0664075d))
- make the internal find behavior logic more clear on when it can find something ([#12](https://github.com/VeryGoodOpenSource/flame_behaviors/issues/12)) ([e778b00](https://github.com/VeryGoodOpenSource/flame_behaviors/commit/e778b00c06f0bdd3d973548458402e7a3fa051b1))
- proxy `debugMode` down to individual behaviors ([#9](https://github.com/VeryGoodOpenSource/flame_behaviors/issues/9)) ([eaab29f](https://github.com/VeryGoodOpenSource/flame_behaviors/commit/eaab29f3fd17412072e975bd11ebf2828adf548a))

## 0.0.1-dev.1 (2022-05-04)
