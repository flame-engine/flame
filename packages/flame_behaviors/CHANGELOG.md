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
