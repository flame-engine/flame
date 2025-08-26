# Change Log

All notable changes to this project will be documented in this file.
See [Conventional Commits](https://conventionalcommits.org) for commit guidelines.

## 2025-08-26

### Changes

---

Packages with breaking changes:

 - There are no breaking changes in this release.

Packages with other changes:

 - [`flame` - `v1.32.0`](#flame---v1320)
 - [`flame_3d` - `v0.1.1`](#flame_3d---v011)
 - [`flame_tiled` - `v3.0.7`](#flame_tiled---v307)
 - [`flame_behavior_tree` - `v0.1.3+16`](#flame_behavior_tree---v01316)
 - [`flame_test` - `v2.0.3`](#flame_test---v203)
 - [`flame_oxygen` - `v0.2.3+16`](#flame_oxygen---v02316)
 - [`flame_isolate` - `v0.6.2+16`](#flame_isolate---v06216)
 - [`flame_texturepacker` - `v5.0.1`](#flame_texturepacker---v501)
 - [`flame_sprite_fusion` - `v0.2.0+3`](#flame_sprite_fusion---v0203)
 - [`flame_fire_atlas` - `v1.8.11`](#flame_fire_atlas---v1811)
 - [`flame_audio` - `v2.11.10`](#flame_audio---v21110)
 - [`flame_spine` - `v0.2.2+16`](#flame_spine---v02216)
 - [`flame_bloc` - `v1.12.17`](#flame_bloc---v11217)
 - [`flame_kenney_xml` - `v0.1.1+16`](#flame_kenney_xml---v01116)
 - [`flame_lottie` - `v0.4.2+16`](#flame_lottie---v04216)
 - [`flame_markdown` - `v0.2.4+9`](#flame_markdown---v0249)
 - [`flame_console` - `v0.1.2+12`](#flame_console---v01212)
 - [`flame_rive` - `v1.10.19`](#flame_rive---v11019)
 - [`flame_forge2d` - `v0.19.0+6`](#flame_forge2d---v01906)
 - [`flame_noise` - `v0.3.2+16`](#flame_noise---v03216)
 - [`flame_riverpod` - `v5.4.19`](#flame_riverpod---v5419)
 - [`flame_svg` - `v1.11.16`](#flame_svg---v11116)
 - [`flame_network_assets` - `v0.3.3+16`](#flame_network_assets---v03316)

Packages with dependency updates only:

> Packages listed below depend on other packages in this workspace that have had changes. Their versions have been incremented to bump the minimum dependency versions of the packages they depend upon in this project.

 - `flame_behavior_tree` - `v0.1.3+16`
 - `flame_test` - `v2.0.3`
 - `flame_oxygen` - `v0.2.3+16`
 - `flame_isolate` - `v0.6.2+16`
 - `flame_texturepacker` - `v5.0.1`
 - `flame_sprite_fusion` - `v0.2.0+3`
 - `flame_fire_atlas` - `v1.8.11`
 - `flame_audio` - `v2.11.10`
 - `flame_spine` - `v0.2.2+16`
 - `flame_bloc` - `v1.12.17`
 - `flame_kenney_xml` - `v0.1.1+16`
 - `flame_lottie` - `v0.4.2+16`
 - `flame_markdown` - `v0.2.4+9`
 - `flame_console` - `v0.1.2+12`
 - `flame_rive` - `v1.10.19`
 - `flame_forge2d` - `v0.19.0+6`
 - `flame_noise` - `v0.3.2+16`
 - `flame_riverpod` - `v5.4.19`
 - `flame_svg` - `v1.11.16`
 - `flame_network_assets` - `v0.3.3+16`

---

#### `flame` - `v1.32.0`

 - **REFACTOR**: Move MutableRSTransform out of flame_tiled package and into flame package ([#3695](https://github.com/flame-engine/flame/issues/3695)). ([7d644dd8](https://github.com/flame-engine/flame/commit/7d644dd84ce27e292b53f7310967393cf4c60618))
 - **FEAT**: Add renderLine helper to canvas extensions ([#3697](https://github.com/flame-engine/flame/issues/3697)). ([7ede916f](https://github.com/flame-engine/flame/commit/7ede916f77f20d8c1b0c89627800214dba9facec))

#### `flame_3d` - `v0.1.1`

 - **FIX**: Cleanup and make OBJ parser more resilient ([#3702](https://github.com/flame-engine/flame/issues/3702)). ([b96421d5](https://github.com/flame-engine/flame/commit/b96421d5035393d764a9ec34aeba8db380222f45))
 - **FIX**: Fix color to byte conversion for shaders ([#3700](https://github.com/flame-engine/flame/issues/3700)). ([2426c06b](https://github.com/flame-engine/flame/commit/2426c06b799797720c9df8fbd73e337422654d00))
 - **FIX**: Add fallback default material to avoid crashes ([#3701](https://github.com/flame-engine/flame/issues/3701)). ([8e6b04e3](https://github.com/flame-engine/flame/commit/8e6b04e38855b6fae6761a9f8d20c82c6bff6d76))
 - **FIX**: Expose Line3D on components.dart ([#3698](https://github.com/flame-engine/flame/issues/3698)). ([d58d7b54](https://github.com/flame-engine/flame/commit/d58d7b5482f646e4536160449f4a17317b8aff2b))
 - **FEAT**: Introduce cone mesh ([#3699](https://github.com/flame-engine/flame/issues/3699)). ([874a97fe](https://github.com/flame-engine/flame/commit/874a97fe421dadbed9f3825c8562f8bd7e6c95c9))
 - **DOCS**: Update instructions on how to use flame_3d ([#3696](https://github.com/flame-engine/flame/issues/3696)). ([11cc2a8f](https://github.com/flame-engine/flame/commit/11cc2a8fae0f1c17106f91ef1ac319e6f8e39036))

#### `flame_tiled` - `v3.0.7`

 - **REFACTOR**: Move MutableRSTransform out of flame_tiled package and into flame package ([#3695](https://github.com/flame-engine/flame/issues/3695)). ([7d644dd8](https://github.com/flame-engine/flame/commit/7d644dd84ce27e292b53f7310967393cf4c60618))


## 2025-08-23

### Changes

---

Packages with breaking changes:

 - [`flame` - `v1.31.0`](#flame---v1310)
 - [`flame_texturepacker` - `v5.0.0`](#flame_texturepacker---v500)

Packages with other changes:

 - [`flame_3d` - `v0.1.0`](#flame_3d---v010)
 - [`flame_lint` - `v1.4.2`](#flame_lint---v142)
 - [`flame_behavior_tree` - `v0.1.3+15`](#flame_behavior_tree---v01315)
 - [`flame_test` - `v2.0.2`](#flame_test---v202)
 - [`flame_tiled` - `v3.0.6`](#flame_tiled---v306)
 - [`flame_oxygen` - `v0.2.3+15`](#flame_oxygen---v02315)
 - [`flame_isolate` - `v0.6.2+15`](#flame_isolate---v06215)
 - [`flame_sprite_fusion` - `v0.2.0+2`](#flame_sprite_fusion---v0202)
 - [`flame_fire_atlas` - `v1.8.10`](#flame_fire_atlas---v1810)
 - [`flame_audio` - `v2.11.9`](#flame_audio---v2119)
 - [`flame_spine` - `v0.2.2+15`](#flame_spine---v02215)
 - [`flame_bloc` - `v1.12.16`](#flame_bloc---v11216)
 - [`flame_kenney_xml` - `v0.1.1+15`](#flame_kenney_xml---v01115)
 - [`flame_lottie` - `v0.4.2+15`](#flame_lottie---v04215)
 - [`flame_markdown` - `v0.2.4+8`](#flame_markdown---v0248)
 - [`flame_console` - `v0.1.2+11`](#flame_console---v01211)
 - [`flame_rive` - `v1.10.18`](#flame_rive---v11018)
 - [`flame_forge2d` - `v0.19.0+5`](#flame_forge2d---v01905)
 - [`flame_noise` - `v0.3.2+15`](#flame_noise---v03215)
 - [`flame_riverpod` - `v5.4.18`](#flame_riverpod---v5418)
 - [`flame_svg` - `v1.11.15`](#flame_svg---v11115)
 - [`flame_network_assets` - `v0.3.3+15`](#flame_network_assets---v03315)

Packages with dependency updates only:

> Packages listed below depend on other packages in this workspace that have had changes. Their versions have been incremented to bump the minimum dependency versions of the packages they depend upon in this project.

 - `flame_behavior_tree` - `v0.1.3+15`
 - `flame_test` - `v2.0.2`
 - `flame_tiled` - `v3.0.6`
 - `flame_oxygen` - `v0.2.3+15`
 - `flame_isolate` - `v0.6.2+15`
 - `flame_sprite_fusion` - `v0.2.0+2`
 - `flame_fire_atlas` - `v1.8.10`
 - `flame_audio` - `v2.11.9`
 - `flame_spine` - `v0.2.2+15`
 - `flame_bloc` - `v1.12.16`
 - `flame_kenney_xml` - `v0.1.1+15`
 - `flame_lottie` - `v0.4.2+15`
 - `flame_markdown` - `v0.2.4+8`
 - `flame_console` - `v0.1.2+11`
 - `flame_rive` - `v1.10.18`
 - `flame_forge2d` - `v0.19.0+5`
 - `flame_noise` - `v0.3.2+15`
 - `flame_riverpod` - `v5.4.18`
 - `flame_svg` - `v1.11.15`
 - `flame_network_assets` - `v0.3.3+15`

---

#### `flame` - `v1.31.0`

 - **FIX**: Resume engine on mount if paused by backgrounding ([#3631](https://github.com/flame-engine/flame/issues/3631)) ([#3637](https://github.com/flame-engine/flame/issues/3637)). ([b556dc35](https://github.com/flame-engine/flame/commit/b556dc3557d4b655d605c8e2b3744cafd0635841))
 - **FIX**: Export `ComponentRenderContext` ([#3669](https://github.com/flame-engine/flame/issues/3669)). ([086096ca](https://github.com/flame-engine/flame/commit/086096ca73236aaea79a2651cb9e3fa8b6211d50))
 - **FIX**: The `ParallaxComponent` should respect the `virtualSize` ([#3666](https://github.com/flame-engine/flame/issues/3666)). ([9f29c785](https://github.com/flame-engine/flame/commit/9f29c785a1e17428d3a59965b2bf484267c4b2a8))
 - **FIX**: Attach layout listeners to new children ([#3648](https://github.com/flame-engine/flame/issues/3648)). ([4821ec2c](https://github.com/flame-engine/flame/commit/4821ec2ca9cccbf8017d0b539373f599d168c45c))
 - **FEAT**: Add support for model parsing and rendering in flame_3d, including skeletal animations ([#3675](https://github.com/flame-engine/flame/issues/3675)). ([cc58aef5](https://github.com/flame-engine/flame/commit/cc58aef5b53f208fb1cbb116bfb9f9af9a351e8e))
 - **FEAT**: Add Random extensions ([#3672](https://github.com/flame-engine/flame/issues/3672)). ([50e5f296](https://github.com/flame-engine/flame/commit/50e5f29610e9bcc8d939d1e86b5c8bc398516eb1))
 - **FEAT**: Padding component ([#3661](https://github.com/flame-engine/flame/issues/3661)). ([6c953a28](https://github.com/flame-engine/flame/commit/6c953a2862b46c66b91785c5d481385567596adb))
 - **FEAT**: Add canPop to RouterComponent ([#3659](https://github.com/flame-engine/flame/issues/3659)). ([6bd3b48f](https://github.com/flame-engine/flame/commit/6bd3b48ff34c92b221b8a66ac951238d7e6176e0))
 - **FEAT**: Add children and priority to SpriteBatchComponent ([#3649](https://github.com/flame-engine/flame/issues/3649)). ([97b9ba83](https://github.com/flame-engine/flame/commit/97b9ba837e094d79f9e8d8c1ed413717b9d11663))
 - **BREAKING** **REFACTOR**: Remove shrinkwrap ([#3660](https://github.com/flame-engine/flame/issues/3660)). ([e8860f62](https://github.com/flame-engine/flame/commit/e8860f622acaf7df97ca8fcfbdf94fdae26d5921))

#### `flame_texturepacker` - `v5.0.0`

 - **BREAKING** **PERF**: TexturePacker optimizations ([#3647](https://github.com/flame-engine/flame/issues/3647)). ([5cc2eedb](https://github.com/flame-engine/flame/commit/5cc2eedb1cb17f249c97889ba924e763f83d774e))

#### `flame_3d` - `v0.1.0`

 - **REFACTOR**: Add collections library to flame_3d ([#3680](https://github.com/flame-engine/flame/issues/3680)). ([89e5e58e](https://github.com/flame-engine/flame/commit/89e5e58efb580ec267a0dca78a3a0f320203d4ee))
 - **FIX**: Update flame_3d to support both old and newer Flutter APIs ([#3663](https://github.com/flame-engine/flame/issues/3663)). ([d9f1fe7f](https://github.com/flame-engine/flame/commit/d9f1fe7f9abd8f0307ecc22ff24d3b492e9ca332))
 - **FEAT**: Add ability to run on flame_3d example ([#3679](https://github.com/flame-engine/flame/issues/3679)). ([801692bf](https://github.com/flame-engine/flame/commit/801692bfa1226e01f1540166a8140ab42e36ed87))
 - **FEAT**: Add support for model parsing and rendering in flame_3d, including skeletal animations ([#3675](https://github.com/flame-engine/flame/issues/3675)). ([cc58aef5](https://github.com/flame-engine/flame/commit/cc58aef5b53f208fb1cbb116bfb9f9af9a351e8e))
 - **FEAT**: Add setup command to flame_3d example ([#3671](https://github.com/flame-engine/flame/issues/3671)). ([2f5ba87b](https://github.com/flame-engine/flame/commit/2f5ba87be8068b12c2604b79f7db9c1f3307a4b6))
 - **FEAT**: Organize components and add destroy command to flame_3d example ([#3665](https://github.com/flame-engine/flame/issues/3665)). ([d5915752](https://github.com/flame-engine/flame/commit/d591575263d8b13aee862efe05842001aa60f89d))
 - **FEAT**: Add keybind to jump on flame_3d example ([#3664](https://github.com/flame-engine/flame/issues/3664)). ([7be0bccd](https://github.com/flame-engine/flame/commit/7be0bccda0040bfc3734f90b6bca7d5e99455bee))

#### `flame_lint` - `v1.4.2`

 - **FIX**: Update flame_lint to use lints 6.0.0 ([#3612](https://github.com/flame-engine/flame/issues/3612)). ([ba5f6789](https://github.com/flame-engine/flame/commit/ba5f6789bed68e4cc7ca95584e35ed62d0111da2))


## 2025-07-13

### Changes

---

Packages with breaking changes:

 - There are no breaking changes in this release.

Packages with other changes:

 - [`flame` - `v1.30.1`](#flame---v1301)
 - [`flame_lint` - `v1.4.1`](#flame_lint---v141)
 - [`jenny` - `v1.5.0`](#jenny---v150)
 - [`flame_behavior_tree` - `v0.1.3+14`](#flame_behavior_tree---v01314)
 - [`flame_test` - `v2.0.1`](#flame_test---v201)
 - [`flame_tiled` - `v3.0.5`](#flame_tiled---v305)
 - [`flame_oxygen` - `v0.2.3+14`](#flame_oxygen---v02314)
 - [`flame_isolate` - `v0.6.2+14`](#flame_isolate---v06214)
 - [`flame_texturepacker` - `v4.4.1`](#flame_texturepacker---v441)
 - [`flame_sprite_fusion` - `v0.2.0+1`](#flame_sprite_fusion---v0201)
 - [`flame_fire_atlas` - `v1.8.9`](#flame_fire_atlas---v189)
 - [`flame_audio` - `v2.11.8`](#flame_audio---v2118)
 - [`flame_spine` - `v0.2.2+14`](#flame_spine---v02214)
 - [`flame_bloc` - `v1.12.15`](#flame_bloc---v11215)
 - [`flame_kenney_xml` - `v0.1.1+14`](#flame_kenney_xml---v01114)
 - [`flame_lottie` - `v0.4.2+14`](#flame_lottie---v04214)
 - [`flame_markdown` - `v0.2.4+7`](#flame_markdown---v0247)
 - [`flame_console` - `v0.1.2+10`](#flame_console---v01210)
 - [`flame_rive` - `v1.10.17`](#flame_rive---v11017)
 - [`flame_forge2d` - `v0.19.0+4`](#flame_forge2d---v01904)
 - [`flame_noise` - `v0.3.2+14`](#flame_noise---v03214)
 - [`flame_riverpod` - `v5.4.17`](#flame_riverpod---v5417)
 - [`flame_svg` - `v1.11.14`](#flame_svg---v11114)
 - [`flame_network_assets` - `v0.3.3+14`](#flame_network_assets---v03314)
 - [`flame_3d` - `v0.1.0-dev.14`](#flame_3d---v010-dev14)

Packages with dependency updates only:

> Packages listed below depend on other packages in this workspace that have had changes. Their versions have been incremented to bump the minimum dependency versions of the packages they depend upon in this project.

 - `flame_behavior_tree` - `v0.1.3+14`
 - `flame_test` - `v2.0.1`
 - `flame_tiled` - `v3.0.5`
 - `flame_oxygen` - `v0.2.3+14`
 - `flame_isolate` - `v0.6.2+14`
 - `flame_texturepacker` - `v4.4.1`
 - `flame_sprite_fusion` - `v0.2.0+1`
 - `flame_fire_atlas` - `v1.8.9`
 - `flame_audio` - `v2.11.8`
 - `flame_spine` - `v0.2.2+14`
 - `flame_bloc` - `v1.12.15`
 - `flame_kenney_xml` - `v0.1.1+14`
 - `flame_lottie` - `v0.4.2+14`
 - `flame_markdown` - `v0.2.4+7`
 - `flame_console` - `v0.1.2+10`
 - `flame_rive` - `v1.10.17`
 - `flame_forge2d` - `v0.19.0+4`
 - `flame_noise` - `v0.3.2+14`
 - `flame_riverpod` - `v5.4.17`
 - `flame_svg` - `v1.11.14`
 - `flame_network_assets` - `v0.3.3+14`
 - `flame_3d` - `v0.1.0-dev.14`

---

#### `flame` - `v1.30.1`

 - **FIX**: Hitboxes with vertically flipped ancestor should not reflect angle for vertices ([#3642](https://github.com/flame-engine/flame/issues/3642)). ([7e8d3a98](https://github.com/flame-engine/flame/commit/7e8d3a9885f77da12456b148cd1f425395a00f71))
 - **FIX**: Remove unnecessary breaks ([#3638](https://github.com/flame-engine/flame/issues/3638)). ([ea29929c](https://github.com/flame-engine/flame/commit/ea29929cd86ed00407f2d2aa69dcf6f34ffc5bbd))
 - **FEAT**: Adding priority to layout components ([#3639](https://github.com/flame-engine/flame/issues/3639)). ([2eff267d](https://github.com/flame-engine/flame/commit/2eff267d795fbfbf9f5b3215b6dca4a2da9864e1))

#### `flame_lint` - `v1.4.1`

 - **FIX**: Remove unnecessary breaks ([#3638](https://github.com/flame-engine/flame/issues/3638)). ([ea29929c](https://github.com/flame-engine/flame/commit/ea29929cd86ed00407f2d2aa69dcf6f34ffc5bbd))

#### `jenny` - `v1.5.0`

 - **FEAT**: Expose additional flame_jenny Command classes ([#3641](https://github.com/flame-engine/flame/issues/3641)). ([8ef2587d](https://github.com/flame-engine/flame/commit/8ef2587de4a1bef1d745cc1f5a626a7e84c6230c))


## 2025-06-30

### Changes

---

Packages with breaking changes:

 - [`flame` - `v1.30.0`](#flame---v1300)
 - [`flame_sprite_fusion` - `v0.2.0`](#flame_sprite_fusion---v020)
 - [`flame_test` - `v2.0.0`](#flame_test---v200)

Packages with other changes:

 - [`flame_svg` - `v1.11.13`](#flame_svg---v11113)
 - [`flame_texturepacker` - `v4.4.0`](#flame_texturepacker---v440)
 - [`flame_tiled` - `v3.0.4`](#flame_tiled---v304)
 - [`flame_behavior_tree` - `v0.1.3+13`](#flame_behavior_tree---v01313)
 - [`flame_oxygen` - `v0.2.3+13`](#flame_oxygen---v02313)
 - [`flame_isolate` - `v0.6.2+13`](#flame_isolate---v06213)
 - [`flame_fire_atlas` - `v1.8.8`](#flame_fire_atlas---v188)
 - [`flame_audio` - `v2.11.7`](#flame_audio---v2117)
 - [`flame_spine` - `v0.2.2+13`](#flame_spine---v02213)
 - [`flame_bloc` - `v1.12.14`](#flame_bloc---v11214)
 - [`flame_kenney_xml` - `v0.1.1+13`](#flame_kenney_xml---v01113)
 - [`flame_lottie` - `v0.4.2+13`](#flame_lottie---v04213)
 - [`flame_markdown` - `v0.2.4+6`](#flame_markdown---v0246)
 - [`flame_console` - `v0.1.2+9`](#flame_console---v0129)
 - [`flame_rive` - `v1.10.16`](#flame_rive---v11016)
 - [`flame_forge2d` - `v0.19.0+3`](#flame_forge2d---v01903)
 - [`flame_noise` - `v0.3.2+13`](#flame_noise---v03213)
 - [`flame_riverpod` - `v5.4.16`](#flame_riverpod---v5416)
 - [`flame_network_assets` - `v0.3.3+13`](#flame_network_assets---v03313)
 - [`flame_3d` - `v0.1.0-dev.13`](#flame_3d---v010-dev13)

Packages with dependency updates only:

> Packages listed below depend on other packages in this workspace that have had changes. Their versions have been incremented to bump the minimum dependency versions of the packages they depend upon in this project.

 - `flame_behavior_tree` - `v0.1.3+13`
 - `flame_oxygen` - `v0.2.3+13`
 - `flame_isolate` - `v0.6.2+13`
 - `flame_fire_atlas` - `v1.8.8`
 - `flame_audio` - `v2.11.7`
 - `flame_spine` - `v0.2.2+13`
 - `flame_bloc` - `v1.12.14`
 - `flame_kenney_xml` - `v0.1.1+13`
 - `flame_lottie` - `v0.4.2+13`
 - `flame_markdown` - `v0.2.4+6`
 - `flame_console` - `v0.1.2+9`
 - `flame_rive` - `v1.10.16`
 - `flame_forge2d` - `v0.19.0+3`
 - `flame_noise` - `v0.3.2+13`
 - `flame_riverpod` - `v5.4.16`
 - `flame_network_assets` - `v0.3.3+13`
 - `flame_3d` - `v0.1.0-dev.13`

---

#### `flame` - `v1.30.0`

 - **FIX**: `angleTo` and `lookAt` should consider parental transformations ([#3629](https://github.com/flame-engine/flame/issues/3629)). ([e6f3d105](https://github.com/flame-engine/flame/commit/e6f3d105577cd346d377aaaed42d4ceb93aec077))
 - **FIX**: `angleTo`, `absoluteAngle` and the `angle` setter now returns normalized angles between `[-pi, pi]` ([#3629](https://github.com/flame-engine/flame/issues/3629)). ([e6f3d105](https://github.com/flame-engine/flame/commit/e6f3d105577cd346d377aaaed42d4ceb93aec077))
 - **FIX**: Delay should work with SpeedEffectControllers ([#3618](https://github.com/flame-engine/flame/issues/3618)). ([bfbb49f5](https://github.com/flame-engine/flame/commit/bfbb49f5b6aac4f69c8602cd20a457e95fe02973))
 - **FIX**: Pass in intended parent to remove ([#3626](https://github.com/flame-engine/flame/issues/3626)). ([7a05f74d](https://github.com/flame-engine/flame/commit/7a05f74dff7c3dbac96d8c8eb52ad7f0625266a1))
 - **FIX**: Call `super.onDispose` last and check `mounted` before `setState` ([#3623](https://github.com/flame-engine/flame/issues/3623)). ([3d2716c1](https://github.com/flame-engine/flame/commit/3d2716c1fb2b64d363dbc8e9aea852723e909710))
 - **FIX**: Angled line intersections should work with 32-bit vectors ([#3617](https://github.com/flame-engine/flame/issues/3617)). ([e32bff45](https://github.com/flame-engine/flame/commit/e32bff455c0f5715c1a7018f865b44b2410ed7db))
 - **FIX**: PostProcessComponent should size dynamically ([#3611](https://github.com/flame-engine/flame/issues/3611)). ([baecb861](https://github.com/flame-engine/flame/commit/baecb86186a1bff7f21d804e7867f894d2f9d23c))
 - **FEAT**: Add `target` argument to `SpawnComponent` ([#3635](https://github.com/flame-engine/flame/issues/3635)). ([3747e1e8](https://github.com/flame-engine/flame/commit/3747e1e8bd1f4bde3c6b64fff0f336690f9da6c8))
 - **FEAT**: Add `spawnCount` to `SpawnComponent` ([#3634](https://github.com/flame-engine/flame/issues/3634)). ([f377d7e7](https://github.com/flame-engine/flame/commit/f377d7e702892836a5fded1c8d4f648682e69e50))
 - **FEAT**: Adding RasterSpriteComponent.fromImage constructor ([#3627](https://github.com/flame-engine/flame/issues/3627)). ([74a84ba7](https://github.com/flame-engine/flame/commit/74a84ba7c159631296961eec994179e227ccd1d3))
 - **FEAT**: Implement measure to fix ghost lines and graphical artifacts in Sprites ([#3590](https://github.com/flame-engine/flame/issues/3590)). ([6fd36bc1](https://github.com/flame-engine/flame/commit/6fd36bc1d883d61621806fba54a792dc6924c4e8))
 - **BREAKING** **FEAT**: Pass `WidgetTester` for `testGolden` prepare function ([#3624](https://github.com/flame-engine/flame/issues/3624)). ([10509326](https://github.com/flame-engine/flame/commit/105093266431408db0f9e74042e03e2234d9b22e))

#### `flame_sprite_fusion` - `v0.2.0`

 - **BREAKING** **FEAT**: Pass `WidgetTester` for `testGolden` prepare function ([#3624](https://github.com/flame-engine/flame/issues/3624)). ([10509326](https://github.com/flame-engine/flame/commit/105093266431408db0f9e74042e03e2234d9b22e))

#### `flame_test` - `v2.0.0`

 - **BREAKING** **FEAT**: Pass `WidgetTester` for `testGolden` prepare function ([#3624](https://github.com/flame-engine/flame/issues/3624)). ([10509326](https://github.com/flame-engine/flame/commit/105093266431408db0f9e74042e03e2234d9b22e))

#### `flame_svg` - `v1.11.13`

 - **FIX**: Calculate zoom ratio before rendering svg ([#3616](https://github.com/flame-engine/flame/issues/3616)). ([f8b7ef82](https://github.com/flame-engine/flame/commit/f8b7ef82b7fc54af7171c94ae2112b18cebb236a))

#### `flame_texturepacker` - `v4.4.0`

 - **FEAT**: Implement measure to fix ghost lines and graphical artifacts in Sprites ([#3590](https://github.com/flame-engine/flame/issues/3590)). ([6fd36bc1](https://github.com/flame-engine/flame/commit/6fd36bc1d883d61621806fba54a792dc6924c4e8))

#### `flame_tiled` - `v3.0.4`

 - **FIX**: Add optional key parameter to TiledComponent.load method ([#3630](https://github.com/flame-engine/flame/issues/3630)). ([5a27746e](https://github.com/flame-engine/flame/commit/5a27746ee4dbab17565472133274dd1308525978))
 - **FIX**: PostProcessComponent should size dynamically ([#3611](https://github.com/flame-engine/flame/issues/3611)). ([baecb861](https://github.com/flame-engine/flame/commit/baecb86186a1bff7f21d804e7867f894d2f9d23c))


## 2025-05-23

### Changes

---

Packages with breaking changes:

 - [`flame` - `v1.29.0`](#flame---v1290)

Packages with other changes:

 - [`flame_3d` - `v0.1.0-dev.12`](#flame_3d---v010-dev12)
 - [`flame_lint` - `v1.4.0`](#flame_lint---v140)
 - [`jenny` - `v1.4.0`](#jenny---v140)
 - [`flame_behavior_tree` - `v0.1.3+12`](#flame_behavior_tree---v01312)
 - [`flame_test` - `v1.19.2`](#flame_test---v1192)
 - [`flame_tiled` - `v3.0.3`](#flame_tiled---v303)
 - [`flame_oxygen` - `v0.2.3+12`](#flame_oxygen---v02312)
 - [`flame_isolate` - `v0.6.2+12`](#flame_isolate---v06212)
 - [`flame_texturepacker` - `v4.3.1`](#flame_texturepacker---v431)
 - [`flame_sprite_fusion` - `v0.1.3+12`](#flame_sprite_fusion---v01312)
 - [`flame_fire_atlas` - `v1.8.7`](#flame_fire_atlas---v187)
 - [`flame_audio` - `v2.11.6`](#flame_audio---v2116)
 - [`flame_spine` - `v0.2.2+12`](#flame_spine---v02212)
 - [`flame_bloc` - `v1.12.13`](#flame_bloc---v11213)
 - [`flame_kenney_xml` - `v0.1.1+12`](#flame_kenney_xml---v01112)
 - [`flame_lottie` - `v0.4.2+12`](#flame_lottie---v04212)
 - [`flame_markdown` - `v0.2.4+5`](#flame_markdown---v0245)
 - [`flame_console` - `v0.1.2+8`](#flame_console---v0128)
 - [`flame_rive` - `v1.10.15`](#flame_rive---v11015)
 - [`flame_forge2d` - `v0.19.0+2`](#flame_forge2d---v01902)
 - [`flame_noise` - `v0.3.2+12`](#flame_noise---v03212)
 - [`flame_riverpod` - `v5.4.15`](#flame_riverpod---v5415)
 - [`flame_svg` - `v1.11.12`](#flame_svg---v11112)
 - [`flame_network_assets` - `v0.3.3+12`](#flame_network_assets---v03312)

Packages with dependency updates only:

> Packages listed below depend on other packages in this workspace that have had changes. Their versions have been incremented to bump the minimum dependency versions of the packages they depend upon in this project.

 - `flame_behavior_tree` - `v0.1.3+12`
 - `flame_test` - `v1.19.2`
 - `flame_tiled` - `v3.0.3`
 - `flame_oxygen` - `v0.2.3+12`
 - `flame_isolate` - `v0.6.2+12`
 - `flame_texturepacker` - `v4.3.1`
 - `flame_sprite_fusion` - `v0.1.3+12`
 - `flame_fire_atlas` - `v1.8.7`
 - `flame_audio` - `v2.11.6`
 - `flame_spine` - `v0.2.2+12`
 - `flame_bloc` - `v1.12.13`
 - `flame_kenney_xml` - `v0.1.1+12`
 - `flame_lottie` - `v0.4.2+12`
 - `flame_markdown` - `v0.2.4+5`
 - `flame_console` - `v0.1.2+8`
 - `flame_rive` - `v1.10.15`
 - `flame_forge2d` - `v0.19.0+2`
 - `flame_noise` - `v0.3.2+12`
 - `flame_riverpod` - `v5.4.15`
 - `flame_svg` - `v1.11.12`
 - `flame_network_assets` - `v0.3.3+12`

---

#### `flame` - `v1.29.0`

 - **FIX**: Only expose `ReadOnlyOrderedset` from `component.children` ([#3606](https://github.com/flame-engine/flame/issues/3606)). ([79351d19](https://github.com/flame-engine/flame/commit/79351d195ea968b8016129e79a489ef113a0fdf3))
 - **FIX**: Dispose picture is postprocess  ([#3604](https://github.com/flame-engine/flame/issues/3604)). ([3b24cdac](https://github.com/flame-engine/flame/commit/3b24cdac18ec6d846dbc4d08905fbcb897f90be8))
 - **FIX**: Materialize post process list before removing items ([#3591](https://github.com/flame-engine/flame/issues/3591)). ([e858cc1f](https://github.com/flame-engine/flame/commit/e858cc1fc74814769fc11f49014190d37bda5cbe))
 - **DOCS**: Update structure and add RowComponent + ColumnComponent docs ([#3599](https://github.com/flame-engine/flame/issues/3599)). ([d04843a4](https://github.com/flame-engine/flame/commit/d04843a44c9987825cc927a2ec8952395b423ba4))
 - **BREAKING** **FEAT**: Children should retain `parent` after parent is remove from tree ([#3602](https://github.com/flame-engine/flame/issues/3602)). ([008829af](https://github.com/flame-engine/flame/commit/008829af67e3556a92b926db6b6368acf10e249b))

#### `flame_3d` - `v0.1.0-dev.12`

 - **FIX**: Only expose `ReadOnlyOrderedset` from `component.children` ([#3606](https://github.com/flame-engine/flame/issues/3606)). ([79351d19](https://github.com/flame-engine/flame/commit/79351d195ea968b8016129e79a489ef113a0fdf3))

#### `flame_lint` - `v1.4.0`

 - **FEAT**: Preserve trailing commas in Dart ^3.8.0 ([#3607](https://github.com/flame-engine/flame/issues/3607)). ([433829cb](https://github.com/flame-engine/flame/commit/433829cbdaafa9b1e9f0250b68f5143ec1a4d562))

#### `jenny` - `v1.4.0`

 - **FEAT**(Jenny): Add onCommandFinish lifecycle method to DialogueView ([#3600](https://github.com/flame-engine/flame/issues/3600)). ([bd5a4ca6](https://github.com/flame-engine/flame/commit/bd5a4ca68a46feb6734a70d5320bb7bf23b782d5))


## 2025-04-23

### Changes

---

Packages with breaking changes:

 - There are no breaking changes in this release.

Packages with other changes:

 - [`flame` - `v1.28.1`](#flame---v1281)
 - [`flame_3d` - `v0.1.0-dev.11`](#flame_3d---v010-dev11)
 - [`flame_console` - `v0.1.2+7`](#flame_console---v0127)
 - [`flame_texturepacker` - `v4.3.0`](#flame_texturepacker---v430)
 - [`flame_behavior_tree` - `v0.1.3+11`](#flame_behavior_tree---v01311)
 - [`flame_test` - `v1.19.1`](#flame_test---v1191)
 - [`flame_tiled` - `v3.0.2`](#flame_tiled---v302)
 - [`flame_oxygen` - `v0.2.3+11`](#flame_oxygen---v02311)
 - [`flame_isolate` - `v0.6.2+11`](#flame_isolate---v06211)
 - [`flame_sprite_fusion` - `v0.1.3+11`](#flame_sprite_fusion---v01311)
 - [`flame_fire_atlas` - `v1.8.6`](#flame_fire_atlas---v186)
 - [`flame_audio` - `v2.11.5`](#flame_audio---v2115)
 - [`flame_spine` - `v0.2.2+11`](#flame_spine---v02211)
 - [`flame_bloc` - `v1.12.12`](#flame_bloc---v11212)
 - [`flame_kenney_xml` - `v0.1.1+11`](#flame_kenney_xml---v01111)
 - [`flame_lottie` - `v0.4.2+11`](#flame_lottie---v04211)
 - [`flame_markdown` - `v0.2.4+4`](#flame_markdown---v0244)
 - [`flame_rive` - `v1.10.14`](#flame_rive---v11014)
 - [`flame_forge2d` - `v0.19.0+1`](#flame_forge2d---v01901)
 - [`flame_noise` - `v0.3.2+11`](#flame_noise---v03211)
 - [`flame_riverpod` - `v5.4.14`](#flame_riverpod---v5414)
 - [`flame_svg` - `v1.11.11`](#flame_svg---v11111)
 - [`flame_network_assets` - `v0.3.3+11`](#flame_network_assets---v03311)

Packages with dependency updates only:

> Packages listed below depend on other packages in this workspace that have had changes. Their versions have been incremented to bump the minimum dependency versions of the packages they depend upon in this project.

 - `flame_behavior_tree` - `v0.1.3+11`
 - `flame_test` - `v1.19.1`
 - `flame_tiled` - `v3.0.2`
 - `flame_oxygen` - `v0.2.3+11`
 - `flame_isolate` - `v0.6.2+11`
 - `flame_sprite_fusion` - `v0.1.3+11`
 - `flame_fire_atlas` - `v1.8.6`
 - `flame_audio` - `v2.11.5`
 - `flame_spine` - `v0.2.2+11`
 - `flame_bloc` - `v1.12.12`
 - `flame_kenney_xml` - `v0.1.1+11`
 - `flame_lottie` - `v0.4.2+11`
 - `flame_markdown` - `v0.2.4+4`
 - `flame_rive` - `v1.10.14`
 - `flame_forge2d` - `v0.19.0+1`
 - `flame_noise` - `v0.3.2+11`
 - `flame_riverpod` - `v5.4.14`
 - `flame_svg` - `v1.11.11`
 - `flame_network_assets` - `v0.3.3+11`

---

#### `flame` - `v1.28.1`

 - **REFACTOR**: Replace dart:io usage with defaultTargetPlatform ([#3567](https://github.com/flame-engine/flame/issues/3567)). ([77925eb8](https://github.com/flame-engine/flame/commit/77925eb84e3ab23c301d504ccc85cc84a91cb3e4))
 - **FIX**: Add fragment shader extension from flutter_shaders ([#3578](https://github.com/flame-engine/flame/issues/3578)). ([27115729](https://github.com/flame-engine/flame/commit/271157295209cc3f147d38582c7c9447e2e84844))
 - **FIX**: Use `virtualSize` when calling `onParentResize` on children of `Viewport` ([#3577](https://github.com/flame-engine/flame/issues/3577)). ([245fb3f5](https://github.com/flame-engine/flame/commit/245fb3f5cf286b19076e758b8fea75a410680ffe))
 - **FEAT**: Add method to toggle overlays ([#3581](https://github.com/flame-engine/flame/issues/3581)). ([ad7c37e1](https://github.com/flame-engine/flame/commit/ad7c37e16b20b71c8049d68fd57414b174fd9492))

#### `flame_3d` - `v0.1.0-dev.11`

 - **FEAT**: Add flame_console to flame_3d example to enable more complex setups ([#3580](https://github.com/flame-engine/flame/issues/3580)). ([15a6f8b0](https://github.com/flame-engine/flame/commit/15a6f8b001deb714134976d7cbb5ef0a6ec31c86))
 - **DOCS**: Update flame_3d example to fix movement and camera, organize files ([#3573](https://github.com/flame-engine/flame/issues/3573)). ([54ca8433](https://github.com/flame-engine/flame/commit/54ca8433f20b451eb1a2c3c5f5a47a3430e71a6e))

#### `flame_console` - `v0.1.2+7`

 - **FIX**: Export necessary classes to build custom commands, update docs [flame_console] ([#3579](https://github.com/flame-engine/flame/issues/3579)). ([b05d55bc](https://github.com/flame-engine/flame/commit/b05d55bcc5f331ac8a8d82619b6df3a546848e10))

#### `flame_texturepacker` - `v4.3.0`

 - **FEAT**: Use `XFile` to support web platform ([#3569](https://github.com/flame-engine/flame/issues/3569)). ([20731167](https://github.com/flame-engine/flame/commit/20731167e8574e98d784b9734dbcee9ba6e6aa88))


## 2025-04-18

### Changes

---

Packages with breaking changes:

 - [`flame` - `v1.28.0`](#flame---v1280)
 - [`flame_test` - `v1.19.0`](#flame_test---v1190)
 - [`flame_forge2d` - `v0.19.0`](#flame_forge2d---v0190)

Packages with other changes:

 - [`flame_3d` - `v0.1.0-dev.10`](#flame_3d---v010-dev10)
 - [`flame_svg` - `v1.11.10`](#flame_svg---v11110)
 - [`flame_texturepacker` - `v4.2.0`](#flame_texturepacker---v420)
 - [`flame_behavior_tree` - `v0.1.3+10`](#flame_behavior_tree---v01310)
 - [`flame_tiled` - `v3.0.1`](#flame_tiled---v301)
 - [`flame_oxygen` - `v0.2.3+10`](#flame_oxygen---v02310)
 - [`flame_isolate` - `v0.6.2+10`](#flame_isolate---v06210)
 - [`flame_sprite_fusion` - `v0.1.3+10`](#flame_sprite_fusion---v01310)
 - [`flame_fire_atlas` - `v1.8.5`](#flame_fire_atlas---v185)
 - [`flame_audio` - `v2.11.4`](#flame_audio---v2114)
 - [`flame_spine` - `v0.2.2+10`](#flame_spine---v02210)
 - [`flame_bloc` - `v1.12.11`](#flame_bloc---v11211)
 - [`flame_kenney_xml` - `v0.1.1+10`](#flame_kenney_xml---v01110)
 - [`flame_lottie` - `v0.4.2+10`](#flame_lottie---v04210)
 - [`flame_markdown` - `v0.2.4+3`](#flame_markdown---v0243)
 - [`flame_console` - `v0.1.2+6`](#flame_console---v0126)
 - [`flame_rive` - `v1.10.13`](#flame_rive---v11013)
 - [`flame_noise` - `v0.3.2+10`](#flame_noise---v03210)
 - [`flame_riverpod` - `v5.4.13`](#flame_riverpod---v5413)
 - [`flame_network_assets` - `v0.3.3+10`](#flame_network_assets---v03310)

Packages with dependency updates only:

> Packages listed below depend on other packages in this workspace that have had changes. Their versions have been incremented to bump the minimum dependency versions of the packages they depend upon in this project.

 - `flame_behavior_tree` - `v0.1.3+10`
 - `flame_tiled` - `v3.0.1`
 - `flame_oxygen` - `v0.2.3+10`
 - `flame_isolate` - `v0.6.2+10`
 - `flame_sprite_fusion` - `v0.1.3+10`
 - `flame_fire_atlas` - `v1.8.5`
 - `flame_audio` - `v2.11.4`
 - `flame_spine` - `v0.2.2+10`
 - `flame_bloc` - `v1.12.11`
 - `flame_kenney_xml` - `v0.1.1+10`
 - `flame_lottie` - `v0.4.2+10`
 - `flame_markdown` - `v0.2.4+3`
 - `flame_console` - `v0.1.2+6`
 - `flame_rive` - `v1.10.13`
 - `flame_noise` - `v0.3.2+10`
 - `flame_riverpod` - `v5.4.13`
 - `flame_network_assets` - `v0.3.3+10`

---

#### `flame` - `v1.28.0`

 - **FIX**: Priority change should be reflected directly ([#3564](https://github.com/flame-engine/flame/issues/3564)). ([ab2fd639](https://github.com/flame-engine/flame/commit/ab2fd639f73896c0859dd133337ec2adc7adf832))
 - **FIX**: Deprecate `HasGameRef` in favor of `HasGameReference` ([#3559](https://github.com/flame-engine/flame/issues/3559)). ([a882261b](https://github.com/flame-engine/flame/commit/a882261b63ef21e29dde041d99b2eaf94264d7ad))
 - **FIX**: The SpriteButton label should be nullable ([#3557](https://github.com/flame-engine/flame/issues/3557)). ([80a598cd](https://github.com/flame-engine/flame/commit/80a598cd006f2cf90b1b799bbb51c0c073a94743))
 - **FIX**: Update ordered_set, remove ComponentSet ([#3554](https://github.com/flame-engine/flame/issues/3554)). ([728e13f8](https://github.com/flame-engine/flame/commit/728e13f855d988e8f8e24976557b213b98221603))
 - **FEAT**: Post Process API ([#3404](https://github.com/flame-engine/flame/issues/3404)). ([c3316ae4](https://github.com/flame-engine/flame/commit/c3316ae4a50230e6d9720cb4653a8e3e309f3234))
 - **FEAT**: Add helper methods on LineSegment (translate, inflate, deflate, spread) ([#3561](https://github.com/flame-engine/flame/issues/3561)). ([6d388870](https://github.com/flame-engine/flame/commit/6d388870138b9e02e120647d241d7cf9093795f6))
 - **FEAT**: Support for disabled state for `SpriteButton` ([#3560](https://github.com/flame-engine/flame/issues/3560)). ([eaa2b442](https://github.com/flame-engine/flame/commit/eaa2b442b717ae086cac2d715a322ffa7c7a1116))
 - **FEAT**: Add a Render Context API ([#3409](https://github.com/flame-engine/flame/issues/3409)). ([532f0191](https://github.com/flame-engine/flame/commit/532f0191f658e767fde4c200cf1902cbe36d6e7d))
 - **FEAT**: Adding tickCount to TimerComponent ([#3552](https://github.com/flame-engine/flame/issues/3552)). ([dcd694e8](https://github.com/flame-engine/flame/commit/dcd694e8554c59b4b92f6d05928320c175d433f0))
 - **FEAT**: Ability to reset SpriteAnimation on removal ([#3553](https://github.com/flame-engine/flame/issues/3553)). ([59ae5831](https://github.com/flame-engine/flame/commit/59ae58318eba93e3909bdb2deaa13f6aa7b7d35e))
 - **BREAKING** **FIX**: Use 32bit Vector2 in Flame to be compatible with shaders and forge2d ([#3515](https://github.com/flame-engine/flame/issues/3515)). ([19dcecf5](https://github.com/flame-engine/flame/commit/19dcecf5df85345fd4fac168e1f360cee4665658))

#### `flame_test` - `v1.19.0`

 - **BREAKING** **FIX**: Use 32bit Vector2 in Flame to be compatible with shaders and forge2d ([#3515](https://github.com/flame-engine/flame/issues/3515)). ([19dcecf5](https://github.com/flame-engine/flame/commit/19dcecf5df85345fd4fac168e1f360cee4665658))

#### `flame_forge2d` - `v0.19.0`

 - **BREAKING** **FIX**: Use 32bit Vector2 in Flame to be compatible with shaders and forge2d ([#3515](https://github.com/flame-engine/flame/issues/3515)). ([19dcecf5](https://github.com/flame-engine/flame/commit/19dcecf5df85345fd4fac168e1f360cee4665658))

#### `flame_3d` - `v0.1.0-dev.10`

 - **FIX**: Update ordered_set, remove ComponentSet ([#3554](https://github.com/flame-engine/flame/issues/3554)). ([728e13f8](https://github.com/flame-engine/flame/commit/728e13f855d988e8f8e24976557b213b98221603))

#### `flame_svg` - `v1.11.10`

 - **FIX**: SvgComponent should use `drawImage` on first render too ([#3549](https://github.com/flame-engine/flame/issues/3549)). ([91721a6b](https://github.com/flame-engine/flame/commit/91721a6b7b2ecda338d64d3c982e448e9cd71122))

#### `flame_texturepacker` - `v4.2.0`

 - **FEAT**: Whitelist textures ([#3505](https://github.com/flame-engine/flame/issues/3505)). ([9ca9e858](https://github.com/flame-engine/flame/commit/9ca9e858442031cf91798e0fe09cbadc232b3900))


## 2025-04-02

### Changes

---

Packages with breaking changes:

 - [`flame_tiled` - `v3.0.0`](#flame_tiled---v300)

Packages with other changes:

 - [`jenny` - `v1.3.3`](#jenny---v133)
 - [`flame` - `v1.27.0`](#flame---v1270)
 - [`flame_3d` - `v0.1.0-dev.9`](#flame_3d---v010-dev9)
 - [`flame_forge2d` - `v0.18.3+1`](#flame_forge2d---v01831)
 - [`flame_isolate` - `v0.6.2+9`](#flame_isolate---v0629)
 - [`flame_lint` - `v1.3.0`](#flame_lint---v130)
 - [`flame_rive` - `v1.10.12`](#flame_rive---v11012)
 - [`flame_texturepacker` - `v4.1.9`](#flame_texturepacker---v419)
 - [`flame_behavior_tree` - `v0.1.3+9`](#flame_behavior_tree---v0139)
 - [`flame_test` - `v1.18.3`](#flame_test---v1183)
 - [`flame_oxygen` - `v0.2.3+9`](#flame_oxygen---v0239)
 - [`flame_sprite_fusion` - `v0.1.3+9`](#flame_sprite_fusion---v0139)
 - [`flame_fire_atlas` - `v1.8.4`](#flame_fire_atlas---v184)
 - [`flame_audio` - `v2.11.3`](#flame_audio---v2113)
 - [`flame_spine` - `v0.2.2+9`](#flame_spine---v0229)
 - [`flame_bloc` - `v1.12.10`](#flame_bloc---v11210)
 - [`flame_kenney_xml` - `v0.1.1+9`](#flame_kenney_xml---v0119)
 - [`flame_lottie` - `v0.4.2+9`](#flame_lottie---v0429)
 - [`flame_markdown` - `v0.2.4+2`](#flame_markdown---v0242)
 - [`flame_console` - `v0.1.2+5`](#flame_console---v0125)
 - [`flame_noise` - `v0.3.2+9`](#flame_noise---v0329)
 - [`flame_riverpod` - `v5.4.12`](#flame_riverpod---v5412)
 - [`flame_svg` - `v1.11.9`](#flame_svg---v1119)
 - [`flame_network_assets` - `v0.3.3+9`](#flame_network_assets---v0339)

Packages with dependency updates only:

> Packages listed below depend on other packages in this workspace that have had changes. Their versions have been incremented to bump the minimum dependency versions of the packages they depend upon in this project.

 - `flame_behavior_tree` - `v0.1.3+9`
 - `flame_test` - `v1.18.3`
 - `flame_oxygen` - `v0.2.3+9`
 - `flame_sprite_fusion` - `v0.1.3+9`
 - `flame_fire_atlas` - `v1.8.4`
 - `flame_audio` - `v2.11.3`
 - `flame_spine` - `v0.2.2+9`
 - `flame_bloc` - `v1.12.10`
 - `flame_kenney_xml` - `v0.1.1+9`
 - `flame_lottie` - `v0.4.2+9`
 - `flame_markdown` - `v0.2.4+2`
 - `flame_console` - `v0.1.2+5`
 - `flame_noise` - `v0.3.2+9`
 - `flame_riverpod` - `v5.4.12`
 - `flame_svg` - `v1.11.9`
 - `flame_network_assets` - `v0.3.3+9`

---

#### `flame_tiled` - `v3.0.0`

 - **BREAKING** **FIX**: Add APIs to get TileData by layer index ([#3539](https://github.com/flame-engine/flame/issues/3539)). ([4676b1b7](https://github.com/flame-engine/flame/commit/4676b1b7a5aefe7a958de55b1d209e554c9b02a6))

#### `jenny` - `v1.3.3`

 - **FEAT**: Bump to new lint package ([#3545](https://github.com/flame-engine/flame/issues/3545)). ([bf6ee518](https://github.com/flame-engine/flame/commit/bf6ee51897591b7ad6e5f9da2193b1eeeaf026f4))

#### `flame` - `v1.27.0`

 - **FIX**: Remove outdated deprecations ([#3541](https://github.com/flame-engine/flame/issues/3541)). ([b918e40d](https://github.com/flame-engine/flame/commit/b918e40d0ce14b89ba9b5c82aed8ff51d6f549c3))
 - **FEAT**: Bump to new lint package ([#3545](https://github.com/flame-engine/flame/issues/3545)). ([bf6ee518](https://github.com/flame-engine/flame/commit/bf6ee51897591b7ad6e5f9da2193b1eeeaf026f4))
 - **FEAT**: The `FunctionEffect`, run any function as an `Effect` ([#3537](https://github.com/flame-engine/flame/issues/3537)). ([f4ac1ec6](https://github.com/flame-engine/flame/commit/f4ac1ec63a22b7a7d0c17d7119787f3ce2acadc1))

#### `flame_3d` - `v0.1.0-dev.9`

 - **FEAT**: Bump to new lint package ([#3545](https://github.com/flame-engine/flame/issues/3545)). ([bf6ee518](https://github.com/flame-engine/flame/commit/bf6ee51897591b7ad6e5f9da2193b1eeeaf026f4))

#### `flame_forge2d` - `v0.18.3+1`

 - **FIX**: Remove outdated deprecations ([#3541](https://github.com/flame-engine/flame/issues/3541)). ([b918e40d](https://github.com/flame-engine/flame/commit/b918e40d0ce14b89ba9b5c82aed8ff51d6f549c3))

#### `flame_isolate` - `v0.6.2+9`

 - **FIX**: Remove outdated deprecations ([#3541](https://github.com/flame-engine/flame/issues/3541)). ([b918e40d](https://github.com/flame-engine/flame/commit/b918e40d0ce14b89ba9b5c82aed8ff51d6f549c3))

#### `flame_lint` - `v1.3.0`

 - **FEAT**: Bump to new lint package ([#3545](https://github.com/flame-engine/flame/issues/3545)). ([bf6ee518](https://github.com/flame-engine/flame/commit/bf6ee51897591b7ad6e5f9da2193b1eeeaf026f4))

#### `flame_rive` - `v1.10.12`

 - **FIX**: Bump Rive version and skip tests ([#3544](https://github.com/flame-engine/flame/issues/3544)). ([a3a7dd51](https://github.com/flame-engine/flame/commit/a3a7dd51faee57d74e89fbc29e7581ed44459832))

#### `flame_texturepacker` - `v4.1.9`

 - **FIX**: Remove outdated deprecations ([#3541](https://github.com/flame-engine/flame/issues/3541)). ([b918e40d](https://github.com/flame-engine/flame/commit/b918e40d0ce14b89ba9b5c82aed8ff51d6f549c3))


## 2025-03-21

### Changes

---

Packages with breaking changes:

 - There are no breaking changes in this release.

Packages with other changes:

 - [`flame_forge2d` - `v0.18.3`](#flame_forge2d---v0183)
 - [`flame` - `v1.26.1`](#flame---v1261)
 - [`flame_spine` - `v0.2.2+8`](#flame_spine---v0228)
 - [`flame_behavior_tree` - `v0.1.3+8`](#flame_behavior_tree---v0138)
 - [`flame_test` - `v1.18.2`](#flame_test---v1182)
 - [`flame_tiled` - `v2.0.3`](#flame_tiled---v203)
 - [`flame_oxygen` - `v0.2.3+8`](#flame_oxygen---v0238)
 - [`flame_isolate` - `v0.6.2+8`](#flame_isolate---v0628)
 - [`flame_texturepacker` - `v4.1.8`](#flame_texturepacker---v418)
 - [`flame_sprite_fusion` - `v0.1.3+8`](#flame_sprite_fusion---v0138)
 - [`flame_fire_atlas` - `v1.8.3`](#flame_fire_atlas---v183)
 - [`flame_audio` - `v2.11.2`](#flame_audio---v2112)
 - [`flame_bloc` - `v1.12.9`](#flame_bloc---v1129)
 - [`flame_kenney_xml` - `v0.1.1+8`](#flame_kenney_xml---v0118)
 - [`flame_lottie` - `v0.4.2+8`](#flame_lottie---v0428)
 - [`flame_markdown` - `v0.2.4+1`](#flame_markdown---v0241)
 - [`flame_console` - `v0.1.2+4`](#flame_console---v0124)
 - [`flame_rive` - `v1.10.11`](#flame_rive---v11011)
 - [`flame_noise` - `v0.3.2+8`](#flame_noise---v0328)
 - [`flame_riverpod` - `v5.4.11`](#flame_riverpod---v5411)
 - [`flame_svg` - `v1.11.8`](#flame_svg---v1118)
 - [`flame_network_assets` - `v0.3.3+8`](#flame_network_assets---v0338)
 - [`flame_3d` - `v0.1.0-dev.8`](#flame_3d---v010-dev8)

Packages with dependency updates only:

> Packages listed below depend on other packages in this workspace that have had changes. Their versions have been incremented to bump the minimum dependency versions of the packages they depend upon in this project.

 - `flame_behavior_tree` - `v0.1.3+8`
 - `flame_test` - `v1.18.2`
 - `flame_tiled` - `v2.0.3`
 - `flame_oxygen` - `v0.2.3+8`
 - `flame_isolate` - `v0.6.2+8`
 - `flame_texturepacker` - `v4.1.8`
 - `flame_sprite_fusion` - `v0.1.3+8`
 - `flame_fire_atlas` - `v1.8.3`
 - `flame_audio` - `v2.11.2`
 - `flame_bloc` - `v1.12.9`
 - `flame_kenney_xml` - `v0.1.1+8`
 - `flame_lottie` - `v0.4.2+8`
 - `flame_markdown` - `v0.2.4+1`
 - `flame_console` - `v0.1.2+4`
 - `flame_rive` - `v1.10.11`
 - `flame_noise` - `v0.3.2+8`
 - `flame_riverpod` - `v5.4.11`
 - `flame_svg` - `v1.11.8`
 - `flame_network_assets` - `v0.3.3+8`
 - `flame_3d` - `v0.1.0-dev.8`

---

#### `flame_forge2d` - `v0.18.3`

 - **FIX**: Expose event dispatcher classes ([#3532](https://github.com/flame-engine/flame/issues/3532)). ([db8e0b20](https://github.com/flame-engine/flame/commit/db8e0b20746dc96a221dc4e85b09f5a35ecc7339))

#### `flame` - `v1.26.1`

 - **FIX**: Fix priority rebalancing causing concurrent mutation of component ordered_set ([#3530](https://github.com/flame-engine/flame/issues/3530)). ([c2afe11f](https://github.com/flame-engine/flame/commit/c2afe11f2ce736791a35e77afa5e1ddef0ae7cbb))
 - **FIX**: Expose event dispatcher classes ([#3532](https://github.com/flame-engine/flame/issues/3532)). ([db8e0b20](https://github.com/flame-engine/flame/commit/db8e0b20746dc96a221dc4e85b09f5a35ecc7339))

#### `flame_spine` - `v0.2.2+8`

 - **FIX**: Bump spine version and update example files ([#3534](https://github.com/flame-engine/flame/issues/3534)). ([f346e3f6](https://github.com/flame-engine/flame/commit/f346e3f67793f2ebece3f11c1f440c5d485bf959))


## 2025-03-13

### Changes

---

Packages with breaking changes:

 - There are no breaking changes in this release.

Packages with other changes:

 - [`behavior_tree` - `v0.1.3+2`](#behavior_tree---v0132)
 - [`flame` - `v1.26.0`](#flame---v1260)
 - [`flame_3d` - `v0.1.0-dev.7`](#flame_3d---v010-dev7)
 - [`flame_audio` - `v2.11.1`](#flame_audio---v2111)
 - [`flame_behavior_tree` - `v0.1.3+7`](#flame_behavior_tree---v0137)
 - [`flame_bloc` - `v1.12.8`](#flame_bloc---v1128)
 - [`flame_fire_atlas` - `v1.8.2`](#flame_fire_atlas---v182)
 - [`flame_forge2d` - `v0.18.2+7`](#flame_forge2d---v01827)
 - [`flame_isolate` - `v0.6.2+7`](#flame_isolate---v0627)
 - [`flame_kenney_xml` - `v0.1.1+7`](#flame_kenney_xml---v0117)
 - [`flame_lint` - `v1.2.3`](#flame_lint---v123)
 - [`flame_lottie` - `v0.4.2+7`](#flame_lottie---v0427)
 - [`flame_markdown` - `v0.2.4`](#flame_markdown---v024)
 - [`flame_noise` - `v0.3.2+7`](#flame_noise---v0327)
 - [`flame_oxygen` - `v0.2.3+7`](#flame_oxygen---v0237)
 - [`flame_rive` - `v1.10.10`](#flame_rive---v11010)
 - [`flame_splash_screen` - `v0.3.1+2`](#flame_splash_screen---v0312)
 - [`flame_sprite_fusion` - `v0.1.3+7`](#flame_sprite_fusion---v0137)
 - [`flame_svg` - `v1.11.7`](#flame_svg---v1117)
 - [`flame_test` - `v1.18.1`](#flame_test---v1181)
 - [`flame_texturepacker` - `v4.1.7`](#flame_texturepacker---v417)
 - [`flame_tiled` - `v2.0.2`](#flame_tiled---v202)
 - [`flame_spine` - `v0.2.2+7`](#flame_spine---v0227)
 - [`flame_console` - `v0.1.2+3`](#flame_console---v0123)
 - [`flame_riverpod` - `v5.4.10`](#flame_riverpod---v5410)
 - [`flame_network_assets` - `v0.3.3+7`](#flame_network_assets---v0337)

Packages with dependency updates only:

> Packages listed below depend on other packages in this workspace that have had changes. Their versions have been incremented to bump the minimum dependency versions of the packages they depend upon in this project.

 - `flame_spine` - `v0.2.2+7`
 - `flame_console` - `v0.1.2+3`
 - `flame_riverpod` - `v5.4.10`
 - `flame_network_assets` - `v0.3.3+7`

---

#### `behavior_tree` - `v0.1.3+2`

 - **DOCS**: Fix workflow status badge paths ([#3517](https://github.com/flame-engine/flame/issues/3517)). ([149f16fe](https://github.com/flame-engine/flame/commit/149f16fe29f1fb14b3612964b2226c9c5c7daf95))

#### `flame` - `v1.26.0`

 - **FIX**: RouterComponent should be on top ([#3524](https://github.com/flame-engine/flame/issues/3524)). ([aa52a2a5](https://github.com/flame-engine/flame/commit/aa52a2a58de9661557113c3d6ae5cc760842b1e7))
 - **FEAT**: Support custom attributes syntax to allow for multiple styles in the text rendering pipeline ([#3519](https://github.com/flame-engine/flame/issues/3519)). ([fbc58053](https://github.com/flame-engine/flame/commit/fbc58053dd12e6dc62b09cb14e4b438ef7b7f1b2))
 - **FEAT**: Layout shrinkwrap ([#3513](https://github.com/flame-engine/flame/issues/3513)). ([b3fbdd9d](https://github.com/flame-engine/flame/commit/b3fbdd9d3fd031083ecf7c53a28e2381579e846c))
 - **FEAT**: Layout Components ([#3507](https://github.com/flame-engine/flame/issues/3507)). ([678cf057](https://github.com/flame-engine/flame/commit/678cf05780580dd2cb61dde5e40c0efb1f3bc928))
 - **FEAT**: Add `RotateAroundEffect` ([#3499](https://github.com/flame-engine/flame/issues/3499)). ([0688f410](https://github.com/flame-engine/flame/commit/0688f41093cd451269366a2c2001a0d88bc6e532))
 - **DOCS**: Fix missing reference on documentation for InlineTextNode ([#3520](https://github.com/flame-engine/flame/issues/3520)). ([e3aa78b2](https://github.com/flame-engine/flame/commit/e3aa78b28206150eb85621e2a788fc31f218ff1d))
 - **DOCS**: Make onRemove() behavior more clear in API doc ([#3502](https://github.com/flame-engine/flame/issues/3502)). ([f387ad76](https://github.com/flame-engine/flame/commit/f387ad7604fca4b652d3c7521004a5d420137634))

#### `flame_3d` - `v0.1.0-dev.7`

 - **DOCS**: Fix workflow status badge paths ([#3517](https://github.com/flame-engine/flame/issues/3517)). ([149f16fe](https://github.com/flame-engine/flame/commit/149f16fe29f1fb14b3612964b2226c9c5c7daf95))

#### `flame_audio` - `v2.11.1`

 - **REFACTOR**(flame_audio): Set AudioContext for AudioPool only ([#3511](https://github.com/flame-engine/flame/issues/3511)). ([d5ae35f2](https://github.com/flame-engine/flame/commit/d5ae35f2bbd214159fcb81e2e94e45085bdc2e66))
 - **DOCS**: Fix workflow status badge paths ([#3517](https://github.com/flame-engine/flame/issues/3517)). ([149f16fe](https://github.com/flame-engine/flame/commit/149f16fe29f1fb14b3612964b2226c9c5c7daf95))

#### `flame_behavior_tree` - `v0.1.3+7`

 - **DOCS**: Fix workflow status badge paths ([#3517](https://github.com/flame-engine/flame/issues/3517)). ([149f16fe](https://github.com/flame-engine/flame/commit/149f16fe29f1fb14b3612964b2226c9c5c7daf95))

#### `flame_bloc` - `v1.12.8`

 - **DOCS**: Fix workflow status badge paths ([#3517](https://github.com/flame-engine/flame/issues/3517)). ([149f16fe](https://github.com/flame-engine/flame/commit/149f16fe29f1fb14b3612964b2226c9c5c7daf95))

#### `flame_fire_atlas` - `v1.8.2`

 - **DOCS**: Fix workflow status badge paths ([#3517](https://github.com/flame-engine/flame/issues/3517)). ([149f16fe](https://github.com/flame-engine/flame/commit/149f16fe29f1fb14b3612964b2226c9c5c7daf95))

#### `flame_forge2d` - `v0.18.2+7`

 - **DOCS**: Fix workflow status badge paths ([#3517](https://github.com/flame-engine/flame/issues/3517)). ([149f16fe](https://github.com/flame-engine/flame/commit/149f16fe29f1fb14b3612964b2226c9c5c7daf95))

#### `flame_isolate` - `v0.6.2+7`

 - **DOCS**: Fix workflow status badge paths ([#3517](https://github.com/flame-engine/flame/issues/3517)). ([149f16fe](https://github.com/flame-engine/flame/commit/149f16fe29f1fb14b3612964b2226c9c5c7daf95))

#### `flame_kenney_xml` - `v0.1.1+7`

 - **DOCS**: Fix workflow status badge paths ([#3517](https://github.com/flame-engine/flame/issues/3517)). ([149f16fe](https://github.com/flame-engine/flame/commit/149f16fe29f1fb14b3612964b2226c9c5c7daf95))

#### `flame_lint` - `v1.2.3`

 - **DOCS**: Fix workflow status badge paths ([#3517](https://github.com/flame-engine/flame/issues/3517)). ([149f16fe](https://github.com/flame-engine/flame/commit/149f16fe29f1fb14b3612964b2226c9c5c7daf95))

#### `flame_lottie` - `v0.4.2+7`

 - **DOCS**: Fix workflow status badge paths ([#3517](https://github.com/flame-engine/flame/issues/3517)). ([149f16fe](https://github.com/flame-engine/flame/commit/149f16fe29f1fb14b3612964b2226c9c5c7daf95))

#### `flame_markdown` - `v0.2.4`

 - **FEAT**: Support custom attributes syntax to allow for multiple styles in the text rendering pipeline ([#3519](https://github.com/flame-engine/flame/issues/3519)). ([fbc58053](https://github.com/flame-engine/flame/commit/fbc58053dd12e6dc62b09cb14e4b438ef7b7f1b2))
 - **DOCS**: Fix workflow status badge paths ([#3517](https://github.com/flame-engine/flame/issues/3517)). ([149f16fe](https://github.com/flame-engine/flame/commit/149f16fe29f1fb14b3612964b2226c9c5c7daf95))

#### `flame_noise` - `v0.3.2+7`

 - **DOCS**: Fix workflow status badge paths ([#3517](https://github.com/flame-engine/flame/issues/3517)). ([149f16fe](https://github.com/flame-engine/flame/commit/149f16fe29f1fb14b3612964b2226c9c5c7daf95))

#### `flame_oxygen` - `v0.2.3+7`

 - **DOCS**: Fix workflow status badge paths ([#3517](https://github.com/flame-engine/flame/issues/3517)). ([149f16fe](https://github.com/flame-engine/flame/commit/149f16fe29f1fb14b3612964b2226c9c5c7daf95))

#### `flame_rive` - `v1.10.10`

 - **DOCS**: Fix workflow status badge paths ([#3517](https://github.com/flame-engine/flame/issues/3517)). ([149f16fe](https://github.com/flame-engine/flame/commit/149f16fe29f1fb14b3612964b2226c9c5c7daf95))

#### `flame_splash_screen` - `v0.3.1+2`

 - **DOCS**: Fix workflow status badge paths ([#3517](https://github.com/flame-engine/flame/issues/3517)). ([149f16fe](https://github.com/flame-engine/flame/commit/149f16fe29f1fb14b3612964b2226c9c5c7daf95))

#### `flame_sprite_fusion` - `v0.1.3+7`

 - **DOCS**: Fix workflow status badge paths ([#3517](https://github.com/flame-engine/flame/issues/3517)). ([149f16fe](https://github.com/flame-engine/flame/commit/149f16fe29f1fb14b3612964b2226c9c5c7daf95))

#### `flame_svg` - `v1.11.7`

 - **DOCS**: Fix workflow status badge paths ([#3517](https://github.com/flame-engine/flame/issues/3517)). ([149f16fe](https://github.com/flame-engine/flame/commit/149f16fe29f1fb14b3612964b2226c9c5c7daf95))

#### `flame_test` - `v1.18.1`

 - **DOCS**: Fix workflow status badge paths ([#3517](https://github.com/flame-engine/flame/issues/3517)). ([149f16fe](https://github.com/flame-engine/flame/commit/149f16fe29f1fb14b3612964b2226c9c5c7daf95))

#### `flame_texturepacker` - `v4.1.7`

 - **FIX**: Use game's asset cache for texture packer ([#3523](https://github.com/flame-engine/flame/issues/3523)). ([835c40fc](https://github.com/flame-engine/flame/commit/835c40fc6bbc81218fe5c7d321a4a81e1853cf85))
 - **FIX**: Unhandled Exception: Unable to load asset. Introduced on Texturepacker 4.16 ([#3506](https://github.com/flame-engine/flame/issues/3506)). ([3af91b0e](https://github.com/flame-engine/flame/commit/3af91b0e6cbb28c0862317d572dde5f659592c2b))
 - **DOCS**: Fix workflow status badge paths ([#3517](https://github.com/flame-engine/flame/issues/3517)). ([149f16fe](https://github.com/flame-engine/flame/commit/149f16fe29f1fb14b3612964b2226c9c5c7daf95))

#### `flame_tiled` - `v2.0.2`

 - **DOCS**: Fix workflow status badge paths ([#3517](https://github.com/flame-engine/flame/issues/3517)). ([149f16fe](https://github.com/flame-engine/flame/commit/149f16fe29f1fb14b3612964b2226c9c5c7daf95))


## 2025-02-13

### Changes

---

Packages with breaking changes:

 - There are no breaking changes in this release.

Packages with other changes:

 - [`behavior_tree` - `v0.1.3+1`](#behavior_tree---v0131)
 - [`flame` - `v1.25.0`](#flame---v1250)
 - [`flame_3d` - `v0.1.0-dev.6`](#flame_3d---v010-dev6)
 - [`flame_audio` - `v2.11.0`](#flame_audio---v2110)
 - [`flame_behavior_tree` - `v0.1.3+6`](#flame_behavior_tree---v0136)
 - [`flame_bloc` - `v1.12.7`](#flame_bloc---v1127)
 - [`flame_fire_atlas` - `v1.8.1`](#flame_fire_atlas---v181)
 - [`flame_forge2d` - `v0.18.2+6`](#flame_forge2d---v01826)
 - [`flame_isolate` - `v0.6.2+6`](#flame_isolate---v0626)
 - [`flame_kenney_xml` - `v0.1.1+6`](#flame_kenney_xml---v0116)
 - [`flame_lint` - `v1.2.2`](#flame_lint---v122)
 - [`flame_lottie` - `v0.4.2+6`](#flame_lottie---v0426)
 - [`flame_markdown` - `v0.2.3+2`](#flame_markdown---v0232)
 - [`flame_noise` - `v0.3.2+6`](#flame_noise---v0326)
 - [`flame_oxygen` - `v0.2.3+6`](#flame_oxygen---v0236)
 - [`flame_rive` - `v1.10.9`](#flame_rive---v1109)
 - [`flame_splash_screen` - `v0.3.1+1`](#flame_splash_screen---v0311)
 - [`flame_sprite_fusion` - `v0.1.3+6`](#flame_sprite_fusion---v0136)
 - [`flame_svg` - `v1.11.6`](#flame_svg---v1116)
 - [`flame_test` - `v1.18.0`](#flame_test---v1180)
 - [`flame_texturepacker` - `v4.1.6`](#flame_texturepacker---v416)
 - [`flame_tiled` - `v2.0.1`](#flame_tiled---v201)
 - [`flame_spine` - `v0.2.2+6`](#flame_spine---v0226)
 - [`flame_console` - `v0.1.2+2`](#flame_console---v0122)
 - [`flame_riverpod` - `v5.4.9`](#flame_riverpod---v549)
 - [`flame_network_assets` - `v0.3.3+6`](#flame_network_assets---v0336)

Packages with dependency updates only:

> Packages listed below depend on other packages in this workspace that have had changes. Their versions have been incremented to bump the minimum dependency versions of the packages they depend upon in this project.

 - `flame_spine` - `v0.2.2+6`
 - `flame_console` - `v0.1.2+2`
 - `flame_riverpod` - `v5.4.9`
 - `flame_network_assets` - `v0.3.3+6`

---

#### `behavior_tree` - `v0.1.3+1`

 - **DOCS**: Remove AI assist badges ([#3477](https://github.com/flame-engine/flame/issues/3477)). ([51d7fbc0](https://github.com/flame-engine/flame/commit/51d7fbc06d88adec2e0238c9c4738893b807ec80))

#### `flame` - `v1.25.0`

 - **FEAT**: Add a setter for TextBoxComponent.boxConfig and add a convenience method to skip per-char buildup ([#3490](https://github.com/flame-engine/flame/issues/3490)). ([d1777b7a](https://github.com/flame-engine/flame/commit/d1777b7a9efcf065c4474b7c6702c45d37bf710c))

#### `flame_3d` - `v0.1.0-dev.6`

 - **FEAT**: Add helper methods to create matrix4 with sensible defaults ([#3486](https://github.com/flame-engine/flame/issues/3486)). ([9345c870](https://github.com/flame-engine/flame/commit/9345c870d4de57d8d3a4d07a014d18cb71c01618))
 - **FEAT**: Add setFromMatrix4 to Transform3D ([#3484](https://github.com/flame-engine/flame/issues/3484)). ([1dbb4433](https://github.com/flame-engine/flame/commit/1dbb4433ca9e06b93a49b430fe9c084885551ff2))
 - **FEAT**: Add Line3D mesh component [flame_3d] ([#3412](https://github.com/flame-engine/flame/issues/3412)). ([c332c965](https://github.com/flame-engine/flame/commit/c332c9651ad8b930281c1d0bc13b89754fd0b2c1))

#### `flame_audio` - `v2.11.0`

 - **FEAT**(audio): Set audio context AudioContextConfigFocus.mixWithOthers by default ([#3483](https://github.com/flame-engine/flame/issues/3483)). ([762e0ad8](https://github.com/flame-engine/flame/commit/762e0ad8423e7bf3920139ca71a03b186d09c063))
 - **DOCS**: Remove AI assist badges ([#3477](https://github.com/flame-engine/flame/issues/3477)). ([51d7fbc0](https://github.com/flame-engine/flame/commit/51d7fbc06d88adec2e0238c9c4738893b807ec80))

#### `flame_behavior_tree` - `v0.1.3+6`

 - **DOCS**: Remove AI assist badges ([#3477](https://github.com/flame-engine/flame/issues/3477)). ([51d7fbc0](https://github.com/flame-engine/flame/commit/51d7fbc06d88adec2e0238c9c4738893b807ec80))

#### `flame_bloc` - `v1.12.7`

 - **DOCS**: Remove AI assist badges ([#3477](https://github.com/flame-engine/flame/issues/3477)). ([51d7fbc0](https://github.com/flame-engine/flame/commit/51d7fbc06d88adec2e0238c9c4738893b807ec80))

#### `flame_fire_atlas` - `v1.8.1`

 - **DOCS**: Remove AI assist badges ([#3477](https://github.com/flame-engine/flame/issues/3477)). ([51d7fbc0](https://github.com/flame-engine/flame/commit/51d7fbc06d88adec2e0238c9c4738893b807ec80))

#### `flame_forge2d` - `v0.18.2+6`

 - **FIX**: Use correct matrix indices in BodyComponent ([#3491](https://github.com/flame-engine/flame/issues/3491)). ([d6c83fab](https://github.com/flame-engine/flame/commit/d6c83fab6c5cf56b047dcd22b9f1f0a075c26201))
 - **DOCS**: Remove AI assist badges ([#3477](https://github.com/flame-engine/flame/issues/3477)). ([51d7fbc0](https://github.com/flame-engine/flame/commit/51d7fbc06d88adec2e0238c9c4738893b807ec80))

#### `flame_isolate` - `v0.6.2+6`

 - **DOCS**: Remove AI assist badges ([#3477](https://github.com/flame-engine/flame/issues/3477)). ([51d7fbc0](https://github.com/flame-engine/flame/commit/51d7fbc06d88adec2e0238c9c4738893b807ec80))

#### `flame_kenney_xml` - `v0.1.1+6`

 - **DOCS**: Remove AI assist badges ([#3477](https://github.com/flame-engine/flame/issues/3477)). ([51d7fbc0](https://github.com/flame-engine/flame/commit/51d7fbc06d88adec2e0238c9c4738893b807ec80))

#### `flame_lint` - `v1.2.2`

 - **DOCS**: Remove AI assist badges ([#3477](https://github.com/flame-engine/flame/issues/3477)). ([51d7fbc0](https://github.com/flame-engine/flame/commit/51d7fbc06d88adec2e0238c9c4738893b807ec80))

#### `flame_lottie` - `v0.4.2+6`

 - **DOCS**: Remove AI assist badges ([#3477](https://github.com/flame-engine/flame/issues/3477)). ([51d7fbc0](https://github.com/flame-engine/flame/commit/51d7fbc06d88adec2e0238c9c4738893b807ec80))

#### `flame_markdown` - `v0.2.3+2`

 - **DOCS**: Remove AI assist badges ([#3477](https://github.com/flame-engine/flame/issues/3477)). ([51d7fbc0](https://github.com/flame-engine/flame/commit/51d7fbc06d88adec2e0238c9c4738893b807ec80))

#### `flame_noise` - `v0.3.2+6`

 - **DOCS**: Remove AI assist badges ([#3477](https://github.com/flame-engine/flame/issues/3477)). ([51d7fbc0](https://github.com/flame-engine/flame/commit/51d7fbc06d88adec2e0238c9c4738893b807ec80))

#### `flame_oxygen` - `v0.2.3+6`

 - **DOCS**: Remove AI assist badges ([#3477](https://github.com/flame-engine/flame/issues/3477)). ([51d7fbc0](https://github.com/flame-engine/flame/commit/51d7fbc06d88adec2e0238c9c4738893b807ec80))

#### `flame_rive` - `v1.10.9`

 - **DOCS**: Remove AI assist badges ([#3477](https://github.com/flame-engine/flame/issues/3477)). ([51d7fbc0](https://github.com/flame-engine/flame/commit/51d7fbc06d88adec2e0238c9c4738893b807ec80))

#### `flame_splash_screen` - `v0.3.1+1`

 - **DOCS**: Remove AI assist badges ([#3477](https://github.com/flame-engine/flame/issues/3477)). ([51d7fbc0](https://github.com/flame-engine/flame/commit/51d7fbc06d88adec2e0238c9c4738893b807ec80))

#### `flame_sprite_fusion` - `v0.1.3+6`

 - **DOCS**: Remove AI assist badges ([#3477](https://github.com/flame-engine/flame/issues/3477)). ([51d7fbc0](https://github.com/flame-engine/flame/commit/51d7fbc06d88adec2e0238c9c4738893b807ec80))

#### `flame_svg` - `v1.11.6`

 - **DOCS**: Remove AI assist badges ([#3477](https://github.com/flame-engine/flame/issues/3477)). ([51d7fbc0](https://github.com/flame-engine/flame/commit/51d7fbc06d88adec2e0238c9c4738893b807ec80))

#### `flame_test` - `v1.18.0`

 - **FEAT**: Implement closeToVector4 and closeToQuaternion by extracing a generic CloseToVector base ([#3480](https://github.com/flame-engine/flame/issues/3480)). ([57e58514](https://github.com/flame-engine/flame/commit/57e58514091248884505d3936e3e0aa076efb30a))
 - **FEAT**: Add closeToMatrix4 test matcher ([#3478](https://github.com/flame-engine/flame/issues/3478)). ([8db2476e](https://github.com/flame-engine/flame/commit/8db2476e8c39723670641f1c2646ecf0d7bb09fb))
 - **DOCS**: Remove AI assist badges ([#3477](https://github.com/flame-engine/flame/issues/3477)). ([51d7fbc0](https://github.com/flame-engine/flame/commit/51d7fbc06d88adec2e0238c9c4738893b807ec80))

#### `flame_texturepacker` - `v4.1.6`

 - **FIX**: Remove forced location of the atlas file. ([#3481](https://github.com/flame-engine/flame/issues/3481)). ([bac68dcb](https://github.com/flame-engine/flame/commit/bac68dcbb95ec420c1401e32e60adf42dc338695))
 - **DOCS**: Remove AI assist badges ([#3477](https://github.com/flame-engine/flame/issues/3477)). ([51d7fbc0](https://github.com/flame-engine/flame/commit/51d7fbc06d88adec2e0238c9c4738893b807ec80))

#### `flame_tiled` - `v2.0.1`

 - **DOCS**: Remove AI assist badges ([#3477](https://github.com/flame-engine/flame/issues/3477)). ([51d7fbc0](https://github.com/flame-engine/flame/commit/51d7fbc06d88adec2e0238c9c4738893b807ec80))


## 2025-02-05

### Changes

---

Packages with breaking changes:

 - [`flame_fire_atlas` - `v1.8.0`](#flame_fire_atlas---v180)
 - [`flame_3d` - `v0.1.0-dev.5`](#flame_3d---v010-dev5)
 - [`flame_tiled` - `v2.0.0`](#flame_tiled---v200)

Packages with other changes:

 - [`flame` - `v1.24.0`](#flame---v1240)
 - [`flame_test` - `v1.17.5`](#flame_test---v1175)
 - [`flame_behavior_tree` - `v0.1.3+5`](#flame_behavior_tree---v0135)
 - [`flame_oxygen` - `v0.2.3+5`](#flame_oxygen---v0235)
 - [`flame_isolate` - `v0.6.2+5`](#flame_isolate---v0625)
 - [`flame_texturepacker` - `v4.1.5`](#flame_texturepacker---v415)
 - [`flame_sprite_fusion` - `v0.1.3+5`](#flame_sprite_fusion---v0135)
 - [`flame_audio` - `v2.10.8`](#flame_audio---v2108)
 - [`flame_spine` - `v0.2.2+5`](#flame_spine---v0225)
 - [`flame_bloc` - `v1.12.6`](#flame_bloc---v1126)
 - [`flame_kenney_xml` - `v0.1.1+5`](#flame_kenney_xml---v0115)
 - [`flame_lottie` - `v0.4.2+5`](#flame_lottie---v0425)
 - [`flame_markdown` - `v0.2.3+1`](#flame_markdown---v0231)
 - [`flame_console` - `v0.1.2+1`](#flame_console---v0121)
 - [`flame_rive` - `v1.10.8`](#flame_rive---v1108)
 - [`flame_forge2d` - `v0.18.2+5`](#flame_forge2d---v01825)
 - [`flame_noise` - `v0.3.2+5`](#flame_noise---v0325)
 - [`flame_riverpod` - `v5.4.8`](#flame_riverpod---v548)
 - [`flame_svg` - `v1.11.5`](#flame_svg---v1115)
 - [`flame_network_assets` - `v0.3.3+5`](#flame_network_assets---v0335)

Packages with dependency updates only:

> Packages listed below depend on other packages in this workspace that have had changes. Their versions have been incremented to bump the minimum dependency versions of the packages they depend upon in this project.

 - `flame_behavior_tree` - `v0.1.3+5`
 - `flame_oxygen` - `v0.2.3+5`
 - `flame_isolate` - `v0.6.2+5`
 - `flame_texturepacker` - `v4.1.5`
 - `flame_sprite_fusion` - `v0.1.3+5`
 - `flame_audio` - `v2.10.8`
 - `flame_spine` - `v0.2.2+5`
 - `flame_bloc` - `v1.12.6`
 - `flame_kenney_xml` - `v0.1.1+5`
 - `flame_lottie` - `v0.4.2+5`
 - `flame_markdown` - `v0.2.3+1`
 - `flame_console` - `v0.1.2+1`
 - `flame_rive` - `v1.10.8`
 - `flame_forge2d` - `v0.18.2+5`
 - `flame_noise` - `v0.3.2+5`
 - `flame_riverpod` - `v5.4.8`
 - `flame_svg` - `v1.11.5`
 - `flame_network_assets` - `v0.3.3+5`

---

#### `flame_fire_atlas` - `v1.8.0`

 - **BREAKING** **FIX**: Bump tiled to 0.11.0 and add ColorData extension (#3473).

#### `flame_3d` - `v0.1.0-dev.5`

 - **BREAKING** **FEAT**: Make resource creation be on demand to enable testing (#3411).

#### `flame_tiled` - `v2.0.0`

 - **BREAKING** **FIX**: Bump tiled to 0.11.0 and add ColorData extension (#3473).

#### `flame` - `v1.24.0`

 - **PERF**: Switch from forEach to regular for-loops for about 30% improvement in raw update performance (#3472).
 - **FIX**: SpawnComponent.periodRange should change range each iteration (#3464).
 - **FIX**: Don't use a future when assets for SpriteButton is already loaded (#3456).
 - **FIX**: Darkness increases with higher values (#3448).
 - **FEAT**: NineTileBoxComponent with HasPaint to enable effects (#3459).
 - **FEAT**: Devtools overlay navigation (#3449).
 - **FEAT**: Add direction and length getters and constructor to LineSegment (#3446).
 - **FEAT**: Add multiFactory to SpawnComponent (#3440).

#### `flame_test` - `v1.17.5`

 - **FIX**: Don't use a future when assets for SpriteButton is already loaded (#3456).


## 2025-01-02

### Changes

---

Packages with breaking changes:

 - [`flame_3d` - `v0.1.0-dev.4`](#flame_3d---v010-dev4)

Packages with other changes:

 - [`flame` - `v1.23.0`](#flame---v1230)
 - [`flame_console` - `v0.1.2`](#flame_console---v012)
 - [`flame_forge2d` - `v0.18.2+4`](#flame_forge2d---v01824)
 - [`flame_isolate` - `v0.6.2+4`](#flame_isolate---v0624)
 - [`flame_markdown` - `v0.2.3`](#flame_markdown---v023)
 - [`flame_oxygen` - `v0.2.3+4`](#flame_oxygen---v0234)
 - [`flame_sprite_fusion` - `v0.1.3+4`](#flame_sprite_fusion---v0134)
 - [`flame_svg` - `v1.11.4`](#flame_svg---v1114)
 - [`flame_test` - `v1.17.4`](#flame_test---v1174)
 - [`flame_tiled` - `v1.21.2`](#flame_tiled---v1212)
 - [`flame_behavior_tree` - `v0.1.3+4`](#flame_behavior_tree---v0134)
 - [`flame_texturepacker` - `v4.1.4`](#flame_texturepacker---v414)
 - [`flame_fire_atlas` - `v1.7.1`](#flame_fire_atlas---v171)
 - [`flame_audio` - `v2.10.7`](#flame_audio---v2107)
 - [`flame_spine` - `v0.2.2+4`](#flame_spine---v0224)
 - [`flame_bloc` - `v1.12.5`](#flame_bloc---v1125)
 - [`flame_kenney_xml` - `v0.1.1+4`](#flame_kenney_xml---v0114)
 - [`flame_lottie` - `v0.4.2+4`](#flame_lottie---v0424)
 - [`flame_rive` - `v1.10.7`](#flame_rive---v1107)
 - [`flame_noise` - `v0.3.2+4`](#flame_noise---v0324)
 - [`flame_riverpod` - `v5.4.7`](#flame_riverpod---v547)
 - [`flame_network_assets` - `v0.3.3+4`](#flame_network_assets---v0334)

Packages with dependency updates only:

> Packages listed below depend on other packages in this workspace that have had changes. Their versions have been incremented to bump the minimum dependency versions of the packages they depend upon in this project.

 - `flame_behavior_tree` - `v0.1.3+4`
 - `flame_texturepacker` - `v4.1.4`
 - `flame_fire_atlas` - `v1.7.1`
 - `flame_audio` - `v2.10.7`
 - `flame_spine` - `v0.2.2+4`
 - `flame_bloc` - `v1.12.5`
 - `flame_kenney_xml` - `v0.1.1+4`
 - `flame_lottie` - `v0.4.2+4`
 - `flame_rive` - `v1.10.7`
 - `flame_noise` - `v0.3.2+4`
 - `flame_riverpod` - `v5.4.7`
 - `flame_network_assets` - `v0.3.3+4`

---

#### `flame_3d` - `v0.1.0-dev.4`

 - **REFACTOR**: Fix lint issues from latest flutter release ([#3390](https://github.com/flame-engine/flame/issues/3390)). ([978ad31b](https://github.com/flame-engine/flame/commit/978ad31b429d1801097b0db385a600c85a157867))
 - **FIX**: Use saner default value for camera's target ([#3238](https://github.com/flame-engine/flame/issues/3238)). ([78522c62](https://github.com/flame-engine/flame/commit/78522c624d846c827a1c0d7377837e04a30ba4e7))
 - **FIX**: Use saner default value for camera's target ([#3238](https://github.com/flame-engine/flame/issues/3238)). ([99ca355b](https://github.com/flame-engine/flame/commit/99ca355b3d4a3e9c7677454dc9bc2c874ee2e4a9))
 - **FIX**: Fix albedo texture binding on shader ([#3400](https://github.com/flame-engine/flame/issues/3400)). ([c380c91f](https://github.com/flame-engine/flame/commit/c380c91f7a7e22ab71c3617c0386159861a64abc))
 - **FIX**: Make build_shaders script compatible with other platforms [flame_3d] ([#3395](https://github.com/flame-engine/flame/issues/3395)). ([38331309](https://github.com/flame-engine/flame/commit/38331309ca5ee609e85422ee9d740569a35e5e9e))
 - **FIX**: Make `flame_3d` work with latest stable ([#3387](https://github.com/flame-engine/flame/issues/3387)). ([f940d3f9](https://github.com/flame-engine/flame/commit/f940d3f9420d3ce001f47a9155c582b8b4cd1dcb))
 - **FIX**: MeshComponent.bind should bind to the provided device ([#3278](https://github.com/flame-engine/flame/issues/3278)). ([d06b4ce6](https://github.com/flame-engine/flame/commit/d06b4ce6935987705447772f912719c405d39c9e))
 - **FIX**: Improve behavior of Quaternion.slerp function [flame_3d] ([#3306](https://github.com/flame-engine/flame/issues/3306)). ([8872a45a](https://github.com/flame-engine/flame/commit/8872a45a1b49d7ba7688d62ca25b2a8d31c495cb))
 - **FIX**: Improve quaternion slerp logic to avoid NaN edge cases ([#3303](https://github.com/flame-engine/flame/issues/3303)). ([712b03fb](https://github.com/flame-engine/flame/commit/712b03fbe176cf238a3780aee641254436520366))
 - **FIX**: Make the `build_shader` script work for windows ([#3402](https://github.com/flame-engine/flame/issues/3402)). ([ce7822a0](https://github.com/flame-engine/flame/commit/ce7822a0d0c5ac1c766635a5cf2c242d5e5f98ec))
 - **FIX**: MeshComponent.bind should bind to the provided device ([#3278](https://github.com/flame-engine/flame/issues/3278)). ([3ae3ef54](https://github.com/flame-engine/flame/commit/3ae3ef5476fa5f9ead7069efeee35cc31c0e9dd2))
 - **FIX**: Fix typo on loadTexture ([#3253](https://github.com/flame-engine/flame/issues/3253)). ([3a20a8cd](https://github.com/flame-engine/flame/commit/3a20a8cd61543aad21c1015de5c31ec1cbe71aed))
 - **FIX**: Improve behavior of Quaternion.slerp function [flame_3d] ([#3306](https://github.com/flame-engine/flame/issues/3306)). ([b9d6a0f1](https://github.com/flame-engine/flame/commit/b9d6a0f1d34e009cd91ae9d2ab0eed09b546d110))
 - **FIX**: Improve quaternion slerp logic to avoid NaN edge cases ([#3303](https://github.com/flame-engine/flame/issues/3303)). ([565b68b9](https://github.com/flame-engine/flame/commit/565b68b9da52d44281e93f9ae8617f9dbe9551f3))
 - **FIX**: Fix typo on loadTexture ([#3253](https://github.com/flame-engine/flame/issues/3253)). ([3d1f1437](https://github.com/flame-engine/flame/commit/3d1f143700506467798e030450227d8029b74ef2))
 - **FIX**: Add missing export for CylinderMesh [flame_3d] ([#3256](https://github.com/flame-engine/flame/issues/3256)). ([d8fb65c1](https://github.com/flame-engine/flame/commit/d8fb65c158a3cce442972fb24f55fb522729085f))
 - **FIX**: Add missing export for CylinderMesh [flame_3d] ([#3256](https://github.com/flame-engine/flame/issues/3256)). ([d517c169](https://github.com/flame-engine/flame/commit/d517c169ed9b4d4457df6ac1ae363277577597fa))
 - **FEAT**: More Lights! [flame_3d] ([#3250](https://github.com/flame-engine/flame/issues/3250)). ([5c508e81](https://github.com/flame-engine/flame/commit/5c508e81bddfb17857355da80e57f1ac77ab368d))
 - **FEAT**(flame_3d): Add helpful extension functions to Vector ([#3141](https://github.com/flame-engine/flame/issues/3141)). ([92195989](https://github.com/flame-engine/flame/commit/9219598904131d8fceba8d1ad980bea2805e3515))
 - **FEAT**: Add CylinderMesh [flame_3d] ([#3239](https://github.com/flame-engine/flame/issues/3239)). ([d5de1733](https://github.com/flame-engine/flame/commit/d5de1733c64c4fbaeee83089a3b0f9a3fbb3355d))
 - **FEAT**: Refactor shader uniform binding to support shader arrays [flame_3d] ([#3282](https://github.com/flame-engine/flame/issues/3282)). ([edae1662](https://github.com/flame-engine/flame/commit/edae166252a519d38496bb6bf7c84fe9f401b8d4))
 - **FEAT**(flame_3d): Make shader api more useful ([#3085](https://github.com/flame-engine/flame/issues/3085)). ([fe2e4f20](https://github.com/flame-engine/flame/commit/fe2e4f20195b453268b34e589616343fdce6201a))
 - **FEAT**(flame_3d): Make shader api more useful ([#3085](https://github.com/flame-engine/flame/issues/3085)). ([4042d300](https://github.com/flame-engine/flame/commit/4042d3002ce619bf6b8597aa7dc17a803bc57c69))
 - **FEAT**: Add more useful extensions to VectorN and Quaternion [flame_3d] ([#3296](https://github.com/flame-engine/flame/issues/3296)). ([f5f03e5e](https://github.com/flame-engine/flame/commit/f5f03e5ed7095ede713727d6bbab39db0505e7bf))
 - **FEAT**: Expose vector classes on core file [flame_3d] ([#3211](https://github.com/flame-engine/flame/issues/3211)). ([8f403ac2](https://github.com/flame-engine/flame/commit/8f403ac23ae7cdf5343652c30f9c0ee71d627b0a))
 - **FEAT**(flame_3d): Add helpful extension functions to Vector ([#3141](https://github.com/flame-engine/flame/issues/3141)). ([39e15fb3](https://github.com/flame-engine/flame/commit/39e15fb30256cbfaa86f4d7b8e3453c52942d1a5))
 - **FEAT**: Add CylinderMesh [flame_3d] ([#3239](https://github.com/flame-engine/flame/issues/3239)). ([01872fb6](https://github.com/flame-engine/flame/commit/01872fb6e45e10dc380fee7a176a8b37eeaef880))
 - **FEAT**(flame_3d): initial implementation of 3D support ([#3012](https://github.com/flame-engine/flame/issues/3012)). ([acb8e6fc](https://github.com/flame-engine/flame/commit/acb8e6fc07592a7df041512ed9e033b33eda8799))
 - **FEAT**: Support skeletal animation basics [flame_3d]  ([#3291](https://github.com/flame-engine/flame/issues/3291)). ([9c0d1500](https://github.com/flame-engine/flame/commit/9c0d15006047597097dc0e054c1e03a04491cff9))
 - **FEAT**: Add normals to surfaces when not specified ([#3257](https://github.com/flame-engine/flame/issues/3257)). ([1dd21d7d](https://github.com/flame-engine/flame/commit/1dd21d7d6d4f58c9ac54a38363ee2fd0978a9d0c))
 - **FEAT**(flame_3d): initial implementation of 3D support ([#3012](https://github.com/flame-engine/flame/issues/3012)). ([0242e1dd](https://github.com/flame-engine/flame/commit/0242e1dd12a9b50a411d895b662f9df33536f6d9))
 - **FEAT**: Support skeletal animation basics [flame_3d]  ([#3291](https://github.com/flame-engine/flame/issues/3291)). ([12927e41](https://github.com/flame-engine/flame/commit/12927e4100a7b4b46e4218db6792d25be1623f88))
 - **FEAT**: Add more useful extensions to VectorN and Quaternion [flame_3d] ([#3296](https://github.com/flame-engine/flame/issues/3296)). ([9cb95279](https://github.com/flame-engine/flame/commit/9cb9527909a4faa38609d25ebd7463f1e2e1a1ab))
 - **FEAT**: Make it easier work with the Mesh class [flame_3d] ([#3212](https://github.com/flame-engine/flame/issues/3212)). ([ebf2ee62](https://github.com/flame-engine/flame/commit/ebf2ee62e535fd1d0f499112b314e1d88e59bbc1))
 - **FEAT**: More Lights! [flame_3d] ([#3250](https://github.com/flame-engine/flame/issues/3250)). ([1780630e](https://github.com/flame-engine/flame/commit/1780630e7fcb386a331ba1219c15cb1ae8b139e6))
 - **FEAT**: Add normals to surfaces when not specified ([#3257](https://github.com/flame-engine/flame/issues/3257)). ([844c1d72](https://github.com/flame-engine/flame/commit/844c1d726e04e9c3c5739214720cf26fc62d3f9f))
 - **FEAT**(flame_3d): Fix minor nits on flame_3d ([#3140](https://github.com/flame-engine/flame/issues/3140)). ([11cdfb5e](https://github.com/flame-engine/flame/commit/11cdfb5ebeb62dd1aec2d51fd7fadfbfb17c6da5))
 - **FEAT**: Expose vector classes on core file [flame_3d] ([#3211](https://github.com/flame-engine/flame/issues/3211)). ([c3e68dff](https://github.com/flame-engine/flame/commit/c3e68dffd2e53a8dc8d4d3804c47e956dfc0ebb4))
 - **FEAT**(flame_3d): Fix minor nits on flame_3d ([#3140](https://github.com/flame-engine/flame/issues/3140)). ([b537d20a](https://github.com/flame-engine/flame/commit/b537d20ab65ce0312e9c05ba9156d794234d93e0))
 - **FEAT**: Make it easier work with the Mesh class [flame_3d] ([#3212](https://github.com/flame-engine/flame/issues/3212)). ([7f80b530](https://github.com/flame-engine/flame/commit/7f80b53078c037f81d386a44fa9b749cf7835ffa))
 - **DOCS**: Update docs and comments (flame_3d) ([#3057](https://github.com/flame-engine/flame/issues/3057)). ([14047879](https://github.com/flame-engine/flame/commit/14047879a13e1f13e51ce3411feb7c7962d6d7ee))
 - **DOCS**: Update docs and comments (flame_3d) ([#3057](https://github.com/flame-engine/flame/issues/3057)). ([b5fd457a](https://github.com/flame-engine/flame/commit/b5fd457a6b6bcad73006fc77a538c7e8521178a5))
 - **DOCS**: Update README.md docs to reflect current state of affairs ([#3305](https://github.com/flame-engine/flame/issues/3305)). ([ac3f48ff](https://github.com/flame-engine/flame/commit/ac3f48ffa6527c595035e8a9cc24307343dacb31))
 - **DOCS**: Update wording on README to match newer instructions [flame_3d] ([#3399](https://github.com/flame-engine/flame/issues/3399)). ([9c416cbf](https://github.com/flame-engine/flame/commit/9c416cbfcb4106ab7b1ad14324ca9cb89593b80d))
 - **DOCS**: Update README.md docs to reflect current state of affairs ([#3305](https://github.com/flame-engine/flame/issues/3305)). ([be72daee](https://github.com/flame-engine/flame/commit/be72daee6b92bcef2af3af78c1f64abe94c49d18))
 - **BREAKING** **FEAT**: Allow for custom shaders and materials ([#3384](https://github.com/flame-engine/flame/issues/3384)). ([ae731814](https://github.com/flame-engine/flame/commit/ae73181466c7e32b0e5e9e814f5170310c20f263))
 - **BREAKING** **FEAT**: Refactor the `CameraComponent3D` ([#3394](https://github.com/flame-engine/flame/issues/3394)). ([4a61718d](https://github.com/flame-engine/flame/commit/4a61718d3b8d45d18a74f662f1bf1eb8e6069983))

#### `flame` - `v1.23.0`

 - **REFACTOR**: Fix lint issues from latest flutter release ([#3390](https://github.com/flame-engine/flame/issues/3390)). ([978ad31b](https://github.com/flame-engine/flame/commit/978ad31b429d1801097b0db385a600c85a157867))
 - **FIX**: Take into consideration when child is added to parent that is removed in the same tick ([#3428](https://github.com/flame-engine/flame/issues/3428)). ([9a5c54be](https://github.com/flame-engine/flame/commit/9a5c54bea858fc8e9e84878f3ac0a0f7bc190b46))
 - **FIX**: Add missing export of GroupTextElement to text.dart ([#3424](https://github.com/flame-engine/flame/issues/3424)). ([c9c0f691](https://github.com/flame-engine/flame/commit/c9c0f691412bb026c1d766ec7b424a468f8929f7))
 - **FIX**: Add missing export of GroupElement to text.dart ([#3423](https://github.com/flame-engine/flame/issues/3423)). ([c0c4bb02](https://github.com/flame-engine/flame/commit/c0c4bb02a32306120a8770122116631f55c1c700))
 - **FIX**: Fix brighten and darken alpha issue ([#3414](https://github.com/flame-engine/flame/issues/3414)). ([de8e3bce](https://github.com/flame-engine/flame/commit/de8e3bcea2c2c2fa5e01dd288176c8f5623d21fb))
 - **FIX**: Set button size in onMount if not set ([#3413](https://github.com/flame-engine/flame/issues/3413)). ([916aa5ce](https://github.com/flame-engine/flame/commit/916aa5ce2ad3851b3044e043d2be7cbe923f2c40))
 - **FIX**: Fix bug preventing removeAll(children) from be called before mount ([#3408](https://github.com/flame-engine/flame/issues/3408)). ([726cb8b6](https://github.com/flame-engine/flame/commit/726cb8b6390c839f9cbab959b2268a7b45fa691c))
 - **FEAT**: Add support for strike-through text for flame_markdown ([#3426](https://github.com/flame-engine/flame/issues/3426)). ([1f9b0ea9](https://github.com/flame-engine/flame/commit/1f9b0ea9f35a7180725ec7f8f79a561c5f544bb7))
 - **FEAT**: Warning and docs about fullscreen methods outside the mobile platforms ([#3419](https://github.com/flame-engine/flame/issues/3419)). ([994e098b](https://github.com/flame-engine/flame/commit/994e098bd699a30aa13aed65f2bd0ab7254ad779))
 - **FEAT**: Add baseColor to Shadow3DDecorator ([#3375](https://github.com/flame-engine/flame/issues/3375)). ([b5d7ee07](https://github.com/flame-engine/flame/commit/b5d7ee0752ee1f2dddf1da4ac817f138296e1c96))

#### `flame_console` - `v0.1.2`

 - **REFACTOR**: Fix lint issues from latest flutter release ([#3390](https://github.com/flame-engine/flame/issues/3390)). ([978ad31b](https://github.com/flame-engine/flame/commit/978ad31b429d1801097b0db385a600c85a157867))
 - **FEAT**: Refactoring flame_console to use terminui ([#3388](https://github.com/flame-engine/flame/issues/3388)). ([de74a93b](https://github.com/flame-engine/flame/commit/de74a93b44f442341f816a2988c854f40902ff7e))

#### `flame_forge2d` - `v0.18.2+4`

 - **REFACTOR**: Fix lint issues from latest flutter release ([#3390](https://github.com/flame-engine/flame/issues/3390)). ([978ad31b](https://github.com/flame-engine/flame/commit/978ad31b429d1801097b0db385a600c85a157867))

#### `flame_isolate` - `v0.6.2+4`

 - **REFACTOR**: Fix lint issues from latest flutter release ([#3390](https://github.com/flame-engine/flame/issues/3390)). ([978ad31b](https://github.com/flame-engine/flame/commit/978ad31b429d1801097b0db385a600c85a157867))

#### `flame_markdown` - `v0.2.3`

 - **FIX**: Do not encode HTML by default when parsing markdown [flame_markdown] ([#3425](https://github.com/flame-engine/flame/issues/3425)). ([3067da94](https://github.com/flame-engine/flame/commit/3067da94fbc6df2da5197771cb9617588006a9b9))
 - **FEAT**: Add support for strike-through text for flame_markdown ([#3426](https://github.com/flame-engine/flame/issues/3426)). ([1f9b0ea9](https://github.com/flame-engine/flame/commit/1f9b0ea9f35a7180725ec7f8f79a561c5f544bb7))

#### `flame_oxygen` - `v0.2.3+4`

 - **REFACTOR**: Fix lint issues from latest flutter release ([#3390](https://github.com/flame-engine/flame/issues/3390)). ([978ad31b](https://github.com/flame-engine/flame/commit/978ad31b429d1801097b0db385a600c85a157867))

#### `flame_sprite_fusion` - `v0.1.3+4`

 - **REFACTOR**: Fix lint issues from latest flutter release ([#3390](https://github.com/flame-engine/flame/issues/3390)). ([978ad31b](https://github.com/flame-engine/flame/commit/978ad31b429d1801097b0db385a600c85a157867))

#### `flame_svg` - `v1.11.4`

 - **REFACTOR**: Fix lint issues from latest flutter release ([#3390](https://github.com/flame-engine/flame/issues/3390)). ([978ad31b](https://github.com/flame-engine/flame/commit/978ad31b429d1801097b0db385a600c85a157867))

#### `flame_test` - `v1.17.4`

 - **REFACTOR**: Fix lint issues from latest flutter release ([#3390](https://github.com/flame-engine/flame/issues/3390)). ([978ad31b](https://github.com/flame-engine/flame/commit/978ad31b429d1801097b0db385a600c85a157867))

#### `flame_tiled` - `v1.21.2`

 - **REFACTOR**: Fix lint issues from latest flutter release ([#3390](https://github.com/flame-engine/flame/issues/3390)). ([978ad31b](https://github.com/flame-engine/flame/commit/978ad31b429d1801097b0db385a600c85a157867))


## 2024-12-10

### Changes

---

Packages with breaking changes:

 - There are no breaking changes in this release.

Packages with other changes:

 - [`flame_3d` - `v0.1.0-dev.3`](#flame_3d---v010-dev3)

---

#### `flame_3d` - `v0.1.0-dev.3`

 - **FIX**: Improve behavior of Quaternion.slerp function [flame_3d] ([#3306](https://github.com/flame-engine/flame/issues/3306)). ([b9d6a0f1](https://github.com/flame-engine/flame/commit/b9d6a0f1d34e009cd91ae9d2ab0eed09b546d110))
 - **DOCS**: Update README.md docs to reflect current state of affairs ([#3305](https://github.com/flame-engine/flame/issues/3305)). ([be72daee](https://github.com/flame-engine/flame/commit/be72daee6b92bcef2af3af78c1f64abe94c49d18))


## 2024-12-10

### Changes

---

Packages with breaking changes:

 - There are no breaking changes in this release.

Packages with other changes:

 - [`flame_3d` - `v0.1.0-dev.2`](#flame_3d---v010-dev2)

---

#### `flame_3d` - `v0.1.0-dev.2`

 - **FIX**: Improve quaternion slerp logic to avoid NaN edge cases ([#3303](https://github.com/flame-engine/flame/issues/3303)). ([565b68b9](https://github.com/flame-engine/flame/commit/565b68b9da52d44281e93f9ae8617f9dbe9551f3))
 - **FIX**: MeshComponent.bind should bind to the provided device ([#3278](https://github.com/flame-engine/flame/issues/3278)). ([3ae3ef54](https://github.com/flame-engine/flame/commit/3ae3ef5476fa5f9ead7069efeee35cc31c0e9dd2))
 - **FIX**: Add missing export for CylinderMesh [flame_3d] ([#3256](https://github.com/flame-engine/flame/issues/3256)). ([d517c169](https://github.com/flame-engine/flame/commit/d517c169ed9b4d4457df6ac1ae363277577597fa))
 - **FIX**: Fix typo on loadTexture ([#3253](https://github.com/flame-engine/flame/issues/3253)). ([3a20a8cd](https://github.com/flame-engine/flame/commit/3a20a8cd61543aad21c1015de5c31ec1cbe71aed))
 - **FIX**: Use saner default value for camera's target ([#3238](https://github.com/flame-engine/flame/issues/3238)). ([78522c62](https://github.com/flame-engine/flame/commit/78522c624d846c827a1c0d7377837e04a30ba4e7))
 - **FIX**: Revert "feat(flame_3d): initial implementation of 3D support" ([#3060](https://github.com/flame-engine/flame/issues/3060)). ([741d9384](https://github.com/flame-engine/flame/commit/741d9384dbfea7bb692f181a7689a7b10a947ef0))
 - **FEAT**: Support skeletal animation basics [flame_3d]  ([#3291](https://github.com/flame-engine/flame/issues/3291)). ([12927e41](https://github.com/flame-engine/flame/commit/12927e4100a7b4b46e4218db6792d25be1623f88))
 - **FEAT**: Add more useful extensions to VectorN and Quaternion [flame_3d] ([#3296](https://github.com/flame-engine/flame/issues/3296)). ([9cb95279](https://github.com/flame-engine/flame/commit/9cb9527909a4faa38609d25ebd7463f1e2e1a1ab))
 - **FEAT**: More Lights! [flame_3d] ([#3250](https://github.com/flame-engine/flame/issues/3250)). ([1780630e](https://github.com/flame-engine/flame/commit/1780630e7fcb386a331ba1219c15cb1ae8b139e6))
 - **FEAT**: Add normals to surfaces when not specified ([#3257](https://github.com/flame-engine/flame/issues/3257)). ([844c1d72](https://github.com/flame-engine/flame/commit/844c1d726e04e9c3c5739214720cf26fc62d3f9f))
 - **FEAT**: Add CylinderMesh [flame_3d] ([#3239](https://github.com/flame-engine/flame/issues/3239)). ([01872fb6](https://github.com/flame-engine/flame/commit/01872fb6e45e10dc380fee7a176a8b37eeaef880))
 - **FEAT**(flame_3d): Make shader api more useful ([#3085](https://github.com/flame-engine/flame/issues/3085)). ([fe2e4f20](https://github.com/flame-engine/flame/commit/fe2e4f20195b453268b34e589616343fdce6201a))
 - **FEAT**: Make it easier work with the Mesh class [flame_3d] ([#3212](https://github.com/flame-engine/flame/issues/3212)). ([ebf2ee62](https://github.com/flame-engine/flame/commit/ebf2ee62e535fd1d0f499112b314e1d88e59bbc1))
 - **FEAT**: Expose vector classes on core file [flame_3d] ([#3211](https://github.com/flame-engine/flame/issues/3211)). ([c3e68dff](https://github.com/flame-engine/flame/commit/c3e68dffd2e53a8dc8d4d3804c47e956dfc0ebb4))
 - **FEAT**(flame_3d): Add helpful extension functions to Vector ([#3141](https://github.com/flame-engine/flame/issues/3141)). ([92195989](https://github.com/flame-engine/flame/commit/9219598904131d8fceba8d1ad980bea2805e3515))
 - **FEAT**(flame_3d): Fix minor nits on flame_3d ([#3140](https://github.com/flame-engine/flame/issues/3140)). ([11cdfb5e](https://github.com/flame-engine/flame/commit/11cdfb5ebeb62dd1aec2d51fd7fadfbfb17c6da5))
 - **FEAT**(flame_3d): initial implementation of 3D support ([#3012](https://github.com/flame-engine/flame/issues/3012)). ([0242e1dd](https://github.com/flame-engine/flame/commit/0242e1dd12a9b50a411d895b662f9df33536f6d9))
 - **FEAT**(flame_3d): initial implementation of 3D support ([#3012](https://github.com/flame-engine/flame/issues/3012)). ([e434bafb](https://github.com/flame-engine/flame/commit/e434bafb15fc486c51b43aaa9d9190b8b7e783cb))
 - **DOCS**: Update docs and comments (flame_3d) ([#3057](https://github.com/flame-engine/flame/issues/3057)). ([14047879](https://github.com/flame-engine/flame/commit/14047879a13e1f13e51ce3411feb7c7962d6d7ee))

## 2024-11-24

### Changes

---

Packages with breaking changes:

 - There are no breaking changes in this release.

Packages with other changes:

 - [`flame` - `v1.22.0`](#flame---v1220)
 - [`flame_console` - `v0.1.1`](#flame_console---v011)
 - [`flame_fire_atlas` - `v1.7.0`](#flame_fire_atlas---v170)
 - [`flame_behavior_tree` - `v0.1.3+3`](#flame_behavior_tree---v0133)
 - [`flame_test` - `v1.17.3`](#flame_test---v1173)
 - [`flame_tiled` - `v1.21.1`](#flame_tiled---v1211)
 - [`flame_oxygen` - `v0.2.3+3`](#flame_oxygen---v0233)
 - [`flame_isolate` - `v0.6.2+3`](#flame_isolate---v0623)
 - [`flame_texturepacker` - `v4.1.3`](#flame_texturepacker---v413)
 - [`flame_sprite_fusion` - `v0.1.3+3`](#flame_sprite_fusion---v0133)
 - [`flame_audio` - `v2.10.6`](#flame_audio---v2106)
 - [`flame_spine` - `v0.2.2+3`](#flame_spine---v0223)
 - [`flame_bloc` - `v1.12.4`](#flame_bloc---v1124)
 - [`flame_kenney_xml` - `v0.1.1+3`](#flame_kenney_xml---v0113)
 - [`flame_lottie` - `v0.4.2+3`](#flame_lottie---v0423)
 - [`flame_rive` - `v1.10.6`](#flame_rive---v1106)
 - [`flame_markdown` - `v0.2.2+3`](#flame_markdown---v0223)
 - [`flame_svg` - `v1.11.3`](#flame_svg---v1113)
 - [`flame_forge2d` - `v0.18.2+3`](#flame_forge2d---v01823)
 - [`flame_noise` - `v0.3.2+3`](#flame_noise---v0323)
 - [`flame_riverpod` - `v5.4.6`](#flame_riverpod---v546)
 - [`flame_network_assets` - `v0.3.3+3`](#flame_network_assets---v0333)

Packages with dependency updates only:

> Packages listed below depend on other packages in this workspace that have had changes. Their versions have been incremented to bump the minimum dependency versions of the packages they depend upon in this project.

 - `flame_behavior_tree` - `v0.1.3+3`
 - `flame_test` - `v1.17.3`
 - `flame_tiled` - `v1.21.1`
 - `flame_oxygen` - `v0.2.3+3`
 - `flame_isolate` - `v0.6.2+3`
 - `flame_texturepacker` - `v4.1.3`
 - `flame_sprite_fusion` - `v0.1.3+3`
 - `flame_audio` - `v2.10.6`
 - `flame_spine` - `v0.2.2+3`
 - `flame_bloc` - `v1.12.4`
 - `flame_kenney_xml` - `v0.1.1+3`
 - `flame_lottie` - `v0.4.2+3`
 - `flame_rive` - `v1.10.6`
 - `flame_markdown` - `v0.2.2+3`
 - `flame_svg` - `v1.11.3`
 - `flame_forge2d` - `v0.18.2+3`
 - `flame_noise` - `v0.3.2+3`
 - `flame_riverpod` - `v5.4.6`
 - `flame_network_assets` - `v0.3.3+3`

---

#### `flame` - `v1.22.0`

 - **FIX**: Remove extra `implements SizeProvider`s ([#3358](https://github.com/flame-engine/flame/issues/3358)). ([47ba0d87](https://github.com/flame-engine/flame/commit/47ba0d8738b101ed59781f8ba384cf05a16d65f1))
 - **FEAT**: Add WorldRoute to enable swapping worlds from the RouterComponent ([#3372](https://github.com/flame-engine/flame/issues/3372)). ([497f128f](https://github.com/flame-engine/flame/commit/497f128f8c32758f94d8d4752e9166fd3b625608))
 - **FEAT**(overlays): Added the 'priority' parameter for overlays ([#3349](https://github.com/flame-engine/flame/issues/3349)). ([e591ebf8](https://github.com/flame-engine/flame/commit/e591ebf8a320ff3d55b9ae9e50390bf2ab5a8919))

#### `flame_console` - `v0.1.1`

 - **FIX**(flame_console): MemoryRepository can't be const ([#3362](https://github.com/flame-engine/flame/issues/3362)). ([e977bd49](https://github.com/flame-engine/flame/commit/e977bd495b196368582eda4e7d8019adc6c268f4))
 - **FEAT**: Adding FlameConsole ([#3329](https://github.com/flame-engine/flame/issues/3329)). ([cf5358cd](https://github.com/flame-engine/flame/commit/cf5358cd9069dab9e327e766553bd65e151f1540))

#### `flame_fire_atlas` - `v1.7.0`

 - **FEAT**: Adding getters and methods for easier manipulation of selections ([#3350](https://github.com/flame-engine/flame/issues/3350)). ([291af57d](https://github.com/flame-engine/flame/commit/291af57deb7d742a73438b026ca2f4fd1c6a3454))


## 2024-10-16

### Changes

---

Packages with breaking changes:

 - There are no breaking changes in this release.

Packages with other changes:

 - [`flame` - `v1.21.0`](#flame---v1210)
 - [`flame_fire_atlas` - `v1.6.0`](#flame_fire_atlas---v160)
 - [`flame_test` - `v1.17.2`](#flame_test---v1172)
 - [`flame_tiled` - `v1.21.0`](#flame_tiled---v1210)
 - [`flame_audio` - `v2.10.5`](#flame_audio---v2105)
 - [`flame_forge2d` - `v0.18.2+2`](#flame_forge2d---v01822)
 - [`flame_oxygen` - `v0.2.3+2`](#flame_oxygen---v0232)
 - [`flame_rive` - `v1.10.5`](#flame_rive---v1105)
 - [`flame_texturepacker` - `v4.1.2`](#flame_texturepacker---v412)
 - [`flame_behavior_tree` - `v0.1.3+2`](#flame_behavior_tree---v0132)
 - [`flame_spine` - `v0.2.2+2`](#flame_spine---v0222)
 - [`flame_riverpod` - `v5.4.5`](#flame_riverpod---v545)
 - [`flame_kenney_xml` - `v0.1.1+2`](#flame_kenney_xml---v0112)
 - [`flame_bloc` - `v1.12.3`](#flame_bloc---v1123)
 - [`flame_noise` - `v0.3.2+2`](#flame_noise---v0322)
 - [`flame_lottie` - `v0.4.2+2`](#flame_lottie---v0422)
 - [`flame_network_assets` - `v0.3.3+2`](#flame_network_assets---v0332)
 - [`flame_svg` - `v1.11.2`](#flame_svg---v1112)
 - [`flame_sprite_fusion` - `v0.1.3+2`](#flame_sprite_fusion---v0132)
 - [`flame_markdown` - `v0.2.2+2`](#flame_markdown---v0222)
 - [`flame_isolate` - `v0.6.2+2`](#flame_isolate---v0622)

Packages with dependency updates only:

> Packages listed below depend on other packages in this workspace that have had changes. Their versions have been incremented to bump the minimum dependency versions of the packages they depend upon in this project.

 - `flame_audio` - `v2.10.5`
 - `flame_forge2d` - `v0.18.2+2`
 - `flame_oxygen` - `v0.2.3+2`
 - `flame_rive` - `v1.10.5`
 - `flame_texturepacker` - `v4.1.2`
 - `flame_behavior_tree` - `v0.1.3+2`
 - `flame_spine` - `v0.2.2+2`
 - `flame_riverpod` - `v5.4.5`
 - `flame_kenney_xml` - `v0.1.1+2`
 - `flame_bloc` - `v1.12.3`
 - `flame_noise` - `v0.3.2+2`
 - `flame_lottie` - `v0.4.2+2`
 - `flame_network_assets` - `v0.3.3+2`
 - `flame_svg` - `v1.11.2`
 - `flame_sprite_fusion` - `v0.1.3+2`
 - `flame_markdown` - `v0.2.2+2`
 - `flame_isolate` - `v0.6.2+2`

---

#### `flame` - `v1.21.0`

 - **FIX**: Widgets flickering ([#3343](https://github.com/flame-engine/flame/issues/3343)). ([ff170dc5](https://github.com/flame-engine/flame/commit/ff170dc5c2acc41190249b48e61767ea459fabb4))
 - **FIX**: Ray should not be able to escape `CircleHitbox` ([#3341](https://github.com/flame-engine/flame/issues/3341)). ([7311d034](https://github.com/flame-engine/flame/commit/7311d034d4c3b43592b49472384fe8576809e6a5))
 - **FIX**: Fix SpriteBatch to comply with new drawAtlas requirement ([#3338](https://github.com/flame-engine/flame/issues/3338)). ([a17fe4cd](https://github.com/flame-engine/flame/commit/a17fe4cdfaafa071cfd2ab8ef8279b26b79f00a7))
 - **FIX**: Set SpriteButtonComponent sprites in `onMount` ([#3327](https://github.com/flame-engine/flame/issues/3327)). ([f36533e7](https://github.com/flame-engine/flame/commit/f36533e78c7634866680ab5fb202a3e230529943))
 - **FIX**: Export TapConfig to make visible ([#3323](https://github.com/flame-engine/flame/issues/3323)). ([8e00115c](https://github.com/flame-engine/flame/commit/8e00115cd299423564dfce4b9d1674c9257a3c42))
 - **FIX**: Clarify `SpriteGroupComponent.updateSprite` assertion ([#3317](https://github.com/flame-engine/flame/issues/3317)). ([d976ee8c](https://github.com/flame-engine/flame/commit/d976ee8c7e4fbbca08e549412ca8b5af6928d4f4))
 - **FEAT**: Adding spawnWhenLoaded flag on SpawnComponent ([#3334](https://github.com/flame-engine/flame/issues/3334)). ([51a7e26b](https://github.com/flame-engine/flame/commit/51a7e26b1ab0ef2a2d040548c74aef84b164272d))
 - **FEAT**: Add a getter for images cache keys ([#3324](https://github.com/flame-engine/flame/issues/3324)). ([7746f2f8](https://github.com/flame-engine/flame/commit/7746f2f867092c19222a40aec2b66dc80558dccb))

#### `flame_fire_atlas` - `v1.6.0`

 - **FEAT**: Adding getter for the atlas image on flame fire atlas ([#3326](https://github.com/flame-engine/flame/issues/3326)). ([ae230ffa](https://github.com/flame-engine/flame/commit/ae230ffaaa588df7a99a3e2e8fa8980dc32104c0))

#### `flame_test` - `v1.17.2`

 - **FIX**: Widgets flickering ([#3343](https://github.com/flame-engine/flame/issues/3343)). ([ff170dc5](https://github.com/flame-engine/flame/commit/ff170dc5c2acc41190249b48e61767ea459fabb4))
 - **FIX**: Fix SpriteBatch to comply with new drawAtlas requirement ([#3338](https://github.com/flame-engine/flame/issues/3338)). ([a17fe4cd](https://github.com/flame-engine/flame/commit/a17fe4cdfaafa071cfd2ab8ef8279b26b79f00a7))

#### `flame_tiled` - `v1.21.0`

 - **FEAT**: Add a getter for images cache keys ([#3324](https://github.com/flame-engine/flame/issues/3324)). ([7746f2f8](https://github.com/flame-engine/flame/commit/7746f2f867092c19222a40aec2b66dc80558dccb))


## 2024-09-20

### Changes

---

Packages with breaking changes:

 - There are no breaking changes in this release.

Packages with other changes:

 - [`flame` - `v1.20.0`](#flame---v1200)
 - [`flame_oxygen` - `v0.2.3+1`](#flame_oxygen---v0231)
 - [`flame_behavior_tree` - `v0.1.3+1`](#flame_behavior_tree---v0131)
 - [`flame_isolate` - `v0.6.2+1`](#flame_isolate---v0621)
 - [`flame_noise` - `v0.3.2+1`](#flame_noise---v0321)
 - [`flame_svg` - `v1.11.1`](#flame_svg---v1111)
 - [`flame_rive` - `v1.10.4`](#flame_rive---v1104)
 - [`flame_audio` - `v2.10.4`](#flame_audio---v2104)
 - [`flame_texturepacker` - `v4.1.1`](#flame_texturepacker---v411)
 - [`flame_spine` - `v0.2.2+1`](#flame_spine---v0221)
 - [`flame_sprite_fusion` - `v0.1.3+1`](#flame_sprite_fusion---v0131)
 - [`flame_markdown` - `v0.2.2+1`](#flame_markdown---v0221)
 - [`flame_forge2d` - `v0.18.2+1`](#flame_forge2d---v01821)
 - [`flame_test` - `v1.17.1`](#flame_test---v1171)
 - [`flame_fire_atlas` - `v1.5.5`](#flame_fire_atlas---v155)
 - [`flame_bloc` - `v1.12.2`](#flame_bloc---v1122)
 - [`flame_kenney_xml` - `v0.1.1+1`](#flame_kenney_xml---v0111)
 - [`flame_riverpod` - `v5.4.4`](#flame_riverpod---v544)
 - [`flame_network_assets` - `v0.3.3+1`](#flame_network_assets---v0331)
 - [`flame_tiled` - `v1.20.4`](#flame_tiled---v1204)
 - [`flame_lottie` - `v0.4.2+1`](#flame_lottie---v0421)

Packages with dependency updates only:

> Packages listed below depend on other packages in this workspace that have had changes. Their versions have been incremented to bump the minimum dependency versions of the packages they depend upon in this project.

 - `flame_oxygen` - `v0.2.3+1`
 - `flame_behavior_tree` - `v0.1.3+1`
 - `flame_isolate` - `v0.6.2+1`
 - `flame_noise` - `v0.3.2+1`
 - `flame_svg` - `v1.11.1`
 - `flame_rive` - `v1.10.4`
 - `flame_audio` - `v2.10.4`
 - `flame_texturepacker` - `v4.1.1`
 - `flame_spine` - `v0.2.2+1`
 - `flame_sprite_fusion` - `v0.1.3+1`
 - `flame_markdown` - `v0.2.2+1`
 - `flame_forge2d` - `v0.18.2+1`
 - `flame_test` - `v1.17.1`
 - `flame_fire_atlas` - `v1.5.5`
 - `flame_bloc` - `v1.12.2`
 - `flame_kenney_xml` - `v0.1.1+1`
 - `flame_riverpod` - `v5.4.4`
 - `flame_network_assets` - `v0.3.3+1`
 - `flame_tiled` - `v1.20.4`
 - `flame_lottie` - `v0.4.2+1`

---

#### `flame` - `v1.20.0`

 - **FIX**: SpriteButtonComponent to initialize sprites in `onLoad` ([#3302](https://github.com/flame-engine/flame/issues/3302)). ([1204216c](https://github.com/flame-engine/flame/commit/1204216cb227d3831b546a54818075065fa7beec))
 - **FIX**: ViewportAwareBounds component and lifecycle issues ([#3276](https://github.com/flame-engine/flame/issues/3276)). ([026bf41f](https://github.com/flame-engine/flame/commit/026bf41f020de66ae9adfcdda9209bfbb75cf60c))
 - **FEAT**: Add ComponentTreeRoot.lifecycleEventsProcessed future ([#3308](https://github.com/flame-engine/flame/issues/3308)). ([ebc47418](https://github.com/flame-engine/flame/commit/ebc474189ceb587bcdebef7d3645ed2f3b3dba6f))
 - **FEAT**: Adding paint attribute to SpriteWidget and SpriteAnimationWidget ([#3298](https://github.com/flame-engine/flame/issues/3298)). ([a5338d0c](https://github.com/flame-engine/flame/commit/a5338d0c20d01bbe461c6d7fed5951d11e1c76f0))
 - **FEAT**: Adding tickOnLoad to TimerComponent ([#3285](https://github.com/flame-engine/flame/issues/3285)). ([0113aa37](https://github.com/flame-engine/flame/commit/0113aa376145109079a89bd310b9e528631ce9d4))
 - **DOCS**: Include information about the Flame DevTools extension in example readme ([#3288](https://github.com/flame-engine/flame/issues/3288)). ([76a9abaf](https://github.com/flame-engine/flame/commit/76a9abaf3c70659323e02bf7b6531b4fbba1f7a2))


## 2024-08-27

### Changes

---

Packages with breaking changes:

 - [`flame` - `v1.19.0`](#flame---v1190)

Packages with other changes:

 - [`behavior_tree` - `v0.1.3`](#behavior_tree---v013)
 - [`flame_behavior_tree` - `v0.1.3`](#flame_behavior_tree---v013)
 - [`flame_bloc` - `v1.12.1`](#flame_bloc---v1121)
 - [`flame_forge2d` - `v0.18.2`](#flame_forge2d---v0182)
 - [`flame_isolate` - `v0.6.2`](#flame_isolate---v062)
 - [`flame_kenney_xml` - `v0.1.1`](#flame_kenney_xml---v011)
 - [`flame_lint` - `v1.2.1`](#flame_lint---v121)
 - [`flame_lottie` - `v0.4.2`](#flame_lottie---v042)
 - [`flame_markdown` - `v0.2.2`](#flame_markdown---v022)
 - [`flame_noise` - `v0.3.2`](#flame_noise---v032)
 - [`flame_oxygen` - `v0.2.3`](#flame_oxygen---v023)
 - [`flame_rive` - `v1.10.3`](#flame_rive---v1103)
 - [`flame_spine` - `v0.2.2`](#flame_spine---v022)
 - [`flame_splash_screen` - `v0.3.1`](#flame_splash_screen---v031)
 - [`flame_sprite_fusion` - `v0.1.3`](#flame_sprite_fusion---v013)
 - [`flame_svg` - `v1.11.0`](#flame_svg---v1110)
 - [`flame_test` - `v1.17.0`](#flame_test---v1170)
 - [`flame_texturepacker` - `v4.1.0`](#flame_texturepacker---v410)
 - [`flame_tiled` - `v1.20.3`](#flame_tiled---v1203)
 - [`jenny` - `v1.3.2`](#jenny---v132)
 - [`flame_fire_atlas` - `v1.5.4`](#flame_fire_atlas---v154)
 - [`flame_riverpod` - `v5.4.3`](#flame_riverpod---v543)
 - [`flame_network_assets` - `v0.3.3`](#flame_network_assets---v033)
 - [`flame_audio` - `v2.10.3`](#flame_audio---v2103)

---

#### `flame` - `v1.19.0`

 - **REFACTOR**: Use a temp vector for delta calculations of `FollowBehavior` ([#3230](https://github.com/flame-engine/flame/issues/3230)). ([524793d4](https://github.com/flame-engine/flame/commit/524793d4a0dbe384d42fb9f844685b85abb05574))
 - **FIX**: Add assertion when trying to set "current" that doesn't exist ([#3258](https://github.com/flame-engine/flame/issues/3258)). ([267d6801](https://github.com/flame-engine/flame/commit/267d6801cb7e6cbbaa450e24e38aaa7d8fcfc03f))
 - **FIX**: Update version of lints to comply with new pub requirements ([#3223](https://github.com/flame-engine/flame/issues/3223)). ([1b0bee72](https://github.com/flame-engine/flame/commit/1b0bee726b5937f73d4be5e304bc8780aa3ca6f0))
 - **FIX**: Replace CurvedParticle inheritance with Particle in ScaledParticle ([#3221](https://github.com/flame-engine/flame/issues/3221)). ([8cd054d0](https://github.com/flame-engine/flame/commit/8cd054d02b614d1ee35a71f32dcbacf0952c9780))
 - **FIX**: Fix text rendering issue where spaces are missing ([#3192](https://github.com/flame-engine/flame/issues/3192)). ([28fd2a0f](https://github.com/flame-engine/flame/commit/28fd2a0f0f1ea04872d0c4e8b674c8ce7bca69ee))
 - **FIX**: Add nativeAngle to constructors where it makes sense ([#3197](https://github.com/flame-engine/flame/issues/3197)). ([e8704934](https://github.com/flame-engine/flame/commit/e8704934b19d9ed1982d35ce62819f01ac3de189))
 - **FIX**: Wire in background and foreground colors in TextPaint ([#3191](https://github.com/flame-engine/flame/issues/3191)). ([983cfab6](https://github.com/flame-engine/flame/commit/983cfab6def86dbf68455fb021281caaf0135793))
 - **FIX**: Disallow mutatation of `SpriteGroupComponent.sprites` ([#3185](https://github.com/flame-engine/flame/issues/3185)). ([7c40034d](https://github.com/flame-engine/flame/commit/7c40034d20ed26114b14fd262130d11cf226fb6a))
 - **FIX**: Disallow mutatation of `SpriteAnimationGroupComponent.animations` ([#3183](https://github.com/flame-engine/flame/issues/3183)). ([52773407](https://github.com/flame-engine/flame/commit/527734071b030ec7dbe0f3c017108db0dfda3ced))
 - **FEAT**: Adding scale and angle to devtools attributes ([#3267](https://github.com/flame-engine/flame/issues/3267)). ([b2a5e658](https://github.com/flame-engine/flame/commit/b2a5e6581ebaebc8044d65504efc58309f8a2b9b))
 - **FEAT**: Adding x,y,width and height inputs to position components on Dev Tools ([#3263](https://github.com/flame-engine/flame/issues/3263)). ([003ec3a1](https://github.com/flame-engine/flame/commit/003ec3a17beed2bad5540b968a0f5602c19ada79))
 - **FEAT**: Adding component snapshot to Dev tools ([#3261](https://github.com/flame-engine/flame/issues/3261)). ([1a574917](https://github.com/flame-engine/flame/commit/1a574917cd5311aea2576942d5cf4ea579218aaf))
 - **FEAT**: Fixing tests on flutter 3.24.0 ([#3259](https://github.com/flame-engine/flame/issues/3259)). ([bf9a2481](https://github.com/flame-engine/flame/commit/bf9a2481fbeb77413a26ae96b57843ca51411f9f))
 - **FEAT**: Loading builder for Route ([#3113](https://github.com/flame-engine/flame/issues/3113)). ([1e62b342](https://github.com/flame-engine/flame/commit/1e62b3424578150718514aa762f184485dba024a))
 - **FEAT**: Take in super.curve in ScalingParticle ([#3220](https://github.com/flame-engine/flame/issues/3220)). ([0fbc73cc](https://github.com/flame-engine/flame/commit/0fbc73ccdf36938a20f2eb8ae544881a8dbeae1e))
 - **FEAT**: Add `pause` and `resume` to `HasTimeScale` mixin ([#3216](https://github.com/flame-engine/flame/issues/3216)). ([9a86e7b5](https://github.com/flame-engine/flame/commit/9a86e7b54b55047ec9c63997015f71b7308dec27))
 - **FEAT**: Add missing background and foreground properties to InlineTextStyle ([#3187](https://github.com/flame-engine/flame/issues/3187)). ([34dde50f](https://github.com/flame-engine/flame/commit/34dde50f978f810df89fb1c051d13aee9214b307))
 - **FEAT**: Support inline code blocks on markdown rich text ([#3186](https://github.com/flame-engine/flame/issues/3186)). ([67e069c0](https://github.com/flame-engine/flame/commit/67e069c00dcb32c258231a326b0918739c6f80e6))
 - **DOCS**: Remove `PositionType` from the docs ([#3198](https://github.com/flame-engine/flame/issues/3198)). ([b0ff5c41](https://github.com/flame-engine/flame/commit/b0ff5c41c572da4dfa4221bef89b93b6f6be74c6))
 - **DOCS**: Add dartdocs to inline text node classes ([#3189](https://github.com/flame-engine/flame/issues/3189)). ([84c1ee87](https://github.com/flame-engine/flame/commit/84c1ee87f827a85c7accd92e061077ef291cb433))
 - **BREAKING** **REFACTOR**: Make query() result an Iterable ([#3209](https://github.com/flame-engine/flame/issues/3209)). ([c094caa7](https://github.com/flame-engine/flame/commit/c094caa77b17b1d69856396e27c88db8515bb44a))

#### `behavior_tree` - `v0.1.3`

 - **FIX**: Update version of lints to comply with new pub requirements ([#3223](https://github.com/flame-engine/flame/issues/3223)). ([1b0bee72](https://github.com/flame-engine/flame/commit/1b0bee726b5937f73d4be5e304bc8780aa3ca6f0))
 - **DOCS**: Add AI assist badge to readme(s) ([#3226](https://github.com/flame-engine/flame/issues/3226)). ([380d6aa9](https://github.com/flame-engine/flame/commit/380d6aa946d6b852c55f4ebbfce53d2087287fa2))
 - **DOCS**: Fix capitalization of the Dart programming language on pubspec description field ([#3222](https://github.com/flame-engine/flame/issues/3222)). ([9404241e](https://github.com/flame-engine/flame/commit/9404241e8a14d8d510f693c8557ca62ed76bd390))

#### `flame_behavior_tree` - `v0.1.3`

 - **FIX**: Update version of lints to comply with new pub requirements ([#3223](https://github.com/flame-engine/flame/issues/3223)). ([1b0bee72](https://github.com/flame-engine/flame/commit/1b0bee726b5937f73d4be5e304bc8780aa3ca6f0))
 - **DOCS**: Add AI assist badge to readme(s) ([#3226](https://github.com/flame-engine/flame/issues/3226)). ([380d6aa9](https://github.com/flame-engine/flame/commit/380d6aa946d6b852c55f4ebbfce53d2087287fa2))
 - **DOCS**: Fix capitalization of the Dart programming language on pubspec description field ([#3222](https://github.com/flame-engine/flame/issues/3222)). ([9404241e](https://github.com/flame-engine/flame/commit/9404241e8a14d8d510f693c8557ca62ed76bd390))

#### `flame_bloc` - `v1.12.1`

 - **DOCS**: Add AI assist badge to readme(s) ([#3226](https://github.com/flame-engine/flame/issues/3226)). ([380d6aa9](https://github.com/flame-engine/flame/commit/380d6aa946d6b852c55f4ebbfce53d2087287fa2))

#### `flame_forge2d` - `v0.18.2`

 - **DOCS**: Add AI assist badge to readme(s) ([#3226](https://github.com/flame-engine/flame/issues/3226)). ([380d6aa9](https://github.com/flame-engine/flame/commit/380d6aa946d6b852c55f4ebbfce53d2087287fa2))

#### `flame_isolate` - `v0.6.2`

 - **DOCS**: Add AI assist badge to readme(s) ([#3226](https://github.com/flame-engine/flame/issues/3226)). ([380d6aa9](https://github.com/flame-engine/flame/commit/380d6aa946d6b852c55f4ebbfce53d2087287fa2))

#### `flame_kenney_xml` - `v0.1.1`

 - **DOCS**: Add AI assist badge to readme(s) ([#3226](https://github.com/flame-engine/flame/issues/3226)). ([380d6aa9](https://github.com/flame-engine/flame/commit/380d6aa946d6b852c55f4ebbfce53d2087287fa2))

#### `flame_lint` - `v1.2.1`

 - **FIX**: Update version of lints to comply with new pub requirements ([#3223](https://github.com/flame-engine/flame/issues/3223)). ([1b0bee72](https://github.com/flame-engine/flame/commit/1b0bee726b5937f73d4be5e304bc8780aa3ca6f0))
 - **DOCS**: Add AI assist badge to readme(s) ([#3226](https://github.com/flame-engine/flame/issues/3226)). ([380d6aa9](https://github.com/flame-engine/flame/commit/380d6aa946d6b852c55f4ebbfce53d2087287fa2))

#### `flame_lottie` - `v0.4.2`

 - **DOCS**: Add AI assist badge to readme(s) ([#3226](https://github.com/flame-engine/flame/issues/3226)). ([380d6aa9](https://github.com/flame-engine/flame/commit/380d6aa946d6b852c55f4ebbfce53d2087287fa2))

#### `flame_markdown` - `v0.2.2`

 - **FEAT**: Support inline code blocks on markdown rich text ([#3186](https://github.com/flame-engine/flame/issues/3186)). ([67e069c0](https://github.com/flame-engine/flame/commit/67e069c00dcb32c258231a326b0918739c6f80e6))
 - **DOCS**: Add AI assist badge to readme(s) ([#3226](https://github.com/flame-engine/flame/issues/3226)). ([380d6aa9](https://github.com/flame-engine/flame/commit/380d6aa946d6b852c55f4ebbfce53d2087287fa2))

#### `flame_noise` - `v0.3.2`

 - **DOCS**: Add AI assist badge to readme(s) ([#3226](https://github.com/flame-engine/flame/issues/3226)). ([380d6aa9](https://github.com/flame-engine/flame/commit/380d6aa946d6b852c55f4ebbfce53d2087287fa2))

#### `flame_oxygen` - `v0.2.3`

 - **DOCS**: Add AI assist badge to readme(s) ([#3226](https://github.com/flame-engine/flame/issues/3226)). ([380d6aa9](https://github.com/flame-engine/flame/commit/380d6aa946d6b852c55f4ebbfce53d2087287fa2))

#### `flame_rive` - `v1.10.3`

 - **DOCS**: Add AI assist badge to readme(s) ([#3226](https://github.com/flame-engine/flame/issues/3226)). ([380d6aa9](https://github.com/flame-engine/flame/commit/380d6aa946d6b852c55f4ebbfce53d2087287fa2))

#### `flame_spine` - `v0.2.2`

 - **DOCS**: Homepage link typo for flame_spine ([#3277](https://github.com/flame-engine/flame/issues/3277)). ([f76355f1](https://github.com/flame-engine/flame/commit/f76355f151a61fa0eddb5356b7e2a7c27b96c221))

#### `flame_splash_screen` - `v0.3.1`

 - **DOCS**: Add AI assist badge to readme(s) ([#3226](https://github.com/flame-engine/flame/issues/3226)). ([380d6aa9](https://github.com/flame-engine/flame/commit/380d6aa946d6b852c55f4ebbfce53d2087287fa2))

#### `flame_sprite_fusion` - `v0.1.3`

 - **FIX**: Add nativeAngle to constructors where it makes sense ([#3197](https://github.com/flame-engine/flame/issues/3197)). ([e8704934](https://github.com/flame-engine/flame/commit/e8704934b19d9ed1982d35ce62819f01ac3de189))
 - **DOCS**: Add AI assist badge to readme(s) ([#3226](https://github.com/flame-engine/flame/issues/3226)). ([380d6aa9](https://github.com/flame-engine/flame/commit/380d6aa946d6b852c55f4ebbfce53d2087287fa2))

#### `flame_svg` - `v1.11.0`

 - **FEAT**: Fixing tests on flutter 3.24.0 ([#3259](https://github.com/flame-engine/flame/issues/3259)). ([bf9a2481](https://github.com/flame-engine/flame/commit/bf9a2481fbeb77413a26ae96b57843ca51411f9f))
 - **DOCS**: Add AI assist badge to readme(s) ([#3226](https://github.com/flame-engine/flame/issues/3226)). ([380d6aa9](https://github.com/flame-engine/flame/commit/380d6aa946d6b852c55f4ebbfce53d2087287fa2))

#### `flame_test` - `v1.17.0`

 - **FEAT**: Add a closeToVector3 matcher to flame_test ([#3242](https://github.com/flame-engine/flame/issues/3242)). ([965b684a](https://github.com/flame-engine/flame/commit/965b684a286ae2e2a89ba303839004d0b12cb3ef))
 - **DOCS**: Add AI assist badge to readme(s) ([#3226](https://github.com/flame-engine/flame/issues/3226)). ([380d6aa9](https://github.com/flame-engine/flame/commit/380d6aa946d6b852c55f4ebbfce53d2087287fa2))

#### `flame_texturepacker` - `v4.1.0`

 - **PERF**: Optimize `TexturePackerSprite` when sprites do not need to be rotated ([#3236](https://github.com/flame-engine/flame/issues/3236)). ([e9512e9b](https://github.com/flame-engine/flame/commit/e9512e9b28188476d5956e875430f1ef195f5882))
 - **FEAT**: Enhance TexturePackerSprite ([#3224](https://github.com/flame-engine/flame/issues/3224)). ([0b0a6c1b](https://github.com/flame-engine/flame/commit/0b0a6c1bacfca8772d1b9518e9433d994e68bae1))
 - **DOCS**: Add AI assist badge to readme(s) ([#3226](https://github.com/flame-engine/flame/issues/3226)). ([380d6aa9](https://github.com/flame-engine/flame/commit/380d6aa946d6b852c55f4ebbfce53d2087287fa2))

#### `flame_tiled` - `v1.20.3`

 - **DOCS**: Add AI assist badge to readme(s) ([#3226](https://github.com/flame-engine/flame/issues/3226)). ([380d6aa9](https://github.com/flame-engine/flame/commit/380d6aa946d6b852c55f4ebbfce53d2087287fa2))

#### `jenny` - `v1.3.2`

 - **FIX**: Fix analyze issue on main ([#3265](https://github.com/flame-engine/flame/issues/3265)). ([f60b6e13](https://github.com/flame-engine/flame/commit/f60b6e134177495bcfd0f405a50f9e0e666b8b42))

#### `flame_fire_atlas` - `v1.5.4`

#### `flame_riverpod` - `v5.4.3`

 - Bump "flame_riverpod" to `5.4.3`.

#### `flame_network_assets` - `v0.3.3`

#### `flame_audio` - `v2.10.3`

 - **DOCS**: Add AI assist badge to readme(s) ([#3226](https://github.com/flame-engine/flame/issues/3226)). ([380d6aa9](https://github.com/flame-engine/flame/commit/380d6aa946d6b852c55f4ebbfce53d2087287fa2))


## 2024-07-29

### Changes

---

Packages with breaking changes:

 - There are no breaking changes in this release.

Packages with other changes:

 - [`flame_fire_atlas` - `v1.5.3`](#flame_fire_atlas---v153)

---

#### `flame_fire_atlas` - `v1.5.3`

 - **FEAT**: Adding group to flame fire atlas ([#3245](https://github.com/flame-engine/flame/issues/3245)). ([0fab444c](https://github.com/flame-engine/flame/commit/0fab444c3dd9ad8faa1e0e9e702150b950dbf30f))
 - **DOCS**: Add AI assist badge to readme(s) ([#3226](https://github.com/flame-engine/flame/issues/3226)). ([380d6aa9](https://github.com/flame-engine/flame/commit/380d6aa946d6b852c55f4ebbfce53d2087287fa2))


## 2024-05-27

### Changes

---

Packages with breaking changes:

 - [`flame` - `v1.18.0`](#flame---v1180)

Packages with other changes:

 - [`behavior_tree` - `v0.1.2`](#behavior_tree---v012)
 - [`flame_behavior_tree` - `v0.1.2`](#flame_behavior_tree---v012)
 - [`flame_forge2d` - `v0.18.1`](#flame_forge2d---v0181)
 - [`flame_isolate` - `v0.6.1`](#flame_isolate---v061)
 - [`flame_markdown` - `v0.2.1`](#flame_markdown---v021)
 - [`flame_oxygen` - `v0.2.2`](#flame_oxygen---v022)
 - [`flame_sprite_fusion` - `v0.1.2`](#flame_sprite_fusion---v012)
 - [`flame_lottie` - `v0.4.1`](#flame_lottie---v041)
 - [`flame_noise` - `v0.3.1`](#flame_noise---v031)
 - [`flame_network_assets` - `v0.3.2`](#flame_network_assets---v032)
 - [`flame_spine` - `v0.2.1`](#flame_spine---v021)
 - [`flame_audio` - `v2.10.2`](#flame_audio---v2102)
 - [`flame_bloc` - `v1.12.0`](#flame_bloc---v1120)
 - [`flame_lint` - `v1.2.0`](#flame_lint---v120)
 - [`flame_rive` - `v1.10.2`](#flame_rive---v1102)
 - [`flame_texturepacker` - `v4.0.1`](#flame_texturepacker---v401)
 - [`flame_tiled` - `v1.20.2`](#flame_tiled---v1202)
 - [`jenny` - `v1.3.1`](#jenny---v131)
 - [`flame_test` - `v1.16.2`](#flame_test---v1162)
 - [`flame_fire_atlas` - `v1.5.2`](#flame_fire_atlas---v152)
 - [`flame_riverpod` - `v5.4.2`](#flame_riverpod---v542)
 - [`flame_svg` - `v1.10.2`](#flame_svg---v1102)

Packages with dependency updates only:

> Packages listed below depend on other packages in this workspace that have had changes. Their versions have been incremented to bump the minimum dependency versions of the packages they depend upon in this project.

 - `flame_test` - `v1.16.2`
 - `flame_fire_atlas` - `v1.5.2`
 - `flame_riverpod` - `v5.4.2`
 - `flame_svg` - `v1.10.2`

---

#### `flame` - `v1.18.0`

 - **REFACTOR**: Modernize switch; use switch-expressions and no break; ([#3133](https://github.com/flame-engine/flame/issues/3133)). ([b283b82f](https://github.com/flame-engine/flame/commit/b283b82f6cfa7e7f2ce5ff7f657e6569667183d4))
 - **FIX**: Add key parameters to the rest of the components ([#3170](https://github.com/flame-engine/flame/issues/3170)). ([2477ea0f](https://github.com/flame-engine/flame/commit/2477ea0fcee99e71597983146f4af2dffd866971))
 - **FIX**: Invoke `setToStart` on child effect controller of wrapping effect controllers ([#3168](https://github.com/flame-engine/flame/issues/3168)). ([217c95f0](https://github.com/flame-engine/flame/commit/217c95f0a53fd5a7933bfa57833f951cc0037878))
 - **FIX**: Fix cascading and fallback propagation of text styles ([#3129](https://github.com/flame-engine/flame/issues/3129)). ([7b706d5f](https://github.com/flame-engine/flame/commit/7b706d5f63207aaf82d12a4b26233bc476771b1e))
 - **FEAT**: Add `onReleased` action to `AdvancedButtonComponent` which will be called within `onTapUp` ([#3152](https://github.com/flame-engine/flame/issues/3152)). ([2269732e](https://github.com/flame-engine/flame/commit/2269732e64a2acef2451d283c85b03e1101229ec))
 - **FEAT**: Support text align on new text rendering pipeline ([#3147](https://github.com/flame-engine/flame/issues/3147)). ([194d5536](https://github.com/flame-engine/flame/commit/194d5536560e464644bff8d5582a8ca8996539f5))
 - **FEAT**: Add missing parameters to InlineTextStyle ([#3146](https://github.com/flame-engine/flame/issues/3146)). ([ce9392ab](https://github.com/flame-engine/flame/commit/ce9392abd85fe5fd3ae6f766c3a2957275c6fb8c))
 - **FEAT**: Expand flame_lint to respect required pub.dev checks ([#3139](https://github.com/flame-engine/flame/issues/3139)). ([6e80bf5e](https://github.com/flame-engine/flame/commit/6e80bf5e679d1cdeeb9362d4103690b0b381161d))
 - **FEAT**: Add accessor to determine a TextElement size ([#3130](https://github.com/flame-engine/flame/issues/3130)). ([8a63a07a](https://github.com/flame-engine/flame/commit/8a63a07ae3b569c316eafa23f0378e00180e0963))
 - **FEAT**: Add ability to convert between TextPaint and InlineTextStyle ([#3128](https://github.com/flame-engine/flame/issues/3128)). ([6b63a57a](https://github.com/flame-engine/flame/commit/6b63a57a4888211b284f3a074c17519cb31341e0))
 - **FEAT**: Add completed future for effects ([#3123](https://github.com/flame-engine/flame/issues/3123)). ([5e967deb](https://github.com/flame-engine/flame/commit/5e967deb876ed39fa4ee6839471bbfbcd3b72463))
 - **FEAT**: Add custom long tap delay ([#3110](https://github.com/flame-engine/flame/issues/3110)). ([a95d7df6](https://github.com/flame-engine/flame/commit/a95d7df606bd2119423cc8a7ae51cacfb7b4dbed))
 - **DOCS**: Update the dartdocs for `FixedResolutionViewport` ([#3132](https://github.com/flame-engine/flame/issues/3132)). ([db4b6fd6](https://github.com/flame-engine/flame/commit/db4b6fd6fa5968462d3f89238a92edbb93e4898d))
 - **BREAKING** **FIX**: Update IsometricTileMapComponent to have better defined position and size ([#3142](https://github.com/flame-engine/flame/issues/3142)). ([9a7bdc74](https://github.com/flame-engine/flame/commit/9a7bdc7439322a26a388e3ac1b9c1a7c43742222))

#### `behavior_tree` - `v0.1.2`

 - **REFACTOR**: Modernize switch; use switch-expressions and no break; ([#3133](https://github.com/flame-engine/flame/issues/3133)). ([b283b82f](https://github.com/flame-engine/flame/commit/b283b82f6cfa7e7f2ce5ff7f657e6569667183d4))

#### `flame_behavior_tree` - `v0.1.2`

 - **REFACTOR**: Modernize switch; use switch-expressions and no break; ([#3133](https://github.com/flame-engine/flame/issues/3133)). ([b283b82f](https://github.com/flame-engine/flame/commit/b283b82f6cfa7e7f2ce5ff7f657e6569667183d4))

#### `flame_forge2d` - `v0.18.1`

 - **REFACTOR**: Modernize switch; use switch-expressions and no break; ([#3133](https://github.com/flame-engine/flame/issues/3133)). ([b283b82f](https://github.com/flame-engine/flame/commit/b283b82f6cfa7e7f2ce5ff7f657e6569667183d4))

#### `flame_isolate` - `v0.6.1`

 - **REFACTOR**: Modernize switch; use switch-expressions and no break; ([#3133](https://github.com/flame-engine/flame/issues/3133)). ([b283b82f](https://github.com/flame-engine/flame/commit/b283b82f6cfa7e7f2ce5ff7f657e6569667183d4))

#### `flame_markdown` - `v0.2.1`

 - **REFACTOR**: Modernize switch; use switch-expressions and no break; ([#3133](https://github.com/flame-engine/flame/issues/3133)). ([b283b82f](https://github.com/flame-engine/flame/commit/b283b82f6cfa7e7f2ce5ff7f657e6569667183d4))

#### `flame_oxygen` - `v0.2.2`

#### `flame_sprite_fusion` - `v0.1.2`

#### `flame_lottie` - `v0.4.1`

#### `flame_noise` - `v0.3.1`

#### `flame_network_assets` - `v0.3.2`

#### `flame_spine` - `v0.2.1`

#### `flame_audio` - `v2.10.2`

 - **DOCS**: Update flame_audio readme ([#3119](https://github.com/flame-engine/flame/issues/3119)). ([843984de](https://github.com/flame-engine/flame/commit/843984dee5f5f6afd351ef29ad2adb39650f30bb))

#### `flame_bloc` - `v1.12.0`

 - **REFACTOR**: Modernize switch; use switch-expressions and no break; ([#3133](https://github.com/flame-engine/flame/issues/3133)). ([b283b82f](https://github.com/flame-engine/flame/commit/b283b82f6cfa7e7f2ce5ff7f657e6569667183d4))
 - **FIX**: Call `super.onLoad` from `FlameBlockReader` ([#3175](https://github.com/flame-engine/flame/issues/3175)). ([349f7bd7](https://github.com/flame-engine/flame/commit/349f7bd71437abad666d05f973b6983970ccd0c6))
 - **FEAT**: Expand flame_lint to respect required pub.dev checks ([#3139](https://github.com/flame-engine/flame/issues/3139)). ([6e80bf5e](https://github.com/flame-engine/flame/commit/6e80bf5e679d1cdeeb9362d4103690b0b381161d))

#### `flame_lint` - `v1.2.0`

 - **FEAT**: Expand flame_lint to respect required pub.dev checks ([#3139](https://github.com/flame-engine/flame/issues/3139)). ([6e80bf5e](https://github.com/flame-engine/flame/commit/6e80bf5e679d1cdeeb9362d4103690b0b381161d))

#### `flame_rive` - `v1.10.2`

 - **REFACTOR**: Modernize switch; use switch-expressions and no break; ([#3133](https://github.com/flame-engine/flame/issues/3133)). ([b283b82f](https://github.com/flame-engine/flame/commit/b283b82f6cfa7e7f2ce5ff7f657e6569667183d4))

#### `flame_texturepacker` - `v4.0.1`

 - **FIX**: TexturePacker fixes the wrong path for the atlas file. ([#3124](https://github.com/flame-engine/flame/issues/3124)). ([69f5c388](https://github.com/flame-engine/flame/commit/69f5c388ce4e0a64ba5f7331a596777a9eab1e40))

#### `flame_tiled` - `v1.20.2`

 - **REFACTOR**: Modernize switch; use switch-expressions and no break; ([#3133](https://github.com/flame-engine/flame/issues/3133)). ([b283b82f](https://github.com/flame-engine/flame/commit/b283b82f6cfa7e7f2ce5ff7f657e6569667183d4))

#### `jenny` - `v1.3.1`

 - **REFACTOR**: Modernize switch; use switch-expressions and no break; ([#3133](https://github.com/flame-engine/flame/issues/3133)). ([b283b82f](https://github.com/flame-engine/flame/commit/b283b82f6cfa7e7f2ce5ff7f657e6569667183d4))


## 2024-04-05

### Changes

---

Packages with breaking changes:

 - [`flame_texturepacker` - `v4.0.0`](#flame_texturepacker---v400)

Packages with other changes:

 - [`flame_forge2d` - `v0.18.0`](#flame_forge2d---v0180)
 - [`flame_tiled` - `v1.20.1`](#flame_tiled---v1201)

---

#### `flame_texturepacker` - `v4.0.0`

 - **BREAKING** **FEAT**: Use `Flame.images` in flame_texturepacker ([#3103](https://github.com/flame-engine/flame/issues/3103)). ([418cc578](https://github.com/flame-engine/flame/commit/418cc578053d969a4a5c3789b1713b9e1a4b3bdd))

#### `flame_forge2d` - `v0.18.0`

 - **FIX**: Use camera argument name in Forge2DGame ([#3115](https://github.com/flame-engine/flame/issues/3115)). ([9d97b123](https://github.com/flame-engine/flame/commit/9d97b12348161b4b150ee4166ba552f28d5f9d8b))
 - **DOCS**: Upgrade dashbook version ([#3109](https://github.com/flame-engine/flame/issues/3109)). ([a717bcb4](https://github.com/flame-engine/flame/commit/a717bcb475a5604c5d8c66a3a5ac53f0dc173109))

#### `flame_tiled` - `v1.20.1`

 - **FIX**: Respect tile offset when drawing tiles ([#3112](https://github.com/flame-engine/flame/issues/3112)). ([e3477474](https://github.com/flame-engine/flame/commit/e34774743038bc75fec14afc3c753fa997e71577))


## 2024-03-29

### Changes

---

Packages with breaking changes:

 - [`flame` - `v1.17.0`](#flame---v1170)

Packages with other changes:

 - [`flame_forge2d` - `v0.17.1`](#flame_forge2d---v0171)
 - [`flame_oxygen` - `v0.2.1`](#flame_oxygen---v021)
 - [`behavior_tree` - `v0.1.1`](#behavior_tree---v011)
 - [`flame_behavior_tree` - `v0.1.1`](#flame_behavior_tree---v011)
 - [`flame_network_assets` - `v0.3.1`](#flame_network_assets---v031)
 - [`flame_sprite_fusion` - `v0.1.1`](#flame_sprite_fusion---v011)
 - [`flame_texturepacker` - `v3.2.0`](#flame_texturepacker---v320)
 - [`flame_tiled` - `v1.20.0`](#flame_tiled---v1200)
 - [`flame_test` - `v1.16.1`](#flame_test---v1161)
 - [`flame_isolate` - `v0.6.0+1`](#flame_isolate---v0601)
 - [`flame_fire_atlas` - `v1.5.1`](#flame_fire_atlas---v151)
 - [`flame_audio` - `v2.10.1`](#flame_audio---v2101)
 - [`flame_spine` - `v0.2.0+1`](#flame_spine---v0201)
 - [`flame_bloc` - `v1.11.1`](#flame_bloc---v1111)
 - [`flame_lottie` - `v0.4.0+1`](#flame_lottie---v0401)
 - [`flame_markdown` - `v0.2.0+1`](#flame_markdown---v0201)
 - [`flame_rive` - `v1.10.1`](#flame_rive---v1101)
 - [`flame_noise` - `v0.3.0+1`](#flame_noise---v0301)
 - [`flame_riverpod` - `v5.4.1`](#flame_riverpod---v541)
 - [`flame_svg` - `v1.10.1`](#flame_svg---v1101)

Packages with dependency updates only:

> Packages listed below depend on other packages in this workspace that have had changes. Their versions have been incremented to bump the minimum dependency versions of the packages they depend upon in this project.

 - `flame_test` - `v1.16.1`
 - `flame_isolate` - `v0.6.0+1`
 - `flame_fire_atlas` - `v1.5.1`
 - `flame_audio` - `v2.10.1`
 - `flame_spine` - `v0.2.0+1`
 - `flame_bloc` - `v1.11.1`
 - `flame_lottie` - `v0.4.0+1`
 - `flame_markdown` - `v0.2.0+1`
 - `flame_rive` - `v1.10.1`
 - `flame_noise` - `v0.3.0+1`
 - `flame_riverpod` - `v5.4.1`
 - `flame_svg` - `v1.10.1`

---

#### `flame` - `v1.17.0`

 - **REFACTOR**: Change the ClipComponent factory Constructor to redirect Constructor ([#3089](https://github.com/flame-engine/flame/issues/3089)). ([cc035fb4](https://github.com/flame-engine/flame/commit/cc035fb4a3e123473d4e5e0db1fa0253e533bc61))
 - **FIX**: Call `render` properly from nested `FlameGame`s ([#3106](https://github.com/flame-engine/flame/issues/3106)). ([cb1e3701](https://github.com/flame-engine/flame/commit/cb1e37014bac7bb68b647234b718a37e26ad7559))
 - **FIX**: CircleHitbox should properly detect when ray is outside ([#3100](https://github.com/flame-engine/flame/issues/3100)). ([8cd9e123](https://github.com/flame-engine/flame/commit/8cd9e12319c0715def655fcf42f3976fa5f45e11))
 - **FIX**: Clamp opacity set by the `ColorEffect` to 1.0 ([#3069](https://github.com/flame-engine/flame/issues/3069)). ([9282cc38](https://github.com/flame-engine/flame/commit/9282cc38f06cd6c87ed3a1880d28d5c9f290cc04))
 - **FIX**: FutureOr return type of ComponentViewportMargin.onLoad ([#3059](https://github.com/flame-engine/flame/issues/3059)). ([72678c67](https://github.com/flame-engine/flame/commit/72678c676020480beae1d944ee687fd73eac9cf7))
 - **FIX**: Size for `SpriteComponent.fromImage` should be nullable ([#3054](https://github.com/flame-engine/flame/issues/3054)). ([2ed71a3c](https://github.com/flame-engine/flame/commit/2ed71a3c89b3c2182828f2812d8515811483f4d5))
 - **FIX**: Check for removing state while adding a child ([#3050](https://github.com/flame-engine/flame/issues/3050)). ([3a24a51d](https://github.com/flame-engine/flame/commit/3a24a51d108b1138ac3dd735956f4276f16b2974))
 - **FEAT**: Add onFinished callback to ScrollTextBoxComponent ([#3105](https://github.com/flame-engine/flame/issues/3105)). ([233cc94c](https://github.com/flame-engine/flame/commit/233cc94c557e0af2fcf7599943ddf75180abf801))
 - **FEAT**: Add `copyWith` method on the `TextBoxConfig` ([#3099](https://github.com/flame-engine/flame/issues/3099)). ([b946ba70](https://github.com/flame-engine/flame/commit/b946ba70cbfb5793a8d4d7c61d6ba029fbc303ab))
 - **FEAT**: Component tree for the devtools extension tab ([#3094](https://github.com/flame-engine/flame/issues/3094)). ([bf5d68e9](https://github.com/flame-engine/flame/commit/bf5d68e9b5147dd5e7c10d72bf9c2f705733d688))
 - **FEAT**: Add PositionComponent.toString ([#3095](https://github.com/flame-engine/flame/issues/3095)). ([b1f01986](https://github.com/flame-engine/flame/commit/b1f01986b440ac18bb35b0d76963b2c66f49ea33))
 - **FEAT**: Add SpriteBatch.replace to allow the replacement of the batch information ([#3079](https://github.com/flame-engine/flame/issues/3079)). ([bf3c282d](https://github.com/flame-engine/flame/commit/bf3c282dd669e9a32a550b86770dba7fb8472afa))
 - **FEAT**: Initial functionality of flame_devtools ([#3061](https://github.com/flame-engine/flame/issues/3061)). ([c92910c6](https://github.com/flame-engine/flame/commit/c92910c688f5dc4463e129132759102e7ebf2e36))
 - **FEAT**: Add `HasPerformanceTracker` mixin on `Game` ([#3043](https://github.com/flame-engine/flame/issues/3043)). ([6270353a](https://github.com/flame-engine/flame/commit/6270353af9a6ec58ee9275ddfa6a8b26276a2c20))
 - **BREAKING** **REFACTOR**: Use HasTimeScale for Route ([#3064](https://github.com/flame-engine/flame/issues/3064)). ([30fde805](https://github.com/flame-engine/flame/commit/30fde805b4650cc802f9908f9a1149dae19669d4))
 - **BREAKING** **FIX**: Removed unused parameters from SpriteWidget ([#3074](https://github.com/flame-engine/flame/issues/3074)). ([f49d24c0](https://github.com/flame-engine/flame/commit/f49d24c02dd0d9b781926908bad1fb6dfcbda5f2))

#### `flame_forge2d` - `v0.17.1`

 - **FIX**: Null gravity override by Forge2dGame ([#3092](https://github.com/flame-engine/flame/issues/3092)). ([3c35d59b](https://github.com/flame-engine/flame/commit/3c35d59b4a4ec064106d24a17e748005a20d9fde))

#### `flame_oxygen` - `v0.2.1`

 - **FIX**: Updated oxygen dep to v0.3.1 and added removing components ([#3087](https://github.com/flame-engine/flame/issues/3087)). ([8f50c927](https://github.com/flame-engine/flame/commit/8f50c9279581999b4ff7f506682148425b248e28))

#### `behavior_tree` - `v0.1.1`

 - **FEAT**: Add initial version of `behavior_tree` and `flame_behavior_tree` package ([#3045](https://github.com/flame-engine/flame/issues/3045)). ([faf2df4b](https://github.com/flame-engine/flame/commit/faf2df4b8c68015a1bfbdd96f93c950cb14963ef))

#### `flame_behavior_tree` - `v0.1.1`

 - **FEAT**: Add initial version of `behavior_tree` and `flame_behavior_tree` package ([#3045](https://github.com/flame-engine/flame/issues/3045)). ([faf2df4b](https://github.com/flame-engine/flame/commit/faf2df4b8c68015a1bfbdd96f93c950cb14963ef))

#### `flame_network_assets` - `v0.3.1`

 - **FEAT**: Update http dependency on flame_network_assets ([#3084](https://github.com/flame-engine/flame/issues/3084)). ([e3e755c6](https://github.com/flame-engine/flame/commit/e3e755c6dec35f36b4a42893afeea5f64ff025b7))

#### `flame_sprite_fusion` - `v0.1.1`

 - **FEAT**: Add initial version of `flame_sprite_fusion` package ([#3062](https://github.com/flame-engine/flame/issues/3062)). ([1c51334e](https://github.com/flame-engine/flame/commit/1c51334e865ae7000f93832574e24707e8c9dfa0))

#### `flame_texturepacker` - `v3.2.0`

 - **REFACTOR**: Deprecate `fromAtlas` in favour of `atlasFromAssets` and `atlasFromStorage` ([#3098](https://github.com/flame-engine/flame/issues/3098)). ([6c8190b7](https://github.com/flame-engine/flame/commit/6c8190b7215671e7d6e1e271b6aac2a9723ec20d))
 - **FEAT**: Support for new atlas format and rotated sprites ([#3097](https://github.com/flame-engine/flame/issues/3097)). ([ed690b30](https://github.com/flame-engine/flame/commit/ed690b3048924749f829c7c44156e258bf4ab3e7))
 - **FEAT**(flame_texturepacker): Expose TexturePackerAtlas ([#3047](https://github.com/flame-engine/flame/issues/3047)). ([892052b9](https://github.com/flame-engine/flame/commit/892052b99a21a8e371c4163e1e1918fd187c6e11))

#### `flame_tiled` - `v1.20.0`

 - **FEAT**: Export `TileAtlas` from `flame_tiled` package ([#3049](https://github.com/flame-engine/flame/issues/3049)). ([41e9e4e3](https://github.com/flame-engine/flame/commit/41e9e4e38c643b07a3a7269b1cd8d3fa60cbeebb))


## 2024-03-15

### Changes

---

Packages with breaking changes:

 - There are no breaking changes in this release.

Packages with other changes:

 - [`flame_riverpod` - `v5.4.0`](#flame_riverpod---v540)

---

#### `flame_riverpod` - `v5.4.0`

 - **FIX**: Resolve logic error with assignment of ComponentRef's game property in flame_riverpod ([#3082](https://github.com/flame-engine/flame/issues/3082)). ([b44011fd](https://github.com/flame-engine/flame/commit/b44011fd714ec5919de5407f53d0772f31ed1a13))
 - **FIX**: Resolve breaking changes from Riverpod affecting flame_riverpod ([#3080](https://github.com/flame-engine/flame/issues/3080)). ([e3aaa7c2](https://github.com/flame-engine/flame/commit/e3aaa7c21d89a6679c3ae70de6e676d1f11501fa))
 - **FIX**: Implement necessary `ProviderSubscription` getters ([#3075](https://github.com/flame-engine/flame/issues/3075)). ([17da92b2](https://github.com/flame-engine/flame/commit/17da92b2d1c527162106778f459d72f19a5c5607))
 - **FEAT**: Allow ComponentRef access in RiverpodGameMixin ([#3010](https://github.com/flame-engine/flame/issues/3010)). ([44b10fd6](https://github.com/flame-engine/flame/commit/44b10fd60c61392d449a8d12020c45724ad19625))


## 2024-02-17

### Changes

---

Packages with breaking changes:

 - [`flame` - `v1.16.0`](#flame---v1160)
 - [`flame_audio` - `v2.10.0`](#flame_audio---v2100)
 - [`flame_bloc` - `v1.11.0`](#flame_bloc---v1110)
 - [`flame_fire_atlas` - `v1.5.0`](#flame_fire_atlas---v150)
 - [`flame_rive` - `v1.10.0`](#flame_rive---v1100)
 - [`flame_riverpod` - `v5.3.0`](#flame_riverpod---v530)
 - [`flame_svg` - `v1.10.0`](#flame_svg---v1100)
 - [`flame_test` - `v1.16.0`](#flame_test---v1160)
 - [`flame_texturepacker` - `v3.1.0`](#flame_texturepacker---v310)
 - [`flame_tiled` - `v1.19.0`](#flame_tiled---v1190)
 - [`flame_forge2d` - `v0.17.0`](#flame_forge2d---v0170)
 - [`flame_isolate` - `v0.6.0`](#flame_isolate---v060)
 - [`flame_lottie` - `v0.4.0`](#flame_lottie---v040)
 - [`flame_markdown` - `v0.2.0`](#flame_markdown---v020)
 - [`flame_network_assets` - `v0.3.0`](#flame_network_assets---v030)
 - [`flame_noise` - `v0.3.0`](#flame_noise---v030)
 - [`flame_oxygen` - `v0.2.0`](#flame_oxygen---v020)
 - [`flame_spine` - `v0.2.0`](#flame_spine---v020)
 - [`flame_splash_screen` - `v0.3.0`](#flame_splash_screen---v030)

Packages with other changes:

 - [`jenny` - `v1.3.0`](#jenny---v130)

---

#### `flame` - `v1.16.0`

 - **REFACTOR**: Fix unrelated types reported by DCM ([#3023](https://github.com/flame-engine/flame/issues/3023)). ([1d020a52](https://github.com/flame-engine/flame/commit/1d020a525b81df1cb45345d3e36a9c4e9caf701e))
 - **FIX**: Vertices in `PolygonComponent` should subtract vertices positioning ([#3040](https://github.com/flame-engine/flame/issues/3040)). ([4f053ed7](https://github.com/flame-engine/flame/commit/4f053ed74c09d4e19a53694130b5d5c0d3e23aa6))
 - **BREAKING** **FIX**: Migrate from `RawKeyEvent` to `KeyEvent` ([#3002](https://github.com/flame-engine/flame/issues/3002)). ([330862c9](https://github.com/flame-engine/flame/commit/330862c98ecc7ed8d94e7cae0c34cd5781da0007))

#### `flame_audio` - `v2.10.0`

 - **BREAKING** **FIX**: Migrate from `RawKeyEvent` to `KeyEvent` ([#3002](https://github.com/flame-engine/flame/issues/3002)). ([330862c9](https://github.com/flame-engine/flame/commit/330862c98ecc7ed8d94e7cae0c34cd5781da0007))

#### `flame_bloc` - `v1.11.0`

 - **BREAKING** **FIX**: Migrate from `RawKeyEvent` to `KeyEvent` ([#3002](https://github.com/flame-engine/flame/issues/3002)). ([330862c9](https://github.com/flame-engine/flame/commit/330862c98ecc7ed8d94e7cae0c34cd5781da0007))

#### `flame_fire_atlas` - `v1.5.0`

 - **BREAKING** **FIX**: Migrate from `RawKeyEvent` to `KeyEvent` ([#3002](https://github.com/flame-engine/flame/issues/3002)). ([330862c9](https://github.com/flame-engine/flame/commit/330862c98ecc7ed8d94e7cae0c34cd5781da0007))

#### `flame_rive` - `v1.10.0`

 - **BREAKING** **FIX**: Migrate from `RawKeyEvent` to `KeyEvent` ([#3002](https://github.com/flame-engine/flame/issues/3002)). ([330862c9](https://github.com/flame-engine/flame/commit/330862c98ecc7ed8d94e7cae0c34cd5781da0007))

#### `flame_riverpod` - `v5.3.0`

 - **BREAKING** **FIX**: Migrate from `RawKeyEvent` to `KeyEvent` ([#3002](https://github.com/flame-engine/flame/issues/3002)). ([330862c9](https://github.com/flame-engine/flame/commit/330862c98ecc7ed8d94e7cae0c34cd5781da0007))

#### `flame_svg` - `v1.10.0`

 - **BREAKING** **FIX**: Migrate from `RawKeyEvent` to `KeyEvent` ([#3002](https://github.com/flame-engine/flame/issues/3002)). ([330862c9](https://github.com/flame-engine/flame/commit/330862c98ecc7ed8d94e7cae0c34cd5781da0007))

#### `flame_test` - `v1.16.0`

 - **BREAKING** **FIX**: Migrate from `RawKeyEvent` to `KeyEvent` ([#3002](https://github.com/flame-engine/flame/issues/3002)). ([330862c9](https://github.com/flame-engine/flame/commit/330862c98ecc7ed8d94e7cae0c34cd5781da0007))

#### `flame_texturepacker` - `v3.1.0`

 - **BREAKING** **FIX**: Migrate from `RawKeyEvent` to `KeyEvent` ([#3002](https://github.com/flame-engine/flame/issues/3002)). ([330862c9](https://github.com/flame-engine/flame/commit/330862c98ecc7ed8d94e7cae0c34cd5781da0007))

#### `flame_tiled` - `v1.19.0`

 - **FEAT**: Add TiledObjectHealpers extension on TiledObject ([#3032](https://github.com/flame-engine/flame/issues/3032)). ([78380b9d](https://github.com/flame-engine/flame/commit/78380b9d3bb895e20f382c4a1227bcc11e5038b9))
 - **BREAKING** **FIX**: Migrate from `RawKeyEvent` to `KeyEvent` ([#3002](https://github.com/flame-engine/flame/issues/3002)). ([330862c9](https://github.com/flame-engine/flame/commit/330862c98ecc7ed8d94e7cae0c34cd5781da0007))

#### `flame_forge2d` - `v0.17.0`

 - **FIX**: BodyComponent fixtures should test with global point ([#3042](https://github.com/flame-engine/flame/issues/3042)). ([7c3038be](https://github.com/flame-engine/flame/commit/7c3038becba91550eb47a033cbed7208d570e012))
 - **BREAKING** **FIX**: Migrate from `RawKeyEvent` to `KeyEvent` ([#3002](https://github.com/flame-engine/flame/issues/3002)). ([330862c9](https://github.com/flame-engine/flame/commit/330862c98ecc7ed8d94e7cae0c34cd5781da0007))

#### `flame_isolate` - `v0.6.0`

 - **BREAKING** **FIX**: Migrate from `RawKeyEvent` to `KeyEvent` ([#3002](https://github.com/flame-engine/flame/issues/3002)). ([330862c9](https://github.com/flame-engine/flame/commit/330862c98ecc7ed8d94e7cae0c34cd5781da0007))

#### `flame_lottie` - `v0.4.0`

 - **BREAKING** **FIX**: Migrate from `RawKeyEvent` to `KeyEvent` ([#3002](https://github.com/flame-engine/flame/issues/3002)). ([330862c9](https://github.com/flame-engine/flame/commit/330862c98ecc7ed8d94e7cae0c34cd5781da0007))

#### `flame_markdown` - `v0.2.0`

 - **BREAKING** **FIX**: Migrate from `RawKeyEvent` to `KeyEvent` ([#3002](https://github.com/flame-engine/flame/issues/3002)). ([330862c9](https://github.com/flame-engine/flame/commit/330862c98ecc7ed8d94e7cae0c34cd5781da0007))

#### `flame_network_assets` - `v0.3.0`

 - **BREAKING** **FIX**: Migrate from `RawKeyEvent` to `KeyEvent` ([#3002](https://github.com/flame-engine/flame/issues/3002)). ([330862c9](https://github.com/flame-engine/flame/commit/330862c98ecc7ed8d94e7cae0c34cd5781da0007))

#### `flame_noise` - `v0.3.0`

 - **BREAKING** **FIX**: Migrate from `RawKeyEvent` to `KeyEvent` ([#3002](https://github.com/flame-engine/flame/issues/3002)). ([330862c9](https://github.com/flame-engine/flame/commit/330862c98ecc7ed8d94e7cae0c34cd5781da0007))

#### `flame_oxygen` - `v0.2.0`

 - **BREAKING** **FIX**: Migrate from `RawKeyEvent` to `KeyEvent` ([#3002](https://github.com/flame-engine/flame/issues/3002)). ([330862c9](https://github.com/flame-engine/flame/commit/330862c98ecc7ed8d94e7cae0c34cd5781da0007))

#### `flame_spine` - `v0.2.0`

 - **BREAKING** **FIX**: Migrate from `RawKeyEvent` to `KeyEvent` ([#3002](https://github.com/flame-engine/flame/issues/3002)). ([330862c9](https://github.com/flame-engine/flame/commit/330862c98ecc7ed8d94e7cae0c34cd5781da0007))

#### `flame_splash_screen` - `v0.3.0`

 - **BREAKING** **FIX**: Migrate from `RawKeyEvent` to `KeyEvent` ([#3002](https://github.com/flame-engine/flame/issues/3002)). ([330862c9](https://github.com/flame-engine/flame/commit/330862c98ecc7ed8d94e7cae0c34cd5781da0007))

#### `jenny` - `v1.3.0`

 - **FEAT**: Add new methods to CommandStorage to support more arguments ([#3035](https://github.com/flame-engine/flame/issues/3035)). ([21922620](https://github.com/flame-engine/flame/commit/219226201a8d0c6e301c388299277be95b585c0e))


## 2024-02-11

### Changes

---

Packages with breaking changes:

 - There are no breaking changes in this release.

Packages with other changes:

 - [`flame_svg` - `v1.9.0`](#flame_svg---v190)

---

#### `flame_svg` - `v1.9.0`

 - **FEAT**: Add `loadFromString` to Svg class ([#3030](https://github.com/flame-engine/flame/issues/3030)). ([b0cafb2a](https://github.com/flame-engine/flame/commit/b0cafb2a5561de136af93eb7a09df37b93d38ce0))


## 2024-02-07

### Changes

---

Packages with breaking changes:

 - [`flame_noise` - `v0.2.0`](#flame_noise---v020)
 - [`flame_texturepacker` - `v3.0.0`](#flame_texturepacker---v300)

Packages with other changes:

 - [`flame` - `v1.15.0`](#flame---v1150)
 - [`flame_isolate` - `v0.5.1`](#flame_isolate---v051)
 - [`flame_riverpod` - `v5.2.0`](#flame_riverpod---v520)
 - [`flame_test` - `v1.15.4`](#flame_test---v1154)
 - [`flame_oxygen` - `v0.1.9+8`](#flame_oxygen---v0198)
 - [`flame_tiled` - `v1.18.4`](#flame_tiled---v1184)
 - [`flame_fire_atlas` - `v1.4.8`](#flame_fire_atlas---v148)
 - [`flame_audio` - `v2.1.8`](#flame_audio---v218)
 - [`flame_spine` - `v0.1.1+10`](#flame_spine---v01110)
 - [`flame_bloc` - `v1.10.10`](#flame_bloc---v11010)
 - [`flame_rive` - `v1.9.11`](#flame_rive---v1911)
 - [`flame_lottie` - `v0.3.0+8`](#flame_lottie---v0308)
 - [`flame_markdown` - `v0.1.1+8`](#flame_markdown---v0118)
 - [`flame_forge2d` - `v0.16.0+5`](#flame_forge2d---v01605)
 - [`flame_svg` - `v1.8.10`](#flame_svg---v1810)
 - [`flame_network_assets` - `v0.2.0+13`](#flame_network_assets---v02013)

Packages with dependency updates only:

> Packages listed below depend on other packages in this workspace that have had changes. Their versions have been incremented to bump the minimum dependency versions of the packages they depend upon in this project.

 - `flame_oxygen` - `v0.1.9+8`
 - `flame_tiled` - `v1.18.4`
 - `flame_fire_atlas` - `v1.4.8`
 - `flame_audio` - `v2.1.8`
 - `flame_spine` - `v0.1.1+10`
 - `flame_bloc` - `v1.10.10`
 - `flame_rive` - `v1.9.11`
 - `flame_lottie` - `v0.3.0+8`
 - `flame_markdown` - `v0.1.1+8`
 - `flame_forge2d` - `v0.16.0+5`
 - `flame_svg` - `v1.8.10`
 - `flame_network_assets` - `v0.2.0+13`

---

#### `flame_noise` - `v0.2.0`

 - **BREAKING** **FEAT**: Update flame_noise to use latest version of fast_noise ([#3015](https://github.com/flame-engine/flame/issues/3015)). ([2fd84c84](https://github.com/flame-engine/flame/commit/2fd84c846f808bf593ef568150ffb49eecaebf30))

#### `flame_texturepacker` - `v3.0.0`

 - **REFACTOR**: Update `flame_texturepacker`'s file structure ([#3014](https://github.com/flame-engine/flame/issues/3014)). ([982f2263](https://github.com/flame-engine/flame/commit/982f2263daae882fb456e750298c874b77c5471b))
 - **FEAT**: TexturePacker atlas can be generated from device's file ([#3006](https://github.com/flame-engine/flame/issues/3006)). ([4e6968a0](https://github.com/flame-engine/flame/commit/4e6968a05c659aae09e9f613870c6e5b326f4b44))
 - **BREAKING** **FEAT**: Transfer flame_texturepacker to monorepo ([#2987](https://github.com/flame-engine/flame/issues/2987)). ([45c87ddf](https://github.com/flame-engine/flame/commit/45c87ddfb668b035f095cdc17f1a4b7662a3ae11))

#### `flame` - `v1.15.0`

 - **REFACTOR**: Minimize `Vector2` creation in `IsometricTileMapComponent` ([#3018](https://github.com/flame-engine/flame/issues/3018)). ([5d3be313](https://github.com/flame-engine/flame/commit/5d3be3137a177c8900158fce10cffc01f729ed7a))
 - **FIX**: Set margins of `JoystickComponent` properly ([#3019](https://github.com/flame-engine/flame/issues/3019)). ([e27818d8](https://github.com/flame-engine/flame/commit/e27818d8721c577507411fca085859335206391f))
 - **FIX**: Properly update sprites in SpriteButtonComponent ([#3013](https://github.com/flame-engine/flame/issues/3013)). ([23cf8b9d](https://github.com/flame-engine/flame/commit/23cf8b9de81cade9ce90b8401c39432bc70f9d0d))
 - **FIX**: Lifecycle completers to be called for FlameGame ([#3007](https://github.com/flame-engine/flame/issues/3007)). ([3804f524](https://github.com/flame-engine/flame/commit/3804f52434cf1bcaf28b501bf96858ecd3636164))
 - **FIX**: CameraComponent no longer throws Concurrent modification on stop ([#2997](https://github.com/flame-engine/flame/issues/2997)). ([6a1059b0](https://github.com/flame-engine/flame/commit/6a1059b0a6e381020cdaa7a96ceecbcaa45b9a42))
 - **FIX**: Updated PolygonComponent.containsPoint to account for concave polygons ([#2979](https://github.com/flame-engine/flame/issues/2979)). ([a6fe62a2](https://github.com/flame-engine/flame/commit/a6fe62a2c3b74d9b4781531e0c53470b6d3242ea))
 - **FIX**: Add missing generic to `ComponentViewportMargin` ([#2983](https://github.com/flame-engine/flame/issues/2983)). ([1d9fe613](https://github.com/flame-engine/flame/commit/1d9fe6139287b984a05e0056c279b9c5d277e026))
 - **FEAT**: Add support for base64 encoded images to be manually added to Images cache. ([#3008](https://github.com/flame-engine/flame/issues/3008)). ([1e56293c](https://github.com/flame-engine/flame/commit/1e56293c1f89e7636c97b0ed518642bd493d7a40))
 - **FEAT**: Make `Component.key` public ([#2988](https://github.com/flame-engine/flame/issues/2988)). ([7fbd5af9](https://github.com/flame-engine/flame/commit/7fbd5af935211264822f89bc1beb4062d3efdf7a))
 - **FEAT**: Add a hitboxFilter argument to raycast() ([#2968](https://github.com/flame-engine/flame/issues/2968)). ([d7c53e23](https://github.com/flame-engine/flame/commit/d7c53e230f32b4b224e23483d99b0b276d14686f))

#### `flame_isolate` - `v0.5.1`

 - **FEAT**: Bumped integral_isolates package for flame_isolate ([#2994](https://github.com/flame-engine/flame/issues/2994)). ([3c38ee60](https://github.com/flame-engine/flame/commit/3c38ee6058e7c8b7546c3fcdb1b08e3e40ba138b))

#### `flame_riverpod` - `v5.2.0`

 - **FIX**: Add Template param to RiverpodGameMixin ([#2972](https://github.com/flame-engine/flame/issues/2972)). ([622c8553](https://github.com/flame-engine/flame/commit/622c855318b6c1731891b023ddc6429ba1f32329))
 - **FEAT**: Make `Component.key` public ([#2988](https://github.com/flame-engine/flame/issues/2988)). ([7fbd5af9](https://github.com/flame-engine/flame/commit/7fbd5af935211264822f89bc1beb4062d3efdf7a))

#### `flame_test` - `v1.15.4`

 - **FIX**: Lifecycle completers to be called for FlameGame ([#3007](https://github.com/flame-engine/flame/issues/3007)). ([3804f524](https://github.com/flame-engine/flame/commit/3804f52434cf1bcaf28b501bf96858ecd3636164))


## 2024-01-07

### Changes

---

Packages with breaking changes:

 - There are no breaking changes in this release.

Packages with other changes:

 - [`flame_riverpod` - `v5.1.5`](#flame_riverpod---v515)

---

#### `flame_riverpod` - `v5.1.5`

 - **FIX**: Change return type of RiverpodComponentMixin.onLoad to FutureOr<void> ([#2964](https://github.com/flame-engine/flame/issues/2964)). ([7ac80a78](https://github.com/flame-engine/flame/commit/7ac80a78e95b06bb1287fb74773634483d80b1c9))


## 2024-01-04

### Changes

---

Packages with breaking changes:

 - [`flame` - `v1.14.0`](#flame---v1140)

Packages with other changes:

 - [`flame_forge2d` - `v0.16.0+4`](#flame_forge2d---v01604)
 - [`flame_test` - `v1.15.3`](#flame_test---v1153)
 - [`flame_tiled` - `v1.18.3`](#flame_tiled---v1183)
 - [`flame_oxygen` - `v0.1.9+7`](#flame_oxygen---v0197)
 - [`flame_isolate` - `v0.5.0+7`](#flame_isolate---v0507)
 - [`flame_fire_atlas` - `v1.4.7`](#flame_fire_atlas---v147)
 - [`flame_audio` - `v2.1.7`](#flame_audio---v217)
 - [`flame_spine` - `v0.1.1+9`](#flame_spine---v0119)
 - [`flame_bloc` - `v1.10.9`](#flame_bloc---v1109)
 - [`flame_lottie` - `v0.3.0+7`](#flame_lottie---v0307)
 - [`flame_markdown` - `v0.1.1+7`](#flame_markdown---v0117)
 - [`flame_rive` - `v1.9.10`](#flame_rive---v1910)
 - [`flame_noise` - `v0.1.1+12`](#flame_noise---v01112)
 - [`flame_riverpod` - `v5.1.4`](#flame_riverpod---v514)
 - [`flame_svg` - `v1.8.9`](#flame_svg---v189)
 - [`flame_network_assets` - `v0.2.0+12`](#flame_network_assets---v02012)

Packages with dependency updates only:

> Packages listed below depend on other packages in this workspace that have had changes. Their versions have been incremented to bump the minimum dependency versions of the packages they depend upon in this project.

 - `flame_test` - `v1.15.3`
 - `flame_tiled` - `v1.18.3`
 - `flame_oxygen` - `v0.1.9+7`
 - `flame_isolate` - `v0.5.0+7`
 - `flame_fire_atlas` - `v1.4.7`
 - `flame_audio` - `v2.1.7`
 - `flame_spine` - `v0.1.1+9`
 - `flame_bloc` - `v1.10.9`
 - `flame_lottie` - `v0.3.0+7`
 - `flame_markdown` - `v0.1.1+7`
 - `flame_rive` - `v1.9.10`
 - `flame_noise` - `v0.1.1+12`
 - `flame_riverpod` - `v5.1.4`
 - `flame_svg` - `v1.8.9`
 - `flame_network_assets` - `v0.2.0+12`

---

#### `flame` - `v1.14.0`

 - **FIX**: Set hitbox `debugColor` to yellow ([#2958](https://github.com/flame-engine/flame/issues/2958)). ([6858eae0](https://github.com/flame-engine/flame/commit/6858eae0766225bb7c940c2aa453459063f7d514))
 - **FIX**: Consider displaced hitboxes in GestureHitboxes mixin ([#2957](https://github.com/flame-engine/flame/issues/2957)). ([1085518f](https://github.com/flame-engine/flame/commit/1085518fe279e674bef9a7b938d59926472511f3))
 - **FIX**: PolygonComponent.containsLocalPoint to use anchor ([#2953](https://github.com/flame-engine/flame/issues/2953)). ([7969321e](https://github.com/flame-engine/flame/commit/7969321e8662515aa9efe305831ff36d51dd43cb))
 - **FEAT**: Notifier for changing current sprite/animation in group components ([#2956](https://github.com/flame-engine/flame/issues/2956)). ([75cf2390](https://github.com/flame-engine/flame/commit/75cf23908e5d509a25cd794d6810162f22b978cb))
 - **BREAKING** **REFACTOR**: Remove the Projector interface that is no longer used for coordinate transformations ([#2955](https://github.com/flame-engine/flame/issues/2955)). ([0979dc97](https://github.com/flame-engine/flame/commit/0979dc97f54af1b71b200ced609d874d390c1ca6))

#### `flame_forge2d` - `v0.16.0+4`

 - **FIX**: Wake up bodies on gravity change ([#2954](https://github.com/flame-engine/flame/issues/2954)). ([4f58329c](https://github.com/flame-engine/flame/commit/4f58329ceacef84d91cd41019d72bc2351bc50cd))


## 2023-12-22

### Changes

---

Packages with breaking changes:

 - There are no breaking changes in this release.

Packages with other changes:

 - [`flame_riverpod` - `v5.1.3`](#flame_riverpod---v513)

---

#### `flame_riverpod` - `v5.1.3`

 - **FIX**: Fix logic inside flame_riverpod persistent frame callback. ([#2950](https://github.com/flame-engine/flame/issues/2950)). ([230fb88f](https://github.com/flame-engine/flame/commit/230fb88fa9f9d82711461d10fe4aff9f8520cd29))


## 2023-12-21

### Changes

---

Packages with breaking changes:

 - There are no breaking changes in this release.

Packages with other changes:

 - [`flame` - `v1.13.1`](#flame---v1131)
 - [`flame_riverpod` - `v5.1.2`](#flame_riverpod---v512)
 - [`flame_test` - `v1.15.3`](#flame_test---v1153)
 - [`flame_tiled` - `v1.18.3`](#flame_tiled---v1183)
 - [`flame_oxygen` - `v0.1.9+7`](#flame_oxygen---v0197)
 - [`flame_isolate` - `v0.5.0+7`](#flame_isolate---v0507)
 - [`flame_fire_atlas` - `v1.4.7`](#flame_fire_atlas---v147)
 - [`flame_audio` - `v2.1.7`](#flame_audio---v217)
 - [`flame_spine` - `v0.1.1+9`](#flame_spine---v0119)
 - [`flame_bloc` - `v1.10.9`](#flame_bloc---v1109)
 - [`flame_lottie` - `v0.3.0+7`](#flame_lottie---v0307)
 - [`flame_markdown` - `v0.1.1+7`](#flame_markdown---v0117)
 - [`flame_rive` - `v1.9.10`](#flame_rive---v1910)
 - [`flame_forge2d` - `v0.16.0+4`](#flame_forge2d---v01604)
 - [`flame_noise` - `v0.1.1+12`](#flame_noise---v01112)
 - [`flame_svg` - `v1.8.9`](#flame_svg---v189)
 - [`flame_network_assets` - `v0.2.0+12`](#flame_network_assets---v02012)

Packages with dependency updates only:

> Packages listed below depend on other packages in this workspace that have had changes. Their versions have been incremented to bump the minimum dependency versions of the packages they depend upon in this project.

 - `flame_test` - `v1.15.3`
 - `flame_tiled` - `v1.18.3`
 - `flame_oxygen` - `v0.1.9+7`
 - `flame_isolate` - `v0.5.0+7`
 - `flame_fire_atlas` - `v1.4.7`
 - `flame_audio` - `v2.1.7`
 - `flame_spine` - `v0.1.1+9`
 - `flame_bloc` - `v1.10.9`
 - `flame_lottie` - `v0.3.0+7`
 - `flame_markdown` - `v0.1.1+7`
 - `flame_rive` - `v1.9.10`
 - `flame_forge2d` - `v0.16.0+4`
 - `flame_noise` - `v0.1.1+12`
 - `flame_svg` - `v1.8.9`
 - `flame_network_assets` - `v0.2.0+12`

---

#### `flame` - `v1.13.1`

 - **FIX**: The `visibleGameSize` should be based on `viewport.virtualSize` ([#2945](https://github.com/flame-engine/flame/issues/2945)). ([bd130b71](https://github.com/flame-engine/flame/commit/bd130b711b5cb486b8f05225711c6e6c3fe574e6))
 - **FEAT**: Adding ability for a SpawnComponent to not auto start ([#2947](https://github.com/flame-engine/flame/issues/2947)). ([37c7a075](https://github.com/flame-engine/flame/commit/37c7a075a37cfc7c298f02542715b18e87f4cf99))

#### `flame_riverpod` - `v5.1.2`

 - **FIX**: Package flame_riverpod, setState() or markNeedsBuild() called during build. ([#2943](https://github.com/flame-engine/flame/issues/2943)). ([54d0e95d](https://github.com/flame-engine/flame/commit/54d0e95d863cc40e95f0310b4964343085f422e9))


## 2023-12-19

### Changes

---

Packages with breaking changes:

 - There are no breaking changes in this release.

Packages with other changes:

 - [`flame` - `v1.13.0`](#flame---v1130)
 - [`flame_rive` - `v1.9.9`](#flame_rive---v199)
 - [`flame_riverpod` - `v5.1.1`](#flame_riverpod---v511)
 - [`flame_tiled` - `v1.18.2`](#flame_tiled---v1182)
 - [`flame_test` - `v1.15.2`](#flame_test---v1152)
 - [`flame_oxygen` - `v0.1.9+6`](#flame_oxygen---v0196)
 - [`flame_isolate` - `v0.5.0+6`](#flame_isolate---v0506)
 - [`flame_fire_atlas` - `v1.4.6`](#flame_fire_atlas---v146)
 - [`flame_audio` - `v2.1.6`](#flame_audio---v216)
 - [`flame_spine` - `v0.1.1+8`](#flame_spine---v0118)
 - [`flame_bloc` - `v1.10.8`](#flame_bloc---v1108)
 - [`flame_lottie` - `v0.3.0+6`](#flame_lottie---v0306)
 - [`flame_markdown` - `v0.1.1+6`](#flame_markdown---v0116)
 - [`flame_svg` - `v1.8.8`](#flame_svg---v188)
 - [`flame_forge2d` - `v0.16.0+3`](#flame_forge2d---v01603)
 - [`flame_noise` - `v0.1.1+11`](#flame_noise---v01111)
 - [`flame_network_assets` - `v0.2.0+11`](#flame_network_assets---v02011)

Packages with dependency updates only:

> Packages listed below depend on other packages in this workspace that have had changes. Their versions have been incremented to bump the minimum dependency versions of the packages they depend upon in this project.

 - `flame_test` - `v1.15.2`
 - `flame_oxygen` - `v0.1.9+6`
 - `flame_isolate` - `v0.5.0+6`
 - `flame_fire_atlas` - `v1.4.6`
 - `flame_audio` - `v2.1.6`
 - `flame_spine` - `v0.1.1+8`
 - `flame_bloc` - `v1.10.8`
 - `flame_lottie` - `v0.3.0+6`
 - `flame_markdown` - `v0.1.1+6`
 - `flame_svg` - `v1.8.8`
 - `flame_forge2d` - `v0.16.0+3`
 - `flame_noise` - `v0.1.1+11`
 - `flame_network_assets` - `v0.2.0+11`

---

#### `flame` - `v1.13.0`

 - **FIX**: Logic error in MemoryCache.setValue() ([#2931](https://github.com/flame-engine/flame/issues/2931)). ([8cee80c3](https://github.com/flame-engine/flame/commit/8cee80c35ca676ad25a25c771f0aade88b58150b))
 - **FIX**: Export `ScalingParticle` ([#2928](https://github.com/flame-engine/flame/issues/2928)). ([3730cb1d](https://github.com/flame-engine/flame/commit/3730cb1d834c73c87dc3597554039fd0f0a32bae))
 - **FIX**: Misalignment of the hittest area of PolygonHitbox ([#2930](https://github.com/flame-engine/flame/issues/2930)). ([dbdb1379](https://github.com/flame-engine/flame/commit/dbdb1379d0bc1b6ac02b3ee27f62263bd1be3fc3))
 - **FIX**: Allow setting `bounds` while `BoundedPositionBehavior`'s target is null ([#2926](https://github.com/flame-engine/flame/issues/2926)). ([bab9be6e](https://github.com/flame-engine/flame/commit/bab9be6e7051b7be6c84fc9760c7347692dbf140))
 - **FEAT**: Ability to use `selfPositioning` in `SpawnComponent` ([#2927](https://github.com/flame-engine/flame/issues/2927)). ([b526aa14](https://github.com/flame-engine/flame/commit/b526aa1488c0f891edb356007ebc2c5c2de596b5))
 - **FEAT**: Add `margin` and `spacing` properties to `SpriteSheet` ([#2925](https://github.com/flame-engine/flame/issues/2925)). ([67f7c126](https://github.com/flame-engine/flame/commit/67f7c126b4c8052df99ffa8c657a90cc7fb6f867))
 - **FEAT**: Add `children` to `SpriteAnimationComponent.fromFrameData` ([#2914](https://github.com/flame-engine/flame/issues/2914)). ([caf2b909](https://github.com/flame-engine/flame/commit/caf2b90930ca500c85b9f9f63e7d3d7a5d82c18e))
 - **DOCS**: Remove references to Tappable and Draggable ([#2912](https://github.com/flame-engine/flame/issues/2912)). ([d12e4544](https://github.com/flame-engine/flame/commit/d12e45444e49bbe0b24a7acbd24f0cda20a13755))

#### `flame_rive` - `v1.9.9`

 - **DOCS**: Remove references to Tappable and Draggable ([#2912](https://github.com/flame-engine/flame/issues/2912)). ([d12e4544](https://github.com/flame-engine/flame/commit/d12e45444e49bbe0b24a7acbd24f0cda20a13755))

#### `flame_riverpod` - `v5.1.1`

 - **FIX**: Add super constructor fields to RiverpodAwareGameWidget ([#2932](https://github.com/flame-engine/flame/issues/2932)). ([c2e6ea71](https://github.com/flame-engine/flame/commit/c2e6ea71e5c3c5f0d7ae6bc01a6c2f1f4d4d563b))

#### `flame_tiled` - `v1.18.2`

 - **FIX**: Image layers repeat indefinitely if repeated in Tiled ([#2921](https://github.com/flame-engine/flame/issues/2921)). ([6f79bc5e](https://github.com/flame-engine/flame/commit/6f79bc5ef920ace17d09c88156a73043357d514f))


## 2023-12-08

### Changes

---

Packages with breaking changes:

 - There are no breaking changes in this release.

Packages with other changes:

 - [`flame` - `v1.12.0`](#flame---v1120)
 - [`flame_riverpod` - `v5.1.0`](#flame_riverpod---v510)
 - [`flame_test` - `v1.15.1`](#flame_test---v1151)
 - [`flame_tiled` - `v1.18.1`](#flame_tiled---v1181)
 - [`flame_oxygen` - `v0.1.9+5`](#flame_oxygen---v0195)
 - [`flame_isolate` - `v0.5.0+5`](#flame_isolate---v0505)
 - [`flame_fire_atlas` - `v1.4.5`](#flame_fire_atlas---v145)
 - [`flame_audio` - `v2.1.5`](#flame_audio---v215)
 - [`flame_spine` - `v0.1.1+7`](#flame_spine---v0117)
 - [`flame_bloc` - `v1.10.7`](#flame_bloc---v1107)
 - [`flame_lottie` - `v0.3.0+5`](#flame_lottie---v0305)
 - [`flame_markdown` - `v0.1.1+5`](#flame_markdown---v0115)
 - [`flame_rive` - `v1.9.8`](#flame_rive---v198)
 - [`flame_forge2d` - `v0.16.0+2`](#flame_forge2d---v01602)
 - [`flame_noise` - `v0.1.1+10`](#flame_noise---v01110)
 - [`flame_svg` - `v1.8.7`](#flame_svg---v187)
 - [`flame_network_assets` - `v0.2.0+10`](#flame_network_assets---v02010)

Packages with dependency updates only:

> Packages listed below depend on other packages in this workspace that have had changes. Their versions have been incremented to bump the minimum dependency versions of the packages they depend upon in this project.

 - `flame_test` - `v1.15.1`
 - `flame_tiled` - `v1.18.1`
 - `flame_oxygen` - `v0.1.9+5`
 - `flame_isolate` - `v0.5.0+5`
 - `flame_fire_atlas` - `v1.4.5`
 - `flame_audio` - `v2.1.5`
 - `flame_spine` - `v0.1.1+7`
 - `flame_bloc` - `v1.10.7`
 - `flame_lottie` - `v0.3.0+5`
 - `flame_markdown` - `v0.1.1+5`
 - `flame_rive` - `v1.9.8`
 - `flame_forge2d` - `v0.16.0+2`
 - `flame_noise` - `v0.1.1+10`
 - `flame_svg` - `v1.8.7`
 - `flame_network_assets` - `v0.2.0+10`

---

#### `flame` - `v1.12.0`

 - **FIX**: SpriteAnimationWidget was resetting the ticker even when the playing didn't changed ([#2891](https://github.com/flame-engine/flame/issues/2891)). ([9aed8b4d](https://github.com/flame-engine/flame/commit/9aed8b4dea3074c9ca708ad991cdc90b12707fbe))
 - **FEAT**: Scrollable TextBoxComponent ([#2901](https://github.com/flame-engine/flame/issues/2901)). ([8c3cb725](https://github.com/flame-engine/flame/commit/8c3cb725413c46089854713f6ecc4617e1f15600))
 - **FEAT**: Add collision completed listener ([#2896](https://github.com/flame-engine/flame/issues/2896)). ([957db3c1](https://github.com/flame-engine/flame/commit/957db3c1ed476b22f7cc62d4df22595449f8756c))
 - **FEAT**: Adding autoResetTicker option to SpriteAnimationGroupComponent ([#2899](https://github.com/flame-engine/flame/issues/2899)). ([001c870d](https://github.com/flame-engine/flame/commit/001c870d61be6e7e7aae798df0dc33e5321ed882))
 - **FEAT**: Add clearSnapshot function ([#2897](https://github.com/flame-engine/flame/issues/2897)). ([d4decd21](https://github.com/flame-engine/flame/commit/d4decd21eb7506ffd6d84ab5a3ebf1f2067083b6))

#### `flame_riverpod` - `v5.1.0`

 - **FIX**: SpriteAnimationWidget was resetting the ticker even when the playing didn't changed ([#2891](https://github.com/flame-engine/flame/issues/2891)). ([9aed8b4d](https://github.com/flame-engine/flame/commit/9aed8b4dea3074c9ca708ad991cdc90b12707fbe))
 - **FEAT**: Integration of flame_riverpod ([#2367](https://github.com/flame-engine/flame/issues/2367)). ([0c74560b](https://github.com/flame-engine/flame/commit/0c74560b2e25e86163c6c678ef6515bc11f9c3e7))


## 2023-11-30

### Changes

---

Packages with breaking changes:

 - [`flame` - `v1.11.0`](#flame---v1110)

Packages with other changes:

 - [`flame_audio` - `v2.1.4`](#flame_audio---v214)
 - [`flame_bloc` - `v1.10.6`](#flame_bloc---v1106)
 - [`flame_fire_atlas` - `v1.4.4`](#flame_fire_atlas---v144)
 - [`flame_isolate` - `v0.5.0+4`](#flame_isolate---v0504)
 - [`flame_lint` - `v1.1.2`](#flame_lint---v112)
 - [`flame_markdown` - `v0.1.1+4`](#flame_markdown---v0114)
 - [`flame_network_assets` - `v0.2.0+9`](#flame_network_assets---v0209)
 - [`flame_noise` - `v0.1.1+9`](#flame_noise---v0119)
 - [`flame_oxygen` - `v0.1.9+4`](#flame_oxygen---v0194)
 - [`flame_rive` - `v1.9.7`](#flame_rive---v197)
 - [`flame_spine` - `v0.1.1+6`](#flame_spine---v0116)
 - [`flame_svg` - `v1.8.6`](#flame_svg---v186)
 - [`flame_test` - `v1.15.0`](#flame_test---v1150)
 - [`flame_tiled` - `v1.18.0`](#flame_tiled---v1180)
 - [`jenny` - `v1.2.1`](#jenny---v121)
 - [`flame_lottie` - `v0.3.0+4`](#flame_lottie---v0304)
 - [`flame_forge2d` - `v0.16.0+1`](#flame_forge2d---v01601)

Packages with dependency updates only:

> Packages listed below depend on other packages in this workspace that have had changes. Their versions have been incremented to bump the minimum dependency versions of the packages they depend upon in this project.

 - `flame_lottie` - `v0.3.0+4`
 - `flame_forge2d` - `v0.16.0+1`

---

#### `flame` - `v1.11.0`

 - **FIX**: Minor issues due Flutter 3.16 ([#2856](https://github.com/flame-engine/flame/issues/2856)). ([d51cd584](https://github.com/flame-engine/flame/commit/d51cd584c71a27c242c2f4600282cf8359daaa17))
 - **FIX**: Properly resize ScreenHitbox when needed ([#2826](https://github.com/flame-engine/flame/issues/2826)). ([24fed757](https://github.com/flame-engine/flame/commit/24fed757ac313453639ddf122ba84b1012a4b606))
 - **FIX**: Setting world on FlameGame camera setter ([#2831](https://github.com/flame-engine/flame/issues/2831)). ([3a8e2464](https://github.com/flame-engine/flame/commit/3a8e2464420f2b513f4f0d99cd7d64ab0eda9826))
 - **FIX**: Allow null passthrough parent ([#2821](https://github.com/flame-engine/flame/issues/2821)). ([c4d2f86e](https://github.com/flame-engine/flame/commit/c4d2f86e1214e9895ff858c511fa3c686313f204))
 - **FIX**: Do not scale debug texts with zoom ([#2818](https://github.com/flame-engine/flame/issues/2818)). ([c2f3f040](https://github.com/flame-engine/flame/commit/c2f3f040c6128d8fd3340d8f7622a2d4c2f22819))
 - **FIX**(flame): Export `FixedResolutionViewport` and make `withFixedResolution` a redirect constructor ([#2817](https://github.com/flame-engine/flame/issues/2817)). ([3420d0e6](https://github.com/flame-engine/flame/commit/3420d0e6f8af6f2dd8695ea61231aa93944c602b))
 - **FEAT**: Using viewport scale on debug mode text paint ([#2883](https://github.com/flame-engine/flame/issues/2883)). ([07ef46ca](https://github.com/flame-engine/flame/commit/07ef46cab01ae08749e678211245896572bb1081))
 - **FEAT**: Make Viewfinder and Viewport comply with CoordinateTransform interface ([#2872](https://github.com/flame-engine/flame/issues/2872)). ([685e1d95](https://github.com/flame-engine/flame/commit/685e1d9529df90f203e7827950ed5d9261b2ce42))
 - **FEAT**: Allow sequence effect to be extended ([#2864](https://github.com/flame-engine/flame/issues/2864)). ([ee11aae9](https://github.com/flame-engine/flame/commit/ee11aae9f519fdb967eb384aaffdb5a6f87a808f))
 - **FEAT**: Adding children argument to all constructors in the shape components ([#2862](https://github.com/flame-engine/flame/issues/2862)). ([082743d3](https://github.com/flame-engine/flame/commit/082743d3ba0860a87a58377a7b5a9cd6b5ae7c70))
 - **FEAT**: Optimization in sprite batch ([#2861](https://github.com/flame-engine/flame/issues/2861)). ([208d7897](https://github.com/flame-engine/flame/commit/208d7897f1e9e512f0bc235233e41e1953a8d546))
 - **FEAT**: Add TimeTrackComponent and ChildCounterComponent ([#2846](https://github.com/flame-engine/flame/issues/2846)). ([6269551a](https://github.com/flame-engine/flame/commit/6269551a77cfbc27094e262c131dec09e489e583))
 - **FEAT**: MoveAlongPathEffect should maintain initial angle of the component ([#2835](https://github.com/flame-engine/flame/issues/2835)). ([e6e78c0d](https://github.com/flame-engine/flame/commit/e6e78c0d66bc958dbe1c2295a7cc946dc5852455))
 - **FEAT**: Add a method to adapt the camera bounds to the world ([#2769](https://github.com/flame-engine/flame/issues/2769)). ([87b69df6](https://github.com/flame-engine/flame/commit/87b69df6a1d29261a514a7ee7d28d2d1f730920e))
 - **FEAT**: Scaling particle feature ([#2830](https://github.com/flame-engine/flame/issues/2830)). ([9faae8a2](https://github.com/flame-engine/flame/commit/9faae8a2371efdcbdf03cad70bded05470d4719a))
 - **BREAKING** **REFACTOR**: Replace `Offset` with `opacityFrom` and `opacityTo` in ColorEffect ([#2876](https://github.com/flame-engine/flame/issues/2876)). ([0fd2662d](https://github.com/flame-engine/flame/commit/0fd2662d4b1187285ee168271a38e1576b6e444a))
 - **BREAKING** **FIX**: Add DisplacementEvent to fix delta coordinate transformations for drag events ([#2871](https://github.com/flame-engine/flame/issues/2871)). ([63994ebc](https://github.com/flame-engine/flame/commit/63994ebcd8e850f68622f4a89ea17224574a8214))

#### `flame_audio` - `v2.1.4`

 - **FIX**: Minor issues due Flutter 3.16 ([#2856](https://github.com/flame-engine/flame/issues/2856)). ([d51cd584](https://github.com/flame-engine/flame/commit/d51cd584c71a27c242c2f4600282cf8359daaa17))

#### `flame_bloc` - `v1.10.6`

 - **FIX**: Minor issues due Flutter 3.16 ([#2856](https://github.com/flame-engine/flame/issues/2856)). ([d51cd584](https://github.com/flame-engine/flame/commit/d51cd584c71a27c242c2f4600282cf8359daaa17))

#### `flame_fire_atlas` - `v1.4.4`

 - **FIX**: Minor issues due Flutter 3.16 ([#2856](https://github.com/flame-engine/flame/issues/2856)). ([d51cd584](https://github.com/flame-engine/flame/commit/d51cd584c71a27c242c2f4600282cf8359daaa17))

#### `flame_isolate` - `v0.5.0+4`

 - **DOCS**: Update flame_isolate to point at repository ([#2880](https://github.com/flame-engine/flame/issues/2880)). ([06fdeac6](https://github.com/flame-engine/flame/commit/06fdeac684b2be26206d50282e6a7f2cbac4264c))

#### `flame_lint` - `v1.1.2`

 - **FIX**: Minor issues due Flutter 3.16 ([#2856](https://github.com/flame-engine/flame/issues/2856)). ([d51cd584](https://github.com/flame-engine/flame/commit/d51cd584c71a27c242c2f4600282cf8359daaa17))

#### `flame_markdown` - `v0.1.1+4`

 - **FIX**: Minor issues due Flutter 3.16 ([#2856](https://github.com/flame-engine/flame/issues/2856)). ([d51cd584](https://github.com/flame-engine/flame/commit/d51cd584c71a27c242c2f4600282cf8359daaa17))

#### `flame_network_assets` - `v0.2.0+9`

 - **FIX**: Minor issues due Flutter 3.16 ([#2856](https://github.com/flame-engine/flame/issues/2856)). ([d51cd584](https://github.com/flame-engine/flame/commit/d51cd584c71a27c242c2f4600282cf8359daaa17))

#### `flame_noise` - `v0.1.1+9`

 - **FIX**: Minor issues due Flutter 3.16 ([#2856](https://github.com/flame-engine/flame/issues/2856)). ([d51cd584](https://github.com/flame-engine/flame/commit/d51cd584c71a27c242c2f4600282cf8359daaa17))

#### `flame_oxygen` - `v0.1.9+4`

 - **FIX**: Minor issues due Flutter 3.16 ([#2856](https://github.com/flame-engine/flame/issues/2856)). ([d51cd584](https://github.com/flame-engine/flame/commit/d51cd584c71a27c242c2f4600282cf8359daaa17))

#### `flame_rive` - `v1.9.7`

 - **FIX**: Minor issues due Flutter 3.16 ([#2856](https://github.com/flame-engine/flame/issues/2856)). ([d51cd584](https://github.com/flame-engine/flame/commit/d51cd584c71a27c242c2f4600282cf8359daaa17))

#### `flame_spine` - `v0.1.1+6`

 - **FIX**: Removing spine flutter overriding ([#2877](https://github.com/flame-engine/flame/issues/2877)). ([f4ff3117](https://github.com/flame-engine/flame/commit/f4ff31174a0498dd8af90f815ad9c098df3b30b7))
 - **FIX**: Minor issues due Flutter 3.16 ([#2856](https://github.com/flame-engine/flame/issues/2856)). ([d51cd584](https://github.com/flame-engine/flame/commit/d51cd584c71a27c242c2f4600282cf8359daaa17))

#### `flame_svg` - `v1.8.6`

 - **FIX**: Minor issues due Flutter 3.16 ([#2856](https://github.com/flame-engine/flame/issues/2856)). ([d51cd584](https://github.com/flame-engine/flame/commit/d51cd584c71a27c242c2f4600282cf8359daaa17))

#### `flame_test` - `v1.15.0`

 - **FIX**: Minor issues due Flutter 3.16 ([#2856](https://github.com/flame-engine/flame/issues/2856)). ([d51cd584](https://github.com/flame-engine/flame/commit/d51cd584c71a27c242c2f4600282cf8359daaa17))
 - **FEAT**: Expose addition test arguments on flame test ([#2832](https://github.com/flame-engine/flame/issues/2832)). ([08b4bd6d](https://github.com/flame-engine/flame/commit/08b4bd6d3f308013d18fec4eb126927239cd6481))

#### `flame_tiled` - `v1.18.0`

 - **FIX**: TiledComponent.atlases had duplicated values ([#2867](https://github.com/flame-engine/flame/issues/2867)). ([e56ad187](https://github.com/flame-engine/flame/commit/e56ad1878333ba19e0c8af3fb9c9758603662330))
 - **FIX**: Minor issues due Flutter 3.16 ([#2856](https://github.com/flame-engine/flame/issues/2856)). ([d51cd584](https://github.com/flame-engine/flame/commit/d51cd584c71a27c242c2f4600282cf8359daaa17))
 - **FEAT**: Adding configurable padding to Tiled atlas packing ([#2868](https://github.com/flame-engine/flame/issues/2868)). ([d0c10cbb](https://github.com/flame-engine/flame/commit/d0c10cbbea20415de471ad0269a22c168082b02d))
 - **FEAT**: Exposing atlases for reading in a TiledComponent ([#2865](https://github.com/flame-engine/flame/issues/2865)). ([e1b4d93a](https://github.com/flame-engine/flame/commit/e1b4d93ad43a4e1b1b55a3843e26612b73d45ed7))

#### `jenny` - `v1.2.1`

 - **FIX**: Minor issues due Flutter 3.16 ([#2856](https://github.com/flame-engine/flame/issues/2856)). ([d51cd584](https://github.com/flame-engine/flame/commit/d51cd584c71a27c242c2f4600282cf8359daaa17))


## 2023-11-15

### Changes

---

Packages with breaking changes:

 - There are no breaking changes in this release.

Packages with other changes:

 - [`flame_tiled` - `v1.17.0`](#flame_tiled---v1170)

---

#### `flame_tiled` - `v1.17.0`

 - **FIX**: Configuration useAtlas was not been propagated correctly everywhere ([#2853](https://github.com/flame-engine/flame/issues/2853)). ([2f0dab9e](https://github.com/flame-engine/flame/commit/2f0dab9e59958176e6c46f6e417188e6c4fa3831))
 - **FEAT**: Adding way to configure a layer paint in flame tiled ([#2851](https://github.com/flame-engine/flame/issues/2851)). ([e893d115](https://github.com/flame-engine/flame/commit/e893d1152c2aeb1c976668c875a1c267bbf819c0))
 - **FEAT**: Expose useAtlas on Flame Tiled ([#2852](https://github.com/flame-engine/flame/issues/2852)). ([c4efb4f8](https://github.com/flame-engine/flame/commit/c4efb4f859fe08cc7fbd3e0ddb35c806d0060c78))


## 2023-11-10

### Changes

---

Packages with breaking changes:

 - There are no breaking changes in this release.

Packages with other changes:

 - [`flame_rive` - `v1.9.6`](#flame_rive---v196)

---

#### `flame_rive` - `v1.9.6`

 - Bump to Rive 0.12.3


## 2023-11-10

### Changes

---

Packages with breaking changes:

 - There are no breaking changes in this release.

Packages with other changes:

 - [`flame_tiled` - `v1.16.0`](#flame_tiled---v1160)

---

#### `flame_tiled` - `v1.16.0`

 - **FEAT**: Allow flame tiled to skip tilesets when packing into a tile atlas ([#2847](https://github.com/flame-engine/flame/issues/2847)). ([b93bdd38](https://github.com/flame-engine/flame/commit/b93bdd38313fd273e3e4cf55f1b142969effbde4))


## 2023-11-03

### Changes

---

Packages with breaking changes:

 - There are no breaking changes in this release.

Packages with other changes:

 - [`flame_forge2d` - `v0.16.0`](#flame_forge2d---v0160)
 - [`flame` - `v1.10.1`](#flame---v1101)
 - [`flame_test` - `v1.14.0`](#flame_test---v1140)
 - [`flame_spine` - `v0.1.1+5`](#flame_spine---v0115)
 - [`flame_markdown` - `v0.1.1+3`](#flame_markdown---v0113)
 - [`flame_network_assets` - `v0.2.0+8`](#flame_network_assets---v0208)
 - [`flame_oxygen` - `v0.1.9+3`](#flame_oxygen---v0193)
 - [`flame_audio` - `v2.1.3`](#flame_audio---v213)
 - [`flame_fire_atlas` - `v1.4.3`](#flame_fire_atlas---v143)
 - [`flame_svg` - `v1.8.5`](#flame_svg---v185)
 - [`flame_lottie` - `v0.3.0+3`](#flame_lottie---v0303)
 - [`flame_isolate` - `v0.5.0+3`](#flame_isolate---v0503)
 - [`flame_noise` - `v0.1.1+8`](#flame_noise---v0118)
 - [`flame_bloc` - `v1.10.5`](#flame_bloc---v1105)
 - [`flame_rive` - `v1.9.5`](#flame_rive---v195)
 - [`flame_tiled` - `v1.15.1`](#flame_tiled---v1151)

Packages with dependency updates only:

> Packages listed below depend on other packages in this workspace that have had changes. Their versions have been incremented to bump the minimum dependency versions of the packages they depend upon in this project.

 - `flame_spine` - `v0.1.1+5`
 - `flame_markdown` - `v0.1.1+3`
 - `flame_network_assets` - `v0.2.0+8`
 - `flame_oxygen` - `v0.1.9+3`
 - `flame_audio` - `v2.1.3`
 - `flame_fire_atlas` - `v1.4.3`
 - `flame_svg` - `v1.8.5`
 - `flame_lottie` - `v0.3.0+3`
 - `flame_isolate` - `v0.5.0+3`
 - `flame_noise` - `v0.1.1+8`
 - `flame_bloc` - `v1.10.5`
 - `flame_rive` - `v1.9.5`
 - `flame_tiled` - `v1.15.1`

---

#### `flame_forge2d` - `v0.16.0`

#### `flame` - `v1.10.1`

 - **FIX**: Properly resize ScreenHitbox when needed ([#2826](https://github.com/flame-engine/flame/issues/2826)). ([24fed757](https://github.com/flame-engine/flame/commit/24fed757ac313453639ddf122ba84b1012a4b606))
 - **FIX**: Setting world on FlameGame camera setter ([#2831](https://github.com/flame-engine/flame/issues/2831)). ([3a8e2464](https://github.com/flame-engine/flame/commit/3a8e2464420f2b513f4f0d99cd7d64ab0eda9826))
 - **FIX**: Allow null passthrough parent ([#2821](https://github.com/flame-engine/flame/issues/2821)). ([c4d2f86e](https://github.com/flame-engine/flame/commit/c4d2f86e1214e9895ff858c511fa3c686313f204))
 - **FIX**: Do not scale debug texts with zoom ([#2818](https://github.com/flame-engine/flame/issues/2818)). ([c2f3f040](https://github.com/flame-engine/flame/commit/c2f3f040c6128d8fd3340d8f7622a2d4c2f22819))
 - **FIX**(flame): Export `FixedResolutionViewport` and make `withFixedResolution` a redirect constructor ([#2817](https://github.com/flame-engine/flame/issues/2817)). ([3420d0e6](https://github.com/flame-engine/flame/commit/3420d0e6f8af6f2dd8695ea61231aa93944c602b))
 - **FEAT**: Scaling particle feature ([#2830](https://github.com/flame-engine/flame/issues/2830)). ([9faae8a2](https://github.com/flame-engine/flame/commit/9faae8a2371efdcbdf03cad70bded05470d4719a))

#### `flame_test` - `v1.14.0`

 - **FEAT**: Expose addition test arguments on flame test ([#2832](https://github.com/flame-engine/flame/issues/2832)). ([08b4bd6d](https://github.com/flame-engine/flame/commit/08b4bd6d3f308013d18fec4eb126927239cd6481))


## 2023-10-17

### Changes

---

Packages with breaking changes:

 - There are no breaking changes in this release.

Packages with other changes:

 - [`jenny` - `v1.2.0`](#jenny---v120)

---

#### `jenny` - `v1.2.0`

 - **FEAT**: Added lastline before choice ([#2822](https://github.com/flame-engine/flame/issues/2822)). ([3ef52524](https://github.com/flame-engine/flame/commit/3ef525246a0d3b1d02c470b5696164e677cdb6c4))


## 2023-10-12

### Changes

---

Packages with breaking changes:

 - There are no breaking changes in this release.

Packages with other changes:

 - [`flame` - `v1.10.0`](#flame---v1100)
 - [`flame_audio` - `v2.1.2`](#flame_audio---v212)
 - [`flame_bloc` - `v1.10.4`](#flame_bloc---v1104)
 - [`flame_fire_atlas` - `v1.4.2`](#flame_fire_atlas---v142)
 - [`flame_forge2d` - `v0.15.1`](#flame_forge2d---v0151)
 - [`flame_isolate` - `v0.5.0+2`](#flame_isolate---v0502)
 - [`flame_lottie` - `v0.3.0+2`](#flame_lottie---v0302)
 - [`flame_network_assets` - `v0.2.0+7`](#flame_network_assets---v0207)
 - [`flame_rive` - `v1.9.4`](#flame_rive---v194)
 - [`flame_svg` - `v1.8.4`](#flame_svg---v184)
 - [`flame_test` - `v1.13.2`](#flame_test---v1132)
 - [`flame_tiled` - `v1.15.0`](#flame_tiled---v1150)
 - [`jenny` - `v1.1.1`](#jenny---v111)
 - [`flame_spine` - `v0.1.1+4`](#flame_spine---v0114)
 - [`flame_markdown` - `v0.1.1+2`](#flame_markdown---v0112)
 - [`flame_oxygen` - `v0.1.9+2`](#flame_oxygen---v0192)
 - [`flame_noise` - `v0.1.1+7`](#flame_noise---v0117)

Packages with dependency updates only:

> Packages listed below depend on other packages in this workspace that have had changes. Their versions have been incremented to bump the minimum dependency versions of the packages they depend upon in this project.

 - `flame_spine` - `v0.1.1+4`
 - `flame_markdown` - `v0.1.1+2`
 - `flame_oxygen` - `v0.1.9+2`
 - `flame_noise` - `v0.1.1+7`

---

#### `flame` - `v1.10.0`

 - **REFACTOR**: Remove unnecessary 'async' keyword across the codebase [DCM] ([#2803](https://github.com/flame-engine/flame/issues/2803)). ([2dfe0e5a](https://github.com/flame-engine/flame/commit/2dfe0e5a431213c7148ab6389e3e8c8dc49fbf3d))
 - **REFACTOR**: Avoid nested conditional expressions whenever possible [DCM] ([#2784](https://github.com/flame-engine/flame/issues/2784)). ([7b6a5712](https://github.com/flame-engine/flame/commit/7b6a571263ece3aa1a8267644d9118230a850830))
 - **REFACTOR**: Mark semantically final variables as final (or const) proper [DCM] ([#2783](https://github.com/flame-engine/flame/issues/2783)). ([71f7b475](https://github.com/flame-engine/flame/commit/71f7b475e33dd6fa7224c4a3ab29ffdb89702c34))
 - **FIX**: Remove deprecations for 1.10.0 ([#2809](https://github.com/flame-engine/flame/issues/2809)). ([5b67b8f1](https://github.com/flame-engine/flame/commit/5b67b8f14ad4fdb38a249d0a41ecba49ba2fcc44))
 - **FIX**: Un-register component keys down the component tree ([#2792](https://github.com/flame-engine/flame/issues/2792)). ([0f679b3f](https://github.com/flame-engine/flame/commit/0f679b3f3d4a643ff4c29569388941c459e35021))
 - **FIX**: AlignComponent set child (remove compare) ([#2774](https://github.com/flame-engine/flame/issues/2774)). ([20aaf656](https://github.com/flame-engine/flame/commit/20aaf656617cef6538b49c067a562f9daf0a5972))
 - **FIX**: Hardcode initCurrentGame lifecycle state as resumed ([#2775](https://github.com/flame-engine/flame/issues/2775)). ([0cd5037c](https://github.com/flame-engine/flame/commit/0cd5037c6a837706891d5f1b85a91715cf85ebb1))
 - **FIX**: Fix TextBoxComponent alignment bug ([#2781](https://github.com/flame-engine/flame/issues/2781)). ([0fb53efb](https://github.com/flame-engine/flame/commit/0fb53efb661ae2a3b4a39407655efb69e92dced0))
 - **FIX**(flame): The `component.removeFromParent` method should use `parent.remove` internally ([#2779](https://github.com/flame-engine/flame/issues/2779)). ([bdb1c79a](https://github.com/flame-engine/flame/commit/bdb1c79a0524801ab425982dae206915c691e4b2))
 - **FIX**: Take unmounted adds into consideration ([#2770](https://github.com/flame-engine/flame/issues/2770)). ([be28a440](https://github.com/flame-engine/flame/commit/be28a4405f4024a3066b764d6dbad0713665665d))
 - **FEAT**: Add `IgnoreEvents` mixin to ignore events for the whole subtree ([#2811](https://github.com/flame-engine/flame/issues/2811)). ([313411c3](https://github.com/flame-engine/flame/commit/313411c311a6a3c2d36e12abf16bdd27ae801f29))
 - **FEAT**: Add advanced button component ([#2742](https://github.com/flame-engine/flame/issues/2742)). ([97fff0ed](https://github.com/flame-engine/flame/commit/97fff0ed2baab53f2780eca29a9d08ea5d90426a))
 - **FEAT**: Introduce the `FixedResolutionViewport` ([#2796](https://github.com/flame-engine/flame/issues/2796)). ([4c762f94](https://github.com/flame-engine/flame/commit/4c762f94d40d200bb2b8a102867b0859a345dbf0))
 - **FEAT**: AssetsBundle can be customized in Images and AssetsCache. ([#2807](https://github.com/flame-engine/flame/issues/2807)). ([a23f80e9](https://github.com/flame-engine/flame/commit/a23f80e94a5d935fc8ba232956fe02e001d5a8f9))
 - **FEAT**: Backdrop (static backgrounds) component for CameraComponent ([#2787](https://github.com/flame-engine/flame/issues/2787)). ([ab329f71](https://github.com/flame-engine/flame/commit/ab329f718a581b8331749fed6f942b6ade0da5ac))
 - **FEAT**: Align component refactoring ([#2767](https://github.com/flame-engine/flame/issues/2767)). ([bde34efe](https://github.com/flame-engine/flame/commit/bde34efef7264c91f49b237b589c74ba80a1554e))
 - **DOCS**: Remove last broad cSpell bypass regex and fix all violations ([#2802](https://github.com/flame-engine/flame/issues/2802)). ([9b16b178](https://github.com/flame-engine/flame/commit/9b16b178048eb19b6596273fcf4daec83277c3b5))

#### `flame_audio` - `v2.1.2`

 - **REFACTOR**: Remove unnecessary 'async' keyword across the codebase [DCM] ([#2803](https://github.com/flame-engine/flame/issues/2803)). ([2dfe0e5a](https://github.com/flame-engine/flame/commit/2dfe0e5a431213c7148ab6389e3e8c8dc49fbf3d))
 - **REFACTOR**: Mark semantically final variables as final (or const) proper [DCM] ([#2783](https://github.com/flame-engine/flame/issues/2783)). ([71f7b475](https://github.com/flame-engine/flame/commit/71f7b475e33dd6fa7224c4a3ab29ffdb89702c34))
 - **FIX**: Remove deprecations for 1.10.0 ([#2809](https://github.com/flame-engine/flame/issues/2809)). ([5b67b8f1](https://github.com/flame-engine/flame/commit/5b67b8f14ad4fdb38a249d0a41ecba49ba2fcc44))

#### `flame_bloc` - `v1.10.4`

 - **FIX**: Remove deprecations for 1.10.0 ([#2809](https://github.com/flame-engine/flame/issues/2809)). ([5b67b8f1](https://github.com/flame-engine/flame/commit/5b67b8f14ad4fdb38a249d0a41ecba49ba2fcc44))

#### `flame_fire_atlas` - `v1.4.2`

 - **REFACTOR**: Remove unnecessary 'async' keyword across the codebase [DCM] ([#2803](https://github.com/flame-engine/flame/issues/2803)). ([2dfe0e5a](https://github.com/flame-engine/flame/commit/2dfe0e5a431213c7148ab6389e3e8c8dc49fbf3d))
 - **FIX**: Remove deprecations for 1.10.0 ([#2809](https://github.com/flame-engine/flame/issues/2809)). ([5b67b8f1](https://github.com/flame-engine/flame/commit/5b67b8f14ad4fdb38a249d0a41ecba49ba2fcc44))

#### `flame_forge2d` - `v0.15.1`

 - **FEAT**: Allow for bodyDef and fixtureDefs to be prepared earlier ([#2768](https://github.com/flame-engine/flame/issues/2768)). ([21357bca](https://github.com/flame-engine/flame/commit/21357bcac1e7e1cebfa6f2a496ec4b627d62d0e7))

#### `flame_isolate` - `v0.5.0+2`

 - **REFACTOR**: Mark semantically final variables as final (or const) proper [DCM] ([#2783](https://github.com/flame-engine/flame/issues/2783)). ([71f7b475](https://github.com/flame-engine/flame/commit/71f7b475e33dd6fa7224c4a3ab29ffdb89702c34))

#### `flame_lottie` - `v0.3.0+2`

 - **REFACTOR**: Remove unnecessary 'async' keyword across the codebase [DCM] ([#2803](https://github.com/flame-engine/flame/issues/2803)). ([2dfe0e5a](https://github.com/flame-engine/flame/commit/2dfe0e5a431213c7148ab6389e3e8c8dc49fbf3d))
 - **FIX**: Duration in `LottieRenderer` rounds down milliseconds ([#2808](https://github.com/flame-engine/flame/issues/2808)). ([cccae2e1](https://github.com/flame-engine/flame/commit/cccae2e1476de456c15ee3779b746f5fe6dadee2))

#### `flame_network_assets` - `v0.2.0+7`

 - **FIX**: Remove deprecations for 1.10.0 ([#2809](https://github.com/flame-engine/flame/issues/2809)). ([5b67b8f1](https://github.com/flame-engine/flame/commit/5b67b8f14ad4fdb38a249d0a41ecba49ba2fcc44))

#### `flame_rive` - `v1.9.4`

 - **REFACTOR**: Remove unnecessary 'async' keyword across the codebase [DCM] ([#2803](https://github.com/flame-engine/flame/issues/2803)). ([2dfe0e5a](https://github.com/flame-engine/flame/commit/2dfe0e5a431213c7148ab6389e3e8c8dc49fbf3d))

#### `flame_svg` - `v1.8.4`

 - **FIX**: Do not render SVGs bigger than requested when pixelRatio > 1 and no match in _imageCache ([#2795](https://github.com/flame-engine/flame/issues/2795)). ([5fa4e09f](https://github.com/flame-engine/flame/commit/5fa4e09f7c464ce2f676df81049a95dad46bf2bd))

#### `flame_test` - `v1.13.2`

 - **REFACTOR**: Remove unnecessary 'async' keyword across the codebase [DCM] ([#2803](https://github.com/flame-engine/flame/issues/2803)). ([2dfe0e5a](https://github.com/flame-engine/flame/commit/2dfe0e5a431213c7148ab6389e3e8c8dc49fbf3d))

#### `flame_tiled` - `v1.15.0`

 - **REFACTOR**: Remove unnecessary 'async' keyword across the codebase [DCM] ([#2803](https://github.com/flame-engine/flame/issues/2803)). ([2dfe0e5a](https://github.com/flame-engine/flame/commit/2dfe0e5a431213c7148ab6389e3e8c8dc49fbf3d))
 - **FIX**: Remove deprecations for 1.10.0 ([#2809](https://github.com/flame-engine/flame/issues/2809)). ([5b67b8f1](https://github.com/flame-engine/flame/commit/5b67b8f14ad4fdb38a249d0a41ecba49ba2fcc44))
 - **FIX**: Parallax offset calculations in flame_tiled don't scale properly ([#2766](https://github.com/flame-engine/flame/issues/2766)). ([89e8427a](https://github.com/flame-engine/flame/commit/89e8427a7a34258ec20276e4ec64d4a484277cdd))
 - **FEAT**(flame_tiled): Allowing tilesets with images in the same folder to load ([#2814](https://github.com/flame-engine/flame/issues/2814)). ([3b0d7e65](https://github.com/flame-engine/flame/commit/3b0d7e65c2bf158db378d66c4f7e687dd05b46e1))
 - **FEAT**: AssetsBundle can be customized in Images and AssetsCache. ([#2807](https://github.com/flame-engine/flame/issues/2807)). ([a23f80e9](https://github.com/flame-engine/flame/commit/a23f80e94a5d935fc8ba232956fe02e001d5a8f9))
 - **FEAT**: Add overriding of Images and Bundle in all classes ([#2806](https://github.com/flame-engine/flame/issues/2806)). ([2df90c9b](https://github.com/flame-engine/flame/commit/2df90c9ba8f2b1cc088c5270df571eee7e18bb57))

#### `jenny` - `v1.1.1`

 - **REFACTOR**: Remove unnecessary 'async' keyword across the codebase [DCM] ([#2803](https://github.com/flame-engine/flame/issues/2803)). ([2dfe0e5a](https://github.com/flame-engine/flame/commit/2dfe0e5a431213c7148ab6389e3e8c8dc49fbf3d))
 - **REFACTOR**: Avoid nested conditional expressions whenever possible [DCM] ([#2784](https://github.com/flame-engine/flame/issues/2784)). ([7b6a5712](https://github.com/flame-engine/flame/commit/7b6a571263ece3aa1a8267644d9118230a850830))
 - **DOCS**: Remove last broad cSpell bypass regex and fix all violations ([#2802](https://github.com/flame-engine/flame/issues/2802)). ([9b16b178](https://github.com/flame-engine/flame/commit/9b16b178048eb19b6596273fcf4daec83277c3b5))


## 2023-09-22

### Changes

---

Packages with breaking changes:

 - There are no breaking changes in this release.

Packages with other changes:

 - [`flame` - `v1.9.1`](#flame---v191)
 - [`flame_isolate` - `v0.5.0+1`](#flame_isolate---v0501)
 - [`flame_tiled` - `v1.14.1`](#flame_tiled---v1141)
 - [`flame_audio` - `v2.1.1`](#flame_audio---v211)
 - [`flame_spine` - `v0.1.1+3`](#flame_spine---v0113)
 - [`flame_svg` - `v1.8.3`](#flame_svg---v183)
 - [`flame_test` - `v1.13.1`](#flame_test---v1131)
 - [`flame_oxygen` - `v0.1.9+1`](#flame_oxygen---v0191)
 - [`flame_bloc` - `v1.10.3`](#flame_bloc---v1103)
 - [`flame_fire_atlas` - `v1.4.1`](#flame_fire_atlas---v141)
 - [`flame_markdown` - `v0.1.1+1`](#flame_markdown---v0111)
 - [`flame_forge2d` - `v0.15.0+1`](#flame_forge2d---v01501)
 - [`flame_rive` - `v1.9.3`](#flame_rive---v193)
 - [`flame_noise` - `v0.1.1+6`](#flame_noise---v0116)
 - [`flame_network_assets` - `v0.2.0+6`](#flame_network_assets---v0206)
 - [`flame_lottie` - `v0.3.0+1`](#flame_lottie---v0301)

Packages with dependency updates only:

> Packages listed below depend on other packages in this workspace that have had changes. Their versions have been incremented to bump the minimum dependency versions of the packages they depend upon in this project.

 - `flame_isolate` - `v0.5.0+1`
 - `flame_tiled` - `v1.14.1`
 - `flame_audio` - `v2.1.1`
 - `flame_spine` - `v0.1.1+3`
 - `flame_svg` - `v1.8.3`
 - `flame_test` - `v1.13.1`
 - `flame_oxygen` - `v0.1.9+1`
 - `flame_bloc` - `v1.10.3`
 - `flame_fire_atlas` - `v1.4.1`
 - `flame_markdown` - `v0.1.1+1`
 - `flame_forge2d` - `v0.15.0+1`
 - `flame_rive` - `v1.9.3`
 - `flame_noise` - `v0.1.1+6`
 - `flame_network_assets` - `v0.2.0+6`
 - `flame_lottie` - `v0.3.0+1`

---

#### `flame` - `v1.9.1`

 - **FIX**: Add necessary generics on mixins on FlameGame ([#2763](https://github.com/flame-engine/flame/issues/2763)). ([b1f5ff26](https://github.com/flame-engine/flame/commit/b1f5ff269441d55b09ce12d5ce99656f2d88a978))
 - **FIX**: Correctly refreshes the widget after new mouse detector ([#2765](https://github.com/flame-engine/flame/issues/2765)). ([64330022](https://github.com/flame-engine/flame/commit/643300222f8bf0545abdd1d8608202f388f8693f))
 - **FIX**: Allow moving to a new parent in the same tick ([#2762](https://github.com/flame-engine/flame/issues/2762)). ([313650ea](https://github.com/flame-engine/flame/commit/313650eafadca4427421ddd355fa5b373966b8d1))


## 2023-09-21

### Changes

---

Packages with breaking changes:

 - [`flame` - `v1.9.0`](#flame---v190)
 - [`flame_oxygen` - `v0.1.9`](#flame_oxygen---v019)
 - [`flame_test` - `v1.13.0`](#flame_test---v1130)
 - [`flame_tiled` - `v1.14.0`](#flame_tiled---v1140)
 - [`flame_forge2d` - `v0.15.0`](#flame_forge2d---v0150)
 - [`flame_isolate` - `v0.5.0`](#flame_isolate---v050)
 - [`flame_lottie` - `v0.3.0`](#flame_lottie---v030)

Packages with other changes:

 - [`flame_audio` - `v2.1.0`](#flame_audio---v210)
 - [`flame_bloc` - `v1.10.2`](#flame_bloc---v1102)
 - [`flame_fire_atlas` - `v1.4.0`](#flame_fire_atlas---v140)
 - [`flame_lint` - `v1.1.1`](#flame_lint---v111)
 - [`flame_markdown` - `v0.1.1`](#flame_markdown---v011)
 - [`flame_network_assets` - `v0.2.0+5`](#flame_network_assets---v0205)
 - [`flame_noise` - `v0.1.1+5`](#flame_noise---v0115)
 - [`flame_rive` - `v1.9.2`](#flame_rive---v192)
 - [`flame_spine` - `v0.1.1+2`](#flame_spine---v0112)
 - [`flame_svg` - `v1.8.2`](#flame_svg---v182)
 - [`jenny` - `v1.1.0`](#jenny---v110)

---

#### `flame` - `v1.9.0`

 - **REFACTOR**: Enable DCM linting ([#2667](https://github.com/flame-engine/flame/issues/2667)). ([27a8fd61](https://github.com/flame-engine/flame/commit/27a8fd61cb7f62513e07a93ff61cf03b426353f2))
 - **REFACTOR**: Fix lint issues across the codebase - Part 2 ([#2677](https://github.com/flame-engine/flame/issues/2677)). ([10e4109c](https://github.com/flame-engine/flame/commit/10e4109c81b266147ec35744e484c2ec7ea15acd))
 - **FIX**: Prevent `onRemove`/`onDetach` being called for initial Gesture Detector addition ([#2653](https://github.com/flame-engine/flame/issues/2653)). ([d1721464](https://github.com/flame-engine/flame/commit/d17214640548eba26f10ba0d55e70545d58cb1b9))
 - **FIX**: Use root game for gestures ([#2756](https://github.com/flame-engine/flame/issues/2756)). ([f5d0cb38](https://github.com/flame-engine/flame/commit/f5d0cb3856e5b397b11a1c4bb2dc9c49afa51de0))
 - **FIX**: Add possibility to remove a child and add it to the same parent ([#2755](https://github.com/flame-engine/flame/issues/2755)). ([285d31ab](https://github.com/flame-engine/flame/commit/285d31ab9894a8c24b995a68fc29329f142d0d09))
 - **FIX**: Adding scale parameter to RectangleComponent constructors ([#2730](https://github.com/flame-engine/flame/issues/2730)). ([173908d9](https://github.com/flame-engine/flame/commit/173908d9f26c5555ffa69d1557bf346c0ab5fbee))
 - **FIX**: Set `CameraComponent.priority` to max ([#2732](https://github.com/flame-engine/flame/issues/2732)). ([820ece1c](https://github.com/flame-engine/flame/commit/820ece1c9aba9d770326adcd2224c951ef54f6f7))
 - **FIX**: Change to `FilterQuality.medium` instead of `high` ([#2733](https://github.com/flame-engine/flame/issues/2733)). ([fc19890c](https://github.com/flame-engine/flame/commit/fc19890c87a78599ea49ee0dfb52a04ea6b09a99))
 - **FIX**: Avoid creating new `Vector2` in `globalToLocal` and `localToGlobal` ([#2727](https://github.com/flame-engine/flame/issues/2727)). ([9fb3bf8d](https://github.com/flame-engine/flame/commit/9fb3bf8dbd71bc981b00d3b4dabbe997d50030bb))
 - **FIX**: Ambiguation is not needed in render box anymore ([#2711](https://github.com/flame-engine/flame/issues/2711)). ([b3d78f58](https://github.com/flame-engine/flame/commit/b3d78f58831ec72f40f721f96f8d659111f25a88))
 - **FIX**: HasGameReference should default to FlameGame ([#2710](https://github.com/flame-engine/flame/issues/2710)). ([93dcb3a1](https://github.com/flame-engine/flame/commit/93dcb3a117c365767e3f20569b2d82abc8a7b152))
 - **FIX**: Make `debugCoordinatesPrecision` into a variable instead of a getter ([#2713](https://github.com/flame-engine/flame/issues/2713)). ([9918c051](https://github.com/flame-engine/flame/commit/9918c0515ae88c2f1bfb7423a2993c983dec16c2))
 - **FIX**: Absolute angle takes into account BodyComponent ancestors too ([#2678](https://github.com/flame-engine/flame/issues/2678)). ([75aee767](https://github.com/flame-engine/flame/commit/75aee767811ef440841956d9e467be157c4ab880))
 - **FEAT**: SpawnComponent ([#2709](https://github.com/flame-engine/flame/issues/2709)). ([83f5ea45](https://github.com/flame-engine/flame/commit/83f5ea45dcc024c3bfd3fe9002533daaf1a2be4e))
 - **FEAT**: Add globalToLocal and localToGlobal methods to viewport, viewfinder and camera ([#2720](https://github.com/flame-engine/flame/issues/2720)). ([00185a3b](https://github.com/flame-engine/flame/commit/00185a3b6b1e0e6b06e67dc724a26d4e9651e1a2))
 - **FEAT**: Add HoverCallbacks ([#2706](https://github.com/flame-engine/flame/issues/2706)). ([d460b846](https://github.com/flame-engine/flame/commit/d460b846c23fb1f67041469c99c81e4c78b89c2e))
 - **FEAT**: Add `onDispose` to `game.dart` called from `game_widget.dart` ([#2659](https://github.com/flame-engine/flame/issues/2659)). ([2f44e483](https://github.com/flame-engine/flame/commit/2f44e4832f0a9a8edf9c002783501610aa051370))
 - **FEAT**(flame): Add helper methods to create frame data on `SpriteSheet` ([#2754](https://github.com/flame-engine/flame/issues/2754)). ([47722199](https://github.com/flame-engine/flame/commit/477221998a272bf659cd86d2bf145adf0f277e65))
 - **FEAT**: Implement Snapshot mixin on PositionComponent ([#2695](https://github.com/flame-engine/flame/issues/2695)). ([c1ee24a2](https://github.com/flame-engine/flame/commit/c1ee24a2894eaffa1f6e206313cda4087a02f0a4))
 - **FEAT**: Add TextElementComponent ([#2694](https://github.com/flame-engine/flame/issues/2694)). ([10fb65f6](https://github.com/flame-engine/flame/commit/10fb65f66ca1f1dbac04a138ef4a28b1ed5e5a23))
 - **FEAT**: Component visibility (HasVisibility mixin) ([#2681](https://github.com/flame-engine/flame/issues/2681)). ([76405daf](https://github.com/flame-engine/flame/commit/76405daf48b2efd59241329d4d1fb4b451d254c0))
 - **FEAT**: Add `HasWorldReference` mixin ([#2746](https://github.com/flame-engine/flame/issues/2746)). ([9105411d](https://github.com/flame-engine/flame/commit/9105411d46e097d4b5bf84ee8921c146dcf5a6cd))
 - **FEAT**: Add `pause` and `isPaused` to SpriteAnimationTicker ([#2660](https://github.com/flame-engine/flame/issues/2660)). ([37271f5c](https://github.com/flame-engine/flame/commit/37271f5c52e75e6b086520a35361a03e0d784586))
 - **DOCS**: Improve documentation around SpriteFontTextFormatter ([#2661](https://github.com/flame-engine/flame/issues/2661)). ([8401c569](https://github.com/flame-engine/flame/commit/8401c569bfbc92a13ce5cee18cd817da06bd0bd8))
 - **DOCS**: Improved spellchecking ([#2722](https://github.com/flame-engine/flame/issues/2722)). ([2f973abe](https://github.com/flame-engine/flame/commit/2f973abe8b298a4f6f1164065783de560953d789))
 - **DOCS**: Enable CSpell on tests ([#2723](https://github.com/flame-engine/flame/issues/2723)). ([e051298c](https://github.com/flame-engine/flame/commit/e051298cba76550229780438b1a589557c7b488d))
 - **DOCS**: Improve comments and documentation for text-rendering Nodes ([#2662](https://github.com/flame-engine/flame/issues/2662)). ([96978e24](https://github.com/flame-engine/flame/commit/96978e2496ffe29dbbf19b8e7e70c2d63309b115))
 - **DOCS**: Fix examples for v1.9.0 ([#2757](https://github.com/flame-engine/flame/issues/2757)). ([152fbb61](https://github.com/flame-engine/flame/commit/152fbb61db1986632f60f3bf98c93aa2e4fbfc86))
 - **BREAKING** **REFACTOR**: Rename (Text) Elements, Nodes and Styles for clarity, add docs ([#2700](https://github.com/flame-engine/flame/issues/2700)). ([4b420b79](https://github.com/flame-engine/flame/commit/4b420b7952ab8d675140b9d8d132015ff2780f92))
 - **BREAKING** **REFACTOR**: Extract TextRendererFactory ([#2680](https://github.com/flame-engine/flame/issues/2680)). ([eeb6749f](https://github.com/flame-engine/flame/commit/eeb6749fd2baa825c7e8267a546ec8bf405a63ae))
 - **BREAKING** **REFACTOR**: Make TextElement more usable on its own ([#2679](https://github.com/flame-engine/flame/issues/2679)). ([1a64443c](https://github.com/flame-engine/flame/commit/1a64443ccaae32e71fe7d016ad1e8f18a75c93da))
 - **BREAKING** **REFACTOR**: Simplify text rendering pipeline ([#2663](https://github.com/flame-engine/flame/issues/2663)). ([34f69b95](https://github.com/flame-engine/flame/commit/34f69b953c137fbf0168aebec3860c6abc888594))
 - **BREAKING** **REFACTOR**: Kill TextRenderer, Long Live TextRenderer ([#2683](https://github.com/flame-engine/flame/issues/2683)). ([a1cb9a06](https://github.com/flame-engine/flame/commit/a1cb9a06ada6f87bf22bc20e3c190ccd53517389))
 - **BREAKING** **FIX**: Update should be called before render in first tick ([#2714](https://github.com/flame-engine/flame/issues/2714)). ([51932c09](https://github.com/flame-engine/flame/commit/51932c09c1e934ec30ffa04eda6c050440f85548))
 - **BREAKING** **FEAT**: Move `Forge2DGame` to use `CameraComponent` ([#2728](https://github.com/flame-engine/flame/issues/2728)). ([7a3d5126](https://github.com/flame-engine/flame/commit/7a3d5126a54d23cdebde20953772a53ba1a53204))
 - **BREAKING** **FEAT**: Pause game when backgrounded ([#2642](https://github.com/flame-engine/flame/issues/2642)). ([521e56b6](https://github.com/flame-engine/flame/commit/521e56b6d20c1c5b24a2818d73be58a6e6523f6b))
 - **BREAKING** **FEAT**: Add CameraComponent to FlameGame ([#2740](https://github.com/flame-engine/flame/issues/2740)). ([7c2f4000](https://github.com/flame-engine/flame/commit/7c2f4000761580dbabb5d73b27f64d5819b34e8d))

#### `flame_oxygen` - `v0.1.9`

 - **REFACTOR**: Enable DCM linting ([#2667](https://github.com/flame-engine/flame/issues/2667)). ([27a8fd61](https://github.com/flame-engine/flame/commit/27a8fd61cb7f62513e07a93ff61cf03b426353f2))
 - **BREAKING** **REFACTOR**: Simplify text rendering pipeline ([#2663](https://github.com/flame-engine/flame/issues/2663)). ([34f69b95](https://github.com/flame-engine/flame/commit/34f69b953c137fbf0168aebec3860c6abc888594))

#### `flame_test` - `v1.13.0`

 - **REFACTOR**: Enable DCM linting ([#2667](https://github.com/flame-engine/flame/issues/2667)). ([27a8fd61](https://github.com/flame-engine/flame/commit/27a8fd61cb7f62513e07a93ff61cf03b426353f2))
 - **FIX**: HasGameReference should default to FlameGame ([#2710](https://github.com/flame-engine/flame/issues/2710)). ([93dcb3a1](https://github.com/flame-engine/flame/commit/93dcb3a117c365767e3f20569b2d82abc8a7b152))
 - **FEAT**: Add HoverCallbacks ([#2706](https://github.com/flame-engine/flame/issues/2706)). ([d460b846](https://github.com/flame-engine/flame/commit/d460b846c23fb1f67041469c99c81e4c78b89c2e))
 - **BREAKING** **REFACTOR**: Rename (Text) Elements, Nodes and Styles for clarity, add docs ([#2700](https://github.com/flame-engine/flame/issues/2700)). ([4b420b79](https://github.com/flame-engine/flame/commit/4b420b7952ab8d675140b9d8d132015ff2780f92))
 - **BREAKING** **REFACTOR**: Kill TextRenderer, Long Live TextRenderer ([#2683](https://github.com/flame-engine/flame/issues/2683)). ([a1cb9a06](https://github.com/flame-engine/flame/commit/a1cb9a06ada6f87bf22bc20e3c190ccd53517389))
 - **BREAKING** **REFACTOR**: Make TextElement more usable on its own ([#2679](https://github.com/flame-engine/flame/issues/2679)). ([1a64443c](https://github.com/flame-engine/flame/commit/1a64443ccaae32e71fe7d016ad1e8f18a75c93da))
 - **BREAKING** **FEAT**: Add CameraComponent to FlameGame ([#2740](https://github.com/flame-engine/flame/issues/2740)). ([7c2f4000](https://github.com/flame-engine/flame/commit/7c2f4000761580dbabb5d73b27f64d5819b34e8d))

#### `flame_tiled` - `v1.14.0`

 - **REFACTOR**: Enable DCM linting ([#2667](https://github.com/flame-engine/flame/issues/2667)). ([27a8fd61](https://github.com/flame-engine/flame/commit/27a8fd61cb7f62513e07a93ff61cf03b426353f2))
 - **FEAT**: Expose atlas limits for `TiledComponent` ([#2701](https://github.com/flame-engine/flame/issues/2701)). ([99a1016f](https://github.com/flame-engine/flame/commit/99a1016f72d02f4a989986f224e0e77cddd0dfa8))
 - **FEAT**: Added prefix parameter to TiledComponent.load to specify assets folder for tiled maps ([#2651](https://github.com/flame-engine/flame/issues/2651)). ([d08284dd](https://github.com/flame-engine/flame/commit/d08284ddcaf5d2ad6e5312336a71a113702dc241))
 - **DOCS**: Enable CSpell on tests ([#2723](https://github.com/flame-engine/flame/issues/2723)). ([e051298c](https://github.com/flame-engine/flame/commit/e051298cba76550229780438b1a589557c7b488d))
 - **BREAKING** **FEAT**: Add CameraComponent to FlameGame ([#2740](https://github.com/flame-engine/flame/issues/2740)). ([7c2f4000](https://github.com/flame-engine/flame/commit/7c2f4000761580dbabb5d73b27f64d5819b34e8d))

#### `flame_forge2d` - `v0.15.0`

 - **REFACTOR**: Enable DCM linting ([#2667](https://github.com/flame-engine/flame/issues/2667)). ([27a8fd61](https://github.com/flame-engine/flame/commit/27a8fd61cb7f62513e07a93ff61cf03b426353f2))
 - **FIX**: Absolute angle takes into account BodyComponent ancestors too ([#2678](https://github.com/flame-engine/flame/issues/2678)). ([75aee767](https://github.com/flame-engine/flame/commit/75aee767811ef440841956d9e467be157c4ab880))
 - **FIX**: Proper Flame dependency in flame_forge2d ([#2644](https://github.com/flame-engine/flame/issues/2644)). ([9bbecb88](https://github.com/flame-engine/flame/commit/9bbecb88d86aa051626267fd69e5bf71fdca66d6))
 - **DOCS**: Enable CSpell on tests ([#2723](https://github.com/flame-engine/flame/issues/2723)). ([e051298c](https://github.com/flame-engine/flame/commit/e051298cba76550229780438b1a589557c7b488d))
 - **BREAKING** **FEAT**: Add CameraComponent to FlameGame ([#2740](https://github.com/flame-engine/flame/issues/2740)). ([7c2f4000](https://github.com/flame-engine/flame/commit/7c2f4000761580dbabb5d73b27f64d5819b34e8d))
 - **BREAKING** **FEAT**: Move `Forge2DGame` to use `CameraComponent` ([#2728](https://github.com/flame-engine/flame/issues/2728)). ([7a3d5126](https://github.com/flame-engine/flame/commit/7a3d5126a54d23cdebde20953772a53ba1a53204))

#### `flame_isolate` - `v0.5.0`

 - **REFACTOR**: Enable DCM linting ([#2667](https://github.com/flame-engine/flame/issues/2667)). ([27a8fd61](https://github.com/flame-engine/flame/commit/27a8fd61cb7f62513e07a93ff61cf03b426353f2))
 - **DOCS**: Enable CSpell on tests ([#2723](https://github.com/flame-engine/flame/issues/2723)). ([e051298c](https://github.com/flame-engine/flame/commit/e051298cba76550229780438b1a589557c7b488d))
 - **BREAKING** **FEAT**: Add CameraComponent to FlameGame ([#2740](https://github.com/flame-engine/flame/issues/2740)). ([7c2f4000](https://github.com/flame-engine/flame/commit/7c2f4000761580dbabb5d73b27f64d5819b34e8d))

#### `flame_lottie` - `v0.3.0`

 - **REFACTOR**: Enable DCM linting ([#2667](https://github.com/flame-engine/flame/issues/2667)). ([27a8fd61](https://github.com/flame-engine/flame/commit/27a8fd61cb7f62513e07a93ff61cf03b426353f2))
 - **REFACTOR**: Fix lint issues across the codebase ([#2672](https://github.com/flame-engine/flame/issues/2672)). ([6fe9a247](https://github.com/flame-engine/flame/commit/6fe9a24778fbe1e9cb74ec0d50d71eae7b1a048e))
 - **BREAKING** **FEAT**: Add CameraComponent to FlameGame ([#2740](https://github.com/flame-engine/flame/issues/2740)). ([7c2f4000](https://github.com/flame-engine/flame/commit/7c2f4000761580dbabb5d73b27f64d5819b34e8d))

#### `flame_audio` - `v2.1.0`

 - **REFACTOR**: Enable DCM linting ([#2667](https://github.com/flame-engine/flame/issues/2667)). ([27a8fd61](https://github.com/flame-engine/flame/commit/27a8fd61cb7f62513e07a93ff61cf03b426353f2))
 - **FEAT**(flame_audio): Adding an easy way of updating the prefix from FlameAudio ([#2751](https://github.com/flame-engine/flame/issues/2751)). ([d2c9dcec](https://github.com/flame-engine/flame/commit/d2c9dcecbe661896ba8c84d81b9500cdfa8c78c8))

#### `flame_bloc` - `v1.10.2`

 - **REFACTOR**: Enable DCM linting ([#2667](https://github.com/flame-engine/flame/issues/2667)). ([27a8fd61](https://github.com/flame-engine/flame/commit/27a8fd61cb7f62513e07a93ff61cf03b426353f2))
 - **DOCS**: Enable CSpell on tests ([#2723](https://github.com/flame-engine/flame/issues/2723)). ([e051298c](https://github.com/flame-engine/flame/commit/e051298cba76550229780438b1a589557c7b488d))

#### `flame_fire_atlas` - `v1.4.0`

 - **REFACTOR**: Enable DCM linting ([#2667](https://github.com/flame-engine/flame/issues/2667)). ([27a8fd61](https://github.com/flame-engine/flame/commit/27a8fd61cb7f62513e07a93ff61cf03b426353f2))
 - **FEAT**(fire_atlas): Encoded option to load json instead of .fa ([#2649](https://github.com/flame-engine/flame/issues/2649)). ([5be6fc8c](https://github.com/flame-engine/flame/commit/5be6fc8caea138b577bf91244165c0a61659b4c5))

#### `flame_lint` - `v1.1.1`

 - **REFACTOR**: Enable new DCM rule: avoid-cascade-after-if-null ([#2676](https://github.com/flame-engine/flame/issues/2676)). ([158fc34c](https://github.com/flame-engine/flame/commit/158fc34cae858cf8d0b5d3b5155763e02454779a))
 - **REFACTOR**: Enable DCM linting ([#2667](https://github.com/flame-engine/flame/issues/2667)). ([27a8fd61](https://github.com/flame-engine/flame/commit/27a8fd61cb7f62513e07a93ff61cf03b426353f2))

#### `flame_markdown` - `v0.1.1`

 - **FEAT**: Create flame_markdown ([#2703](https://github.com/flame-engine/flame/issues/2703)). ([b77c2373](https://github.com/flame-engine/flame/commit/b77c23737104260aea2483c38ec3bef999975e7d))

#### `flame_network_assets` - `v0.2.0+5`

 - **REFACTOR**: Enable DCM linting ([#2667](https://github.com/flame-engine/flame/issues/2667)). ([27a8fd61](https://github.com/flame-engine/flame/commit/27a8fd61cb7f62513e07a93ff61cf03b426353f2))

#### `flame_noise` - `v0.1.1+5`

 - **REFACTOR**: Enable DCM linting ([#2667](https://github.com/flame-engine/flame/issues/2667)). ([27a8fd61](https://github.com/flame-engine/flame/commit/27a8fd61cb7f62513e07a93ff61cf03b426353f2))

#### `flame_rive` - `v1.9.2`

 - **REFACTOR**: Enable DCM linting ([#2667](https://github.com/flame-engine/flame/issues/2667)). ([27a8fd61](https://github.com/flame-engine/flame/commit/27a8fd61cb7f62513e07a93ff61cf03b426353f2))
 - **DOCS**: Enable CSpell on tests ([#2723](https://github.com/flame-engine/flame/issues/2723)). ([e051298c](https://github.com/flame-engine/flame/commit/e051298cba76550229780438b1a589557c7b488d))

#### `flame_spine` - `v0.1.1+2`

 - **REFACTOR**: Enable DCM linting ([#2667](https://github.com/flame-engine/flame/issues/2667)). ([27a8fd61](https://github.com/flame-engine/flame/commit/27a8fd61cb7f62513e07a93ff61cf03b426353f2))

#### `flame_svg` - `v1.8.2`

 - **REFACTOR**: Enable DCM linting ([#2667](https://github.com/flame-engine/flame/issues/2667)). ([27a8fd61](https://github.com/flame-engine/flame/commit/27a8fd61cb7f62513e07a93ff61cf03b426353f2))
 - **FIX**: Change to `FilterQuality.medium` instead of `high` ([#2733](https://github.com/flame-engine/flame/issues/2733)). ([fc19890c](https://github.com/flame-engine/flame/commit/fc19890c87a78599ea49ee0dfb52a04ea6b09a99))

#### `jenny` - `v1.1.0`

 - **REFACTOR**: Enable new DCM rule: avoid-cascade-after-if-null ([#2676](https://github.com/flame-engine/flame/issues/2676)). ([158fc34c](https://github.com/flame-engine/flame/commit/158fc34cae858cf8d0b5d3b5155763e02454779a))
 - **REFACTOR**: Remove unused variable on dialogue_view_test.dart ([#2673](https://github.com/flame-engine/flame/issues/2673)). ([b77802a5](https://github.com/flame-engine/flame/commit/b77802a5e3a3c2fa68650dfa5d5f2aaed0f9a147))
 - **REFACTOR**: Enable DCM linting ([#2667](https://github.com/flame-engine/flame/issues/2667)). ([27a8fd61](https://github.com/flame-engine/flame/commit/27a8fd61cb7f62513e07a93ff61cf03b426353f2))
 - **FIX**: Change DialogueView to a mixin class ([#2652](https://github.com/flame-engine/flame/issues/2652)). ([f3d4158b](https://github.com/flame-engine/flame/commit/f3d4158b83685b479b0e7373bfbc7f8a6c16d822))
 - **FEAT**(flame_jenny): Allow removal of functions and commands ([#2717](https://github.com/flame-engine/flame/issues/2717)). ([a097cc01](https://github.com/flame-engine/flame/commit/a097cc01bc2bf789684c23320b16018dfc9dc664))
 - **FEAT**(flame_jenny): Allow removal of variables ([#2716](https://github.com/flame-engine/flame/issues/2716)). ([eaa8c091](https://github.com/flame-engine/flame/commit/eaa8c091627e4dd743c88dda42d4da70dca40e8b))
 - **FEAT**(flame_jenny): Allow removal of characters ([#2715](https://github.com/flame-engine/flame/issues/2715)). ([3421f4f9](https://github.com/flame-engine/flame/commit/3421f4f944516d998460a5347125d8f100366c42))
 - **FEAT**(flame_jenny): Public access to variables to allow load/save ([#2689](https://github.com/flame-engine/flame/issues/2689)). ([1485f842](https://github.com/flame-engine/flame/commit/1485f8426ebb6dd1390a0062c5e83ed1c0461f21))
 - **DOCS**: Enable CSpell on tests ([#2723](https://github.com/flame-engine/flame/issues/2723)). ([e051298c](https://github.com/flame-engine/flame/commit/e051298cba76550229780438b1a589557c7b488d))
 - **DOCS**: Improved spellchecking ([#2722](https://github.com/flame-engine/flame/issues/2722)). ([2f973abe](https://github.com/flame-engine/flame/commit/2f973abe8b298a4f6f1164065783de560953d789))


## 2023-08-08

### Changes

---

Packages with breaking changes:

 - [`flame` - `v1.8.2`](#flame---v182)
 - [`flame_lint` - `v1.1.0`](#flame_lint---v110)

Packages with other changes:

 - [`flame_rive` - `v1.9.1`](#flame_rive---v191)
 - [`flame_tiled` - `v1.13.0`](#flame_tiled---v1130)
 - [`flame_isolate` - `v0.4.0+2`](#flame_isolate---v0402)
 - [`flame_audio` - `v2.0.5`](#flame_audio---v205)
 - [`flame_spine` - `v0.1.1+1`](#flame_spine---v0111)
 - [`flame_svg` - `v1.8.1`](#flame_svg---v181)
 - [`flame_test` - `v1.12.1`](#flame_test---v1121)
 - [`flame_oxygen` - `v0.1.8+5`](#flame_oxygen---v0185)
 - [`flame_bloc` - `v1.10.1`](#flame_bloc---v1101)
 - [`flame_fire_atlas` - `v1.3.8`](#flame_fire_atlas---v138)
 - [`flame_forge2d` - `v0.14.1+1`](#flame_forge2d---v01411)
 - [`flame_noise` - `v0.1.1+4`](#flame_noise---v0114)
 - [`flame_network_assets` - `v0.2.0+4`](#flame_network_assets---v0204)
 - [`flame_lottie` - `v0.2.1+1`](#flame_lottie---v0211)

Packages with dependency updates only:

> Packages listed below depend on other packages in this workspace that have had changes. Their versions have been incremented to bump the minimum dependency versions of the packages they depend upon in this project.

 - `flame_isolate` - `v0.4.0+2`
 - `flame_audio` - `v2.0.5`
 - `flame_spine` - `v0.1.1+1`
 - `flame_svg` - `v1.8.1`
 - `flame_test` - `v1.12.1`
 - `flame_oxygen` - `v0.1.8+5`
 - `flame_bloc` - `v1.10.1`
 - `flame_fire_atlas` - `v1.3.8`
 - `flame_forge2d` - `v0.14.1+1`
 - `flame_noise` - `v0.1.1+4`
 - `flame_network_assets` - `v0.2.0+4`
 - `flame_lottie` - `v0.2.1+1`

---

#### `flame` - `v1.8.2`

 - **PERF**: Improve performance of raycasts ([#2617](https://github.com/flame-engine/flame/issues/2617)). ([8e0a7879](https://github.com/flame-engine/flame/commit/8e0a7879d7669e09efcbcee28d9f2038fe9014c0))
 - **FIX**: Reset _completeCompleter in ticker ([#2636](https://github.com/flame-engine/flame/issues/2636)). ([a35d3a10](https://github.com/flame-engine/flame/commit/a35d3a10abfe9e5caab1a646e0980d03fbf585d1))
 - **FIX**: Viewport should recieve events before the world  ([#2630](https://github.com/flame-engine/flame/issues/2630)). ([e852064e](https://github.com/flame-engine/flame/commit/e852064e494e58ea2be19a5b035e09ed2e465608))
 - **FIX**: Use `ComponentKey`s to keep track of dispatchers ([#2629](https://github.com/flame-engine/flame/issues/2629)). ([ff59aa15](https://github.com/flame-engine/flame/commit/ff59aa152c5a2e0b360f980c78a8b3cc4fad7507))
 - **FIX**: FlameGame onRemove fix to prevent memory leak ([#2602](https://github.com/flame-engine/flame/issues/2602)). ([dac2ebbf](https://github.com/flame-engine/flame/commit/dac2ebbf506ff48ca8f34d872bbc47cba3ad6c7b))
 - **FIX**: Only use pre-set ReadonlySizeProvider for sizing in HudMarginComponent ([#2611](https://github.com/flame-engine/flame/issues/2611)). ([832c0510](https://github.com/flame-engine/flame/commit/832c051085e0fade8a7e4b262bf9941d279baef4))
 - **FIX**: TextBoxConfig dismissDelay to not be ignored ([#2607](https://github.com/flame-engine/flame/issues/2607)). ([1567b389](https://github.com/flame-engine/flame/commit/1567b3891057e4ce168d76c920bd40403febd82a))
 - **FEAT**: Adding key argument to shape components ([#2632](https://github.com/flame-engine/flame/issues/2632)). ([c542d3c3](https://github.com/flame-engine/flame/commit/c542d3c34bf911cec8332dcdeb65d0017e6cb576))
 - **FEAT**: Add optional world input to `CameraComponent.canSee` ([#2616](https://github.com/flame-engine/flame/issues/2616)). ([1cad0b23](https://github.com/flame-engine/flame/commit/1cad0b23e18db8f352da5790c8ea5ec6053936da))
 - **FEAT**: Add a Circle.fromPoints utility method ([#2603](https://github.com/flame-engine/flame/issues/2603)). ([a83f2815](https://github.com/flame-engine/flame/commit/a83f2815bbdaf9c176a34a325485a96b5a323575))
 - **FEAT**: Add a midpoint getter to LineSegment ([#2605](https://github.com/flame-engine/flame/issues/2605)). ([1f9f3509](https://github.com/flame-engine/flame/commit/1f9f35093b3b90113e32a36e1103b87246212fa4))
 - **FEAT**: Add Rectangle.fromLTWH and Rect.toFlameRectangle utility methods ([#2604](https://github.com/flame-engine/flame/issues/2604)). ([76271cee](https://github.com/flame-engine/flame/commit/76271ceef04264ec8fa5c39a23f43d638d731694))
 - **DOCS**: Add more guidance to collision detection algorithm choices ([#2624](https://github.com/flame-engine/flame/issues/2624)). ([781e8983](https://github.com/flame-engine/flame/commit/781e898315a0162117a83bf62e2650ce7244503d))
 - **BREAKING** **PERF**: Pool `CollisionProspect`s and remove some list creations from the collision detection ([#2625](https://github.com/flame-engine/flame/issues/2625)). ([e430b6cd](https://github.com/flame-engine/flame/commit/e430b6cdf2e6be52bf384efb3428bcb41ae13d30))
 - **BREAKING** **FEAT**: Make world nullable in `CameraComponent` ([#2615](https://github.com/flame-engine/flame/issues/2615)). ([14f51635](https://github.com/flame-engine/flame/commit/14f51635421b8b30049ea287b7c472e54a269250))

#### `flame_lint` - `v1.1.0`

 - **BREAKING** **PERF**: Pool `CollisionProspect`s and remove some list creations from the collision detection ([#2625](https://github.com/flame-engine/flame/issues/2625)). ([e430b6cd](https://github.com/flame-engine/flame/commit/e430b6cdf2e6be52bf384efb3428bcb41ae13d30))

#### `flame_rive` - `v1.9.1`

 - **FIX**: Respect artboard clip value ([#2639](https://github.com/flame-engine/flame/issues/2639)). ([4e664245](https://github.com/flame-engine/flame/commit/4e6642458494b4d4544bcc03b568476faeb0a71f))

#### `flame_tiled` - `v1.13.0`

 - **FIX**: Compute scale in TileLayers based on native map tile size rather than image sizes to support oversized/undersized tiles. ([#2634](https://github.com/flame-engine/flame/issues/2634)). ([1c4d6cd0](https://github.com/flame-engine/flame/commit/1c4d6cd0654f133771a7af5795cc1de2343268c1))
 - **FEAT**: Possiblity to pass in FilterQuality to tiled layers ([#2627](https://github.com/flame-engine/flame/issues/2627)). ([f3de6650](https://github.com/flame-engine/flame/commit/f3de66507e623e2fe0100cfd4d002dea14f72470))


## 2023-07-02

### Changes

---

Packages with breaking changes:

 - [`flame` - `v1.8.1`](#flame---v181)
 - [`flame_test` - `v1.12.0`](#flame_test---v1120)

Packages with other changes:

 - [`flame_audio` - `v2.0.4`](#flame_audio---v204)
 - [`flame_bloc` - `v1.10.0`](#flame_bloc---v1100)
 - [`flame_fire_atlas` - `v1.3.7`](#flame_fire_atlas---v137)
 - [`flame_forge2d` - `v0.14.1`](#flame_forge2d---v0141)
 - [`flame_isolate` - `v0.4.0+1`](#flame_isolate---v0401)
 - [`flame_lottie` - `v0.2.1`](#flame_lottie---v021)
 - [`flame_noise` - `v0.1.1+3`](#flame_noise---v0113)
 - [`flame_oxygen` - `v0.1.8+4`](#flame_oxygen---v0184)
 - [`flame_rive` - `v1.9.0`](#flame_rive---v190)
 - [`flame_spine` - `v0.1.1`](#flame_spine---v011)
 - [`flame_svg` - `v1.8.0`](#flame_svg---v180)
 - [`flame_tiled` - `v1.12.0`](#flame_tiled---v1120)
 - [`jenny` - `v1.0.4`](#jenny---v104)
 - [`flame_network_assets` - `v0.2.0+3`](#flame_network_assets---v0203)

Packages with dependency updates only:

> Packages listed below depend on other packages in this workspace that have had changes. Their versions have been incremented to bump the minimum dependency versions of the packages they depend upon in this project.

 - `flame_network_assets` - `v0.2.0+3`

---

#### `flame` - `v1.8.1`

 - **FIX**: Adds a check to confirm the component is not loaded ([#2579](https://github.com/flame-engine/flame/issues/2579)). ([985400f2](https://github.com/flame-engine/flame/commit/985400f2955f6bed14066660711d53c5b302ab09))
 - **FIX**: Animation ticker readability improvements ([#2578](https://github.com/flame-engine/flame/issues/2578)). ([667a1698](https://github.com/flame-engine/flame/commit/667a1698115ed69cc11b2e5a598371e136c7e7f0))
 - **FIX**: Remove `mustCallSuper` from `onComponentTypeCheck` ([#2561](https://github.com/flame-engine/flame/issues/2561)). ([bcae760c](https://github.com/flame-engine/flame/commit/bcae760c7138839fee203a1693e02fade753292c))
 - **FIX**: Update sdk constraints to >=3.0.0 ([#2554](https://github.com/flame-engine/flame/issues/2554)). ([2f71e06e](https://github.com/flame-engine/flame/commit/2f71e06eb86ffc65cd459c4d722eee2470be13e5))
 - **FIX**: Reduce the Vector2 creations in Anchor ([#2550](https://github.com/flame-engine/flame/issues/2550)). ([5a9434b0](https://github.com/flame-engine/flame/commit/5a9434b09a6fbe2c86db2d8192cd2d7ae0d5868c))
 - **FIX**: Fix disappearing text on TextBoxComponent for larger pixelRatios ([#2540](https://github.com/flame-engine/flame/issues/2540)). ([6e1d5466](https://github.com/flame-engine/flame/commit/6e1d5466aadc59f90475b1a9e7658bb78ed60340))
 - **FEAT**: Option to prevent propagating collision events from ShapeHitbox to _hitboxParent ([#2594](https://github.com/flame-engine/flame/issues/2594)). ([a58d7436](https://github.com/flame-engine/flame/commit/a58d7436c9b71a2358edc6c3732aeda56d980f64))
 - **FEAT**: Adding filterQuality arguments to Parallax load methods ([#2596](https://github.com/flame-engine/flame/issues/2596)). ([ff3d9107](https://github.com/flame-engine/flame/commit/ff3d91075c49df8efb6130f8e8ac9b711a1a8a14))
 - **FEAT**: Option to use toImageSync in ImageComposition class ([#2593](https://github.com/flame-engine/flame/issues/2593)). ([66d5f97d](https://github.com/flame-engine/flame/commit/66d5f97d303aa1712673b8ca7e1a889cf5e7270e))
 - **FEAT**: ComponentKey API ([#2566](https://github.com/flame-engine/flame/issues/2566)). ([b3efb612](https://github.com/flame-engine/flame/commit/b3efb612cb3cb77f69bc030e9ba71516348035d2))
 - **FEAT**(flame): Set a default negative priority on the world for general use ([#2572](https://github.com/flame-engine/flame/issues/2572)). ([390e9700](https://github.com/flame-engine/flame/commit/390e9700b4293e12b7d4212ce04f6b3d967a24e1))
 - **FEAT**: Add useful methods to Rectangle class ([#2562](https://github.com/flame-engine/flame/issues/2562)). ([4710530b](https://github.com/flame-engine/flame/commit/4710530b420469794602bf4d8cfea98078e0d973))
 - **BREAKING** **FIX**: Convert PositionEvent.canvasPosition to local coordinates ([#2598](https://github.com/flame-engine/flame/issues/2598)). ([87139c85](https://github.com/flame-engine/flame/commit/87139c854534782638fe1b0c24d2dc92f98a3e59))

#### `flame_test` - `v1.12.0`

 - **FIX**: Set constraint for test dependency in flame_test ([#2558](https://github.com/flame-engine/flame/issues/2558)). ([aeef9464](https://github.com/flame-engine/flame/commit/aeef9464f6ca448e3aa2b578af8b3443cbbf6f71))
 - **FIX**: Update sdk constraints to >=3.0.0 ([#2554](https://github.com/flame-engine/flame/issues/2554)). ([2f71e06e](https://github.com/flame-engine/flame/commit/2f71e06eb86ffc65cd459c4d722eee2470be13e5))
 - **BREAKING** **FIX**: Convert PositionEvent.canvasPosition to local coordinates ([#2598](https://github.com/flame-engine/flame/issues/2598)). ([87139c85](https://github.com/flame-engine/flame/commit/87139c854534782638fe1b0c24d2dc92f98a3e59))

#### `flame_audio` - `v2.0.4`

 - **FIX**: Update sdk constraints to >=3.0.0 ([#2554](https://github.com/flame-engine/flame/issues/2554)). ([2f71e06e](https://github.com/flame-engine/flame/commit/2f71e06eb86ffc65cd459c4d722eee2470be13e5))

#### `flame_bloc` - `v1.10.0`

 - **FIX**: Update sdk constraints to >=3.0.0 ([#2554](https://github.com/flame-engine/flame/issues/2554)). ([2f71e06e](https://github.com/flame-engine/flame/commit/2f71e06eb86ffc65cd459c4d722eee2470be13e5))
 - **FEAT**: ComponentKey API ([#2566](https://github.com/flame-engine/flame/issues/2566)). ([b3efb612](https://github.com/flame-engine/flame/commit/b3efb612cb3cb77f69bc030e9ba71516348035d2))
 - **FEAT**: Add onInitialState to FlameBlocListener ([#2565](https://github.com/flame-engine/flame/issues/2565)). ([f440bbf5](https://github.com/flame-engine/flame/commit/f440bbf5db207d454b4abba75a62e0ff2ff5b408))

#### `flame_fire_atlas` - `v1.3.7`

 - **FIX**: Update sdk constraints to >=3.0.0 ([#2554](https://github.com/flame-engine/flame/issues/2554)). ([2f71e06e](https://github.com/flame-engine/flame/commit/2f71e06eb86ffc65cd459c4d722eee2470be13e5))

#### `flame_forge2d` - `v0.14.1`

 - **FIX**: Update sdk constraints to >=3.0.0 ([#2554](https://github.com/flame-engine/flame/issues/2554)). ([2f71e06e](https://github.com/flame-engine/flame/commit/2f71e06eb86ffc65cd459c4d722eee2470be13e5))
 - **FEAT**: ComponentKey API ([#2566](https://github.com/flame-engine/flame/issues/2566)). ([b3efb612](https://github.com/flame-engine/flame/commit/b3efb612cb3cb77f69bc030e9ba71516348035d2))
 - **DOCS**: Fix broken link on flame_forge2d readme ([#2588](https://github.com/flame-engine/flame/issues/2588)). ([45115bbf](https://github.com/flame-engine/flame/commit/45115bbff8539010f5d7bb7cf9479183b1a27cc8))

#### `flame_isolate` - `v0.4.0+1`

 - **FIX**: Update sdk constraints to >=3.0.0 ([#2554](https://github.com/flame-engine/flame/issues/2554)). ([2f71e06e](https://github.com/flame-engine/flame/commit/2f71e06eb86ffc65cd459c4d722eee2470be13e5))

#### `flame_lottie` - `v0.2.1`

 - **FIX**: Update sdk constraints to >=3.0.0 ([#2554](https://github.com/flame-engine/flame/issues/2554)). ([2f71e06e](https://github.com/flame-engine/flame/commit/2f71e06eb86ffc65cd459c4d722eee2470be13e5))
 - **FEAT**: ComponentKey API ([#2566](https://github.com/flame-engine/flame/issues/2566)). ([b3efb612](https://github.com/flame-engine/flame/commit/b3efb612cb3cb77f69bc030e9ba71516348035d2))

#### `flame_noise` - `v0.1.1+3`

 - **FIX**: Update sdk constraints to >=3.0.0 ([#2554](https://github.com/flame-engine/flame/issues/2554)). ([2f71e06e](https://github.com/flame-engine/flame/commit/2f71e06eb86ffc65cd459c4d722eee2470be13e5))

#### `flame_oxygen` - `v0.1.8+4`

 - **FIX**: Update sdk constraints to >=3.0.0 ([#2554](https://github.com/flame-engine/flame/issues/2554)). ([2f71e06e](https://github.com/flame-engine/flame/commit/2f71e06eb86ffc65cd459c4d722eee2470be13e5))

#### `flame_rive` - `v1.9.0`

 - **FIX**: Update sdk constraints to >=3.0.0 ([#2554](https://github.com/flame-engine/flame/issues/2554)). ([2f71e06e](https://github.com/flame-engine/flame/commit/2f71e06eb86ffc65cd459c4d722eee2470be13e5))
 - **FIX**: Avoid creation of unnecessary objects for RiveComponent ([#2553](https://github.com/flame-engine/flame/issues/2553)). ([52b35fbf](https://github.com/flame-engine/flame/commit/52b35fbf56a551a7585c493e2de51473266bf759))
 - **FEAT**: ComponentKey API ([#2566](https://github.com/flame-engine/flame/issues/2566)). ([b3efb612](https://github.com/flame-engine/flame/commit/b3efb612cb3cb77f69bc030e9ba71516348035d2))

#### `flame_spine` - `v0.1.1`

 - **FIX**: Update sdk constraints to >=3.0.0 ([#2554](https://github.com/flame-engine/flame/issues/2554)). ([2f71e06e](https://github.com/flame-engine/flame/commit/2f71e06eb86ffc65cd459c4d722eee2470be13e5))
 - **FEAT**: ComponentKey API ([#2566](https://github.com/flame-engine/flame/issues/2566)). ([b3efb612](https://github.com/flame-engine/flame/commit/b3efb612cb3cb77f69bc030e9ba71516348035d2))

#### `flame_svg` - `v1.8.0`

 - **FIX**: Update sdk constraints to >=3.0.0 ([#2554](https://github.com/flame-engine/flame/issues/2554)). ([2f71e06e](https://github.com/flame-engine/flame/commit/2f71e06eb86ffc65cd459c4d722eee2470be13e5))
 - **FEAT**: ComponentKey API ([#2566](https://github.com/flame-engine/flame/issues/2566)). ([b3efb612](https://github.com/flame-engine/flame/commit/b3efb612cb3cb77f69bc030e9ba71516348035d2))

#### `flame_tiled` - `v1.12.0`

 - **FIX**: Tiled component orthogonal test ([#2549](https://github.com/flame-engine/flame/issues/2549)). ([34e5f0e4](https://github.com/flame-engine/flame/commit/34e5f0e443e21923c311120ce8634a14339bc71d))
 - **FIX**: Update sdk constraints to >=3.0.0 ([#2554](https://github.com/flame-engine/flame/issues/2554)). ([2f71e06e](https://github.com/flame-engine/flame/commit/2f71e06eb86ffc65cd459c4d722eee2470be13e5))
 - **FEAT**: TiledAtlas.clearCache function ([#2592](https://github.com/flame-engine/flame/issues/2592)). ([d40fefcf](https://github.com/flame-engine/flame/commit/d40fefcf08850a986304472d5369dcd74f2b9d4b))
 - **FEAT**: ComponentKey API ([#2566](https://github.com/flame-engine/flame/issues/2566)). ([b3efb612](https://github.com/flame-engine/flame/commit/b3efb612cb3cb77f69bc030e9ba71516348035d2))
 - **FEAT**: Add option for a custom image and asset loader ([#2569](https://github.com/flame-engine/flame/issues/2569)). ([dfe18251](https://github.com/flame-engine/flame/commit/dfe18251c1bac8aaca9bf146e03320efbbc3ce9c))

#### `jenny` - `v1.0.4`

 - **FIX**: Update sdk constraints to >=3.0.0 ([#2554](https://github.com/flame-engine/flame/issues/2554)). ([2f71e06e](https://github.com/flame-engine/flame/commit/2f71e06eb86ffc65cd459c4d722eee2470be13e5))


## 2023-06-09

### Changes

---

Packages with breaking changes:

 - There are no breaking changes in this release.

Packages with other changes:

 - [`flame_tiled` - `v1.11.0`](#flame_tiled---v1110)

---

#### `flame_tiled` - `v1.11.0`

 - **FIX**: Tiled component orthogonal test ([#2549](https://github.com/flame-engine/flame/issues/2549)). ([34e5f0e4](https://github.com/flame-engine/flame/commit/34e5f0e443e21923c311120ce8634a14339bc71d))
 - **FIX**: Update sdk constraints to >=3.0.0 ([#2554](https://github.com/flame-engine/flame/issues/2554)). ([2f71e06e](https://github.com/flame-engine/flame/commit/2f71e06eb86ffc65cd459c4d722eee2470be13e5))
 - **FEAT**: Add option for a custom image and asset loader ([#2569](https://github.com/flame-engine/flame/issues/2569)). ([dfe18251](https://github.com/flame-engine/flame/commit/dfe18251c1bac8aaca9bf146e03320efbbc3ce9c))


## 2023-05-28

### Changes

---

Packages with breaking changes:

 - [`flame` - `v1.8.0`](#flame---v180)
 - [`flame_rive` - `v1.8.0`](#flame_rive---v180)
 - [`flame_test` - `v1.11.0`](#flame_test---v1110)
 - [`flame_forge2d` - `v0.14.0`](#flame_forge2d---v0140)
 - [`flame_isolate` - `v0.4.0`](#flame_isolate---v040)

Packages with other changes:

 - [`flame_lint` - `v1.0.0`](#flame_lint---v100)
 - [`flame_audio` - `v2.0.3`](#flame_audio---v203)
 - [`flame_bloc` - `v1.9.0`](#flame_bloc---v190)
 - [`flame_fire_atlas` - `v1.3.6`](#flame_fire_atlas---v136)
 - [`flame_lottie` - `v0.2.0+3`](#flame_lottie---v0203)
 - [`flame_network_assets` - `v0.2.0+2`](#flame_network_assets---v0202)
 - [`flame_noise` - `v0.1.1+2`](#flame_noise---v0112)
 - [`flame_oxygen` - `v0.1.8+3`](#flame_oxygen---v0183)
 - [`flame_spine` - `v0.1.0+1`](#flame_spine---v0101)
 - [`flame_svg` - `v1.7.4`](#flame_svg---v174)
 - [`flame_tiled` - `v1.10.2`](#flame_tiled---v1102)
 - [`jenny` - `v1.0.3`](#jenny---v103)

---

#### `flame` - `v1.8.0`

 - **FIX**: Update sdk constraints to >=3.0.0 ([#2554](https://github.com/flame-engine/flame/issues/2554)). ([2f71e06e](https://github.com/flame-engine/flame/commit/2f71e06eb86ffc65cd459c4d722eee2470be13e5))
 - **FIX**: Reduce the Vector2 creations in Anchor ([#2550](https://github.com/flame-engine/flame/issues/2550)). ([5a9434b0](https://github.com/flame-engine/flame/commit/5a9434b09a6fbe2c86db2d8192cd2d7ae0d5868c))
 - **FIX**: Fix disappearing text on TextBoxComponent for larger pixelRatios ([#2540](https://github.com/flame-engine/flame/issues/2540)). ([6e1d5466](https://github.com/flame-engine/flame/commit/6e1d5466aadc59f90475b1a9e7658bb78ed60340))
 - **FIX**: Avoid the creation of Vector2 objects in Parallax update ([#2536](https://github.com/flame-engine/flame/issues/2536)). ([3849f07d](https://github.com/flame-engine/flame/commit/3849f07d50870e4364caf9e115e869d8fed6aaed))
 - **FIX**: Solve warnings from 3.10.0 analyzer ([#2532](https://github.com/flame-engine/flame/issues/2532)). ([b41622db](https://github.com/flame-engine/flame/commit/b41622db8faa7559328f83f8f1d93ec4c6386961))
 - **FIX**: Move `errorBuilder` and `loadingBuilder` to constructors ([#2526](https://github.com/flame-engine/flame/issues/2526)). ([55ec0bc3](https://github.com/flame-engine/flame/commit/55ec0bc3cbebc0106dba2e0d4f3fd7693b9bc6d6))
 - **FEAT**: Add onComplete callback to `AnimationWidget` ([#2515](https://github.com/flame-engine/flame/issues/2515)). ([0b68be8a](https://github.com/flame-engine/flame/commit/0b68be8a6f306b0102b3be980dec661909d2c1e0))
 - **FEAT**: Add `stepEngine` to `Game` ([#2516](https://github.com/flame-engine/flame/issues/2516)). ([1ed2c5a2](https://github.com/flame-engine/flame/commit/1ed2c5a2974876a32f620d9dc9cb385e4e928c50))
 - **FEAT**: Customise grid of NineTileBox ([#2495](https://github.com/flame-engine/flame/issues/2495)). ([a25b0a03](https://github.com/flame-engine/flame/commit/a25b0a03a56975e1de2e15747bc3e527ac232545))
 - **FEAT**: Accept `CollisionType` in hitbox constructor ([#2509](https://github.com/flame-engine/flame/issues/2509)). ([89926227](https://github.com/flame-engine/flame/commit/89926227c5132455b971dece6ed313634d7ac873))
 - **DOCS**: Update content types of sphinx code snippets ([#2519](https://github.com/flame-engine/flame/issues/2519)). ([306ad320](https://github.com/flame-engine/flame/commit/306ad32052cfba9c6b3ab38ebb7d0604742d2993))
 - **BREAKING** **REFACTOR**: Move `CameraComponent` and events out of experimental ([#2505](https://github.com/flame-engine/flame/issues/2505)). ([87b8a067](https://github.com/flame-engine/flame/commit/87b8a067f3e0096cebff3db4f5767e68616928fd))
 - **BREAKING** **FEAT**: Add `SpriteAnimationTicker` ([#2457](https://github.com/flame-engine/flame/issues/2457)). ([a50c80cf](https://github.com/flame-engine/flame/commit/a50c80cfa34c08463ab29efe4a1f546fb47da34e))

#### `flame_rive` - `v1.8.0`

 - **FIX**: Update sdk constraints to >=3.0.0 ([#2554](https://github.com/flame-engine/flame/issues/2554)). ([2f71e06e](https://github.com/flame-engine/flame/commit/2f71e06eb86ffc65cd459c4d722eee2470be13e5))
 - **FIX**: Avoid creation of unnecessary objects for RiveComponent ([#2553](https://github.com/flame-engine/flame/issues/2553)). ([52b35fbf](https://github.com/flame-engine/flame/commit/52b35fbf56a551a7585c493e2de51473266bf759))
 - **FIX**: Solve warnings from 3.10.0 analyzer ([#2532](https://github.com/flame-engine/flame/issues/2532)). ([b41622db](https://github.com/flame-engine/flame/commit/b41622db8faa7559328f83f8f1d93ec4c6386961))
 - **BREAKING** **REFACTOR**: Move `CameraComponent` and events out of experimental ([#2505](https://github.com/flame-engine/flame/issues/2505)). ([87b8a067](https://github.com/flame-engine/flame/commit/87b8a067f3e0096cebff3db4f5767e68616928fd))

#### `flame_test` - `v1.11.0`

 - **FIX**: Update sdk constraints to >=3.0.0 ([#2554](https://github.com/flame-engine/flame/issues/2554)). ([2f71e06e](https://github.com/flame-engine/flame/commit/2f71e06eb86ffc65cd459c4d722eee2470be13e5))
 - **FIX**: Solve warnings from 3.10.0 analyzer ([#2532](https://github.com/flame-engine/flame/issues/2532)). ([b41622db](https://github.com/flame-engine/flame/commit/b41622db8faa7559328f83f8f1d93ec4c6386961))
 - **BREAKING** **REFACTOR**: Move `CameraComponent` and events out of experimental ([#2505](https://github.com/flame-engine/flame/issues/2505)). ([87b8a067](https://github.com/flame-engine/flame/commit/87b8a067f3e0096cebff3db4f5767e68616928fd))

#### `flame_forge2d` - `v0.14.0`

 - **FIX**: Update sdk constraints to >=3.0.0 ([#2554](https://github.com/flame-engine/flame/issues/2554)). ([2f71e06e](https://github.com/flame-engine/flame/commit/2f71e06eb86ffc65cd459c4d722eee2470be13e5))
 - **FIX**: Solve warnings from 3.10.0 analyzer ([#2532](https://github.com/flame-engine/flame/issues/2532)). ([b41622db](https://github.com/flame-engine/flame/commit/b41622db8faa7559328f83f8f1d93ec4c6386961))
 - **BREAKING** **REFACTOR**: Move `CameraComponent` and events out of experimental ([#2505](https://github.com/flame-engine/flame/issues/2505)). ([87b8a067](https://github.com/flame-engine/flame/commit/87b8a067f3e0096cebff3db4f5767e68616928fd))

#### `flame_isolate` - `v0.4.0`

 - **FIX**: Update sdk constraints to >=3.0.0 ([#2554](https://github.com/flame-engine/flame/issues/2554)). ([2f71e06e](https://github.com/flame-engine/flame/commit/2f71e06eb86ffc65cd459c4d722eee2470be13e5))
 - **FIX**: Solve warnings from 3.10.0 analyzer ([#2532](https://github.com/flame-engine/flame/issues/2532)). ([b41622db](https://github.com/flame-engine/flame/commit/b41622db8faa7559328f83f8f1d93ec4c6386961))
 - **BREAKING** **REFACTOR**: Move `CameraComponent` and events out of experimental ([#2505](https://github.com/flame-engine/flame/issues/2505)). ([87b8a067](https://github.com/flame-engine/flame/commit/87b8a067f3e0096cebff3db4f5767e68616928fd))

#### `flame_lint` - `v1.0.0`

 - **FIX**: Update sdk constraints to >=3.0.0 ([#2554](https://github.com/flame-engine/flame/issues/2554)). ([2f71e06e](https://github.com/flame-engine/flame/commit/2f71e06eb86ffc65cd459c4d722eee2470be13e5))
 - **FIX**: Solve warnings from 3.10.0 analyzer ([#2532](https://github.com/flame-engine/flame/issues/2532)). ([b41622db](https://github.com/flame-engine/flame/commit/b41622db8faa7559328f83f8f1d93ec4c6386961))

#### `flame_audio` - `v2.0.3`

 - **FIX**: Update sdk constraints to >=3.0.0 ([#2554](https://github.com/flame-engine/flame/issues/2554)). ([2f71e06e](https://github.com/flame-engine/flame/commit/2f71e06eb86ffc65cd459c4d722eee2470be13e5))
 - **FIX**: Solve warnings from 3.10.0 analyzer ([#2532](https://github.com/flame-engine/flame/issues/2532)). ([b41622db](https://github.com/flame-engine/flame/commit/b41622db8faa7559328f83f8f1d93ec4c6386961))

#### `flame_bloc` - `v1.9.0`

 - **FIX**: Update sdk constraints to >=3.0.0 ([#2554](https://github.com/flame-engine/flame/issues/2554)). ([2f71e06e](https://github.com/flame-engine/flame/commit/2f71e06eb86ffc65cd459c4d722eee2470be13e5))
 - **FIX**: Solve warnings from 3.10.0 analyzer ([#2532](https://github.com/flame-engine/flame/issues/2532)). ([b41622db](https://github.com/flame-engine/flame/commit/b41622db8faa7559328f83f8f1d93ec4c6386961))
 - **FEAT**: Add listener for initial state on flame_bloc ([#2382](https://github.com/flame-engine/flame/issues/2382)). ([01121c22](https://github.com/flame-engine/flame/commit/01121c220bec391e0242dfa9afc3d4a03bb3358b))
 - **FEAT**: Accept `CollisionType` in hitbox constructor ([#2509](https://github.com/flame-engine/flame/issues/2509)). ([89926227](https://github.com/flame-engine/flame/commit/89926227c5132455b971dece6ed313634d7ac873))

#### `flame_fire_atlas` - `v1.3.6`

 - **FIX**: Update sdk constraints to >=3.0.0 ([#2554](https://github.com/flame-engine/flame/issues/2554)). ([2f71e06e](https://github.com/flame-engine/flame/commit/2f71e06eb86ffc65cd459c4d722eee2470be13e5))
 - **FIX**: Solve warnings from 3.10.0 analyzer ([#2532](https://github.com/flame-engine/flame/issues/2532)). ([b41622db](https://github.com/flame-engine/flame/commit/b41622db8faa7559328f83f8f1d93ec4c6386961))

#### `flame_lottie` - `v0.2.0+3`

 - **FIX**: Update sdk constraints to >=3.0.0 ([#2554](https://github.com/flame-engine/flame/issues/2554)). ([2f71e06e](https://github.com/flame-engine/flame/commit/2f71e06eb86ffc65cd459c4d722eee2470be13e5))
 - **FIX**: Solve warnings from 3.10.0 analyzer ([#2532](https://github.com/flame-engine/flame/issues/2532)). ([b41622db](https://github.com/flame-engine/flame/commit/b41622db8faa7559328f83f8f1d93ec4c6386961))

#### `flame_network_assets` - `v0.2.0+2`

 - **FIX**: Solve warnings from 3.10.0 analyzer ([#2532](https://github.com/flame-engine/flame/issues/2532)). ([b41622db](https://github.com/flame-engine/flame/commit/b41622db8faa7559328f83f8f1d93ec4c6386961))

#### `flame_noise` - `v0.1.1+2`

 - **FIX**: Update sdk constraints to >=3.0.0 ([#2554](https://github.com/flame-engine/flame/issues/2554)). ([2f71e06e](https://github.com/flame-engine/flame/commit/2f71e06eb86ffc65cd459c4d722eee2470be13e5))
 - **FIX**: Solve warnings from 3.10.0 analyzer ([#2532](https://github.com/flame-engine/flame/issues/2532)). ([b41622db](https://github.com/flame-engine/flame/commit/b41622db8faa7559328f83f8f1d93ec4c6386961))

#### `flame_oxygen` - `v0.1.8+3`

 - **FIX**: Update sdk constraints to >=3.0.0 ([#2554](https://github.com/flame-engine/flame/issues/2554)). ([2f71e06e](https://github.com/flame-engine/flame/commit/2f71e06eb86ffc65cd459c4d722eee2470be13e5))
 - **FIX**: Solve warnings from 3.10.0 analyzer ([#2532](https://github.com/flame-engine/flame/issues/2532)). ([b41622db](https://github.com/flame-engine/flame/commit/b41622db8faa7559328f83f8f1d93ec4c6386961))

#### `flame_spine` - `v0.1.0+1`

 - **FIX**: Update sdk constraints to >=3.0.0 ([#2554](https://github.com/flame-engine/flame/issues/2554)). ([2f71e06e](https://github.com/flame-engine/flame/commit/2f71e06eb86ffc65cd459c4d722eee2470be13e5))
 - **FIX**: Solve warnings from 3.10.0 analyzer ([#2532](https://github.com/flame-engine/flame/issues/2532)). ([b41622db](https://github.com/flame-engine/flame/commit/b41622db8faa7559328f83f8f1d93ec4c6386961))

#### `flame_svg` - `v1.7.4`

 - **FIX**: Update sdk constraints to >=3.0.0 ([#2554](https://github.com/flame-engine/flame/issues/2554)). ([2f71e06e](https://github.com/flame-engine/flame/commit/2f71e06eb86ffc65cd459c4d722eee2470be13e5))
 - **FIX**: Solve warnings from 3.10.0 analyzer ([#2532](https://github.com/flame-engine/flame/issues/2532)). ([b41622db](https://github.com/flame-engine/flame/commit/b41622db8faa7559328f83f8f1d93ec4c6386961))

#### `flame_tiled` - `v1.10.2`

 - **FIX**: Update sdk constraints to >=3.0.0 ([#2554](https://github.com/flame-engine/flame/issues/2554)). ([2f71e06e](https://github.com/flame-engine/flame/commit/2f71e06eb86ffc65cd459c4d722eee2470be13e5))
 - **FIX**: Solve warnings from 3.10.0 analyzer ([#2532](https://github.com/flame-engine/flame/issues/2532)). ([b41622db](https://github.com/flame-engine/flame/commit/b41622db8faa7559328f83f8f1d93ec4c6386961))

#### `jenny` - `v1.0.3`

 - **FIX**: Update sdk constraints to >=3.0.0 ([#2554](https://github.com/flame-engine/flame/issues/2554)). ([2f71e06e](https://github.com/flame-engine/flame/commit/2f71e06eb86ffc65cd459c4d722eee2470be13e5))
 - **FIX**: Solve warnings from 3.10.0 analyzer ([#2532](https://github.com/flame-engine/flame/issues/2532)). ([b41622db](https://github.com/flame-engine/flame/commit/b41622db8faa7559328f83f8f1d93ec4c6386961))


## 2023-05-05

### Changes

---

Packages with breaking changes:

 - There are no breaking changes in this release.

Packages with other changes:

 - [`flame_spine` - `v0.1.0`](#flame_spine---v010)

---

#### `flame_spine` - `v0.1.0`

 - **FEAT**: Spine bridge package ([#2530](https://github.com/flame-engine/flame/issues/2530)). ([5d1a6fd1](https://github.com/flame-engine/flame/commit/5d1a6fd1679c5690685e5a5f9b695a0ab6699bca))


## 2023-04-19

### Changes

---

Packages with breaking changes:

 - There are no breaking changes in this release.

Packages with other changes:

 - [`flame_audio` - `v2.0.2`](#flame_audio---v202)

---

#### `flame_audio` - `v2.0.2`

 - **FIX**: Release instead of dispose audioplayer in play ([#2513](https://github.com/flame-engine/flame/issues/2513)). ([e699b259](https://github.com/flame-engine/flame/commit/e699b259e99619bb97fe370ce0679157e65eb42b))


## 2023-04-16

### Changes

---

Packages with breaking changes:

 - There are no breaking changes in this release.

Packages with other changes:

 - [`flame` - `v1.7.3`](#flame---v173)
 - [`flame_audio` - `v2.0.1`](#flame_audio---v201)
 - [`flame_bloc` - `v1.8.4`](#flame_bloc---v184)
 - [`flame_fire_atlas` - `v1.3.5`](#flame_fire_atlas---v135)
 - [`flame_flare` - `v1.5.4`](#flame_flare---v154)
 - [`flame_forge2d` - `v0.13.0+1`](#flame_forge2d---v01301)
 - [`flame_isolate` - `v0.3.0+1`](#flame_isolate---v0301)
 - [`flame_lint` - `v0.2.0+2`](#flame_lint---v0202)
 - [`flame_oxygen` - `v0.1.8+2`](#flame_oxygen---v0182)
 - [`flame_rive` - `v1.7.1`](#flame_rive---v171)
 - [`flame_svg` - `v1.7.3`](#flame_svg---v173)
 - [`flame_test` - `v1.10.1`](#flame_test---v1101)
 - [`flame_tiled` - `v1.10.1`](#flame_tiled---v1101)
 - [`jenny` - `v1.0.2`](#jenny---v102)
 - [`flame_noise` - `v0.1.1+1`](#flame_noise---v0111)
 - [`flame_network_assets` - `v0.2.0+1`](#flame_network_assets---v0201)
 - [`flame_lottie` - `v0.2.0+2`](#flame_lottie---v0202)

Packages with dependency updates only:

> Packages listed below depend on other packages in this workspace that have had changes. Their versions have been incremented to bump the minimum dependency versions of the packages they depend upon in this project.

 - `flame_noise` - `v0.1.1+1`
 - `flame_network_assets` - `v0.2.0+1`
 - `flame_lottie` - `v0.2.0+2`

---

#### `flame` - `v1.7.3`

 - **REFACTOR**: Make atlas status to be more readable ([#2502](https://github.com/flame-engine/flame/issues/2502)). ([643793d0](https://github.com/flame-engine/flame/commit/643793d06e1c9264ce8fd557552ad8405bc65ec1))
 - **REFACTOR**: Add new lint rules ([#2477](https://github.com/flame-engine/flame/issues/2477)). ([dbda37b8](https://github.com/flame-engine/flame/commit/dbda37b81a9a7411559a6ba919ffbda6018b85c2))
 - **FIX**: Reverse invalid polygon definitions ([#2503](https://github.com/flame-engine/flame/issues/2503)). ([c4c516eb](https://github.com/flame-engine/flame/commit/c4c516ebf8fe6b8eaf82a3e49454b64faf6a7cd2))
 - **FIX**: Fill in mount implementation in `HasTappables` ([#2496](https://github.com/flame-engine/flame/issues/2496)). ([d51a612f](https://github.com/flame-engine/flame/commit/d51a612f8bed2a7a294444e5f11402394dfbc3cd))
 - **FIX**: Modify size only if changed while auto-resizing ([#2498](https://github.com/flame-engine/flame/issues/2498)). ([aa8d49da](https://github.com/flame-engine/flame/commit/aa8d49da9eb77c47d252ac3cc46d268eb10a2f20))
 - **FIX**: RecycleQueue cannot extends and implements Iterable at the same time ([#2497](https://github.com/flame-engine/flame/issues/2497)). ([3e5be3d6](https://github.com/flame-engine/flame/commit/3e5be3d6c23bfc61237befa5d17311474c6d4234))
 - **FIX**: Remove memory leak when creating the image from PictureRecorder ([#2493](https://github.com/flame-engine/flame/issues/2493)). ([a66f2bc0](https://github.com/flame-engine/flame/commit/a66f2bc0a97415f4f57b6c55174a2930cdf9e61b))
 - **FEAT**: Bump ordered_set version ([#2500](https://github.com/flame-engine/flame/issues/2500)). ([81303ea9](https://github.com/flame-engine/flame/commit/81303ea9d805c04c5d85c8e7c2f40ab8e43ae811))
 - **FEAT**: Deprecate `Component.changeParent` ([#2478](https://github.com/flame-engine/flame/issues/2478)). ([bd3e7886](https://github.com/flame-engine/flame/commit/bd3e7886125e60ad1386ec864a5ef33382f7f7f5))

#### `flame_audio` - `v2.0.1`

 - **REFACTOR**: Add new lint rules ([#2477](https://github.com/flame-engine/flame/issues/2477)). ([dbda37b8](https://github.com/flame-engine/flame/commit/dbda37b81a9a7411559a6ba919ffbda6018b85c2))

#### `flame_bloc` - `v1.8.4`

 - **REFACTOR**: Add new lint rules ([#2477](https://github.com/flame-engine/flame/issues/2477)). ([dbda37b8](https://github.com/flame-engine/flame/commit/dbda37b81a9a7411559a6ba919ffbda6018b85c2))

#### `flame_fire_atlas` - `v1.3.5`

 - **REFACTOR**: Add new lint rules ([#2477](https://github.com/flame-engine/flame/issues/2477)). ([dbda37b8](https://github.com/flame-engine/flame/commit/dbda37b81a9a7411559a6ba919ffbda6018b85c2))

#### `flame_flare` - `v1.5.4`

 - **REFACTOR**: Add new lint rules ([#2477](https://github.com/flame-engine/flame/issues/2477)). ([dbda37b8](https://github.com/flame-engine/flame/commit/dbda37b81a9a7411559a6ba919ffbda6018b85c2))

#### `flame_forge2d` - `v0.13.0+1`

 - **REFACTOR**: Add new lint rules ([#2477](https://github.com/flame-engine/flame/issues/2477)). ([dbda37b8](https://github.com/flame-engine/flame/commit/dbda37b81a9a7411559a6ba919ffbda6018b85c2))

#### `flame_isolate` - `v0.3.0+1`

 - **REFACTOR**: Add new lint rules ([#2477](https://github.com/flame-engine/flame/issues/2477)). ([dbda37b8](https://github.com/flame-engine/flame/commit/dbda37b81a9a7411559a6ba919ffbda6018b85c2))

#### `flame_lint` - `v0.2.0+2`

 - **REFACTOR**: Add new lint rules ([#2477](https://github.com/flame-engine/flame/issues/2477)). ([dbda37b8](https://github.com/flame-engine/flame/commit/dbda37b81a9a7411559a6ba919ffbda6018b85c2))

#### `flame_oxygen` - `v0.1.8+2`

 - **REFACTOR**: Add new lint rules ([#2477](https://github.com/flame-engine/flame/issues/2477)). ([dbda37b8](https://github.com/flame-engine/flame/commit/dbda37b81a9a7411559a6ba919ffbda6018b85c2))

#### `flame_rive` - `v1.7.1`

 - **REFACTOR**: Add new lint rules ([#2477](https://github.com/flame-engine/flame/issues/2477)). ([dbda37b8](https://github.com/flame-engine/flame/commit/dbda37b81a9a7411559a6ba919ffbda6018b85c2))

#### `flame_svg` - `v1.7.3`

 - **REFACTOR**: Add new lint rules ([#2477](https://github.com/flame-engine/flame/issues/2477)). ([dbda37b8](https://github.com/flame-engine/flame/commit/dbda37b81a9a7411559a6ba919ffbda6018b85c2))
 - **FIX**: Remove memory leak when creating the image from PictureRecorder ([#2493](https://github.com/flame-engine/flame/issues/2493)). ([a66f2bc0](https://github.com/flame-engine/flame/commit/a66f2bc0a97415f4f57b6c55174a2930cdf9e61b))

#### `flame_test` - `v1.10.1`

 - **REFACTOR**: Add new lint rules ([#2477](https://github.com/flame-engine/flame/issues/2477)). ([dbda37b8](https://github.com/flame-engine/flame/commit/dbda37b81a9a7411559a6ba919ffbda6018b85c2))

#### `flame_tiled` - `v1.10.1`

 - **REFACTOR**: Add new lint rules ([#2477](https://github.com/flame-engine/flame/issues/2477)). ([dbda37b8](https://github.com/flame-engine/flame/commit/dbda37b81a9a7411559a6ba919ffbda6018b85c2))

#### `jenny` - `v1.0.2`

 - **REFACTOR**: Add new lint rules ([#2477](https://github.com/flame-engine/flame/issues/2477)). ([dbda37b8](https://github.com/flame-engine/flame/commit/dbda37b81a9a7411559a6ba919ffbda6018b85c2))


## 2023-04-11

### Changes

---

Packages with breaking changes:

 - [`flame_audio` - `v2.0.0`](#flame_audio---v200)

Packages with other changes:

 - There are no other changes in this release.

---

#### `flame_audio` - `v2.0.0`

 - **BREAKING** **FEAT**: Update AudioPlayers to ^4.0.0 ([#2482](https://github.com/flame-engine/flame/issues/2482)). ([47372087](https://github.com/flame-engine/flame/commit/47372087f218e9c00d0fec82084f6edc7cbee5af))


## 2023-04-07

### Changes

---

Packages with breaking changes:

 - There are no breaking changes in this release.

Packages with other changes:

 - [`flame` - `v1.7.2`](#flame---v172)
 - [`flame_isolate` - `v0.3.0+1`](#flame_isolate---v0301)
 - [`flame_tiled` - `v1.10.1`](#flame_tiled---v1101)
 - [`flame_audio` - `v1.4.2`](#flame_audio---v142)
 - [`flame_svg` - `v1.7.3`](#flame_svg---v173)
 - [`flame_test` - `v1.10.1`](#flame_test---v1101)
 - [`flame_flare` - `v1.5.4`](#flame_flare---v154)
 - [`flame_oxygen` - `v0.1.8+2`](#flame_oxygen---v0182)
 - [`flame_bloc` - `v1.8.4`](#flame_bloc---v184)
 - [`flame_fire_atlas` - `v1.3.5`](#flame_fire_atlas---v135)
 - [`flame_forge2d` - `v0.13.0+1`](#flame_forge2d---v01301)
 - [`flame_rive` - `v1.7.1`](#flame_rive---v171)
 - [`flame_noise` - `v0.1.1+1`](#flame_noise---v0111)
 - [`flame_network_assets` - `v0.2.0+1`](#flame_network_assets---v0201)
 - [`flame_lottie` - `v0.2.0+2`](#flame_lottie---v0202)

Packages with dependency updates only:

> Packages listed below depend on other packages in this workspace that have had changes. Their versions have been incremented to bump the minimum dependency versions of the packages they depend upon in this project.

 - `flame_isolate` - `v0.3.0+1`
 - `flame_tiled` - `v1.10.1`
 - `flame_audio` - `v1.4.2`
 - `flame_svg` - `v1.7.3`
 - `flame_test` - `v1.10.1`
 - `flame_flare` - `v1.5.4`
 - `flame_oxygen` - `v0.1.8+2`
 - `flame_bloc` - `v1.8.4`
 - `flame_fire_atlas` - `v1.3.5`
 - `flame_forge2d` - `v0.13.0+1`
 - `flame_rive` - `v1.7.1`
 - `flame_noise` - `v0.1.1+1`
 - `flame_network_assets` - `v0.2.0+1`
 - `flame_lottie` - `v0.2.0+2`

---

#### `flame` - `v1.7.2`

 - **FIX**: A mistake in auto-resizing disabling logic ([#2471](https://github.com/flame-engine/flame/issues/2471)). ([e7ebf8e5](https://github.com/flame-engine/flame/commit/e7ebf8e55a0ad7b0f3aaae769c0b8855fb1efd96))
 - **FIX**: It should be possible to re-add `ColorEffect` ([#2469](https://github.com/flame-engine/flame/issues/2469)). ([6fa9e9d5](https://github.com/flame-engine/flame/commit/6fa9e9d5470eaf36c2db5f3b040e708615dbfcf1))
 - **FEAT**: Add `isDragged` in `DragCallbacks` mixin ([#2472](https://github.com/flame-engine/flame/issues/2472)). ([de630a1c](https://github.com/flame-engine/flame/commit/de630a1c3a779cefe49a598b46e105f19aacebfb))


## 2023-04-05

### Changes

---

Packages with breaking changes:

 - There are no breaking changes in this release.

Packages with other changes:

 - [`flame` - `v1.7.1`](#flame---v171)
 - [`flame_isolate` - `v0.3.0+1`](#flame_isolate---v0301)
 - [`flame_tiled` - `v1.10.1`](#flame_tiled---v1101)
 - [`flame_audio` - `v1.4.2`](#flame_audio---v142)
 - [`flame_svg` - `v1.7.3`](#flame_svg---v173)
 - [`flame_test` - `v1.10.1`](#flame_test---v1101)
 - [`flame_flare` - `v1.5.4`](#flame_flare---v154)
 - [`flame_oxygen` - `v0.1.8+2`](#flame_oxygen---v0182)
 - [`flame_bloc` - `v1.8.4`](#flame_bloc---v184)
 - [`flame_fire_atlas` - `v1.3.5`](#flame_fire_atlas---v135)
 - [`flame_forge2d` - `v0.13.0+1`](#flame_forge2d---v01301)
 - [`flame_rive` - `v1.7.1`](#flame_rive---v171)
 - [`flame_noise` - `v0.1.1+1`](#flame_noise---v0111)
 - [`flame_network_assets` - `v0.2.0+1`](#flame_network_assets---v0201)
 - [`flame_lottie` - `v0.2.0+2`](#flame_lottie---v0202)

Packages with dependency updates only:

> Packages listed below depend on other packages in this workspace that have had changes. Their versions have been incremented to bump the minimum dependency versions of the packages they depend upon in this project.

 - `flame_isolate` - `v0.3.0+1`
 - `flame_tiled` - `v1.10.1`
 - `flame_audio` - `v1.4.2`
 - `flame_svg` - `v1.7.3`
 - `flame_test` - `v1.10.1`
 - `flame_flare` - `v1.5.4`
 - `flame_oxygen` - `v0.1.8+2`
 - `flame_bloc` - `v1.8.4`
 - `flame_fire_atlas` - `v1.3.5`
 - `flame_forge2d` - `v0.13.0+1`
 - `flame_rive` - `v1.7.1`
 - `flame_noise` - `v0.1.1+1`
 - `flame_network_assets` - `v0.2.0+1`
 - `flame_lottie` - `v0.2.0+2`

---

#### `flame` - `v1.7.1`

 - **FIX**: Stop auto-resizing on external size change in sprite based components ([#2467](https://github.com/flame-engine/flame/issues/2467)). ([df236af4](https://github.com/flame-engine/flame/commit/df236af4f0164cc20b664ab973d91b4554b13b62))


## 2023-04-02

### Changes

---

Packages with breaking changes:

 - [`flame` - `v1.7.0`](#flame---v170)
 - [`flame_rive` - `v1.7.0`](#flame_rive---v170)
 - [`flame_test` - `v1.10.0`](#flame_test---v1100)
 - [`flame_forge2d` - `v0.13.0`](#flame_forge2d---v0130)
 - [`flame_isolate` - `v0.3.0`](#flame_isolate---v030)
 - [`flame_network_assets` - `v0.2.0`](#flame_network_assets---v020)

Packages with other changes:

 - [`flame_audio` - `v1.4.1`](#flame_audio---v141)
 - [`flame_bloc` - `v1.8.3`](#flame_bloc---v183)
 - [`flame_fire_atlas` - `v1.3.4`](#flame_fire_atlas---v134)
 - [`flame_flare` - `v1.5.3`](#flame_flare---v153)
 - [`flame_lint` - `v0.2.0+1`](#flame_lint---v0201)
 - [`flame_lottie` - `v0.2.0+1`](#flame_lottie---v0201)
 - [`flame_noise` - `v0.1.1`](#flame_noise---v011)
 - [`flame_oxygen` - `v0.1.8+1`](#flame_oxygen---v0181)
 - [`flame_svg` - `v1.7.2`](#flame_svg---v172)
 - [`flame_tiled` - `v1.10.0`](#flame_tiled---v1100)
 - [`jenny` - `v1.0.1`](#jenny---v101)

---

#### `flame` - `v1.7.0`

 - **REFACTOR**: Remove "items" variable from core Broadphase class. ([#2284](https://github.com/flame-engine/flame/issues/2284)). ([1819c575](https://github.com/flame-engine/flame/commit/1819c5759060579b8fbbf273befe622e799fef32))
 - **REFACTOR**: Added ComponentTreeRoot ([#2300](https://github.com/flame-engine/flame/issues/2300)). ([619b9b15](https://github.com/flame-engine/flame/commit/619b9b15da5c8992547b38bc88a1378933c20026))
 - **REFACTOR**: Simplify how images.dart decodes images ([#2293](https://github.com/flame-engine/flame/issues/2293)). ([b4925423](https://github.com/flame-engine/flame/commit/b4925423d78f4b152b4808e1aceadf211cc7d2e8))
 - **REFACTOR**: Use variable name on toString in component_test.dart ([#2377](https://github.com/flame-engine/flame/issues/2377)). ([f5c0e5e9](https://github.com/flame-engine/flame/commit/f5c0e5e9d0d20e2c89a57f41f968aeafb3a5a753))
 - **REFACTOR**: Remove unused variable "tapTimes" from multi_touch_tap_detector_test.dart ([#2379](https://github.com/flame-engine/flame/issues/2379)). ([cd2b2a10](https://github.com/flame-engine/flame/commit/cd2b2a109707e32a82d9f96b84218d30c03554ab))
 - **REFACTOR**: Component rebalancing is now performed via a global queue ([#2352](https://github.com/flame-engine/flame/issues/2352)). ([1ef51879](https://github.com/flame-engine/flame/commit/1ef518794c8b02995afb1fd0b431a804ef122a4c))
 - **REFACTOR**: Component adoption now handled via ComponentTreeRoot ([#2332](https://github.com/flame-engine/flame/issues/2332)). ([5ceb5dda](https://github.com/flame-engine/flame/commit/5ceb5dda5c6fc27bbad96445f0e99e5e006e5ed3))
 - **FIX**: Auto-resize `SpriteComponent` on sprite change ([#2430](https://github.com/flame-engine/flame/issues/2430)). ([158460d7](https://github.com/flame-engine/flame/commit/158460d7c66c49ffc6ffc99d43a9f547d6ab4e01))
 - **FIX**: Update MoveAlongPathEffect ([#2422](https://github.com/flame-engine/flame/issues/2422)). ([295cd724](https://github.com/flame-engine/flame/commit/295cd72422ee068635057fe9e6684edd5021a9e4))
 - **FIX**: Removed component to be deleted from _broadphaseCheckCache ([#2282](https://github.com/flame-engine/flame/issues/2282)). ([236a74ce](https://github.com/flame-engine/flame/commit/236a74cef160310c1b2d894835fe34157f18178e))
 - **FIX**: TextBoxComponent rendering for new line ([#2413](https://github.com/flame-engine/flame/issues/2413)). ([9008998e](https://github.com/flame-engine/flame/commit/9008998eefe052b145b1d52ef149b99cbf4ddaaa))
 - **FIX**: Buttons in ButtonComponents should not be final ([#2410](https://github.com/flame-engine/flame/issues/2410)). ([55f66add](https://github.com/flame-engine/flame/commit/55f66add6389db212559750d26570d4eeeb54f34))
 - **FIX**: Set size of viewports in `onLoad` ([#2452](https://github.com/flame-engine/flame/issues/2452)). ([d1ac01f5](https://github.com/flame-engine/flame/commit/d1ac01f5754a7ceaf8308ef0561f0bd108e04ba2))
 - **FIX**: Incorrect JoystickComponent position in landscape mode [#2387](https://github.com/flame-engine/flame/issues/2387) ([#2389](https://github.com/flame-engine/flame/issues/2389)). ([f125593a](https://github.com/flame-engine/flame/commit/f125593aaaaef160395b772180b1514f6be3ac4f))
 - **FIX**: RouterComponent replace methods to correctly handle previous/nextRoute ([#2296](https://github.com/flame-engine/flame/issues/2296)). ([2b1f2266](https://github.com/flame-engine/flame/commit/2b1f226618740542127d53a6fafe8bdba3b80593))
 - **FIX**: Use the hitboxParent instead of the parent in the componentTypeCheck ([#2335](https://github.com/flame-engine/flame/issues/2335)). ([7920e2ba](https://github.com/flame-engine/flame/commit/7920e2ba4d52a2461ae4631ffdaf8c52fbcd9dd3))
 - **FIX**: Materialize list in `Component.removeWhere` ([#2458](https://github.com/flame-engine/flame/issues/2458)). ([13cce4ae](https://github.com/flame-engine/flame/commit/13cce4aed61dfd1edd09dee902b402c2b04718cb))
 - **FIX**: TextBoxComponent's boxConfig timePerChar generates "Optimized Out" error [#2143](https://github.com/flame-engine/flame/issues/2143) ([#2328](https://github.com/flame-engine/flame/issues/2328)). ([5874f600](https://github.com/flame-engine/flame/commit/5874f6007ae0c71269bc72da0e420eb7bf8e2173))
 - **FIX**: Camera no longer "sticks" to boundary with BoundedPositionBehavior ([#2307](https://github.com/flame-engine/flame/issues/2307)). ([914dc6a7](https://github.com/flame-engine/flame/commit/914dc6a7cdd3131023f4b2f52cc18450664bd0f3))
 - **FEAT**: Add reusable vector to the Vector2 extension ([#2429](https://github.com/flame-engine/flame/issues/2429)). ([03d45df5](https://github.com/flame-engine/flame/commit/03d45df5d665c3cff353bdde66ac6fc7bed4e1fe))
 - **FEAT**: Change `HasCollisionDetection` to be on `Component` ([#2404](https://github.com/flame-engine/flame/issues/2404)). ([637c258b](https://github.com/flame-engine/flame/commit/637c258b252892fe5bd1dcc3692d49d1072b0f1d))
 - **FEAT**: Added AlignComponent layout component ([#2350](https://github.com/flame-engine/flame/issues/2350)). ([4f5e56f0](https://github.com/flame-engine/flame/commit/4f5e56f05fdcd6b9ad04077093a9eeadf503b9b3))
 - **FEAT**: Add `autoResize` for `SpriteAnimationComponent` and `SpriteAnimationGroupComponent` ([#2453](https://github.com/flame-engine/flame/issues/2453)). ([dbeba238](https://github.com/flame-engine/flame/commit/dbeba23846b229af95057fe0e260fd9e2394c261))
 - **FEAT**: Adding ImageExtension.resize ([#2418](https://github.com/flame-engine/flame/issues/2418)). ([a3f1601d](https://github.com/flame-engine/flame/commit/a3f1601db863b5b1a0eebd08311467836a7b789c))
 - **FEAT**: Add position and anchor params for Sprite and SpriteAnimation Particles ([#2370](https://github.com/flame-engine/flame/issues/2370)). ([181e0b59](https://github.com/flame-engine/flame/commit/181e0b59fd83a765392a1f1170bfa1e840629029))
 - **FEAT**: Add `autoResize` for `SpriteGroupComponent` ([#2442](https://github.com/flame-engine/flame/issues/2442)). ([1576bd83](https://github.com/flame-engine/flame/commit/1576bd83a5abfebe206d4e4f93381f216f895208))
 - **FEAT**: Introduce flame_noise, deprecate NoiseEffectController ([#2393](https://github.com/flame-engine/flame/issues/2393)). ([b2fdf06a](https://github.com/flame-engine/flame/commit/b2fdf06a79520c2b556c1c83de0b0f24df80cfd2))
 - **FEAT**: Added HardwareKeyboardDetector ([#2257](https://github.com/flame-engine/flame/issues/2257)). ([95b1fc0f](https://github.com/flame-engine/flame/commit/95b1fc0fbc1c40962350bc27a15849c32bba5326))
 - **FEAT**: Allow people to opt-out on repaint boundary ([#2341](https://github.com/flame-engine/flame/issues/2341)). ([b6aeec24](https://github.com/flame-engine/flame/commit/b6aeec24d7745626359e05ad2f0ac9acc8d09fbf))
 - **FEAT**: Add `HasTimeScale` mixin ([#2431](https://github.com/flame-engine/flame/issues/2431)). ([d2a8fe01](https://github.com/flame-engine/flame/commit/d2a8fe01fae54ffd1c2e4584dfa7fdcfbcf4068d))
 - **FEAT**: Add DoubleTapCallbacks that receives double-tap events. ([#2327](https://github.com/flame-engine/flame/issues/2327)). ([b5f79d1c](https://github.com/flame-engine/flame/commit/b5f79d1ce45276d957d0512353ca9cc890b6fef1))
 - **FEAT**: Add ability to opt-out flip ([#2316](https://github.com/flame-engine/flame/issues/2316)). ([34c3b6bd](https://github.com/flame-engine/flame/commit/34c3b6bdc4c570f4e8641b11b94efe19bdd1ef32))
 - **FEAT**: Make `limit` field mutable in the `Timer` class ([#2358](https://github.com/flame-engine/flame/issues/2358)). ([4e0a8c46](https://github.com/flame-engine/flame/commit/4e0a8c468886d57b718f853e78a25a03f3b335ae))
 - **DOCS**: Rename caveace asset to cave_ace in our examples ([#2304](https://github.com/flame-engine/flame/issues/2304)). ([e2399f91](https://github.com/flame-engine/flame/commit/e2399f91e3ce39da8db9ae2b9622c8a6050b94b9))
 - **DOCS**: Update cspell github action and configuration ([#2325](https://github.com/flame-engine/flame/issues/2325)). ([e0a4c07f](https://github.com/flame-engine/flame/commit/e0a4c07f2ad6e19830bfdd3af4eb9b148771698a))
 - **DOCS**: Fix actual typos that made into our dictionary ([#2305](https://github.com/flame-engine/flame/issues/2305)). ([343b8452](https://github.com/flame-engine/flame/commit/343b84529d8f06c0d020b97a40c082b71f0de770))
 - **DOCS**: Add Flame logo for pub.dev ([#2338](https://github.com/flame-engine/flame/issues/2338)). ([65091f34](https://github.com/flame-engine/flame/commit/65091f34bf1fbaaf5a30eab6c59486bc0bf55812))
 - **DOCS**: Refactor documentation for GameWidget ([#2344](https://github.com/flame-engine/flame/issues/2344)). ([655824fc](https://github.com/flame-engine/flame/commit/655824fc00460ec16efc861046c7290ffc14c5c4))
 - **DOCS**: Update funding links ([#2420](https://github.com/flame-engine/flame/issues/2420)). ([8294a2a1](https://github.com/flame-engine/flame/commit/8294a2a15638c504aa2b77f967f5963af1f23c2c))
 - **DOCS**: Fix old doc code ([#2322](https://github.com/flame-engine/flame/issues/2322)). ([90321658](https://github.com/flame-engine/flame/commit/90321658c48a9279d4c82d48c6433a818270d03e))
 - **BREAKING** **REFACTOR**: Use ComponentTreeRoot for component removal ([#2317](https://github.com/flame-engine/flame/issues/2317)). ([75446185](https://github.com/flame-engine/flame/commit/754461850f5827e0cb1a4193f72492e6e78fbfa9))
 - **BREAKING** **FEAT**: HasDraggableComponents mixin is no longer needed ([#2312](https://github.com/flame-engine/flame/issues/2312)). ([3faf1149](https://github.com/flame-engine/flame/commit/3faf114994f4c6405a5d1a89559f0976b4e8c911))
 - **BREAKING** **FEAT**: The `HasTappableComponents` mixin is no longer needed ([#2450](https://github.com/flame-engine/flame/issues/2450)). ([b5bdf4ec](https://github.com/flame-engine/flame/commit/b5bdf4ec173e87907a59a9f62fcdf35cc968af2a))

#### `flame_rive` - `v1.7.0`

 - **FIX**: Added useArtboardSize functionality ([#2294](https://github.com/flame-engine/flame/issues/2294)). ([00b0dbef](https://github.com/flame-engine/flame/commit/00b0dbef0df80433eaa78fe3cc68de867d5ca4f5))
 - **DOCS**: Update funding links ([#2420](https://github.com/flame-engine/flame/issues/2420)). ([8294a2a1](https://github.com/flame-engine/flame/commit/8294a2a15638c504aa2b77f967f5963af1f23c2c))
 - **DOCS**: Fix non-markdown section of README files ([#2406](https://github.com/flame-engine/flame/issues/2406)). ([426b3124](https://github.com/flame-engine/flame/commit/426b3124022e567633c76b80eb389ebce1772ca3))
 - **DOCS**: Update all README files for the bridge packages to be consistent and not broken ([#2402](https://github.com/flame-engine/flame/issues/2402)). ([5e8ecf54](https://github.com/flame-engine/flame/commit/5e8ecf5450688b1287368b3fbc7b0e718a29fce4))
 - **BREAKING** **FEAT**: The `HasTappableComponents` mixin is no longer needed ([#2450](https://github.com/flame-engine/flame/issues/2450)). ([b5bdf4ec](https://github.com/flame-engine/flame/commit/b5bdf4ec173e87907a59a9f62fcdf35cc968af2a))

#### `flame_test` - `v1.10.0`

 - **FIX**: Override `remove()` method to fix the functionality issue in the `FlameMultiBlocProvider` ([#2280](https://github.com/flame-engine/flame/issues/2280)). ([6a818464](https://github.com/flame-engine/flame/commit/6a818464f5f942ce25c3c3c59839b6bddaada386))
 - **DOCS**: Update funding links ([#2420](https://github.com/flame-engine/flame/issues/2420)). ([8294a2a1](https://github.com/flame-engine/flame/commit/8294a2a15638c504aa2b77f967f5963af1f23c2c))
 - **DOCS**: Fix non-markdown section of README files ([#2406](https://github.com/flame-engine/flame/issues/2406)). ([426b3124](https://github.com/flame-engine/flame/commit/426b3124022e567633c76b80eb389ebce1772ca3))
 - **DOCS**: Update all README files for the bridge packages to be consistent and not broken ([#2402](https://github.com/flame-engine/flame/issues/2402)). ([5e8ecf54](https://github.com/flame-engine/flame/commit/5e8ecf5450688b1287368b3fbc7b0e718a29fce4))
 - **BREAKING** **FEAT**: The `HasTappableComponents` mixin is no longer needed ([#2450](https://github.com/flame-engine/flame/issues/2450)). ([b5bdf4ec](https://github.com/flame-engine/flame/commit/b5bdf4ec173e87907a59a9f62fcdf35cc968af2a))

#### `flame_forge2d` - `v0.13.0`

 - **DOCS**: Update funding links ([#2420](https://github.com/flame-engine/flame/issues/2420)). ([8294a2a1](https://github.com/flame-engine/flame/commit/8294a2a15638c504aa2b77f967f5963af1f23c2c))
 - **DOCS**: Fix non-markdown section of README files ([#2406](https://github.com/flame-engine/flame/issues/2406)). ([426b3124](https://github.com/flame-engine/flame/commit/426b3124022e567633c76b80eb389ebce1772ca3))
 - **DOCS**: Update all README files for the bridge packages to be consistent and not broken ([#2402](https://github.com/flame-engine/flame/issues/2402)). ([5e8ecf54](https://github.com/flame-engine/flame/commit/5e8ecf5450688b1287368b3fbc7b0e718a29fce4))
 - **DOCS**: Added a page for Joints documentation + ConstantVolumeJoint doc and example ([#2362](https://github.com/flame-engine/flame/issues/2362)). ([957ad240](https://github.com/flame-engine/flame/commit/957ad2402af1c44aea500d77092d387ed463b7e0))
 - **BREAKING** **FEAT**: The `HasTappableComponents` mixin is no longer needed ([#2450](https://github.com/flame-engine/flame/issues/2450)). ([b5bdf4ec](https://github.com/flame-engine/flame/commit/b5bdf4ec173e87907a59a9f62fcdf35cc968af2a))

#### `flame_isolate` - `v0.3.0`

 - **DOCS**: Fix non-markdown section of README files ([#2406](https://github.com/flame-engine/flame/issues/2406)). ([426b3124](https://github.com/flame-engine/flame/commit/426b3124022e567633c76b80eb389ebce1772ca3))
 - **DOCS**: Update all README files for the bridge packages to be consistent and not broken ([#2402](https://github.com/flame-engine/flame/issues/2402)). ([5e8ecf54](https://github.com/flame-engine/flame/commit/5e8ecf5450688b1287368b3fbc7b0e718a29fce4))
 - **BREAKING** **FEAT**: The `HasTappableComponents` mixin is no longer needed ([#2450](https://github.com/flame-engine/flame/issues/2450)). ([b5bdf4ec](https://github.com/flame-engine/flame/commit/b5bdf4ec173e87907a59a9f62fcdf35cc968af2a))

#### `flame_network_assets` - `v0.2.0`

 - **FEAT**: Add network assets package. ([#2314](https://github.com/flame-engine/flame/issues/2314)). ([61d69656](https://github.com/flame-engine/flame/commit/61d69656de2cede71cd4f1b4c469ebb4904c4ce8))
 - **DOCS**: Update funding links ([#2420](https://github.com/flame-engine/flame/issues/2420)). ([8294a2a1](https://github.com/flame-engine/flame/commit/8294a2a15638c504aa2b77f967f5963af1f23c2c))
 - **BREAKING** **FEAT**: The `HasTappableComponents` mixin is no longer needed ([#2450](https://github.com/flame-engine/flame/issues/2450)). ([b5bdf4ec](https://github.com/flame-engine/flame/commit/b5bdf4ec173e87907a59a9f62fcdf35cc968af2a))

#### `flame_audio` - `v1.4.1`

 - **DOCS**: Update funding links ([#2420](https://github.com/flame-engine/flame/issues/2420)). ([8294a2a1](https://github.com/flame-engine/flame/commit/8294a2a15638c504aa2b77f967f5963af1f23c2c))
 - **DOCS**: Update all README files for the bridge packages to be consistent and not broken ([#2402](https://github.com/flame-engine/flame/issues/2402)). ([5e8ecf54](https://github.com/flame-engine/flame/commit/5e8ecf5450688b1287368b3fbc7b0e718a29fce4))

#### `flame_bloc` - `v1.8.3`

 - **REFACTOR**: Remove unused event "ScoreEventCleared" from flame_block example ([#2380](https://github.com/flame-engine/flame/issues/2380)). ([a9db3f4c](https://github.com/flame-engine/flame/commit/a9db3f4ce5c7c11ddca511826bdf9ab72eb19dfe))
 - **FIX**: Override `remove()` method to fix the functionality issue in the `FlameMultiBlocProvider` ([#2280](https://github.com/flame-engine/flame/issues/2280)). ([6a818464](https://github.com/flame-engine/flame/commit/6a818464f5f942ce25c3c3c59839b6bddaada386))
 - **DOCS**: Update funding links ([#2420](https://github.com/flame-engine/flame/issues/2420)). ([8294a2a1](https://github.com/flame-engine/flame/commit/8294a2a15638c504aa2b77f967f5963af1f23c2c))
 - **DOCS**: Fix non-markdown section of README files ([#2406](https://github.com/flame-engine/flame/issues/2406)). ([426b3124](https://github.com/flame-engine/flame/commit/426b3124022e567633c76b80eb389ebce1772ca3))
 - **DOCS**: Update all README files for the bridge packages to be consistent and not broken ([#2402](https://github.com/flame-engine/flame/issues/2402)). ([5e8ecf54](https://github.com/flame-engine/flame/commit/5e8ecf5450688b1287368b3fbc7b0e718a29fce4))
 - **DOCS**: Fix actual typos that made into our dictionary ([#2305](https://github.com/flame-engine/flame/issues/2305)). ([343b8452](https://github.com/flame-engine/flame/commit/343b84529d8f06c0d020b97a40c082b71f0de770))

#### `flame_fire_atlas` - `v1.3.4`

 - **DOCS**: Update funding links ([#2420](https://github.com/flame-engine/flame/issues/2420)). ([8294a2a1](https://github.com/flame-engine/flame/commit/8294a2a15638c504aa2b77f967f5963af1f23c2c))
 - **DOCS**: Fix non-markdown section of README files ([#2406](https://github.com/flame-engine/flame/issues/2406)). ([426b3124](https://github.com/flame-engine/flame/commit/426b3124022e567633c76b80eb389ebce1772ca3))
 - **DOCS**: Update all README files for the bridge packages to be consistent and not broken ([#2402](https://github.com/flame-engine/flame/issues/2402)). ([5e8ecf54](https://github.com/flame-engine/flame/commit/5e8ecf5450688b1287368b3fbc7b0e718a29fce4))
 - **DOCS**: Rename caveace asset to cave_ace in our examples ([#2304](https://github.com/flame-engine/flame/issues/2304)). ([e2399f91](https://github.com/flame-engine/flame/commit/e2399f91e3ce39da8db9ae2b9622c8a6050b94b9))

#### `flame_flare` - `v1.5.3`

 - **DOCS**: Update funding links ([#2420](https://github.com/flame-engine/flame/issues/2420)). ([8294a2a1](https://github.com/flame-engine/flame/commit/8294a2a15638c504aa2b77f967f5963af1f23c2c))
 - **DOCS**: Fix non-markdown section of README files ([#2406](https://github.com/flame-engine/flame/issues/2406)). ([426b3124](https://github.com/flame-engine/flame/commit/426b3124022e567633c76b80eb389ebce1772ca3))
 - **DOCS**: Update all README files for the bridge packages to be consistent and not broken ([#2402](https://github.com/flame-engine/flame/issues/2402)). ([5e8ecf54](https://github.com/flame-engine/flame/commit/5e8ecf5450688b1287368b3fbc7b0e718a29fce4))
 - **DOCS**: Update broken fireslime references ([#2324](https://github.com/flame-engine/flame/issues/2324)). ([cc1957eb](https://github.com/flame-engine/flame/commit/cc1957eb861f65540e3e25635ca046fa34b0b8b5))

#### `flame_lint` - `v0.2.0+1`

 - **DOCS**: Update funding links ([#2420](https://github.com/flame-engine/flame/issues/2420)). ([8294a2a1](https://github.com/flame-engine/flame/commit/8294a2a15638c504aa2b77f967f5963af1f23c2c))
 - **DOCS**: Fix non-markdown section of README files ([#2406](https://github.com/flame-engine/flame/issues/2406)). ([426b3124](https://github.com/flame-engine/flame/commit/426b3124022e567633c76b80eb389ebce1772ca3))
 - **DOCS**: Update all README files for the bridge packages to be consistent and not broken ([#2402](https://github.com/flame-engine/flame/issues/2402)). ([5e8ecf54](https://github.com/flame-engine/flame/commit/5e8ecf5450688b1287368b3fbc7b0e718a29fce4))

#### `flame_lottie` - `v0.2.0+1`

 - **DOCS**: Update funding links ([#2420](https://github.com/flame-engine/flame/issues/2420)). ([8294a2a1](https://github.com/flame-engine/flame/commit/8294a2a15638c504aa2b77f967f5963af1f23c2c))
 - **DOCS**: Fix non-markdown section of README files ([#2406](https://github.com/flame-engine/flame/issues/2406)). ([426b3124](https://github.com/flame-engine/flame/commit/426b3124022e567633c76b80eb389ebce1772ca3))
 - **DOCS**: Update all README files for the bridge packages to be consistent and not broken ([#2402](https://github.com/flame-engine/flame/issues/2402)). ([5e8ecf54](https://github.com/flame-engine/flame/commit/5e8ecf5450688b1287368b3fbc7b0e718a29fce4))

#### `flame_noise` - `v0.1.1`

 - **FEAT**: Introduce flame_noise, deprecate NoiseEffectController ([#2393](https://github.com/flame-engine/flame/issues/2393)). ([b2fdf06a](https://github.com/flame-engine/flame/commit/b2fdf06a79520c2b556c1c83de0b0f24df80cfd2))
 - **DOCS**: Update funding links ([#2420](https://github.com/flame-engine/flame/issues/2420)). ([8294a2a1](https://github.com/flame-engine/flame/commit/8294a2a15638c504aa2b77f967f5963af1f23c2c))

#### `flame_oxygen` - `v0.1.8+1`

 - **DOCS**: Update funding links ([#2420](https://github.com/flame-engine/flame/issues/2420)). ([8294a2a1](https://github.com/flame-engine/flame/commit/8294a2a15638c504aa2b77f967f5963af1f23c2c))
 - **DOCS**: Fix non-markdown section of README files ([#2406](https://github.com/flame-engine/flame/issues/2406)). ([426b3124](https://github.com/flame-engine/flame/commit/426b3124022e567633c76b80eb389ebce1772ca3))
 - **DOCS**: Update all README files for the bridge packages to be consistent and not broken ([#2402](https://github.com/flame-engine/flame/issues/2402)). ([5e8ecf54](https://github.com/flame-engine/flame/commit/5e8ecf5450688b1287368b3fbc7b0e718a29fce4))

#### `flame_svg` - `v1.7.2`

 - **DOCS**: Update funding links ([#2420](https://github.com/flame-engine/flame/issues/2420)). ([8294a2a1](https://github.com/flame-engine/flame/commit/8294a2a15638c504aa2b77f967f5963af1f23c2c))
 - **DOCS**: Fix non-markdown section of README files ([#2406](https://github.com/flame-engine/flame/issues/2406)). ([426b3124](https://github.com/flame-engine/flame/commit/426b3124022e567633c76b80eb389ebce1772ca3))
 - **DOCS**: Update all README files for the bridge packages to be consistent and not broken ([#2402](https://github.com/flame-engine/flame/issues/2402)). ([5e8ecf54](https://github.com/flame-engine/flame/commit/5e8ecf5450688b1287368b3fbc7b0e718a29fce4))

#### `flame_tiled` - `v1.10.0`

 - **REFACTOR**: Divide TileLayer by its Layer type ([#2326](https://github.com/flame-engine/flame/issues/2326)). ([0c14d4cb](https://github.com/flame-engine/flame/commit/0c14d4cb87ba81957221695547bc06111a28617a))
 - **FIX**: TiledComponent now can be safely loaded regardless of the order ([#2391](https://github.com/flame-engine/flame/issues/2391)). ([4ddc4bba](https://github.com/flame-engine/flame/commit/4ddc4bba2b67ebd8c9c0e9e761eee34d2a74f62b))
 - **FEAT**: Use cached image when creating single source TiledAtlas if available ([#2348](https://github.com/flame-engine/flame/issues/2348)). ([73467c94](https://github.com/flame-engine/flame/commit/73467c941d89f68598c6dc297937af9d9896a949))
 - **FEAT**: Add ability to opt-out flip ([#2316](https://github.com/flame-engine/flame/issues/2316)). ([34c3b6bd](https://github.com/flame-engine/flame/commit/34c3b6bdc4c570f4e8641b11b94efe19bdd1ef32))
 - **DOCS**: Update funding links ([#2420](https://github.com/flame-engine/flame/issues/2420)). ([8294a2a1](https://github.com/flame-engine/flame/commit/8294a2a15638c504aa2b77f967f5963af1f23c2c))
 - **DOCS**: Fix broken image link on flame_tiled pub ([#2407](https://github.com/flame-engine/flame/issues/2407)). ([0d24a6c8](https://github.com/flame-engine/flame/commit/0d24a6c8ed4a5d4de2e653a6430a635ef881ee2e))
 - **DOCS**: Fix non-markdown section of README files ([#2406](https://github.com/flame-engine/flame/issues/2406)). ([426b3124](https://github.com/flame-engine/flame/commit/426b3124022e567633c76b80eb389ebce1772ca3))
 - **DOCS**: Update all README files for the bridge packages to be consistent and not broken ([#2402](https://github.com/flame-engine/flame/issues/2402)). ([5e8ecf54](https://github.com/flame-engine/flame/commit/5e8ecf5450688b1287368b3fbc7b0e718a29fce4))

#### `jenny` - `v1.0.1`

 - **DOCS**: Update funding links ([#2420](https://github.com/flame-engine/flame/issues/2420)). ([8294a2a1](https://github.com/flame-engine/flame/commit/8294a2a15638c504aa2b77f967f5963af1f23c2c))
 - **DOCS**: Create "dart" domain extension ([#2278](https://github.com/flame-engine/flame/issues/2278)). ([3b87e838](https://github.com/flame-engine/flame/commit/3b87e838f6308867b52f7c0cec3fa07e5629f3dc))


## 2023-01-28

### Changes

---

Packages with breaking changes:

 - There are no breaking changes in this release.

Packages with other changes:

 - [`flame_lint` - `v0.2.0`](#flame_lint---v020)

---

#### `flame_lint` - `v0.2.0`

 - Removed invariant_booleans


## 2023-01-25

### Changes

---

Packages with breaking changes:

 - There are no breaking changes in this release.

Packages with other changes:

 - [`flame_audio` - `v1.4.0`](#flame_audio---v140)

---

#### `flame_audio` - `v1.4.0`


## 2023-01-14

### Changes

---

Packages with breaking changes:

 - [`flame` - `v1.6.0`](#flame---v160)
 - [`flame_rive` - `v1.6.0`](#flame_rive---v160)
 - [`flame_isolate` - `v0.2.0`](#flame_isolate---v020)
 - [`flame_lottie` - `v0.2.0`](#flame_lottie---v020)

Packages with other changes:

 - [`flame_forge2d` - `v0.12.5`](#flame_forge2d---v0125)
 - [`flame_jenny` - `v1.0.0`](#flame_jenny---v100)
 - [`jenny` - `v1.0.0`](#jenny---v100)
 - [`flame_oxygen` - `v0.1.8`](#flame_oxygen---v018)
 - [`flame_bloc` - `v1.8.2`](#flame_bloc---v182)
 - [`flame_test` - `v1.9.2`](#flame_test---v192)
 - [`flame_tiled` - `v1.9.1`](#flame_tiled---v191)
 - [`flame_audio` - `v1.3.5`](#flame_audio---v135)
 - [`flame_flare` - `v1.5.2`](#flame_flare---v152)
 - [`flame_svg` - `v1.7.1`](#flame_svg---v171)
 - [`flame_fire_atlas` - `v1.3.3`](#flame_fire_atlas---v133)

Packages with dependency updates only:

> Packages listed below depend on other packages in this workspace that have had changes. Their versions have been incremented to bump the minimum dependency versions of the packages they depend upon in this project.

 - `flame_tiled` - `v1.9.1`
 - `flame_audio` - `v1.3.5`
 - `flame_flare` - `v1.5.2`
 - `flame_svg` - `v1.7.1`
 - `flame_fire_atlas` - `v1.3.3`

---

#### `flame` - `v1.6.0`

 - **PERF**: Avoid Vector2 creation in `Sprite.render` ([#2261](https://github.com/flame-engine/flame/issues/2261)). ([736733d9](https://github.com/flame-engine/flame/commit/736733d91398721452edb4c2600a47277bb5abee))
 - **FIX**: Only use initialized game for tests and remove setMount from onGameResize ([#2246](https://github.com/flame-engine/flame/issues/2246)). ([2a0f1d4b](https://github.com/flame-engine/flame/commit/2a0f1d4bdc2688e596481aad39762f94bf1cc8f1))
 - **FIX**: Re-use paint object in ImageParticle ([#2210](https://github.com/flame-engine/flame/issues/2210)). ([7a945d96](https://github.com/flame-engine/flame/commit/7a945d960c9b88fde11bbc480c0429295445cf30))
 - **FIX**: Depend on test: any for flame_test ([#2207](https://github.com/flame-engine/flame/issues/2207)). ([acfd418d](https://github.com/flame-engine/flame/commit/acfd418d882ee6872f3aa9961c39680ec123c2e6))
 - **FEAT**: Add a `canSee` method to the `CameraComponent` ([#2270](https://github.com/flame-engine/flame/issues/2270)). ([2347c8f5](https://github.com/flame-engine/flame/commit/2347c8f567c88f29540ef1d8e1c7c4b65fe31b06))
 - **FEAT**: Add `moveBy` to `CameraComponent` ([#2269](https://github.com/flame-engine/flame/issues/2269)). ([51e54ebe](https://github.com/flame-engine/flame/commit/51e54ebef823258f28f3e1a60a645ba4dd12e337))
 - **FEAT**: Added computed property CameraComponent.visibleWorldRect ([#2267](https://github.com/flame-engine/flame/issues/2267)). ([f4b0e73f](https://github.com/flame-engine/flame/commit/f4b0e73fa1f068b8867177e9761b2c4b01216a31))
 - **DOCS**: Update example to not create Rect objects ([#2254](https://github.com/flame-engine/flame/issues/2254)). ([a306338b](https://github.com/flame-engine/flame/commit/a306338b112955972b56baa9ac6e419b1af43ef1))
 - **DOCS**: Teh -> the ([#2225](https://github.com/flame-engine/flame/issues/2225)). ([ff7f36d0](https://github.com/flame-engine/flame/commit/ff7f36d0f682206c6c666ea2dbdce8a2e1d19601))
 - **BREAKING** **REFACTOR**: The method `onLoad()` now returns `FutureOr<void>` ([#2228](https://github.com/flame-engine/flame/issues/2228)). ([d898b539](https://github.com/flame-engine/flame/commit/d898b539f734d3e14c47990ef0727043a0e32efb))
 - **BREAKING** **FEAT**: Adds new route methods `pushReplacement`, `pushReplacementNamed`, and `pushReplacementOverlay` ([#2249](https://github.com/flame-engine/flame/issues/2249)). ([a2772b4e](https://github.com/flame-engine/flame/commit/a2772b4e0f828ee8475603ffdaf5ff63872a1a33))

#### `flame_rive` - `v1.6.0`

 - **FIX**: Depend on test: any for flame_test ([#2207](https://github.com/flame-engine/flame/issues/2207)). ([acfd418d](https://github.com/flame-engine/flame/commit/acfd418d882ee6872f3aa9961c39680ec123c2e6))
 - **BREAKING** **REFACTOR**: The method `onLoad()` now returns `FutureOr<void>` ([#2228](https://github.com/flame-engine/flame/issues/2228)). ([d898b539](https://github.com/flame-engine/flame/commit/d898b539f734d3e14c47990ef0727043a0e32efb))

#### `flame_isolate` - `v0.2.0`

 - **FIX**: Depend on test: any for flame_test ([#2207](https://github.com/flame-engine/flame/issues/2207)). ([acfd418d](https://github.com/flame-engine/flame/commit/acfd418d882ee6872f3aa9961c39680ec123c2e6))
 - **BREAKING** **REFACTOR**: The method `onLoad()` now returns `FutureOr<void>` ([#2228](https://github.com/flame-engine/flame/issues/2228)). ([d898b539](https://github.com/flame-engine/flame/commit/d898b539f734d3e14c47990ef0727043a0e32efb))

#### `flame_lottie` - `v0.2.0`

 - **FIX**: Depend on test: any for flame_test ([#2207](https://github.com/flame-engine/flame/issues/2207)). ([acfd418d](https://github.com/flame-engine/flame/commit/acfd418d882ee6872f3aa9961c39680ec123c2e6))
 - **BREAKING** **REFACTOR**: The method `onLoad()` now returns `FutureOr<void>` ([#2228](https://github.com/flame-engine/flame/issues/2228)). ([d898b539](https://github.com/flame-engine/flame/commit/d898b539f734d3e14c47990ef0727043a0e32efb))

#### `flame_forge2d` - `v0.12.5`

 - **FIX**: Depend on test: any for flame_test ([#2207](https://github.com/flame-engine/flame/issues/2207)). ([acfd418d](https://github.com/flame-engine/flame/commit/acfd418d882ee6872f3aa9961c39680ec123c2e6))

#### `flame_jenny` - `v1.0.0`

 - **FIX**: Jenny now always stringifies whole numbers without .0 ([#2265](https://github.com/flame-engine/flame/issues/2265)). ([f262b7ee](https://github.com/flame-engine/flame/commit/f262b7ee39a270f5bfbf3bf2be89d85549d16cd1))
 - **FIX**: Remove whitespace before a command in dialogue option ([#2187](https://github.com/flame-engine/flame/issues/2187)). ([00f0e330](https://github.com/flame-engine/flame/commit/00f0e330b429f5f7ae87742ff5814f44924cb202))
 - **FIX**: Remove flutter from jenny ([#2162](https://github.com/flame-engine/flame/issues/2162)). ([29db304d](https://github.com/flame-engine/flame/commit/29db304d36fdf791f6c9df4c69b95511190b3057))
 - **FEAT**: Added the <<character>> command to Jenny ([#2274](https://github.com/flame-engine/flame/issues/2274)). ([6548e9cb](https://github.com/flame-engine/flame/commit/6548e9cb0a91353489812e211c2aa098fbd04f55))
 - **FEAT**: Added if() built-in function in Jenny ([#2259](https://github.com/flame-engine/flame/issues/2259)). ([087229ed](https://github.com/flame-engine/flame/commit/087229ede545644026eb6c303a037a93a792eaf2))
 - **FEAT**: Added command <<visit>> ([#2233](https://github.com/flame-engine/flame/issues/2233)). ([a90f90ef](https://github.com/flame-engine/flame/commit/a90f90efc5556f9697d409fd6a1e6558ae9e8236))
 - **FEAT**: OnDialogueChoice now returns null by default ([#2234](https://github.com/flame-engine/flame/issues/2234)). ([e2ab129e](https://github.com/flame-engine/flame/commit/e2ab129e5974485241223528fc50f3049ffecf8f))
 - **FEAT**: Added DialogueView.onNodeFinish event ([#2229](https://github.com/flame-engine/flame/issues/2229)). ([19a1f09a](https://github.com/flame-engine/flame/commit/19a1f09acc45199a4411c7026b8adf61a5a5a11f))
 - **FEAT**: Arguments of a UserDefinedCommand are now accessible ([#2224](https://github.com/flame-engine/flame/issues/2224)). ([0a9eaf38](https://github.com/flame-engine/flame/commit/0a9eaf380194e93c89cb8b2f5677d476a33eb83b))
 - **FEAT**: Added escape sequence \- in yarn language ([#2220](https://github.com/flame-engine/flame/issues/2220)). ([43eacdd1](https://github.com/flame-engine/flame/commit/43eacdd1f5e1419c310f5cd34d1476adf03eb4d6))
 - **FEAT**: Add support for user-defined functions in jenny ([#2194](https://github.com/flame-engine/flame/issues/2194)). ([9364a0dd](https://github.com/flame-engine/flame/commit/9364a0dd324a2ed57b1e9a8907108da796e59352))
 - **FEAT**: Support for builtin functions in jenny ([#2192](https://github.com/flame-engine/flame/issues/2192)). ([82d35b8a](https://github.com/flame-engine/flame/commit/82d35b8a5dc8a9378dfee348b3392d0afabf2bc8))
 - **FEAT**: Add command <<local>> ([#2185](https://github.com/flame-engine/flame/issues/2185)). ([9e677e7d](https://github.com/flame-engine/flame/commit/9e677e7dc74bbe15b8521ec945a5b92ce8a4180a))
 - **FEAT**: Added support for markup attributes ([#2183](https://github.com/flame-engine/flame/issues/2183)). ([f887545b](https://github.com/flame-engine/flame/commit/f887545b127b41412b29217c52f9ec6ea0d6c885))
 - **FEAT**: Support user-defined commands ([#2168](https://github.com/flame-engine/flame/issues/2168)). ([ffb36a89](https://github.com/flame-engine/flame/commit/ffb36a89efdcd976fe63c16f27741b77b08aa284))
 - **FEAT**: Added the <<set>> command ([#2155](https://github.com/flame-engine/flame/issues/2155)). ([2b306d9e](https://github.com/flame-engine/flame/commit/2b306d9ee9c92416fe82b42e9a4ee33b280af46f))
 - **FEAT**: Implement the <<declare>> command ([#2154](https://github.com/flame-engine/flame/issues/2154)). ([8d592f17](https://github.com/flame-engine/flame/commit/8d592f17411800a5239720687149122eaf7750f1))
 - **FEAT**: Trim whitespace at the end of dialogue lines ([#2149](https://github.com/flame-engine/flame/issues/2149)). ([9c25e631](https://github.com/flame-engine/flame/commit/9c25e631e2e5ed5c593dbca4f498105e2c8fff66))
 - **FEAT**: DialogueRunner for jenny ([#2113](https://github.com/flame-engine/flame/issues/2113)). ([5ba6ff21](https://github.com/flame-engine/flame/commit/5ba6ff21a633a9f80e15228faaa31c6f0a3df60c))
 - **FEAT**: Support commands outside of nodes ([#2145](https://github.com/flame-engine/flame/issues/2145)). ([b313d630](https://github.com/flame-engine/flame/commit/b313d6302d713bda7baee7e90ecdb2fef2a3d6fc))
 - **FEAT**: Parser for jenny ([#2103](https://github.com/flame-engine/flame/issues/2103)). ([4e4117c8](https://github.com/flame-engine/flame/commit/4e4117c8a25a24686d6f571a9a5a23e19d660282))
 - **DOCS**: Update readme for jenny ([#2266](https://github.com/flame-engine/flame/issues/2266)). ([79129e4a](https://github.com/flame-engine/flame/commit/79129e4a72cec7c5bcfd67c17f9718b7528ac08c))
 - **DOCS**: Documentation for markup in Jenny ([#2262](https://github.com/flame-engine/flame/issues/2262)). ([8b57eaa1](https://github.com/flame-engine/flame/commit/8b57eaa1abc88d154ff45fdab6932bd15fe6eef7))
 - **DOCS**: Documentation for built-in functions in Jenny ([#2258](https://github.com/flame-engine/flame/issues/2258)). ([2eac6f5a](https://github.com/flame-engine/flame/commit/2eac6f5aa9485458203df7f41dc8c3718973eb61))
 - **DOCS**: Added documentation for basic expressions in Jenny ([#2256](https://github.com/flame-engine/flame/issues/2256)). ([69c13568](https://github.com/flame-engine/flame/commit/69c13568e647225bd2a2994e24a45f8258af0d16))
 - **DOCS**: Description of jenny package ([#2102](https://github.com/flame-engine/flame/issues/2102)). ([a99c9303](https://github.com/flame-engine/flame/commit/a99c93038128f913b7df05a5ef3e041e607069b9))

#### `jenny` - `v1.0.0`

 - **FIX**: Jenny now always stringifies whole numbers without .0 ([#2265](https://github.com/flame-engine/flame/issues/2265)). ([f262b7ee](https://github.com/flame-engine/flame/commit/f262b7ee39a270f5bfbf3bf2be89d85549d16cd1))
 - **FIX**: Remove whitespace before a command in dialogue option ([#2187](https://github.com/flame-engine/flame/issues/2187)). ([00f0e330](https://github.com/flame-engine/flame/commit/00f0e330b429f5f7ae87742ff5814f44924cb202))
 - **FIX**: Remove flutter from jenny ([#2162](https://github.com/flame-engine/flame/issues/2162)). ([29db304d](https://github.com/flame-engine/flame/commit/29db304d36fdf791f6c9df4c69b95511190b3057))
 - **FEAT**: Added the <<character>> command to Jenny ([#2274](https://github.com/flame-engine/flame/issues/2274)). ([6548e9cb](https://github.com/flame-engine/flame/commit/6548e9cb0a91353489812e211c2aa098fbd04f55))
 - **FEAT**: Added if() built-in function in Jenny ([#2259](https://github.com/flame-engine/flame/issues/2259)). ([087229ed](https://github.com/flame-engine/flame/commit/087229ede545644026eb6c303a037a93a792eaf2))
 - **FEAT**: Added command <<visit>> ([#2233](https://github.com/flame-engine/flame/issues/2233)). ([a90f90ef](https://github.com/flame-engine/flame/commit/a90f90efc5556f9697d409fd6a1e6558ae9e8236))
 - **FEAT**: OnDialogueChoice now returns null by default ([#2234](https://github.com/flame-engine/flame/issues/2234)). ([e2ab129e](https://github.com/flame-engine/flame/commit/e2ab129e5974485241223528fc50f3049ffecf8f))
 - **FEAT**: Added DialogueView.onNodeFinish event ([#2229](https://github.com/flame-engine/flame/issues/2229)). ([19a1f09a](https://github.com/flame-engine/flame/commit/19a1f09acc45199a4411c7026b8adf61a5a5a11f))
 - **FEAT**: Arguments of a UserDefinedCommand are now accessible ([#2224](https://github.com/flame-engine/flame/issues/2224)). ([0a9eaf38](https://github.com/flame-engine/flame/commit/0a9eaf380194e93c89cb8b2f5677d476a33eb83b))
 - **FEAT**: Added escape sequence \- in yarn language ([#2220](https://github.com/flame-engine/flame/issues/2220)). ([43eacdd1](https://github.com/flame-engine/flame/commit/43eacdd1f5e1419c310f5cd34d1476adf03eb4d6))
 - **FEAT**: Add support for user-defined functions in jenny ([#2194](https://github.com/flame-engine/flame/issues/2194)). ([9364a0dd](https://github.com/flame-engine/flame/commit/9364a0dd324a2ed57b1e9a8907108da796e59352))
 - **FEAT**: Support for builtin functions in jenny ([#2192](https://github.com/flame-engine/flame/issues/2192)). ([82d35b8a](https://github.com/flame-engine/flame/commit/82d35b8a5dc8a9378dfee348b3392d0afabf2bc8))
 - **FEAT**: Add command <<local>> ([#2185](https://github.com/flame-engine/flame/issues/2185)). ([9e677e7d](https://github.com/flame-engine/flame/commit/9e677e7dc74bbe15b8521ec945a5b92ce8a4180a))
 - **FEAT**: Added support for markup attributes ([#2183](https://github.com/flame-engine/flame/issues/2183)). ([f887545b](https://github.com/flame-engine/flame/commit/f887545b127b41412b29217c52f9ec6ea0d6c885))
 - **FEAT**: Support user-defined commands ([#2168](https://github.com/flame-engine/flame/issues/2168)). ([ffb36a89](https://github.com/flame-engine/flame/commit/ffb36a89efdcd976fe63c16f27741b77b08aa284))
 - **FEAT**: Added the <<set>> command ([#2155](https://github.com/flame-engine/flame/issues/2155)). ([2b306d9e](https://github.com/flame-engine/flame/commit/2b306d9ee9c92416fe82b42e9a4ee33b280af46f))
 - **FEAT**: Implement the <<declare>> command ([#2154](https://github.com/flame-engine/flame/issues/2154)). ([8d592f17](https://github.com/flame-engine/flame/commit/8d592f17411800a5239720687149122eaf7750f1))
 - **FEAT**: Trim whitespace at the end of dialogue lines ([#2149](https://github.com/flame-engine/flame/issues/2149)). ([9c25e631](https://github.com/flame-engine/flame/commit/9c25e631e2e5ed5c593dbca4f498105e2c8fff66))
 - **FEAT**: DialogueRunner for jenny ([#2113](https://github.com/flame-engine/flame/issues/2113)). ([5ba6ff21](https://github.com/flame-engine/flame/commit/5ba6ff21a633a9f80e15228faaa31c6f0a3df60c))
 - **FEAT**: Support commands outside of nodes ([#2145](https://github.com/flame-engine/flame/issues/2145)). ([b313d630](https://github.com/flame-engine/flame/commit/b313d6302d713bda7baee7e90ecdb2fef2a3d6fc))
 - **FEAT**: Parser for jenny ([#2103](https://github.com/flame-engine/flame/issues/2103)). ([4e4117c8](https://github.com/flame-engine/flame/commit/4e4117c8a25a24686d6f571a9a5a23e19d660282))
 - **DOCS**: Update readme for jenny ([#2266](https://github.com/flame-engine/flame/issues/2266)). ([79129e4a](https://github.com/flame-engine/flame/commit/79129e4a72cec7c5bcfd67c17f9718b7528ac08c))
 - **DOCS**: Documentation for markup in Jenny ([#2262](https://github.com/flame-engine/flame/issues/2262)). ([8b57eaa1](https://github.com/flame-engine/flame/commit/8b57eaa1abc88d154ff45fdab6932bd15fe6eef7))
 - **DOCS**: Documentation for built-in functions in Jenny ([#2258](https://github.com/flame-engine/flame/issues/2258)). ([2eac6f5a](https://github.com/flame-engine/flame/commit/2eac6f5aa9485458203df7f41dc8c3718973eb61))
 - **DOCS**: Added documentation for basic expressions in Jenny ([#2256](https://github.com/flame-engine/flame/issues/2256)). ([69c13568](https://github.com/flame-engine/flame/commit/69c13568e647225bd2a2994e24a45f8258af0d16))
 - **DOCS**: Description of jenny package ([#2102](https://github.com/flame-engine/flame/issues/2102)). ([a99c9303](https://github.com/flame-engine/flame/commit/a99c93038128f913b7df05a5ef3e041e607069b9))

#### `flame_oxygen` - `v0.1.8`

#### `flame_bloc` - `v1.8.2`

 - **FIX**: Depend on test: any for flame_test ([#2207](https://github.com/flame-engine/flame/issues/2207)). ([acfd418d](https://github.com/flame-engine/flame/commit/acfd418d882ee6872f3aa9961c39680ec123c2e6))

#### `flame_test` - `v1.9.2`

 - **FIX**: Only use initialized game for tests and remove setMount from onGameResize ([#2246](https://github.com/flame-engine/flame/issues/2246)). ([2a0f1d4b](https://github.com/flame-engine/flame/commit/2a0f1d4bdc2688e596481aad39762f94bf1cc8f1))
 - **FIX**: Depend on test: any for flame_test ([#2207](https://github.com/flame-engine/flame/issues/2207)). ([acfd418d](https://github.com/flame-engine/flame/commit/acfd418d882ee6872f3aa9961c39680ec123c2e6))
 - **FIX**: Depend on test: any for flame_test. ([fcf5521c](https://github.com/flame-engine/flame/commit/fcf5521ce4e975830f728481591a1731ce5edb77))


## 2023-01-03

### Changes

---

Packages with breaking changes:

 - There are no breaking changes in this release.

Packages with other changes:

 - [`flame_audio` - `v1.3.4`](#flame_audio---v134)

---

#### `flame_audio` - `v1.3.4`


## 2022-11-28

### Changes

---

Packages with breaking changes:

 - There are no breaking changes in this release.

Packages with other changes:

 - [`flame_test` - `v1.9.1`](#flame_test---v191)

---

#### `flame_test` - `v1.9.1`

 - **FIX**: Depend on test: any for flame_test. ([fcf5521c](https://github.com/flame-engine/flame/commit/fcf5521ce4e975830f728481591a1731ce5edb77))


## 2022-11-27

### Changes

---

Packages with breaking changes:

 - [`flame` - `v1.5.0`](#flame---v150)

Packages with other changes:

 - [`flame_bloc` - `v1.8.1`](#flame_bloc---v181)
 - [`flame_forge2d` - `v0.12.4`](#flame_forge2d---v0124)
 - [`flame_lottie` - `v0.1.1`](#flame_lottie---v011)
 - [`flame_rive` - `v1.5.3`](#flame_rive---v153)
 - [`flame_svg` - `v1.7.0`](#flame_svg---v170)
 - [`flame_test` - `v1.9.0`](#flame_test---v190)
 - [`flame_tiled` - `v1.9.0`](#flame_tiled---v190)
 - [`flame_isolate` - `v0.1.1`](#flame_isolate---v011)
 - [`flame_audio` - `v1.3.3`](#flame_audio---v133)
 - [`flame_flare` - `v1.5.1`](#flame_flare---v151)
 - [`flame_oxygen` - `v0.1.7`](#flame_oxygen---v017)
 - [`flame_fire_atlas` - `v1.3.2`](#flame_fire_atlas---v132)

---

#### `flame` - `v1.5.0`

 - **REFACTOR**: OpacityEffect now uses opacity instead of alpha internally ([#2064](https://github.com/flame-engine/flame/issues/2064)). ([b3b67301](https://github.com/flame-engine/flame/commit/b3b673011cfafc4a9add55f682e7e1074b4dc64b))
 - **REFACTOR**: Game render box cleanup ([#1691](https://github.com/flame-engine/flame/issues/1691)). ([60a5830d](https://github.com/flame-engine/flame/commit/60a5830d3e596c9c6086f8253eb663b01e4f440b))
 - **FIX**: Event mixins missing `@mustCallSuper` ([#2036](https://github.com/flame-engine/flame/issues/2036)). ([c26d5da3](https://github.com/flame-engine/flame/commit/c26d5da3730d4d38002259fbc0d314ae63c3bdff))
 - **FIX**: SpeedController advance() should execute after its effect's onStart() ([#2173](https://github.com/flame-engine/flame/issues/2173)). ([7a1e2e8b](https://github.com/flame-engine/flame/commit/7a1e2e8b657b6b18dc08afd53f52ba513cecb4d9))
 - **FIX**: Refresh vertices on size change of `RectangleComponent` ([#2167](https://github.com/flame-engine/flame/issues/2167)). ([4020d68b](https://github.com/flame-engine/flame/commit/4020d68b4afcba554f8ee493840d7b74b68f6293))
 - **FIX**: Fix coordinate system calculation in FixedAspectRationViewport ([#2175](https://github.com/flame-engine/flame/issues/2175)). ([c9c9881c](https://github.com/flame-engine/flame/commit/c9c9881ccacbdaf1759c7c85b2edff94aa633427))
 - **FIX**: SpriteButtonComponent missing `@mustCallSuper` added ([#2001](https://github.com/flame-engine/flame/issues/2001)). ([45a9d79b](https://github.com/flame-engine/flame/commit/45a9d79bc477d9d9a772d0c2812d82e8a1962468))
 - **FIX**: Focus handling with a scope on the `GameWidget` ([#1725](https://github.com/flame-engine/flame/issues/1725)). ([d1cd8517](https://github.com/flame-engine/flame/commit/d1cd8517e4f9d4aadeacf7caf3ca91440e6041d7))
 - **FIX**: RemoveEffect should work within SequenceEffect ([#2110](https://github.com/flame-engine/flame/issues/2110)). ([03e1f33d](https://github.com/flame-engine/flame/commit/03e1f33d3de1e0d6a16b1f11a7fe503ece9f5d24))
 - **FIX**: [#1966](https://github.com/flame-engine/flame/issues/1966) unit test for `Particles` ([#2097](https://github.com/flame-engine/flame/issues/2097)). ([59bd7ebb](https://github.com/flame-engine/flame/commit/59bd7ebb9deaea44001edce02b306ffaacf5afc8))
 - **FIX**: OpacityEffect custom paint override ([#2056](https://github.com/flame-engine/flame/issues/2056)). ([fe9d4d9b](https://github.com/flame-engine/flame/commit/fe9d4d9bfb97557434d2844357d70db666b02e49))
 - **FIX**: [#1998](https://github.com/flame-engine/flame/issues/1998) ([#2013](https://github.com/flame-engine/flame/issues/2013)). ([f63711dc](https://github.com/flame-engine/flame/commit/f63711dc56961fc664358b4789de5d78b43ce081))
 - **FIX**: solid circles and polygons intersection ([#2067](https://github.com/flame-engine/flame/issues/2067)). ([62c5c2e1](https://github.com/flame-engine/flame/commit/62c5c2e14479c4cb1b0e5487ab6a96182c0f1338))
 - **FIX**: [#2017](https://github.com/flame-engine/flame/issues/2017) ([#2039](https://github.com/flame-engine/flame/issues/2039)). ([7f546b0f](https://github.com/flame-engine/flame/commit/7f546b0f13306edb92a68a331bf28127a42138ce))
 - **FIX**: Exception when having multiple calls to dispose() function of a Svg instance ([#2085](https://github.com/flame-engine/flame/issues/2085)). ([a287904e](https://github.com/flame-engine/flame/commit/a287904eb5dbbe70128207a6f6a56ff98dfbf579))
 - **FIX**: Add missing hitbox parameters ([#2070](https://github.com/flame-engine/flame/issues/2070)). ([8aacb555](https://github.com/flame-engine/flame/commit/8aacb5557ac299852530c5023a1ddd2bebbad564))
 - **FIX**: Change `Vector2.zero()` to `Vector2(0, -1)` in `Vector2Extensions.fromRadians()` ([#2016](https://github.com/flame-engine/flame/issues/2016)). ([801c683c](https://github.com/flame-engine/flame/commit/801c683c6cf448e6d0ae34231a656bc72bcce00a))
 - **FEAT**: Add children to `World` constructor ([#2093](https://github.com/flame-engine/flame/issues/2093)). ([3af416dc](https://github.com/flame-engine/flame/commit/3af416dc2e61c7f43334d06add651d7c21bb511b))
 - **FEAT**: Add paint layers to HasPaint and associated component renders ([#2073](https://github.com/flame-engine/flame/issues/2073)). ([9e6bf4fb](https://github.com/flame-engine/flame/commit/9e6bf4fbccd13b8e7ef848bc77d4da510680539f))
 - **FEAT**: Add SizeProvider to clip_component and custom_paint_component. ([#2100](https://github.com/flame-engine/flame/issues/2100)). ([bb710646](https://github.com/flame-engine/flame/commit/bb71064647c71ff42be40c34fd1231ad9b1c43f0))
 - **FEAT**: Added HasGameReference mixin ([#1828](https://github.com/flame-engine/flame/issues/1828)). ([12ce270b](https://github.com/flame-engine/flame/commit/12ce270b9b3102b6a9bb1f468369a4fce1e064e6))
 - **FEAT**: Added toString method to all the drags events message handlers ([#2014](https://github.com/flame-engine/flame/issues/2014)). ([a34f1df7](https://github.com/flame-engine/flame/commit/a34f1df7904f0bd54fb8465265b24e21be0f4dc2))
 - **FEAT**: Add `maintainState` property to Route ([#2161](https://github.com/flame-engine/flame/issues/2161)). ([576ceaac](https://github.com/flame-engine/flame/commit/576ceaac178de87a3c0ed54c87373cf83f7bd868))
 - **FEAT**: add onCancelled to ButtonComponent and HudButtonComponent ([#2193](https://github.com/flame-engine/flame/issues/2193)). ([e7f08906](https://github.com/flame-engine/flame/commit/e7f089066620ed5326e94ac8d4b7f5705c3ae3f7))
 - **FEAT**: onComponentTypeCheck support for ShapeHitbox ([#1981](https://github.com/flame-engine/flame/issues/1981)). ([f840210b](https://github.com/flame-engine/flame/commit/f840210bf97f9da406282212db265a976506ebf8))
 - **FEAT**: Added glow effect using maskFilter ([#2129](https://github.com/flame-engine/flame/issues/2129)). ([bcecd3c1](https://github.com/flame-engine/flame/commit/bcecd3c1bd400c155807beb77651ebd2ee6f627c))
 - **FEAT**: Add support for styles propagating through the text node tree ([#1915](https://github.com/flame-engine/flame/issues/1915)). ([b5780d42](https://github.com/flame-engine/flame/commit/b5780d421234636144794e663559cec8987656a4))
 - **FEAT**: Added SpriteFont class ([#1992](https://github.com/flame-engine/flame/issues/1992)). ([a0d7eada](https://github.com/flame-engine/flame/commit/a0d7eadae40d4653ce0f5286e7236bedc17ed8cb))
 - **FEAT**: Added CameraComponent.withFixedResolution() constructor ([#2176](https://github.com/flame-engine/flame/issues/2176)). ([e289f118](https://github.com/flame-engine/flame/commit/e289f118eedebf512899d66e01f6234e3890a0d6))
 - **FEAT**: Add optional maxDistance to raycast ([#2012](https://github.com/flame-engine/flame/issues/2012)). ([6b78b10f](https://github.com/flame-engine/flame/commit/6b78b10fb36a9fed5d9c7b06aea89e088bc4d985))
 - **FEAT**: `clampLength` for `Vector2` extension ([#2190](https://github.com/flame-engine/flame/issues/2190)). ([51a896b2](https://github.com/flame-engine/flame/commit/51a896b2c801089968b630937fd23c12a98dbc40))
 - **FEAT**: Adding onChildrenChanged ([#1976](https://github.com/flame-engine/flame/issues/1976)). ([3d043b86](https://github.com/flame-engine/flame/commit/3d043b86f7382cf54313ac59eb3818a5b2788824))
 - **FEAT**: Adding ComponentNotifier API ([#1889](https://github.com/flame-engine/flame/issues/1889)). ([bd7f51f5](https://github.com/flame-engine/flame/commit/bd7f51f5b63e303b8b7230643dccbd040d2708a5))
 - **FEAT**: `removed` future + `isRemoved` field for `Component` ([#2080](https://github.com/flame-engine/flame/issues/2080)). ([9f322785](https://github.com/flame-engine/flame/commit/9f3227857327a99730fd4d02f099acef7c57ca67))
 - **BREAKING** **FIX**: Correct coordinate system for a circular viewport ([#2174](https://github.com/flame-engine/flame/issues/2174)). ([93dc4325](https://github.com/flame-engine/flame/commit/93dc4325476d4727a4de8dd8f0caf3ee081c0ad6))
 - **BREAKING** **FIX**: PolygonComponent no longer modifies _vertices ([#2061](https://github.com/flame-engine/flame/issues/2061)). ([8cd4793a](https://github.com/flame-engine/flame/commit/8cd4793ac2ecade740e53ad628db3f2f9ca6949a))
 - **BREAKING** **FEAT**: Add OpacityProvider ([#2062](https://github.com/flame-engine/flame/issues/2062)). ([0255cc32](https://github.com/flame-engine/flame/commit/0255cc32f0c77b9507f9ad0eddcbd8c35840c885))

#### `flame_bloc` - `v1.8.1`

 - **FIX**: flame-bloc : Remove final keyword from subscription in FlameBlocListenable ([#2098](https://github.com/flame-engine/flame/issues/2098)). ([8a136c99](https://github.com/flame-engine/flame/commit/8a136c9985d7878940f2103484b90e1ffb202a03))

#### `flame_forge2d` - `v0.12.4`

 - **FIX**: 🐛 unit test for `Forge2dGame` ([#2068](https://github.com/flame-engine/flame/issues/2068)). ([d659b85d](https://github.com/flame-engine/flame/commit/d659b85d090614ebb3df06fb68254c087f6f9dff))

#### `flame_lottie` - `v0.1.1`

 - **FEAT**: Lottie bridge package ([#2157](https://github.com/flame-engine/flame/issues/2157)). ([3a73d145](https://github.com/flame-engine/flame/commit/3a73d1456c01937234f0503fd077193884912fbb))

#### `flame_rive` - `v1.5.3`

 - **FIX**: Export rive from flame_rive ([#2130](https://github.com/flame-engine/flame/issues/2130)). ([d1833329](https://github.com/flame-engine/flame/commit/d1833329028d1d8483faa049c6e1ad478ba9ca49))
 - **FIX**: antialiasing should change the artboard([#2076](https://github.com/flame-engine/flame/issues/2076)). ([47970224](https://github.com/flame-engine/flame/commit/47970224f8c9c90718c54301ee69d9cddcced87b))
 - **FIX**: Fixed null exception when no artboard with specified name is exists ([#2069](https://github.com/flame-engine/flame/issues/2069)). ([a3a65f30](https://github.com/flame-engine/flame/commit/a3a65f30ab64c029da66f9ded08eaf730d760336))

#### `flame_svg` - `v1.7.0`

 - **FIX**: Exception when having multiple calls to dispose() function of a Svg instance ([#2085](https://github.com/flame-engine/flame/issues/2085)). ([a287904e](https://github.com/flame-engine/flame/commit/a287904eb5dbbe70128207a6f6a56ff98dfbf579))
 - **FIX**: SvgComponent getting blurred and pixelized ([#2084](https://github.com/flame-engine/flame/issues/2084)). ([0911d10b](https://github.com/flame-engine/flame/commit/0911d10b9177c0dbcc6f9ba927f99cb7e04182a5))
 - **FEAT**: Expose paint from svgComponent to set opacity and have opacity effects ([#2092](https://github.com/flame-engine/flame/issues/2092)). ([bedacd0c](https://github.com/flame-engine/flame/commit/bedacd0c8c79f4f060b002eeddaa9d2ef68d316c))

#### `flame_test` - `v1.9.0`

 - **FEAT**: Add support for styles propagating through the text node tree ([#1915](https://github.com/flame-engine/flame/issues/1915)). ([b5780d42](https://github.com/flame-engine/flame/commit/b5780d421234636144794e663559cec8987656a4))

#### `flame_tiled` - `v1.9.0`

 - **FEAT**: Rename internal classes clashes with Tiled ([#2139](https://github.com/flame-engine/flame/issues/2139)). ([2224eaac](https://github.com/flame-engine/flame/commit/2224eaac701414deb76bac7f7c40a56387cdf817))

#### `flame_isolate` - `v0.1.1`

#### `flame_audio` - `v1.3.3`

#### `flame_flare` - `v1.5.1`

#### `flame_oxygen` - `v0.1.7`

#### `flame_fire_atlas` - `v1.3.2`


## 2022-11-22

### Changes

---

Packages with breaking changes:

 - There are no breaking changes in this release.

Packages with other changes:

 - [`flame_isolate` - `v0.1.0`](#flame_isolate---v010)

---

#### `flame_isolate` - `v0.1.0`

 - **FEAT**: FlameIsolate - a neat way of handling threads ([#1909](https://github.com/flame-engine/flame/issues/1909)). ([b25b9356](https://github.com/flame-engine/flame/commit/b25b935644e258c37145bd6abfe0962d8e872801))


## 2022-10-01

### Changes

---

Packages with breaking changes:

 - [`flame` - `v1.4.0`](#flame---v140)
 - [`flame_test` - `v1.8.0`](#flame_test---v180)

Packages with other changes:

 - [`flame_oxygen` - `v0.1.6`](#flame_oxygen---v016)
 - [`flame_bloc` - `v1.8.0`](#flame_bloc---v180)
 - [`flame_flare` - `v1.5.0`](#flame_flare---v150)
 - [`flame_forge2d` - `v0.12.3`](#flame_forge2d---v0123)
 - [`flame_lint` - `v0.1.3`](#flame_lint---v013)
 - [`flame_svg` - `v1.6.0`](#flame_svg---v160)
 - [`flame_tiled` - `v1.8.0`](#flame_tiled---v180)
 - [`flame_rive` - `v1.5.2`](#flame_rive---v152)
 - [`flame_audio` - `v1.3.2`](#flame_audio---v132)
 - [`flame_fire_atlas` - `v1.3.1`](#flame_fire_atlas---v131)

Packages with dependency updates only:

> Packages listed below depend on other packages in this workspace that have had changes. Their versions have been incremented to bump the minimum dependency versions of the packages they depend upon in this project.

 - `flame_rive` - `v1.5.2`
 - `flame_audio` - `v1.3.2`
 - `flame_fire_atlas` - `v1.3.1`

---

#### `flame` - `v1.4.0`

 - **REFACTOR**: move broadphase-related functionality into separate subdirectory ([#1943](https://github.com/flame-engine/flame/issues/1943)). ([f23acd41](https://github.com/flame-engine/flame/commit/f23acd41e0341909200437bfb6487cbe9ca58a53))
 - **REFACTOR**: used simpler and more implicit widgets in GameWidget ([#1862](https://github.com/flame-engine/flame/issues/1862)). ([44d17c64](https://github.com/flame-engine/flame/commit/44d17c64f80601159cc7f579cef8568727d411b3))
 - **PERF**: SpriteAnimationWidget will re-render only when needed ([#1876](https://github.com/flame-engine/flame/issues/1876)). ([bb678301](https://github.com/flame-engine/flame/commit/bb6783010f3c14362dcb4ed9182c4d240080a7f6))
 - **FIX**: Hitbox children of a CompositeHitbox to return correct parent ([#1922](https://github.com/flame-engine/flame/issues/1922)). ([d518705e](https://github.com/flame-engine/flame/commit/d518705e1665bfc3f54256f113f0d2227fab14dd))
 - **FIX**: OpacityEffect rounding error calculation ([#1933](https://github.com/flame-engine/flame/issues/1933)). ([4cfcfa64](https://github.com/flame-engine/flame/commit/4cfcfa644c641e85cad891b07eac956db8534590))
 - **FIX**: Expose hitboxParent from Hitbox ([#1928](https://github.com/flame-engine/flame/issues/1928)). ([3ba93351](https://github.com/flame-engine/flame/commit/3ba933513d9a4dd73c56e0a3f304069f6989c002))
 - **FIX**: Raycast from CircleHitbox's center ([#1918](https://github.com/flame-engine/flame/issues/1918)). ([57ca47c8](https://github.com/flame-engine/flame/commit/57ca47c8ccfdb0b78c541efa833d32ae746e6616))
 - **FEAT**: quad tree broadphase support  ([#1894](https://github.com/flame-engine/flame/issues/1894)). ([e33d5410](https://github.com/flame-engine/flame/commit/e33d5410a3bfdae5fdde8939b55d7ce178a0c5c8))
 - **FEAT**: Make `_ButtonState` public for SpriteButtonComponent ([#1941](https://github.com/flame-engine/flame/issues/1941)). ([e80412c5](https://github.com/flame-engine/flame/commit/e80412c56895a51ec281e90506f0104d0a9ce47e))
 - **FEAT**: Add possibility for solid hitboxes ([#1919](https://github.com/flame-engine/flame/issues/1919)). ([205ac561](https://github.com/flame-engine/flame/commit/205ac561eef4becd90a0d5dca2301b988b15959f))
 - **FEAT**: Adding callbacks for EffectController ([#1926](https://github.com/flame-engine/flame/issues/1926)) ([#1931](https://github.com/flame-engine/flame/issues/1931)). ([8dcdf155](https://github.com/flame-engine/flame/commit/8dcdf1557903a46766c46e6cf0855f0d6b524608))
 - **FEAT**: Added DebugTextFormatter ([#1921](https://github.com/flame-engine/flame/issues/1921)). ([426827d1](https://github.com/flame-engine/flame/commit/426827d19e803158dab271dce1fbf93bd09f07de))
 - **FEAT**: Add lookAt method for PositionComponent ([#1891](https://github.com/flame-engine/flame/issues/1891)). ([720c3566](https://github.com/flame-engine/flame/commit/720c3566b02815d7ca2c4b45861041f2bddca0fc))
 - **FEAT**: add applyLifespanToChildren to Particle generate ([#1911](https://github.com/flame-engine/flame/issues/1911)). ([884d5190](https://github.com/flame-engine/flame/commit/884d5190adbe6ddfc9b7d006cda310cc656d7da1))
 - **FEAT**: Add broadphase generics to CollisionDetection ([#1908](https://github.com/flame-engine/flame/issues/1908)). ([f7714122](https://github.com/flame-engine/flame/commit/f77141229345c24abdd8a09934397dc09c622352))
 - **FEAT**: Adding ClipComponent ([#1769](https://github.com/flame-engine/flame/issues/1769)). ([f34d86db](https://github.com/flame-engine/flame/commit/f34d86db1e459fb5fe36b601631d6c1999fadf8c))
 - **FEAT**: Add support for isometric staggered maps ([#1895](https://github.com/flame-engine/flame/issues/1895)). ([96be8408](https://github.com/flame-engine/flame/commit/96be840899022a024cef1eb853818d8138592000))
 - **FEAT**: Experimental integer viewport ([#1866](https://github.com/flame-engine/flame/issues/1866)). ([63822de3](https://github.com/flame-engine/flame/commit/63822de34c7938232e4048c7bb0e9bb648929ac8))
 - **FEAT**: RecycledQueue now supports modification during iteration ([#1884](https://github.com/flame-engine/flame/issues/1884)). ([01b59493](https://github.com/flame-engine/flame/commit/01b59493024a93d7f3ecbe0627ad0c6a4b2454a1))
 - **FEAT**: Allow children of `ComposedParticle` to have varied lifespan ([#1879](https://github.com/flame-engine/flame/issues/1879)). ([6db519ec](https://github.com/flame-engine/flame/commit/6db519ecd09752e15848d29a616a5152f7269686))
 - **FEAT**: Add `removeWhere` to `Component` ([#1878](https://github.com/flame-engine/flame/issues/1878)). ([abd28f28](https://github.com/flame-engine/flame/commit/abd28f28a627799ea4602026d91f52bc97feb91e))
 - **FEAT**: Added RecycledQueue class ([#1864](https://github.com/flame-engine/flame/issues/1864)). ([9457e38e](https://github.com/flame-engine/flame/commit/9457e38ebc2485e235e3bdc01c7ba43097139db7))
 - **FEAT**: Possibility to ignore hitboxes for ray casting ([#1863](https://github.com/flame-engine/flame/issues/1863)). ([b22bc643](https://github.com/flame-engine/flame/commit/b22bc6438407808e2d4137b4021a2777c3c22afe))
 - **DOCS**: Added Style Guide and Test Writing Guide ([#1897](https://github.com/flame-engine/flame/issues/1897)). ([999caca1](https://github.com/flame-engine/flame/commit/999caca10fbeb834e85461b6cc828b1bce62bbf9))
 - **BREAKING** **FIX**: Make all `ComponentSet` modifications internal ([#1877](https://github.com/flame-engine/flame/issues/1877)). ([f26a066d](https://github.com/flame-engine/flame/commit/f26a066d77f1f79915c52c93038bde7d3571e068))
 - **BREAKING** **CHORE**: Remove functions/classes that were scheduled for removal in v1.3.0 ([#1867](https://github.com/flame-engine/flame/issues/1867)). ([00ab347c](https://github.com/flame-engine/flame/commit/00ab347c57b151c9232c85150e36a8a7781511a3))

#### `flame_test` - `v1.8.0`

 - **FEAT**: Add avoid_final_parameters, depend_on_referenced_packages, unnecessary_to_list_in_spreads ([#1927](https://github.com/flame-engine/flame/issues/1927)). ([deccb434](https://github.com/flame-engine/flame/commit/deccb4349d38b6a91ccf5bdf229980b2a3296ce5))
 - **FEAT**: Added DebugTextFormatter ([#1921](https://github.com/flame-engine/flame/issues/1921)). ([426827d1](https://github.com/flame-engine/flame/commit/426827d19e803158dab271dce1fbf93bd09f07de))
 - **BREAKING** **CHORE**: Remove functions/classes that were scheduled for removal in v1.3.0 ([#1867](https://github.com/flame-engine/flame/issues/1867)). ([00ab347c](https://github.com/flame-engine/flame/commit/00ab347c57b151c9232c85150e36a8a7781511a3))

#### `flame_oxygen` - `v0.1.6`

#### `flame_bloc` - `v1.8.0`

 - **FEAT**: Add avoid_final_parameters, depend_on_referenced_packages, unnecessary_to_list_in_spreads ([#1927](https://github.com/flame-engine/flame/issues/1927)). ([deccb434](https://github.com/flame-engine/flame/commit/deccb4349d38b6a91ccf5bdf229980b2a3296ce5))
 - **FEAT**: Add `removeWhere` to `Component` ([#1878](https://github.com/flame-engine/flame/issues/1878)). ([abd28f28](https://github.com/flame-engine/flame/commit/abd28f28a627799ea4602026d91f52bc97feb91e))

#### `flame_flare` - `v1.5.0`

 - **FEAT**: Add avoid_final_parameters, depend_on_referenced_packages, unnecessary_to_list_in_spreads ([#1927](https://github.com/flame-engine/flame/issues/1927)). ([deccb434](https://github.com/flame-engine/flame/commit/deccb4349d38b6a91ccf5bdf229980b2a3296ce5))

#### `flame_forge2d` - `v0.12.3`

 - **FEAT**: Allow flame_forge2d's followBodyComponent to follow centre of mass ([#1947](https://github.com/flame-engine/flame/issues/1947)) ([#1948](https://github.com/flame-engine/flame/issues/1948)). ([c4fd2ba5](https://github.com/flame-engine/flame/commit/c4fd2ba5402f42d5a333270f401bb7208e050986))
 - **DOCS**: Fix broken link in forge2d readme ([#1853](https://github.com/flame-engine/flame/issues/1853)). ([31d39f86](https://github.com/flame-engine/flame/commit/31d39f86708295ef19624554e636e1ddd4846c4d))

#### `flame_lint` - `v0.1.3`

 - **FEAT**: Add avoid_final_parameters, depend_on_referenced_packages, unnecessary_to_list_in_spreads ([#1927](https://github.com/flame-engine/flame/issues/1927)). ([deccb434](https://github.com/flame-engine/flame/commit/deccb4349d38b6a91ccf5bdf229980b2a3296ce5))

#### `flame_svg` - `v1.6.0`

 - **FEAT**: Add avoid_final_parameters, depend_on_referenced_packages, unnecessary_to_list_in_spreads ([#1927](https://github.com/flame-engine/flame/issues/1927)). ([deccb434](https://github.com/flame-engine/flame/commit/deccb4349d38b6a91ccf5bdf229980b2a3296ce5))

#### `flame_tiled` - `v1.8.0`

 - **REFACTOR**: Split layers into files ([#1916](https://github.com/flame-engine/flame/issues/1916)). ([dac2ee13](https://github.com/flame-engine/flame/commit/dac2ee1375a0ed9535ccd5052e0960043ec8d3d2))
 - **FIX**: Take scale into account ([#1906](https://github.com/flame-engine/flame/issues/1906)). ([27ab12ff](https://github.com/flame-engine/flame/commit/27ab12ff6865e5d3d567c4714c4737cd7a0bc1fa))
 - **FEAT**: Animated tile support! ([#1930](https://github.com/flame-engine/flame/issues/1930)). ([6410dc75](https://github.com/flame-engine/flame/commit/6410dc753ce1d044e2d8ea8061186c88d80589e9))
 - **FEAT**: Add avoid_final_parameters, depend_on_referenced_packages, unnecessary_to_list_in_spreads ([#1927](https://github.com/flame-engine/flame/issues/1927)). ([deccb434](https://github.com/flame-engine/flame/commit/deccb4349d38b6a91ccf5bdf229980b2a3296ce5))
 - **FEAT**: Tiled component is positionable ([#1900](https://github.com/flame-engine/flame/issues/1900)). ([88cb2a05](https://github.com/flame-engine/flame/commit/88cb2a05c37535053ece3eb19311c4c78fac249c))
 - **FEAT**: Add support for isometric staggered maps ([#1895](https://github.com/flame-engine/flame/issues/1895)). ([96be8408](https://github.com/flame-engine/flame/commit/96be840899022a024cef1eb853818d8138592000))
 - **FEAT**: Adding support for Group layer nesting for RenderableTileMap ([#1886](https://github.com/flame-engine/flame/issues/1886)). ([5ed34547](https://github.com/flame-engine/flame/commit/5ed345471da0586a2a3071a523c4e5b6d7f184c0))
 - **FEAT**: Hexagonal maps ([#1892](https://github.com/flame-engine/flame/issues/1892)). ([29bda336](https://github.com/flame-engine/flame/commit/29bda336b8febe9cb08dc621da3dc0271c6d2802))
 - **FEAT**: Add isometric support for flame_tiled ([#1885](https://github.com/flame-engine/flame/issues/1885)). ([cf828823](https://github.com/flame-engine/flame/commit/cf82882390efc45a0b2323463b4b28e557f5df48))


## 2022-08-19

### Changes

---

Packages with breaking changes:

 - [`flame` - `v1.3.0`](#flame---v130)
 - [`flame_test` - `v1.7.0`](#flame_test---v170)

Packages with other changes:

 - [`flame_bloc` - `v1.7.0`](#flame_bloc---v170)
 - [`flame_fire_atlas` - `v1.3.0`](#flame_fire_atlas---v130)
 - [`flame_flare` - `v1.4.0`](#flame_flare---v140)
 - [`flame_forge2d` - `v0.12.2`](#flame_forge2d---v0122)
 - [`flame_lint` - `v0.1.2`](#flame_lint---v012)
 - [`flame_oxygen` - `v0.1.5`](#flame_oxygen---v015)
 - [`flame_svg` - `v1.5.0`](#flame_svg---v150)
 - [`flame_tiled` - `v1.7.2`](#flame_tiled---v172)
 - [`flame_rive` - `v1.5.1`](#flame_rive---v151)
 - [`flame_audio` - `v1.3.1`](#flame_audio---v131)

Packages with dependency updates only:

> Packages listed below depend on other packages in this workspace that have had changes. Their versions have been incremented to bump the minimum dependency versions of the packages they depend upon in this project.

 - `flame_rive` - `v1.5.1`
 - `flame_audio` - `v1.3.1`

---

#### `flame` - `v1.3.0`

 - **REFACTOR**: Use new "super"-constructors in ShapeComponents ([#1752](https://github.com/flame-engine/flame/issues/1752)). ([b69e8d85](https://github.com/flame-engine/flame/commit/b69e8d85c77346081d1fc5a2ee5cbf9c204a9edf))
 - **REFACTOR**: Game is now a class, not a mixin ([#1751](https://github.com/flame-engine/flame/issues/1751)). ([5225a4eb](https://github.com/flame-engine/flame/commit/5225a4ebd55a21f5709ccab9a1e24c728b2747ed))
 - **PERF**: Use TextElements within the TextComponent ([#1802](https://github.com/flame-engine/flame/issues/1802)). ([7b044430](https://github.com/flame-engine/flame/commit/7b04443046978c9bcdcf3eacab4813f3bcb545af))
 - **PERF**: Avoid unnecessary copy in AssetsCache.readBinaryFile ([#1749](https://github.com/flame-engine/flame/issues/1749)). ([7e79638d](https://github.com/flame-engine/flame/commit/7e79638dd577cb07d55402d4e862de08ce832b85))
 - **FIX**: ButtonComponent behavior when the engine is paused ([#1726](https://github.com/flame-engine/flame/issues/1726)). ([197e63d6](https://github.com/flame-engine/flame/commit/197e63d69e2a4c6779e49b918d05a60447ce9462))
 - **FIX**: Correct flutter constraint ([#1731](https://github.com/flame-engine/flame/issues/1731)). ([c7383843](https://github.com/flame-engine/flame/commit/c738384314a1a5c3695d1c3adaebcb59604df83a))
 - **FIX**: World component can now be queried with `componentsAtPoint` ([#1739](https://github.com/flame-engine/flame/issues/1739)). ([f750d705](https://github.com/flame-engine/flame/commit/f750d705d14dd0ba95d550b2b8a320201a96584b))
 - **FIX**: Merge basic and advanced gesture detectors ([#1718](https://github.com/flame-engine/flame/issues/1718)). ([f08f8e12](https://github.com/flame-engine/flame/commit/f08f8e12f5322c7bea1491908f06b350e13c14b7))
 - **FIX**: Correct key events in GameWidget.controller ([#1745](https://github.com/flame-engine/flame/issues/1745)). ([01ed2ec9](https://github.com/flame-engine/flame/commit/01ed2ec967ee29c946c967786eec6bf7cc6ec958))
 - **FIX**: Camera incorrect follow with zoom and world boundaries. ([c1756177](https://github.com/flame-engine/flame/commit/c175617714e2f15f4379ed8ea412c7cb8bfa1842))
 - **FIX**: Add missing paint arguments on shapes ([#1727](https://github.com/flame-engine/flame/issues/1727)). ([e59f3428](https://github.com/flame-engine/flame/commit/e59f3428469e4298d812bb665171679df8895daf))
 - **FIX**: Delay camera update ([#1811](https://github.com/flame-engine/flame/issues/1811)). ([a5598a8f](https://github.com/flame-engine/flame/commit/a5598a8fa43552028654a3a4b760b7b375dd81e5))
 - **FIX**: Overlays can now be properly added during onLoad ([#1759](https://github.com/flame-engine/flame/issues/1759)). ([9f35b154](https://github.com/flame-engine/flame/commit/9f35b15420bea9ac5eeeddc245484b854e8eed38))
 - **FIX**: SpriteAnimationWidget can now be update animation safely ([#1738](https://github.com/flame-engine/flame/issues/1738)). ([eb070195](https://github.com/flame-engine/flame/commit/eb0701951c165576fac1f540c8860e560a8961e6))
 - **FIX**: JoystickComponent drags using the delta Viewport ([#1831](https://github.com/flame-engine/flame/issues/1831)). ([54e40de6](https://github.com/flame-engine/flame/commit/54e40de674f628282ea19af4f5ce2173ee48fd6e))
 - **FIX**: Specify size for the SpriteWidget ([#1760](https://github.com/flame-engine/flame/issues/1760)). ([82f75fcb](https://github.com/flame-engine/flame/commit/82f75fcb57c8185a7138ee6ceb9082a418099df8))
 - **FEAT**: New colors to palette.dart ([#1783](https://github.com/flame-engine/flame/issues/1783)). ([85cd60e1](https://github.com/flame-engine/flame/commit/85cd60e16c7b4dafdf1823bf85a7ae8a50fd05f2))
 - **FEAT**: add `children` argument to `SpriteComponent.fromImage` ([#1793](https://github.com/flame-engine/flame/issues/1793)). ([80a63362](https://github.com/flame-engine/flame/commit/80a633622a5784f377ef08515115d66ff200b848))
 - **FEAT**: Added Decorator class and HasDecorator mixin ([#1781](https://github.com/flame-engine/flame/issues/1781)). ([8d00847c](https://github.com/flame-engine/flame/commit/8d00847cfcecb60a96772ccba1bcf3aec56b78ff))
 - **FEAT**: Added TextFormatter classes ([#1720](https://github.com/flame-engine/flame/issues/1720)). ([c44272be](https://github.com/flame-engine/flame/commit/c44272be45eadfabc8f03ef250eb663e59ef2aab))
 - **FEAT**: Move to Flutter 3.0.0 and Dart 2.17.0 ([#1713](https://github.com/flame-engine/flame/issues/1713)). ([2a41d0d6](https://github.com/flame-engine/flame/commit/2a41d0d683391194b7209c47bde91199ab7a663e))
 - **FEAT**: Added Rotate3DDecorator ([#1805](https://github.com/flame-engine/flame/issues/1805)). ([f05194c8](https://github.com/flame-engine/flame/commit/f05194c80c4d09d024be486882e5defbb10dd506))
 - **FEAT**: Added Shadow3DDecorator ([#1812](https://github.com/flame-engine/flame/issues/1812)). ([0a41b2da](https://github.com/flame-engine/flame/commit/0a41b2dabe51dbdfcd0b4c9f441bc4cc2e9e1b5e))
 - **FEAT**: Add tertiary tap detector mixin ([#1815](https://github.com/flame-engine/flame/issues/1815)). ([e9e7b0d5](https://github.com/flame-engine/flame/commit/e9e7b0d598dac588daf37010b53221da4aea24be))
 - **FEAT**: Add `Ray2` class to be used in raytracing/casting ([#1788](https://github.com/flame-engine/flame/issues/1788)). ([26196c01](https://github.com/flame-engine/flame/commit/26196c0152911c6d20b3feffe96319df4a625a7f))
 - **FEAT**: Added RouterComponent  ([#1755](https://github.com/flame-engine/flame/issues/1755)). ([24092bd7](https://github.com/flame-engine/flame/commit/24092bd72d2e615c06908d9784f19fecb4d0b8b9))
 - **FEAT**: Structured text and text styles ([#1830](https://github.com/flame-engine/flame/issues/1830)). ([bfdc3a29](https://github.com/flame-engine/flame/commit/bfdc3a291ba08ee0df07a80f0709c8470ed8a739))
 - **FEAT**: Drag events that dispatch using componentsAtPoint ([#1715](https://github.com/flame-engine/flame/issues/1715)). ([10669c12](https://github.com/flame-engine/flame/commit/10669c12702a3a82fcf5be9161107dce4349a79f))
 - **FEAT**: Added routes that can return a value ([#1848](https://github.com/flame-engine/flame/issues/1848)). ([f1b276e0](https://github.com/flame-engine/flame/commit/f1b276e020c6f80a18764e63ffbea21abb52b1f2))
 - **FEAT**: PositionComponent now has a built-in Decorator ([#1846](https://github.com/flame-engine/flame/issues/1846)). ([8dd52c33](https://github.com/flame-engine/flame/commit/8dd52c338bbd66938dd90c068f99107337bae4ea))
 - **FEAT**: add `HasAncestor` mixin ([#1711](https://github.com/flame-engine/flame/issues/1711)). ([987a44f4](https://github.com/flame-engine/flame/commit/987a44f441429534c743388b44e6d84b28e8f5ca))
 - **FEAT**: Added ability to control overlays via the RouterComponent ([#1840](https://github.com/flame-engine/flame/issues/1840)). ([e2de70c9](https://github.com/flame-engine/flame/commit/e2de70c98afabb6e570c3442213b2246a724bdd9))
 - **FEAT**: Add vector projection and inversion ([#1787](https://github.com/flame-engine/flame/issues/1787)). ([d197870f](https://github.com/flame-engine/flame/commit/d197870f529829adc51bbafc28180bde33d6f2cb))
 - **DOCS**: Klondike tutorial, part 4 ([#1740](https://github.com/flame-engine/flame/issues/1740)). ([02d0b71b](https://github.com/flame-engine/flame/commit/02d0b71b2379d12b36b53a76b6bcf5f4018ec9df))
 - **BREAKING** **REFACTOR**: Matcher closeToVector() now accepts Vector2 as an argument ([#1761](https://github.com/flame-engine/flame/issues/1761)). ([c5083501](https://github.com/flame-engine/flame/commit/c5083501d54023f04d3f09e3358bce039ade9a20))
 - **BREAKING** **PERF**: Game.images/assets are now same as Flame.images/assets by default ([#1775](https://github.com/flame-engine/flame/issues/1775)). ([0ccb0e2e](https://github.com/flame-engine/flame/commit/0ccb0e2ef525661830c7b4662662ba64fda830fe))
 - **BREAKING** **FEAT**: Raycasting and raytracing ([#1785](https://github.com/flame-engine/flame/issues/1785)). ([ed452dd1](https://github.com/flame-engine/flame/commit/ed452dd172289d49b6a9fbf02ee5b61b33f84c4c))

#### `flame_test` - `v1.7.0`

 - **FIX**: Correct flutter constraint ([#1731](https://github.com/flame-engine/flame/issues/1731)). ([c7383843](https://github.com/flame-engine/flame/commit/c738384314a1a5c3695d1c3adaebcb59604df83a))
 - **FEAT**: Added size parameter for testGolden() ([#1780](https://github.com/flame-engine/flame/issues/1780)). ([8e41d83e](https://github.com/flame-engine/flame/commit/8e41d83ea4e057e1a428f0456450d697351683bf))
 - **FEAT**: Move to Flutter 3.0.0 and Dart 2.17.0 ([#1713](https://github.com/flame-engine/flame/issues/1713)). ([2a41d0d6](https://github.com/flame-engine/flame/commit/2a41d0d683391194b7209c47bde91199ab7a663e))
 - **BREAKING** **REFACTOR**: Matcher closeToVector() now accepts Vector2 as an argument ([#1761](https://github.com/flame-engine/flame/issues/1761)). ([c5083501](https://github.com/flame-engine/flame/commit/c5083501d54023f04d3f09e3358bce039ade9a20))

#### `flame_bloc` - `v1.7.0`

 - **FIX**: Correct flutter constraint ([#1731](https://github.com/flame-engine/flame/issues/1731)). ([c7383843](https://github.com/flame-engine/flame/commit/c738384314a1a5c3695d1c3adaebcb59604df83a))
 - **FEAT**: Adding bloc getter to FlameBlocListenable mixin ([#1732](https://github.com/flame-engine/flame/issues/1732)). ([3d19caa3](https://github.com/flame-engine/flame/commit/3d19caa36dcb470b306b841ef9c03647a2f307d7))
 - **FEAT**: Move to Flutter 3.0.0 and Dart 2.17.0 ([#1713](https://github.com/flame-engine/flame/issues/1713)). ([2a41d0d6](https://github.com/flame-engine/flame/commit/2a41d0d683391194b7209c47bde91199ab7a663e))
 - **DOCS**: Fixing typo in `FlameMultiBlocProvider` dartdoc. ([67be6ab8](https://github.com/flame-engine/flame/commit/67be6ab86264f6def4b1b3b0e4ba00763c7dab4e))
 - **DOCS**: updating README to the new flame bloc version ([#1737](https://github.com/flame-engine/flame/issues/1737)). ([6a2356aa](https://github.com/flame-engine/flame/commit/6a2356aa5eba1696caa6f88ecfe8143c4ffdb507))

#### `flame_fire_atlas` - `v1.3.0`

 - **PERF**: Avoid unnecessary copy in AssetsCache.readBinaryFile ([#1749](https://github.com/flame-engine/flame/issues/1749)). ([7e79638d](https://github.com/flame-engine/flame/commit/7e79638dd577cb07d55402d4e862de08ce832b85))
 - **FIX**: Correct flutter constraint ([#1731](https://github.com/flame-engine/flame/issues/1731)). ([c7383843](https://github.com/flame-engine/flame/commit/c738384314a1a5c3695d1c3adaebcb59604df83a))
 - **FEAT**: Move to Flutter 3.0.0 and Dart 2.17.0 ([#1713](https://github.com/flame-engine/flame/issues/1713)). ([2a41d0d6](https://github.com/flame-engine/flame/commit/2a41d0d683391194b7209c47bde91199ab7a663e))

#### `flame_flare` - `v1.4.0`

 - **FIX**: Correct flutter constraint ([#1731](https://github.com/flame-engine/flame/issues/1731)). ([c7383843](https://github.com/flame-engine/flame/commit/c738384314a1a5c3695d1c3adaebcb59604df83a))
 - **FEAT**: Move to Flutter 3.0.0 and Dart 2.17.0 ([#1713](https://github.com/flame-engine/flame/issues/1713)). ([2a41d0d6](https://github.com/flame-engine/flame/commit/2a41d0d683391194b7209c47bde91199ab7a663e))
 - **DOCS**: Documenting how to write documentation ([#1721](https://github.com/flame-engine/flame/issues/1721)). ([ea354e3a](https://github.com/flame-engine/flame/commit/ea354e3a81e3810a8d2b9e3783d9833ae92349e0))

#### `flame_forge2d` - `v0.12.2`

 - **FIX**: `renderChain` should allow open-ended chain drawing ([#1804](https://github.com/flame-engine/flame/issues/1804)). ([60daa196](https://github.com/flame-engine/flame/commit/60daa196a8b2f9d3b022bf4d25b0dc8af29f40b8))
 - **FIX**: Correct flutter constraint ([#1731](https://github.com/flame-engine/flame/issues/1731)). ([c7383843](https://github.com/flame-engine/flame/commit/c738384314a1a5c3695d1c3adaebcb59604df83a))
 - **FEAT**: Move to Flutter 3.0.0 and Dart 2.17.0 ([#1713](https://github.com/flame-engine/flame/issues/1713)). ([2a41d0d6](https://github.com/flame-engine/flame/commit/2a41d0d683391194b7209c47bde91199ab7a663e))

#### `flame_lint` - `v0.1.2`

 - **REFACTOR**: Move to package imports ([#1625](https://github.com/flame-engine/flame/issues/1625)). ([843ddc36](https://github.com/flame-engine/flame/commit/843ddc36249272fcb518b44672e1012307dfa1b5))
 - **REFACTOR**: Add a few more rules to flame_lint, including use_key_in_widget_constructors ([#1248](https://github.com/flame-engine/flame/issues/1248)). ([bac6c8a4](https://github.com/flame-engine/flame/commit/bac6c8a4469f2c5c2926335f2f589eec9b1a5b5b))
 - **FIX**: Upgrade dartdoc (upgrade analyzer transitive dependency) ([#1630](https://github.com/flame-engine/flame/issues/1630)). ([6da8adb2](https://github.com/flame-engine/flame/commit/6da8adb28cffd8fcb43e6bf8a33aae22578f1b40))
 - **FEAT**: Move to Flutter 3.0.0 and Dart 2.17.0 ([#1713](https://github.com/flame-engine/flame/issues/1713)). ([2a41d0d6](https://github.com/flame-engine/flame/commit/2a41d0d683391194b7209c47bde91199ab7a663e))
 - **FEAT**: Add more lint rules ([#1703](https://github.com/flame-engine/flame/issues/1703)). ([49252f8e](https://github.com/flame-engine/flame/commit/49252f8ef29aa6b77144dcb97c24346f2f39380b))
 - **FEAT**: Add non_constant_identifier_names rule ([#1656](https://github.com/flame-engine/flame/issues/1656)). ([1b40de09](https://github.com/flame-engine/flame/commit/1b40de094f4e66be7622d077a6e18cecf1964dde))
 - **FEAT**: Bump to Flutter 2.10.0 ([#1617](https://github.com/flame-engine/flame/issues/1617)). ([beac9013](https://github.com/flame-engine/flame/commit/beac901313456cf0b39b6f4e6459f0feed183614))
 - **DOCS**: Fix various dartdoc warnings ([#1353](https://github.com/flame-engine/flame/issues/1353)). ([9f096053](https://github.com/flame-engine/flame/commit/9f096053fd3c8ebd52d301710625a187db09704f))

#### `flame_oxygen` - `v0.1.5`

 - **REFACTOR**: Game is now a class, not a mixin ([#1751](https://github.com/flame-engine/flame/issues/1751)). ([5225a4eb](https://github.com/flame-engine/flame/commit/5225a4ebd55a21f5709ccab9a1e24c728b2747ed))
 - **FIX**: Correct flutter constraint ([#1731](https://github.com/flame-engine/flame/issues/1731)). ([c7383843](https://github.com/flame-engine/flame/commit/c738384314a1a5c3695d1c3adaebcb59604df83a))
 - **FEAT**: Move to Flutter 3.0.0 and Dart 2.17.0 ([#1713](https://github.com/flame-engine/flame/issues/1713)). ([2a41d0d6](https://github.com/flame-engine/flame/commit/2a41d0d683391194b7209c47bde91199ab7a663e))

#### `flame_svg` - `v1.5.0`

 - **FIX**: Correct flutter constraint ([#1731](https://github.com/flame-engine/flame/issues/1731)). ([c7383843](https://github.com/flame-engine/flame/commit/c738384314a1a5c3695d1c3adaebcb59604df83a))
 - **FEAT**: Move to Flutter 3.0.0 and Dart 2.17.0 ([#1713](https://github.com/flame-engine/flame/issues/1713)). ([2a41d0d6](https://github.com/flame-engine/flame/commit/2a41d0d683391194b7209c47bde91199ab7a663e))

#### `flame_tiled` - `v1.7.2`

 - **FIX**: Remove unnecessary x offset ([#1838](https://github.com/flame-engine/flame/issues/1838)). ([4ea12b72](https://github.com/flame-engine/flame/commit/4ea12b724e04843b3b7dcd02dc2fb5060c9cf283))


## 2022-08-10

### Changes

---

Packages with breaking changes:

 - There are no breaking changes in this release.

Packages with other changes:

 - [`flame_tiled` - `v1.7.1`](#flame_tiled---v171)

---

#### `flame_tiled` - `v1.7.1`

 - **FIX**: Remove unnecessary x offset ([#1838](https://github.com/flame-engine/flame/issues/1838)). ([4ea12b72](https://github.com/flame-engine/flame/commit/4ea12b724e04843b3b7dcd02dc2fb5060c9cf283))
 - **FEAT**: Adding support for additional layer rendering options ([#1794](https://github.com/flame-engine/flame/issues/1794)). ([112acf2a](https://github.com/flame-engine/flame/commit/112acf2aa70ded86e6c2b661f5d6a4855d043f99))


## 2022-08-09

### Changes

---

Packages with breaking changes:

 - There are no breaking changes in this release.

Packages with other changes:

 - [`flame_tiled` - `v1.7.0`](#flame_tiled---v170)

---

#### `flame_tiled` - `v1.7.0`

 - **FIX**: Correct flutter constraint ([#1731](https://github.com/flame-engine/flame/issues/1731)). ([c7383843](https://github.com/flame-engine/flame/commit/c738384314a1a5c3695d1c3adaebcb59604df83a))
 - **FIX**: tiled example size ([#1729](https://github.com/flame-engine/flame/issues/1729)). ([8306fc11](https://github.com/flame-engine/flame/commit/8306fc1104cb752ce71108abb3768f05ce1b1dac))
 - **FEAT**: Adding support for additional layer rendering options ([#1794](https://github.com/flame-engine/flame/issues/1794)). ([112acf2a](https://github.com/flame-engine/flame/commit/112acf2aa70ded86e6c2b661f5d6a4855d043f99))
 - **FEAT**: Move to Flutter 3.0.0 and Dart 2.17.0 ([#1713](https://github.com/flame-engine/flame/issues/1713)). ([2a41d0d6](https://github.com/flame-engine/flame/commit/2a41d0d683391194b7209c47bde91199ab7a663e))


## 2022-07-08

### Changes

---

Packages with breaking changes:

 - [`flame` - `v1.2.1`](#flame---v121)
 - [`flame_audio` - `v1.3.0`](#flame_audio---v130)
 - [`flame_test` - `v1.6.0`](#flame_test---v160)

Packages with other changes:

 - [`flame_bloc` - `v1.6.0`](#flame_bloc---v160)
 - [`flame_fire_atlas` - `v1.2.0`](#flame_fire_atlas---v120)
 - [`flame_flare` - `v1.3.0`](#flame_flare---v130)
 - [`flame_forge2d` - `v0.12.1`](#flame_forge2d---v0121)
 - [`flame_lint` - `v0.1.1`](#flame_lint---v011)
 - [`flame_oxygen` - `v0.1.4`](#flame_oxygen---v014)
 - [`flame_rive` - `v1.5.0`](#flame_rive---v150)
 - [`flame_svg` - `v1.4.0`](#flame_svg---v140)
 - [`flame_tiled` - `v1.6.0`](#flame_tiled---v160)

---

#### `flame` - `v1.2.1`

 - **REFACTOR**: Game is now a class, not a mixin ([#1751](https://github.com/flame-engine/flame/issues/1751)). ([5225a4eb](https://github.com/flame-engine/flame/commit/5225a4ebd55a21f5709ccab9a1e24c728b2747ed))
 - **REFACTOR**: Use new "super"-constructors in ShapeComponents ([#1752](https://github.com/flame-engine/flame/issues/1752)). ([b69e8d85](https://github.com/flame-engine/flame/commit/b69e8d85c77346081d1fc5a2ee5cbf9c204a9edf))
 - **PERF**: Avoid unnecessary copy in AssetsCache.readBinaryFile ([#1749](https://github.com/flame-engine/flame/issues/1749)). ([7e79638d](https://github.com/flame-engine/flame/commit/7e79638dd577cb07d55402d4e862de08ce832b85))
 - **FIX**: Specify size for the SpriteWidget ([#1760](https://github.com/flame-engine/flame/issues/1760)). ([82f75fcb](https://github.com/flame-engine/flame/commit/82f75fcb57c8185a7138ee6ceb9082a418099df8))
 - **FIX**: SpriteAnimationWidget can now be update animation safely ([#1738](https://github.com/flame-engine/flame/issues/1738)). ([eb070195](https://github.com/flame-engine/flame/commit/eb0701951c165576fac1f540c8860e560a8961e6))
 - **FIX**: Overlays can now be properly added during onLoad ([#1759](https://github.com/flame-engine/flame/issues/1759)). ([9f35b154](https://github.com/flame-engine/flame/commit/9f35b15420bea9ac5eeeddc245484b854e8eed38))
 - **FIX**: Camera incorrect follow with zoom and world boundaries. ([c1756177](https://github.com/flame-engine/flame/commit/c175617714e2f15f4379ed8ea412c7cb8bfa1842))
 - **FIX**: Correct key events in GameWidget.controller ([#1745](https://github.com/flame-engine/flame/issues/1745)). ([01ed2ec9](https://github.com/flame-engine/flame/commit/01ed2ec967ee29c946c967786eec6bf7cc6ec958))
 - **FIX**: World component can now be queried with `componentsAtPoint` ([#1739](https://github.com/flame-engine/flame/issues/1739)). ([f750d705](https://github.com/flame-engine/flame/commit/f750d705d14dd0ba95d550b2b8a320201a96584b))
 - **FIX**: Correct flutter constraint ([#1731](https://github.com/flame-engine/flame/issues/1731)). ([c7383843](https://github.com/flame-engine/flame/commit/c738384314a1a5c3695d1c3adaebcb59604df83a))
 - **FIX**: ButtonComponent behavior when the engine is paused ([#1726](https://github.com/flame-engine/flame/issues/1726)). ([197e63d6](https://github.com/flame-engine/flame/commit/197e63d69e2a4c6779e49b918d05a60447ce9462))
 - **FIX**: Add missing paint arguments on shapes ([#1727](https://github.com/flame-engine/flame/issues/1727)). ([e59f3428](https://github.com/flame-engine/flame/commit/e59f3428469e4298d812bb665171679df8895daf))
 - **FIX**: Merge basic and advanced gesture detectors ([#1718](https://github.com/flame-engine/flame/issues/1718)). ([f08f8e12](https://github.com/flame-engine/flame/commit/f08f8e12f5322c7bea1491908f06b350e13c14b7))
 - **FEAT**: New colors to palette.dart ([#1783](https://github.com/flame-engine/flame/issues/1783)). ([85cd60e1](https://github.com/flame-engine/flame/commit/85cd60e16c7b4dafdf1823bf85a7ae8a50fd05f2))
 - **FEAT**: Added TextFormatter classes ([#1720](https://github.com/flame-engine/flame/issues/1720)). ([c44272be](https://github.com/flame-engine/flame/commit/c44272be45eadfabc8f03ef250eb663e59ef2aab))
 - **FEAT**: Drag events that dispatch using componentsAtPoint ([#1715](https://github.com/flame-engine/flame/issues/1715)). ([10669c12](https://github.com/flame-engine/flame/commit/10669c12702a3a82fcf5be9161107dce4349a79f))
 - **FEAT**: add `HasAncestor` mixin ([#1711](https://github.com/flame-engine/flame/issues/1711)). ([987a44f4](https://github.com/flame-engine/flame/commit/987a44f441429534c743388b44e6d84b28e8f5ca))
 - **FEAT**: Move to Flutter 3.0.0 and Dart 2.17.0 ([#1713](https://github.com/flame-engine/flame/issues/1713)). ([2a41d0d6](https://github.com/flame-engine/flame/commit/2a41d0d683391194b7209c47bde91199ab7a663e))
 - **DOCS**: Klondike tutorial, part 4 ([#1740](https://github.com/flame-engine/flame/issues/1740)). ([02d0b71b](https://github.com/flame-engine/flame/commit/02d0b71b2379d12b36b53a76b6bcf5f4018ec9df))
 - **BREAKING** **REFACTOR**: Matcher closeToVector() now accepts Vector2 as an argument ([#1761](https://github.com/flame-engine/flame/issues/1761)). ([c5083501](https://github.com/flame-engine/flame/commit/c5083501d54023f04d3f09e3358bce039ade9a20))
 - **BREAKING** **PERF**: Game.images/assets are now same as Flame.images/assets by default ([#1775](https://github.com/flame-engine/flame/issues/1775)). ([0ccb0e2e](https://github.com/flame-engine/flame/commit/0ccb0e2ef525661830c7b4662662ba64fda830fe))

#### `flame_audio` - `v1.3.0`

 - **FEAT**: Move to Flutter 3.0.0 and Dart 2.17.0 ([#1713](https://github.com/flame-engine/flame/issues/1713)). ([2a41d0d6](https://github.com/flame-engine/flame/commit/2a41d0d683391194b7209c47bde91199ab7a663e))
 - **BREAKING** **FEAT**: Update flame_audio to AP 1.0.0 ([#1724](https://github.com/flame-engine/flame/issues/1724)). ([d6bf920d](https://github.com/flame-engine/flame/commit/d6bf920d28eea5f08adcba2601104271078e7a3d))

#### `flame_test` - `v1.6.0`

 - **FIX**: Correct flutter constraint ([#1731](https://github.com/flame-engine/flame/issues/1731)). ([c7383843](https://github.com/flame-engine/flame/commit/c738384314a1a5c3695d1c3adaebcb59604df83a))
 - **FEAT**: Added size parameter for testGolden() ([#1780](https://github.com/flame-engine/flame/issues/1780)). ([8e41d83e](https://github.com/flame-engine/flame/commit/8e41d83ea4e057e1a428f0456450d697351683bf))
 - **FEAT**: Move to Flutter 3.0.0 and Dart 2.17.0 ([#1713](https://github.com/flame-engine/flame/issues/1713)). ([2a41d0d6](https://github.com/flame-engine/flame/commit/2a41d0d683391194b7209c47bde91199ab7a663e))
 - **BREAKING** **REFACTOR**: Matcher closeToVector() now accepts Vector2 as an argument ([#1761](https://github.com/flame-engine/flame/issues/1761)). ([c5083501](https://github.com/flame-engine/flame/commit/c5083501d54023f04d3f09e3358bce039ade9a20))

#### `flame_bloc` - `v1.6.0`

 - **FIX**: Correct flutter constraint ([#1731](https://github.com/flame-engine/flame/issues/1731)). ([c7383843](https://github.com/flame-engine/flame/commit/c738384314a1a5c3695d1c3adaebcb59604df83a))
 - **FEAT**: Adding bloc getter to FlameBlocListenable mixin ([#1732](https://github.com/flame-engine/flame/issues/1732)). ([3d19caa3](https://github.com/flame-engine/flame/commit/3d19caa36dcb470b306b841ef9c03647a2f307d7))
 - **FEAT**: Move to Flutter 3.0.0 and Dart 2.17.0 ([#1713](https://github.com/flame-engine/flame/issues/1713)). ([2a41d0d6](https://github.com/flame-engine/flame/commit/2a41d0d683391194b7209c47bde91199ab7a663e))
 - **DOCS**: updating README to the new flame bloc version ([#1737](https://github.com/flame-engine/flame/issues/1737)). ([6a2356aa](https://github.com/flame-engine/flame/commit/6a2356aa5eba1696caa6f88ecfe8143c4ffdb507))

#### `flame_fire_atlas` - `v1.2.0`

 - **PERF**: Avoid unnecessary copy in AssetsCache.readBinaryFile ([#1749](https://github.com/flame-engine/flame/issues/1749)). ([7e79638d](https://github.com/flame-engine/flame/commit/7e79638dd577cb07d55402d4e862de08ce832b85))
 - **FIX**: Correct flutter constraint ([#1731](https://github.com/flame-engine/flame/issues/1731)). ([c7383843](https://github.com/flame-engine/flame/commit/c738384314a1a5c3695d1c3adaebcb59604df83a))
 - **FEAT**: Move to Flutter 3.0.0 and Dart 2.17.0 ([#1713](https://github.com/flame-engine/flame/issues/1713)). ([2a41d0d6](https://github.com/flame-engine/flame/commit/2a41d0d683391194b7209c47bde91199ab7a663e))

#### `flame_flare` - `v1.3.0`

 - **FIX**: Correct flutter constraint ([#1731](https://github.com/flame-engine/flame/issues/1731)). ([c7383843](https://github.com/flame-engine/flame/commit/c738384314a1a5c3695d1c3adaebcb59604df83a))
 - **FEAT**: Move to Flutter 3.0.0 and Dart 2.17.0 ([#1713](https://github.com/flame-engine/flame/issues/1713)). ([2a41d0d6](https://github.com/flame-engine/flame/commit/2a41d0d683391194b7209c47bde91199ab7a663e))
 - **DOCS**: Documenting how to write documentation ([#1721](https://github.com/flame-engine/flame/issues/1721)). ([ea354e3a](https://github.com/flame-engine/flame/commit/ea354e3a81e3810a8d2b9e3783d9833ae92349e0))

#### `flame_forge2d` - `v0.12.1`

 - **FIX**: Correct flutter constraint ([#1731](https://github.com/flame-engine/flame/issues/1731)). ([c7383843](https://github.com/flame-engine/flame/commit/c738384314a1a5c3695d1c3adaebcb59604df83a))
 - **FEAT**: Move to Flutter 3.0.0 and Dart 2.17.0 ([#1713](https://github.com/flame-engine/flame/issues/1713)). ([2a41d0d6](https://github.com/flame-engine/flame/commit/2a41d0d683391194b7209c47bde91199ab7a663e))

#### `flame_lint` - `v0.1.1`

 - **REFACTOR**: Move to package imports ([#1625](https://github.com/flame-engine/flame/issues/1625)). ([843ddc36](https://github.com/flame-engine/flame/commit/843ddc36249272fcb518b44672e1012307dfa1b5))
 - **REFACTOR**: Add a few more rules to flame_lint, including use_key_in_widget_constructors ([#1248](https://github.com/flame-engine/flame/issues/1248)). ([bac6c8a4](https://github.com/flame-engine/flame/commit/bac6c8a4469f2c5c2926335f2f589eec9b1a5b5b))
 - **FIX**: Upgrade dartdoc (upgrade analyzer transitive dependency) ([#1630](https://github.com/flame-engine/flame/issues/1630)). ([6da8adb2](https://github.com/flame-engine/flame/commit/6da8adb28cffd8fcb43e6bf8a33aae22578f1b40))
 - **FEAT**: Move to Flutter 3.0.0 and Dart 2.17.0 ([#1713](https://github.com/flame-engine/flame/issues/1713)). ([2a41d0d6](https://github.com/flame-engine/flame/commit/2a41d0d683391194b7209c47bde91199ab7a663e))
 - **FEAT**: Add more lint rules ([#1703](https://github.com/flame-engine/flame/issues/1703)). ([49252f8e](https://github.com/flame-engine/flame/commit/49252f8ef29aa6b77144dcb97c24346f2f39380b))
 - **FEAT**: Add non_constant_identifier_names rule ([#1656](https://github.com/flame-engine/flame/issues/1656)). ([1b40de09](https://github.com/flame-engine/flame/commit/1b40de094f4e66be7622d077a6e18cecf1964dde))
 - **FEAT**: Bump to Flutter 2.10.0 ([#1617](https://github.com/flame-engine/flame/issues/1617)). ([beac9013](https://github.com/flame-engine/flame/commit/beac901313456cf0b39b6f4e6459f0feed183614))
 - **DOCS**: Fix various dartdoc warnings ([#1353](https://github.com/flame-engine/flame/issues/1353)). ([9f096053](https://github.com/flame-engine/flame/commit/9f096053fd3c8ebd52d301710625a187db09704f))

#### `flame_oxygen` - `v0.1.4`

 - **REFACTOR**: Game is now a class, not a mixin ([#1751](https://github.com/flame-engine/flame/issues/1751)). ([5225a4eb](https://github.com/flame-engine/flame/commit/5225a4ebd55a21f5709ccab9a1e24c728b2747ed))
 - **FIX**: Correct flutter constraint ([#1731](https://github.com/flame-engine/flame/issues/1731)). ([c7383843](https://github.com/flame-engine/flame/commit/c738384314a1a5c3695d1c3adaebcb59604df83a))
 - **FEAT**: Move to Flutter 3.0.0 and Dart 2.17.0 ([#1713](https://github.com/flame-engine/flame/issues/1713)). ([2a41d0d6](https://github.com/flame-engine/flame/commit/2a41d0d683391194b7209c47bde91199ab7a663e))

#### `flame_rive` - `v1.5.0`

 - **FIX**: Flame_rive now can load Nested Artboards and update to 0.9.0 rive package  ([#1741](https://github.com/flame-engine/flame/issues/1741)). ([82e4be96](https://github.com/flame-engine/flame/commit/82e4be96f3090908e95659a96006bf50fbb5b08c))
 - **FIX**: Correct flutter constraint ([#1731](https://github.com/flame-engine/flame/issues/1731)). ([c7383843](https://github.com/flame-engine/flame/commit/c738384314a1a5c3695d1c3adaebcb59604df83a))
 - **FEAT**: Move to Flutter 3.0.0 and Dart 2.17.0 ([#1713](https://github.com/flame-engine/flame/issues/1713)). ([2a41d0d6](https://github.com/flame-engine/flame/commit/2a41d0d683391194b7209c47bde91199ab7a663e))

#### `flame_svg` - `v1.4.0`

 - **FIX**: Correct flutter constraint ([#1731](https://github.com/flame-engine/flame/issues/1731)). ([c7383843](https://github.com/flame-engine/flame/commit/c738384314a1a5c3695d1c3adaebcb59604df83a))
 - **FEAT**: Move to Flutter 3.0.0 and Dart 2.17.0 ([#1713](https://github.com/flame-engine/flame/issues/1713)). ([2a41d0d6](https://github.com/flame-engine/flame/commit/2a41d0d683391194b7209c47bde91199ab7a663e))

#### `flame_tiled` - `v1.6.0`

 - **FIX**: Correct flutter constraint ([#1731](https://github.com/flame-engine/flame/issues/1731)). ([c7383843](https://github.com/flame-engine/flame/commit/c738384314a1a5c3695d1c3adaebcb59604df83a))
 - **FIX**: tiled example size ([#1729](https://github.com/flame-engine/flame/issues/1729)). ([8306fc11](https://github.com/flame-engine/flame/commit/8306fc1104cb752ce71108abb3768f05ce1b1dac))
 - **FEAT**: Move to Flutter 3.0.0 and Dart 2.17.0 ([#1713](https://github.com/flame-engine/flame/issues/1713)). ([2a41d0d6](https://github.com/flame-engine/flame/commit/2a41d0d683391194b7209c47bde91199ab7a663e))


## 2022-06-19

### Changes

---

Packages with breaking changes:

 - There are no breaking changes in this release.

Packages with other changes:

 - [`flame_rive` - `v1.4.0`](#flame_rive---v140)

---

#### `flame_rive` - `v1.4.0`

 - **FIX**: Flame_rive now can load Nested Artboards and update to 0.9.0 rive package  ([#1741](https://github.com/flame-engine/flame/issues/1741)). ([82e4be96](https://github.com/flame-engine/flame/commit/82e4be96f3090908e95659a96006bf50fbb5b08c))
 - **FIX**: Correct flutter constraint ([#1731](https://github.com/flame-engine/flame/issues/1731)). ([c7383843](https://github.com/flame-engine/flame/commit/c738384314a1a5c3695d1c3adaebcb59604df83a))
 - **FEAT**: Move to Flutter 3.0.0 and Dart 2.17.0 ([#1713](https://github.com/flame-engine/flame/issues/1713)). ([2a41d0d6](https://github.com/flame-engine/flame/commit/2a41d0d683391194b7209c47bde91199ab7a663e))


## 2022-06-14

### Changes

---

Packages with breaking changes:

 - [`flame_audio` - `v1.2.0`](#flame_audio---v120)

Packages with other changes:

 - There are no other changes in this release.

---

#### `flame_audio` - `v1.2.0`

 - **FEAT**: Move to Flutter 3.0.0 and Dart 2.17.0 ([#1713](https://github.com/flame-engine/flame/issues/1713)). ([2a41d0d6](https://github.com/flame-engine/flame/commit/2a41d0d683391194b7209c47bde91199ab7a663e))
 - **BREAKING** **FEAT**: Update flame_audio to AP 1.0.0 ([#1724](https://github.com/flame-engine/flame/issues/1724)). ([d6bf920d](https://github.com/flame-engine/flame/commit/d6bf920d28eea5f08adcba2601104271078e7a3d))


## 2022-06-07

### Changes

---

Packages with breaking changes:

 - [`flame` - `v1.2.0`](#flame---v120)
 - [`flame_forge2d` - `v0.12.0`](#flame_forge2d---v0120)

Packages with other changes:

 - [`flame_audio` - `v1.1.0`](#flame_audio---v110)
 - [`flame_bloc` - `v1.5.0`](#flame_bloc---v150)
 - [`flame_fire_atlas` - `v1.1.0`](#flame_fire_atlas---v110)
 - [`flame_flare` - `v1.2.0`](#flame_flare---v120)
 - [`flame_oxygen` - `v0.1.3`](#flame_oxygen---v013)
 - [`flame_rive` - `v1.3.0`](#flame_rive---v130)
 - [`flame_svg` - `v1.3.0`](#flame_svg---v130)
 - [`flame_test` - `v1.5.0`](#flame_test---v150)
 - [`flame_tiled` - `v1.5.0`](#flame_tiled---v150)

---

#### `flame` - `v1.2.0`

 - **REFACTOR**: Organize Component class ([#1608](https://github.com/flame-engine/flame/issues/1608)). ([069294f4](https://github.com/flame-engine/flame/commit/069294f44082a5d4ae6e9eff1d29be9cb06ee4a7))
 - **REFACTOR**: Remove unecessary copy operation on Camera ([#1708](https://github.com/flame-engine/flame/issues/1708)). ([94cc115a](https://github.com/flame-engine/flame/commit/94cc115a9ee6660d1f3a72378e8b35523b83bfad))
 - **REFACTOR**: Update and guarantee consistency on mocktail dev dependency version across repo ([#1701](https://github.com/flame-engine/flame/issues/1701)). ([f4a98878](https://github.com/flame-engine/flame/commit/f4a98878062dbd4fe8238a8b014e6be3e528c5d8))
 - **REFACTOR**: Add onComplete as optional parameter ([#1686](https://github.com/flame-engine/flame/issues/1686)). ([4ca65f8a](https://github.com/flame-engine/flame/commit/4ca65f8a2c330d61527e071434441f2df9deefb4))
 - **REFACTOR**: Added MultiDragListener - common API between HasDraggables and MultiTouchDragDetector ([#1668](https://github.com/flame-engine/flame/issues/1668)). ([801dbba1](https://github.com/flame-engine/flame/commit/801dbba1d8b6fd721d4e2fc752c70f97d4771198))
 - **REFACTOR**: Simplify Component.firstChild, .lastChild, and .findParent ([#1673](https://github.com/flame-engine/flame/issues/1673)). ([84f2f57e](https://github.com/flame-engine/flame/commit/84f2f57e5fddb82572177b2bcd0f8309a891ea4e))
 - **REFACTOR**: Replace some usages of fold<> with .sum ([#1670](https://github.com/flame-engine/flame/issues/1670)). ([dd05ecb6](https://github.com/flame-engine/flame/commit/dd05ecb6b8b105b4d1fc894dc6ce7ca3f8cf793e))
 - **REFACTOR**: Deprecate ComponentSet.createDefault() ([#1676](https://github.com/flame-engine/flame/issues/1676)). ([f37e3a20](https://github.com/flame-engine/flame/commit/f37e3a2028e16143d8bb3218691904c38fb848a4))
 - **REFACTOR**: Simplify HudButtonComponent ([#1647](https://github.com/flame-engine/flame/issues/1647)). ([30d84b7c](https://github.com/flame-engine/flame/commit/30d84b7caea128c7dc579dce170129e462bc03bf))
 - **REFACTOR**: Component's lifecycle futures moved into LifecycleManager ([#1613](https://github.com/flame-engine/flame/issues/1613)). ([39201c40](https://github.com/flame-engine/flame/commit/39201c40fa3eea5dbdbaa823309cdf8856f912a6))
 - **REFACTOR**: TextRenderer and TextPaint moved to separate files ([#1628](https://github.com/flame-engine/flame/issues/1628)). ([5e1f5966](https://github.com/flame-engine/flame/commit/5e1f59663bf7e09a02475979d1eded54dbaaefd7))
 - **REFACTOR**: Move to package imports ([#1625](https://github.com/flame-engine/flame/issues/1625)). ([843ddc36](https://github.com/flame-engine/flame/commit/843ddc36249272fcb518b44672e1012307dfa1b5))
 - **REFACTOR**: Improve tests ([#1609](https://github.com/flame-engine/flame/issues/1609)). ([f33b3986](https://github.com/flame-engine/flame/commit/f33b3986cd913416ae3955c922d6cc8b0db872e3))
 - **FIX**: Fix tile flips when using canvas.drawAtlas ([#1610](https://github.com/flame-engine/flame/issues/1610)). ([b4ad498f](https://github.com/flame-engine/flame/commit/b4ad498fe5488795deb2c2e098fcde357b448bf0))
 - **FIX**: Expose `CompositeHitbox` ([#1589](https://github.com/flame-engine/flame/issues/1589)). ([78775798](https://github.com/flame-engine/flame/commit/7877579868041f4844ebae885da559097b7aa8a5))
 - **FIX**: Anchor equality operator is now more reliable ([#1560](https://github.com/flame-engine/flame/issues/1560)). ([0d6581ef](https://github.com/flame-engine/flame/commit/0d6581ef1aaff4437b2a84f9e57d7d0e1d093d1f))
 - **FIX**: Deprecate Anchor.translate() ([#1672](https://github.com/flame-engine/flame/issues/1672)). ([80c648fc](https://github.com/flame-engine/flame/commit/80c648fc94dc00e37f2c0876fec39b2628b3128a))
 - **FIX**: Avoid leaks when using PictureRecorders ([#1643](https://github.com/flame-engine/flame/issues/1643)). ([d67065e5](https://github.com/flame-engine/flame/commit/d67065e52db453b0f4f190a7aec1bec6bc389e45))
 - **FIX**: Remove nonVirtual method shouldRemove ([#1707](https://github.com/flame-engine/flame/issues/1707)). ([1efd067e](https://github.com/flame-engine/flame/commit/1efd067e31ad425941e5b83891c7289ba063ec90))
 - **FIX**: Fix flame package example app ([#1709](https://github.com/flame-engine/flame/issues/1709)). ([bd2ef967](https://github.com/flame-engine/flame/commit/bd2ef967e10eb0309e0a468652a657cae3d5e7d5))
 - **FIX**: Subscription for events when game changes in GameWidget ([#1659](https://github.com/flame-engine/flame/issues/1659)). ([04f0d5d1](https://github.com/flame-engine/flame/commit/04f0d5d172ca5065e58e8b9b5536cbce706147d4))
 - **FIX**: performance improvements on `SpriteBatch` APIs ([#1637](https://github.com/flame-engine/flame/issues/1637)). ([4b19a1b2](https://github.com/flame-engine/flame/commit/4b19a1b203c5cfca5bb412b91c795fe6a215506e))
 - **FIX**: Removed warnings using flutter v3 ([#1640](https://github.com/flame-engine/flame/issues/1640)). ([69214827](https://github.com/flame-engine/flame/commit/69214827a0edb563468951256eccecab408f89df))
 - **FIX**: ParallaxComponent.update mustCallSuper ([#1635](https://github.com/flame-engine/flame/issues/1635)). ([9474ce74](https://github.com/flame-engine/flame/commit/9474ce7425ffc18f6b1a1a35c35f59b76f435166))
 - **FIX**: Isometric tile map component uses scale when getting block from position ([#1569](https://github.com/flame-engine/flame/issues/1569)). ([0c430786](https://github.com/flame-engine/flame/commit/0c430786e2774174424a21a13464e93d04c69295))
 - **FIX**: Dispose `TextBoxComponent` image cache properly ([#1579](https://github.com/flame-engine/flame/issues/1579)). ([c0e3257a](https://github.com/flame-engine/flame/commit/c0e3257a0b348885275f2659c351bacbfa5a8732))
 - **FIX**: `ParentIsA` missing `mustCallSuper` ([#1604](https://github.com/flame-engine/flame/issues/1604)). ([72129019](https://github.com/flame-engine/flame/commit/721290198cc7062f8cfb958cb8499e64be7a1e9c))
 - **FIX**: Component can now be removed in any lifecycle stage ([#1601](https://github.com/flame-engine/flame/issues/1601)). ([c0a14156](https://github.com/flame-engine/flame/commit/c0a141563b9e832b1a81bf32d860d4dfb2b359ae))
 - **FIX**: Export NotifyingVector2 ([#1633](https://github.com/flame-engine/flame/issues/1633)). ([aeaf9999](https://github.com/flame-engine/flame/commit/aeaf9999b0b4f69e394063d3af8e18f67dff5ed9))
 - **FIX**: RectangleHitbox should shrink to bounds ([#1596](https://github.com/flame-engine/flame/issues/1596)). ([60df3b9f](https://github.com/flame-engine/flame/commit/60df3b9f60f538fbad7a3d806f5d38262ab6d66c))
 - **FIX**: Components in uninitialized state can now be safely removed ([#1551](https://github.com/flame-engine/flame/issues/1551)). ([ba617790](https://github.com/flame-engine/flame/commit/ba617790e4a7ca4dc03f4a2e29de43d42efd3482))
 - **FIX**: Bug in "tty" TextBoxComponent ([#1619](https://github.com/flame-engine/flame/issues/1619)). ([6cc3e827](https://github.com/flame-engine/flame/commit/6cc3e82727509f8877873b095c84eef3543fe01e))
 - **FIX**: Component.loaded future sometimes failed to complete ([#1593](https://github.com/flame-engine/flame/issues/1593)). ([89ee9b98](https://github.com/flame-engine/flame/commit/89ee9b984bfc3784dedde1ada1daa992a9f0dedc))
 - **FIX**: correctly calculating frame length ([#1578](https://github.com/flame-engine/flame/issues/1578)). ([efda45e7](https://github.com/flame-engine/flame/commit/efda45e76c38a2d38a4cd0bb66ece9792f5832df))
 - **FIX**: Optimize AcceleratedParticle and MovingParticle ([#1568](https://github.com/flame-engine/flame/issues/1568)). ([5591c109](https://github.com/flame-engine/flame/commit/5591c109437309907cdac72f0bb479a6a6bfa00a))
 - **FEAT**: Method `componentsAtPoint` now reports the "stacktrace" of points ([#1615](https://github.com/flame-engine/flame/issues/1615)). ([e2398966](https://github.com/flame-engine/flame/commit/e239896624f1e2736de83148ff172ca1b0f97dae))
 - **FEAT**: Allow changing parent from null parent ([#1662](https://github.com/flame-engine/flame/issues/1662)). ([53268b5f](https://github.com/flame-engine/flame/commit/53268b5f5fd81f3822bfda9721b97be4e72e48e3))
 - **FEAT**: Callbacks in `HudButtonComponent` constructor and `ViewportMargin` mixin to avoid code duplication ([#1685](https://github.com/flame-engine/flame/issues/1685)). ([f55b2e0d](https://github.com/flame-engine/flame/commit/f55b2e0dc01c98718e4871430c6745472c221821))
 - **FEAT**: Add more lint rules ([#1703](https://github.com/flame-engine/flame/issues/1703)). ([49252f8e](https://github.com/flame-engine/flame/commit/49252f8ef29aa6b77144dcb97c24346f2f39380b))
 - **FEAT**: Keep stacktrace when rethrowing an error from GameWidget ([#1675](https://github.com/flame-engine/flame/issues/1675)). ([dd28183b](https://github.com/flame-engine/flame/commit/dd28183bc4ebe2ea2f80d1dab3b5ab22d11b8382))
 - **FEAT**: Aligned text in the TextBoxComponent ([#1620](https://github.com/flame-engine/flame/issues/1620)). ([c64aedae](https://github.com/flame-engine/flame/commit/c64aedaeb3fed908722b8872b71e288ff87bc761))
 - **FEAT**: Included `completed` completer in `SpriteAnimation` ([#1564](https://github.com/flame-engine/flame/issues/1564)). ([71999b19](https://github.com/flame-engine/flame/commit/71999b191af0285e8d61583b041da58afd40d8d2))
 - **FEAT**: Optional key for Images.load ([#1624](https://github.com/flame-engine/flame/issues/1624)). ([067c34b5](https://github.com/flame-engine/flame/commit/067c34b5f29e1a9bd51861d872092ae5ee0a551f))
 - **FEAT**: Bump to Flutter 2.10.0 ([#1617](https://github.com/flame-engine/flame/issues/1617)). ([beac9013](https://github.com/flame-engine/flame/commit/beac901313456cf0b39b6f4e6459f0feed183614))
 - **FEAT**: Add `isFirstFrame` and `onStart` event to `SpriteAnimation` ([#1492](https://github.com/flame-engine/flame/issues/1492)). ([701d0706](https://github.com/flame-engine/flame/commit/701d0706af74e6437d71376d468b32bb2537e5b7))
 - **FEAT**: Add `FpsComponent` and `FpsTextComponent` ([#1595](https://github.com/flame-engine/flame/issues/1595)). ([4c68c2b0](https://github.com/flame-engine/flame/commit/4c68c2b0a2660e705b30099234da4ab1eb4616d0))
 - **FEAT**: Added FollowBehavior and ability for the new Camera to follow a component ([#1561](https://github.com/flame-engine/flame/issues/1561)). ([b583388c](https://github.com/flame-engine/flame/commit/b583388ca432f799ad13b92a3a7bf25ddf98ceb0))
 - **FEAT**: Added componentsAtPoint() iterable ([#1518](https://github.com/flame-engine/flame/issues/1518)). ([b99e3512](https://github.com/flame-engine/flame/commit/b99e35120dc4fe81ebfedc89a666286ec489384c))
 - **FEAT**: Added AnchorToEffect and AnchorByEffect ([#1556](https://github.com/flame-engine/flame/issues/1556)). ([eff72794](https://github.com/flame-engine/flame/commit/eff72794afed73bdb1df8e14b17d50f0f446e92b))
 - **FEAT**: Added utility function solveCubic() ([#1696](https://github.com/flame-engine/flame/issues/1696)). ([31784ca0](https://github.com/flame-engine/flame/commit/31784ca0b05082042003f847be2b4004da83edb6))
 - **FEAT**: add FutureOr support on SpriteButton ([#1645](https://github.com/flame-engine/flame/issues/1645)). ([2e82dc95](https://github.com/flame-engine/flame/commit/2e82dc95ecd6d7298239cadad5a746341c37fcd9))
 - **FEAT**: MoveAlongPathEffect can now be applied to any PositionProvider ([#1555](https://github.com/flame-engine/flame/issues/1555)). ([a0ff2d18](https://github.com/flame-engine/flame/commit/a0ff2d18a1efc54f648a277453fa9cf6414ce44c))
 - **FEAT**: adding KeyboardListenerComponent ([#1594](https://github.com/flame-engine/flame/issues/1594)). ([c887c361](https://github.com/flame-engine/flame/commit/c887c3616e9f65209b8e29cb8575a0052db3e2bb))
 - **FEAT**: new flame bloc API ([#1538](https://github.com/flame-engine/flame/issues/1538)). ([f98970a9](https://github.com/flame-engine/flame/commit/f98970a91f91fe70e4a38834d7b69bfcb438d197))
 - **FEAT**: Added the onLongTapDown event ([#1587](https://github.com/flame-engine/flame/issues/1587)). ([ed302d89](https://github.com/flame-engine/flame/commit/ed302d89160cd7391e3aaf66a0038cd8f57ceca9))
 - **FEAT**: Add ability to add/remove multiple overlays at once ([#1657](https://github.com/flame-engine/flame/issues/1657)). ([0ac84c00](https://github.com/flame-engine/flame/commit/0ac84c0024338cbe87fcff264b83e01192aa355b))
 - **FEAT**: Helpers for whether a `PositionComponent` is flipped. ([#1700](https://github.com/flame-engine/flame/issues/1700)). ([cf67147e](https://github.com/flame-engine/flame/commit/cf67147ea37aed8e5f1dd12def442dccbe4576fd))
 - **FEAT**: World bounds for a CameraComponent ([#1605](https://github.com/flame-engine/flame/issues/1605)). ([abb497ab](https://github.com/flame-engine/flame/commit/abb497abe47f6366d27f44d25535924bd7de8a28))
 - **FEAT**: Implement tap events based on `componentsAtPoint` ([#1661](https://github.com/flame-engine/flame/issues/1661)). ([2711ba60](https://github.com/flame-engine/flame/commit/2711ba60c2c700984d8a90d90519e17850038ab4))
 - **FEAT**: add `ParentIsA` to force parent child relations ([#1566](https://github.com/flame-engine/flame/issues/1566)). ([2cdf3868](https://github.com/flame-engine/flame/commit/2cdf3868460f04cee76079e3f81cdd12fb407d3a))
 - **FEAT**: Adding classes for raw geometric shapes ([#1528](https://github.com/flame-engine/flame/issues/1528)). ([666a2b19](https://github.com/flame-engine/flame/commit/666a2b199fc740d02628321bb19511ba98de1700))
 - **FEAT**: Add solveQuadratic() utility function ([#1665](https://github.com/flame-engine/flame/issues/1665)). ([d8bbfc06](https://github.com/flame-engine/flame/commit/d8bbfc067e3885cedd133de47a98134fc15c9c82))
 - **FEAT**: allow external packages to await for game to be loaded ([#1699](https://github.com/flame-engine/flame/issues/1699)). ([a15eda0b](https://github.com/flame-engine/flame/commit/a15eda0b67d6020bcb72162f0186e3c5069674bb))
 - **FEAT**: Children as argument to FlameGame ([#1680](https://github.com/flame-engine/flame/issues/1680)). ([db336c03](https://github.com/flame-engine/flame/commit/db336c03b607b878faf618cb1ab5833cd859d0e6))
 - **FEAT**: Add range constructor on SpriteAnimationData ([#1572](https://github.com/flame-engine/flame/issues/1572)). ([e42b4958](https://github.com/flame-engine/flame/commit/e42b495805efd2e969cfe412b069ffcc6e828ad6))
 - **FEAT**: Add helper function for creating golden tests ([#1623](https://github.com/flame-engine/flame/issues/1623)). ([d0faaada](https://github.com/flame-engine/flame/commit/d0faaada2bb971c2dde5a37dfa20d316c532ea28))
 - **FEAT**: Added ability to render spritesheet-based fonts ([#1634](https://github.com/flame-engine/flame/issues/1634)). ([3f287898](https://github.com/flame-engine/flame/commit/3f2878988195606b90d9e48b981444792af08ebe))
 - **BREAKING** **FIX**: `FixedResolutionViewport` noClip -> clip ([#1612](https://github.com/flame-engine/flame/issues/1612)). ([02be4acd](https://github.com/flame-engine/flame/commit/02be4acd8798254eeaf832863d4000e1c5240db1))
 - **BREAKING** **FIX**: Game.mouseCursor and Game.overlays can now be safely set during onLoad ([#1498](https://github.com/flame-engine/flame/issues/1498)). ([821d01c3](https://github.com/flame-engine/flame/commit/821d01c3fab3cdd9e80d6ead8d491ea2e8ec0643))
 - **BREAKING** **FEAT**: Added anchor for the Viewport ([#1611](https://github.com/flame-engine/flame/issues/1611)). ([c3bb14b7](https://github.com/flame-engine/flame/commit/c3bb14b7ca9513fc75f51b0a5cbc9d986db48dd6))
 - **BREAKING** **FEAT**: remove `onTimingsCallback` for Flutter 3.0 ([#1626](https://github.com/flame-engine/flame/issues/1626)). ([0761a79d](https://github.com/flame-engine/flame/commit/0761a79df6c88a5a6ba74ec78d4f600983657c06))
 - **BREAKING** **FEAT**: Add ability to render without loading on image related widgets ([#1674](https://github.com/flame-engine/flame/issues/1674)). ([40a061bc](https://github.com/flame-engine/flame/commit/40a061bcf06b5bf028911964617c1d1e2599460a))
 - **BREAKING** **FEAT**: Adding GameWidget.controlled ([#1650](https://github.com/flame-engine/flame/issues/1650)). ([7ef6a51e](https://github.com/flame-engine/flame/commit/7ef6a51ec60a70807a126b6121a1fd4379b8e19b))
 - **BREAKING** **FEAT**: Size effects will now work only on components implementing SizeProvider ([#1571](https://github.com/flame-engine/flame/issues/1571)). ([1bfed571](https://github.com/flame-engine/flame/commit/1bfed57132330fb948962261735a0545eb37e7b9))

#### `flame_forge2d` - `v0.12.0`

 - **REFACTOR**: Move to package imports ([#1625](https://github.com/flame-engine/flame/issues/1625)). ([843ddc36](https://github.com/flame-engine/flame/commit/843ddc36249272fcb518b44672e1012307dfa1b5))
 - **FIX**: flips back defaultGravity on y axis ([#1585](https://github.com/flame-engine/flame/issues/1585)). ([6b217ac4](https://github.com/flame-engine/flame/commit/6b217ac466f7522772cf1f974b39af1392f5a807))
 - **FIX**: MouseJoint gets less and less reactive ([#1562](https://github.com/flame-engine/flame/issues/1562)). ([90747bf4](https://github.com/flame-engine/flame/commit/90747bf4a52bb4c82611fa1e9c50f0f11e309baa))
 - **FEAT**: Add more lint rules ([#1703](https://github.com/flame-engine/flame/issues/1703)). ([49252f8e](https://github.com/flame-engine/flame/commit/49252f8ef29aa6b77144dcb97c24346f2f39380b))
 - **FEAT**: allow controlling when a fixture is rendered ([#1648](https://github.com/flame-engine/flame/issues/1648)). ([1b59d801](https://github.com/flame-engine/flame/commit/1b59d801c6c1bcc325948ac4e18dfa536baa5a9c))
 - **FEAT**: Bump to Flutter 2.10.0 ([#1617](https://github.com/flame-engine/flame/issues/1617)). ([beac9013](https://github.com/flame-engine/flame/commit/beac901313456cf0b39b6f4e6459f0feed183614))
 - **FEAT**: allowed specifying renderBody via constructor ([#1548](https://github.com/flame-engine/flame/issues/1548)). ([ceb72666](https://github.com/flame-engine/flame/commit/ceb726666e39e20cd12786be86da60ab9cc61c9a))
 - **DOCS**: Move flame_forge2d examples to main examples ([#1588](https://github.com/flame-engine/flame/issues/1588)). ([6dd0a970](https://github.com/flame-engine/flame/commit/6dd0a970e6f106d8927b542d688f3bc9231e1b69))
 - **BREAKING** **FEAT**: enhance ContactCallback process ([#1547](https://github.com/flame-engine/flame/issues/1547)). ([a50d4a1e](https://github.com/flame-engine/flame/commit/a50d4a1e7d9eaf66726ed1bb9894c9d495547d8f))

#### `flame_audio` - `v1.1.0`

 - **REFACTOR**: Move to package imports ([#1625](https://github.com/flame-engine/flame/issues/1625)). ([843ddc36](https://github.com/flame-engine/flame/commit/843ddc36249272fcb518b44672e1012307dfa1b5))
 - **FIX**: Removed warnings using flutter v3 ([#1640](https://github.com/flame-engine/flame/issues/1640)). ([69214827](https://github.com/flame-engine/flame/commit/69214827a0edb563468951256eccecab408f89df))
 - **FEAT**: Add more lint rules ([#1703](https://github.com/flame-engine/flame/issues/1703)). ([49252f8e](https://github.com/flame-engine/flame/commit/49252f8ef29aa6b77144dcb97c24346f2f39380b))
 - **FEAT**: Bump to Flutter 2.10.0 ([#1617](https://github.com/flame-engine/flame/issues/1617)). ([beac9013](https://github.com/flame-engine/flame/commit/beac901313456cf0b39b6f4e6459f0feed183614))

#### `flame_bloc` - `v1.5.0`

 - **REFACTOR**: Update and guarantee consistency on mocktail dev dependency version across repo ([#1701](https://github.com/flame-engine/flame/issues/1701)). ([f4a98878](https://github.com/flame-engine/flame/commit/f4a98878062dbd4fe8238a8b014e6be3e528c5d8))
 - **REFACTOR**: Move to package imports ([#1625](https://github.com/flame-engine/flame/issues/1625)). ([843ddc36](https://github.com/flame-engine/flame/commit/843ddc36249272fcb518b44672e1012307dfa1b5))
 - **FEAT**: Add more lint rules ([#1703](https://github.com/flame-engine/flame/issues/1703)). ([49252f8e](https://github.com/flame-engine/flame/commit/49252f8ef29aa6b77144dcb97c24346f2f39380b))
 - **FEAT**: Bump to Flutter 2.10.0 ([#1617](https://github.com/flame-engine/flame/issues/1617)). ([beac9013](https://github.com/flame-engine/flame/commit/beac901313456cf0b39b6f4e6459f0feed183614))
 - **FEAT**: new flame bloc API ([#1538](https://github.com/flame-engine/flame/issues/1538)). ([f98970a9](https://github.com/flame-engine/flame/commit/f98970a91f91fe70e4a38834d7b69bfcb438d197))

#### `flame_fire_atlas` - `v1.1.0`

 - **REFACTOR**: Update and guarantee consistency on mocktail dev dependency version across repo ([#1701](https://github.com/flame-engine/flame/issues/1701)). ([f4a98878](https://github.com/flame-engine/flame/commit/f4a98878062dbd4fe8238a8b014e6be3e528c5d8))
 - **FEAT**: Add more lint rules ([#1703](https://github.com/flame-engine/flame/issues/1703)). ([49252f8e](https://github.com/flame-engine/flame/commit/49252f8ef29aa6b77144dcb97c24346f2f39380b))
 - **FEAT**: Optional key for Images.load ([#1624](https://github.com/flame-engine/flame/issues/1624)). ([067c34b5](https://github.com/flame-engine/flame/commit/067c34b5f29e1a9bd51861d872092ae5ee0a551f))
 - **FEAT**: Bump to Flutter 2.10.0 ([#1617](https://github.com/flame-engine/flame/issues/1617)). ([beac9013](https://github.com/flame-engine/flame/commit/beac901313456cf0b39b6f4e6459f0feed183614))

#### `flame_flare` - `v1.2.0`

 - **REFACTOR**: Move to package imports ([#1625](https://github.com/flame-engine/flame/issues/1625)). ([843ddc36](https://github.com/flame-engine/flame/commit/843ddc36249272fcb518b44672e1012307dfa1b5))
 - **FEAT**: Bump to Flutter 2.10.0 ([#1617](https://github.com/flame-engine/flame/issues/1617)). ([beac9013](https://github.com/flame-engine/flame/commit/beac901313456cf0b39b6f4e6459f0feed183614))

#### `flame_oxygen` - `v0.1.3`

 - **REFACTOR**: Move to package imports ([#1625](https://github.com/flame-engine/flame/issues/1625)). ([843ddc36](https://github.com/flame-engine/flame/commit/843ddc36249272fcb518b44672e1012307dfa1b5))
 - **FIX**: Fix setter in Oxygen's SizeComponent ([#1557](https://github.com/flame-engine/flame/issues/1557)). ([b1fae297](https://github.com/flame-engine/flame/commit/b1fae2976ef5445a52c99399dd8cc284fc272684))
 - **FEAT**: Add more lint rules ([#1703](https://github.com/flame-engine/flame/issues/1703)). ([49252f8e](https://github.com/flame-engine/flame/commit/49252f8ef29aa6b77144dcb97c24346f2f39380b))
 - **FEAT**: Bump to Flutter 2.10.0 ([#1617](https://github.com/flame-engine/flame/issues/1617)). ([beac9013](https://github.com/flame-engine/flame/commit/beac901313456cf0b39b6f4e6459f0feed183614))
 - **FEAT**: Add `FpsComponent` and `FpsTextComponent` ([#1595](https://github.com/flame-engine/flame/issues/1595)). ([4c68c2b0](https://github.com/flame-engine/flame/commit/4c68c2b0a2660e705b30099234da4ab1eb4616d0))

#### `flame_rive` - `v1.3.0`

 - **FEAT**: Add more lint rules ([#1703](https://github.com/flame-engine/flame/issues/1703)). ([49252f8e](https://github.com/flame-engine/flame/commit/49252f8ef29aa6b77144dcb97c24346f2f39380b))
 - **FEAT**: Bump to Flutter 2.10.0 ([#1617](https://github.com/flame-engine/flame/issues/1617)). ([beac9013](https://github.com/flame-engine/flame/commit/beac901313456cf0b39b6f4e6459f0feed183614))
 - **FEAT**: update to Rive 0.8.4 ([#1542](https://github.com/flame-engine/flame/issues/1542)). ([ac3d4bf6](https://github.com/flame-engine/flame/commit/ac3d4bf61b1386df555de4673e2bb6da1f0edd50))

#### `flame_svg` - `v1.3.0`

 - **REFACTOR**: Update and guarantee consistency on mocktail dev dependency version across repo ([#1701](https://github.com/flame-engine/flame/issues/1701)). ([f4a98878](https://github.com/flame-engine/flame/commit/f4a98878062dbd4fe8238a8b014e6be3e528c5d8))
 - **REFACTOR**: Move to package imports ([#1625](https://github.com/flame-engine/flame/issues/1625)). ([843ddc36](https://github.com/flame-engine/flame/commit/843ddc36249272fcb518b44672e1012307dfa1b5))
 - **FEAT**: Add more lint rules ([#1703](https://github.com/flame-engine/flame/issues/1703)). ([49252f8e](https://github.com/flame-engine/flame/commit/49252f8ef29aa6b77144dcb97c24346f2f39380b))
 - **FEAT**: Optional key for Images.load ([#1624](https://github.com/flame-engine/flame/issues/1624)). ([067c34b5](https://github.com/flame-engine/flame/commit/067c34b5f29e1a9bd51861d872092ae5ee0a551f))
 - **FEAT**: Bump to Flutter 2.10.0 ([#1617](https://github.com/flame-engine/flame/issues/1617)). ([beac9013](https://github.com/flame-engine/flame/commit/beac901313456cf0b39b6f4e6459f0feed183614))

#### `flame_test` - `v1.5.0`

 - **FEAT**: Add more lint rules ([#1703](https://github.com/flame-engine/flame/issues/1703)). ([49252f8e](https://github.com/flame-engine/flame/commit/49252f8ef29aa6b77144dcb97c24346f2f39380b))
 - **FEAT**: Callbacks in `HudButtonComponent` constructor and `ViewportMargin` mixin to avoid code duplication ([#1685](https://github.com/flame-engine/flame/issues/1685)). ([f55b2e0d](https://github.com/flame-engine/flame/commit/f55b2e0dc01c98718e4871430c6745472c221821))
 - **FEAT**: Aligned text in the TextBoxComponent ([#1620](https://github.com/flame-engine/flame/issues/1620)). ([c64aedae](https://github.com/flame-engine/flame/commit/c64aedaeb3fed908722b8872b71e288ff87bc761))
 - **FEAT**: add options to flutter test ([#1690](https://github.com/flame-engine/flame/issues/1690)). ([5dcf2664](https://github.com/flame-engine/flame/commit/5dcf26642363dd245f541c76d6190f8d523c1acb))
 - **FEAT**: Add helper function for creating golden tests ([#1623](https://github.com/flame-engine/flame/issues/1623)). ([d0faaada](https://github.com/flame-engine/flame/commit/d0faaada2bb971c2dde5a37dfa20d316c532ea28))
 - **FEAT**: Bump to Flutter 2.10.0 ([#1617](https://github.com/flame-engine/flame/issues/1617)). ([beac9013](https://github.com/flame-engine/flame/commit/beac901313456cf0b39b6f4e6459f0feed183614))

#### `flame_tiled` - `v1.5.0`

 - **REFACTOR**: Move to package imports ([#1625](https://github.com/flame-engine/flame/issues/1625)). ([843ddc36](https://github.com/flame-engine/flame/commit/843ddc36249272fcb518b44672e1012307dfa1b5))
 - **FIX**: performance improvements on `SpriteBatch` APIs ([#1637](https://github.com/flame-engine/flame/issues/1637)). ([4b19a1b2](https://github.com/flame-engine/flame/commit/4b19a1b203c5cfca5bb412b91c795fe6a215506e))
 - **FIX**: Avoid leaks when using PictureRecorders ([#1643](https://github.com/flame-engine/flame/issues/1643)). ([d67065e5](https://github.com/flame-engine/flame/commit/d67065e52db453b0f4f190a7aec1bec6bc389e45))
 - **FIX**: Fix tile flips when using canvas.drawAtlas ([#1610](https://github.com/flame-engine/flame/issues/1610)). ([b4ad498f](https://github.com/flame-engine/flame/commit/b4ad498fe5488795deb2c2e098fcde357b448bf0))
 - **FIX**: Add centered anchor point for tile rotation ([#1570](https://github.com/flame-engine/flame/issues/1570)). ([f64d5264](https://github.com/flame-engine/flame/commit/f64d5264abb9e1548d26ae15269654e563cd0ee9))
 - **FEAT**: Add more lint rules ([#1703](https://github.com/flame-engine/flame/issues/1703)). ([49252f8e](https://github.com/flame-engine/flame/commit/49252f8ef29aa6b77144dcb97c24346f2f39380b))
 - **FEAT**: Bump to Flutter 2.10.0 ([#1617](https://github.com/flame-engine/flame/issues/1617)). ([beac9013](https://github.com/flame-engine/flame/commit/beac901313456cf0b39b6f4e6459f0feed183614))


## 2022-05-05

### Changes

---

Packages with breaking changes:

 - There are no breaking changes in this release.

Packages with other changes:

 - [`flame_bloc` - `v1.4.0`](#flame_bloc---v140)

---

#### `flame_bloc` - `v1.4.0`

 - **FEAT**: new flame bloc API (#1538). ([f98970a9](https://github.com/flame-engine/flame/commit/f98970a91f91fe70e4a38834d7b69bfcb438d197))
 - **FEAT**: flame tests can now generate golden tests (#1501). ([316a0b3b](https://github.com/flame-engine/flame/commit/316a0b3bb0996ed20a3b93175102524b38bfa3e2))


## 2022-04-12

### Changes

---

Packages with breaking changes:

 - [`flame_forge2d` - `v0.11.0`](#flame_forge2d---v0110)

Packages with other changes:

 - [`flame` - `v1.1.1`](#flame---v111)
 - [`flame_oxygen` - `v0.1.2`](#flame_oxygen---v012)
 - [`flame_bloc` - `v1.3.0`](#flame_bloc---v130)
 - [`flame_rive` - `v1.2.0`](#flame_rive---v120)
 - [`flame_svg` - `v1.2.0`](#flame_svg---v120)
 - [`flame_test` - `v1.4.0`](#flame_test---v140)
 - [`flame_tiled` - `v1.4.0`](#flame_tiled---v140)
 - [`flame_audio` - `v1.0.2`](#flame_audio---v102)
 - [`flame_flare` - `v1.1.1`](#flame_flare---v111)
 - [`flame_fire_atlas` - `v1.0.2`](#flame_fire_atlas---v102)

Packages with dependency updates only:

> Packages listed below depend on other packages in this workspace that have had changes. Their versions have been incremented to bump the minimum dependency versions of the packages they depend upon in this project.

 - `flame_audio` - `v1.0.2`
 - `flame_flare` - `v1.1.1`
 - `flame_fire_atlas` - `v1.0.2`

---

#### `flame_forge2d` - `v0.11.0`

 - **FEAT**: Bump forg2d version and have flame_forge2d examples use latest syntax (#1535). ([4f7a12eb](https://github.com/flame-engine/flame/commit/4f7a12eb2c00d370fd093de4af6a3f9f740aa03a))
 - **FEAT**: Added children parameter to Component constructor (#1525). ([f0b31fcf](https://github.com/flame-engine/flame/commit/f0b31fcfc0fc6b0f8f96895ef6a68fd5a30a3159))
 - **DOCS**: Fix flame_forge2d readme links (#1540). ([c51bc6db](https://github.com/flame-engine/flame/commit/c51bc6db5dbd32283a7e441b450e0dc4636891c6))
 - **BREAKING** **FEAT**: Flip gravity in flame_forge2d to be able to mix Forge2D and Flame components (#1506). ([bdb360f1](https://github.com/flame-engine/flame/commit/bdb360f18128f9305baa0e6ca77ee6fcad496bc7))

#### `flame` - `v1.1.1`

 - **REFACTOR**: Added classes MoveByEffect and MoveToEffect (#1524). ([2171a119](https://github.com/flame-engine/flame/commit/2171a119378855872f6bece37edc95b3d68f28ae))
 - **FIX**: Invalidate polygon cache on resize (#1529). ([11bf75d0](https://github.com/flame-engine/flame/commit/11bf75d074fe9c0d3e043ce43611a1bb1824dd40))
 - **FIX**: Bug with anchor parameter in Sprite.render() (#1508). ([325df46e](https://github.com/flame-engine/flame/commit/325df46e19ebcd5ac13e3192f4360bacb3de1c37))
 - **FIX**: Make CollisionProspect's a, b have unordered equality (#1519). ([5b2471c8](https://github.com/flame-engine/flame/commit/5b2471c8ae29a1313db3b2c21dee6d4654a0132c))
 - **FEAT**: able to clear all overlays (#1536). ([7b15c9a1](https://github.com/flame-engine/flame/commit/7b15c9a1ca58c19265e65899e27c65146d42788c))
 - **FEAT**: Automatic Isometric Grid scaling (#1468). ([cae8c0ce](https://github.com/flame-engine/flame/commit/cae8c0ceb395416ed86fd644c1dd7790eae127ca))
 - **FEAT**: Added children parameter to Component constructor (#1525). ([f0b31fcf](https://github.com/flame-engine/flame/commit/f0b31fcfc0fc6b0f8f96895ef6a68fd5a30a3159))
 - **FEAT**: Camera's Viewfinder can now be affected by rotation effects (#1527). ([f46cae04](https://github.com/flame-engine/flame/commit/f46cae040e34f6037a9e0a7e259bf22b9dff7acb))
 - **FEAT**: Scale (zoom) effects can now be applied to Viewfinder in CameraComponent (#1514). ([403b6e60](https://github.com/flame-engine/flame/commit/403b6e60433f5e059b81298fd4b39a77957932fb))
 - **FEAT**: adding HasGameRef.mockGameRef (#1520). ([4f389f8b](https://github.com/flame-engine/flame/commit/4f389f8b88b181832316bae551e31a3a70907ee7))
 - **FEAT**: flame tests can now generate golden tests (#1501). ([316a0b3b](https://github.com/flame-engine/flame/commit/316a0b3bb0996ed20a3b93175102524b38bfa3e2))

#### `flame_oxygen` - `v0.1.2`

#### `flame_bloc` - `v1.3.0`

 - **FEAT**: flame tests can now generate golden tests (#1501). ([316a0b3b](https://github.com/flame-engine/flame/commit/316a0b3bb0996ed20a3b93175102524b38bfa3e2))

#### `flame_rive` - `v1.2.0`

 - **FEAT**: Added children parameter to Component constructor (#1525). ([f0b31fcf](https://github.com/flame-engine/flame/commit/f0b31fcfc0fc6b0f8f96895ef6a68fd5a30a3159))

#### `flame_svg` - `v1.2.0`

 - **FEAT**: Added children parameter to Component constructor (#1525). ([f0b31fcf](https://github.com/flame-engine/flame/commit/f0b31fcfc0fc6b0f8f96895ef6a68fd5a30a3159))

#### `flame_test` - `v1.4.0`

 - **FEAT**: Added closeToAabb() (#1531). ([f7b6cc69](https://github.com/flame-engine/flame/commit/f7b6cc69abd6af89cafd892c7f2518b9b7bf3fc6))
 - **FEAT**: flame tests can now generate golden tests (#1501). ([316a0b3b](https://github.com/flame-engine/flame/commit/316a0b3bb0996ed20a3b93175102524b38bfa3e2))

#### `flame_tiled` - `v1.4.0`

 - **FEAT**: Possibility to create RenderableTiledMap from TiledMap (#1534). ([5ed08333](https://github.com/flame-engine/flame/commit/5ed08333215658b9eaca049f6ba16b6509901bb9))
 - **FEAT**: Added children parameter to Component constructor (#1525). ([f0b31fcf](https://github.com/flame-engine/flame/commit/f0b31fcfc0fc6b0f8f96895ef6a68fd5a30a3159))


## 2022-03-30

### Changes

---

Packages with breaking changes:

 - There are no breaking changes in this release.

Packages with other changes:

 - [`flame_test` - `v1.3.0`](#flame_test---v130)

---

#### `flame_test` - `v1.3.0`

 - **FIX**: Fix calculation of AABB for `ShapeHitbox`es (#1481). ([a559d9a1](https://github.com/flame-engine/flame/commit/a559d9a12bfb42e161469745795fb91cdf161f8b))
 - **FEAT**: flame tests can now generate golden tests (#1501). ([316a0b3b](https://github.com/flame-engine/flame/commit/316a0b3bb0996ed20a3b93175102524b38bfa3e2))


## 2022-03-28

### Changes

---

Packages with breaking changes:

- There are no breaking changes in this release.

Packages with other changes:

- There are no other changes in this release.

Packages graduated to a stable release (see pre-releases prior to the stable version for changelog entries):

- `flame` - `v1.1.0`
- `flame_audio` - `v1.0.1`
- `flame_bloc` - `v1.2.0`
- `flame_fire_atlas` - `v1.0.1`
- `flame_flare` - `v1.1.0`
- `flame_forge2d` - `v0.9.0`
- `flame_oxygen` - `v0.1.1`
- `flame_rive` - `v1.1.0`
- `flame_svg` - `v1.1.0`
- `flame_test` - `v1.2.0`
- `flame_tiled` - `v1.3.0`

## 2022-03-22

### Changes

---

Packages with breaking changes:

 - There are no breaking changes in this release.

Packages with other changes:

 - [`flame_audio` - `v1.0.1-releasecandidate.1`](#flame_audio---v101-releasecandidate1)
 - [`flame_fire_atlas` - `v1.0.1-releasecandidate.1`](#flame_fire_atlas---v101-releasecandidate1)
 - [`flame_flare` - `v1.1.0-releasecandidate.1`](#flame_flare---v110-releasecandidate1)
 - [`flame_oxygen` - `v0.1.1-releasecandidate.1`](#flame_oxygen---v011-releasecandidate1)
 - [`flame` - `v1.1.0-releasecandidate.6`](#flame---v110-releasecandidate6)
 - [`flame_bloc` - `v1.2.0-releasecandidate.6`](#flame_bloc---v120-releasecandidate6)
 - [`flame_forge2d` - `v0.9.0-releasecandidate.6`](#flame_forge2d---v090-releasecandidate6)
 - [`flame_svg` - `v1.1.0-releasecandidate.5`](#flame_svg---v110-releasecandidate5)
 - [`flame_test` - `v1.2.0-releasecandidate.6`](#flame_test---v120-releasecandidate6)
 - [`flame_rive` - `v1.1.0-releasecandidate.6`](#flame_rive---v110-releasecandidate6)
 - [`flame_tiled` - `v1.3.0-releasecandidate.6`](#flame_tiled---v130-releasecandidate6)

Packages with dependency updates only:

> Packages listed below depend on other packages in this workspace that have had changes. Their versions have been incremented to bump the minimum dependency versions of the packages they depend upon in this project.

 - `flame_svg` - `v1.1.0-releasecandidate.5`
 - `flame_test` - `v1.2.0-releasecandidate.6`
 - `flame_rive` - `v1.1.0-releasecandidate.6`
 - `flame_tiled` - `v1.3.0-releasecandidate.6`

---

#### `flame_audio` - `v1.0.1-releasecandidate.1`

#### `flame_fire_atlas` - `v1.0.1-releasecandidate.1`

#### `flame_flare` - `v1.1.0-releasecandidate.1`

#### `flame_oxygen` - `v0.1.1-releasecandidate.1`

#### `flame` - `v1.1.0-releasecandidate.6`

 - **FIX**: Only end collisions where there was a collision (#1471). ([e1e87fc4](https://github.com/flame-engine/flame/commit/e1e87fc42226c1db2f472377901031277349beb3))
 - **FIX**: `debugMode` should be inherited from parent when mounted (#1469). ([e894d201](https://github.com/flame-engine/flame/commit/e894d20133f6e142c67286c449135e37e892f35b))
 - **FEAT**: Added method that returned descendants (#1461). ([a41f5376](https://github.com/flame-engine/flame/commit/a41f53762ab49bb3d51f1f96c37b934a7ab83844))
 - **FEAT**: Possibility to mark gesture events as handled (#1465). ([4c3960c3](https://github.com/flame-engine/flame/commit/4c3960c3418f8ff4d557c1764c6793468238a8da))
 - **FEAT**: adding loaded future to the component (#1466). ([6434829b](https://github.com/flame-engine/flame/commit/6434829b45cc131719fd950ef2d262d0bfbdff1b))
 - **FEAT**: Deprecating Rect methods (#1455). ([4ddd90aa](https://github.com/flame-engine/flame/commit/4ddd90aafc40a3f5ce3d9b181a66369436de3c9c))
 - **FEAT**: Added .anchor property to CameraComponent.Viewfinder (#1458). ([d51dc5e1](https://github.com/flame-engine/flame/commit/d51dc5e132bc3ba5763be4de36131d3739a6c906))
 - **DOCS**: `Rect` extension docs is out of date (#1451). ([7e505722](https://github.com/flame-engine/flame/commit/7e505722491dd03fea6d2329ff4df2447143d45b))

#### `flame_bloc` - `v1.2.0-releasecandidate.6`

 - **FEAT**: Possibility to mark gesture events as handled (#1465). ([4c3960c3](https://github.com/flame-engine/flame/commit/4c3960c3418f8ff4d557c1764c6793468238a8da))

#### `flame_forge2d` - `v0.9.0-releasecandidate.6`

 - **FEAT**: updating forge2d version (#1479). ([4678e21a](https://github.com/flame-engine/flame/commit/4678e21a0b714b8344ae2453b1ac6df68adfb4cd))
 - **FEAT**: Possibility to mark gesture events as handled (#1465). ([4c3960c3](https://github.com/flame-engine/flame/commit/4c3960c3418f8ff4d557c1764c6793468238a8da))


## 2022-03-13

### Changes

---

Packages with breaking changes:

 - There are no breaking changes in this release.

Packages with other changes:

 - [`flame` - `v1.1.0-releasecandidate.5`](#flame---v110-releasecandidate5)
 - [`flame_forge2d` - `v0.9.0-releasecandidate.5`](#flame_forge2d---v090-releasecandidate5)
 - [`flame_svg` - `v1.1.0-releasecandidate.4`](#flame_svg---v110-releasecandidate4)
 - [`flame_test` - `v1.2.0-releasecandidate.5`](#flame_test---v120-releasecandidate5)
 - [`flame_rive` - `v1.1.0-releasecandidate.5`](#flame_rive---v110-releasecandidate5)
 - [`flame_tiled` - `v1.3.0-releasecandidate.5`](#flame_tiled---v130-releasecandidate5)
 - [`flame_bloc` - `v1.2.0-releasecandidate.5`](#flame_bloc---v120-releasecandidate5)

Packages with dependency updates only:

> Packages listed below depend on other packages in this workspace that have had changes. Their versions have been incremented to bump the minimum dependency versions of the packages they depend upon in this project.

 - `flame_svg` - `v1.1.0-releasecandidate.4`
 - `flame_test` - `v1.2.0-releasecandidate.5`
 - `flame_rive` - `v1.1.0-releasecandidate.5`
 - `flame_tiled` - `v1.3.0-releasecandidate.5`
 - `flame_bloc` - `v1.2.0-releasecandidate.5`

---

#### `flame` - `v1.1.0-releasecandidate.5`

 - **FIX**: `@mustCallSuper` missing on components (#1443). ([e01b4b1a](https://github.com/flame-engine/flame/commit/e01b4b1ac3e423037fa313672b4882e7d29210b8))
 - **FEAT**: Add setter to priority (#1444). ([34284686](https://github.com/flame-engine/flame/commit/342846860af36ed73a1fc0a9a76ed9add12cec71))

#### `flame_forge2d` - `v0.9.0-releasecandidate.5`

 - **FEAT**: `BodyComponent` can properly have normal Flame component children (#1442). ([7fe8b6de](https://github.com/flame-engine/flame/commit/7fe8b6deb18b3579fecc99cc44e0ffea73be5f02))


## 2022-03-11

### Changes

---

Packages with breaking changes:

 - There are no breaking changes in this release.

Packages with other changes:

 - [`flame` - `v1.1.0-releasecandidate.4`](#flame---v110-releasecandidate4)
 - [`flame_forge2d` - `v0.9.0-releasecandidate.4`](#flame_forge2d---v090-releasecandidate4)
 - [`flame_svg` - `v1.1.0-releasecandidate.3`](#flame_svg---v110-releasecandidate3)
 - [`flame_test` - `v1.2.0-releasecandidate.4`](#flame_test---v120-releasecandidate4)
 - [`flame_rive` - `v1.1.0-releasecandidate.4`](#flame_rive---v110-releasecandidate4)
 - [`flame_tiled` - `v1.3.0-releasecandidate.4`](#flame_tiled---v130-releasecandidate4)
 - [`flame_bloc` - `v1.2.0-releasecandidate.4`](#flame_bloc---v120-releasecandidate4)

Packages with dependency updates only:

> Packages listed below depend on other packages in this workspace that have had changes. Their versions have been incremented to bump the minimum dependency versions of the packages they depend upon in this project.

 - `flame_svg` - `v1.1.0-releasecandidate.3`
 - `flame_test` - `v1.2.0-releasecandidate.4`
 - `flame_rive` - `v1.1.0-releasecandidate.4`
 - `flame_tiled` - `v1.3.0-releasecandidate.4`
 - `flame_bloc` - `v1.2.0-releasecandidate.4`

---

#### `flame` - `v1.1.0-releasecandidate.4`

 - **FIX**: Setting images.prefix to empty string (#1437). ([694102bd](https://github.com/flame-engine/flame/commit/694102bd0304736ed3bdfbd596d64901d7adf57f))

#### `flame_forge2d` - `v0.9.0-releasecandidate.4`

 - **FIX**: Don't use debug rendering by default in BodyComponent (#1439). ([33b725e8](https://github.com/flame-engine/flame/commit/33b725e8378d4060e726e99c0452b64f54ef8f67))


## 2022-03-10

### Changes

---

Packages with breaking changes:

 - There are no breaking changes in this release.

Packages with other changes:

 - [`flame` - `v1.1.0-releasecandidate.3`](#flame---v110-releasecandidate3)
 - [`flame_bloc` - `v1.2.0-releasecandidate.3`](#flame_bloc---v120-releasecandidate3)
 - [`flame_svg` - `v1.1.0-releasecandidate.2`](#flame_svg---v110-releasecandidate2)
 - [`flame_test` - `v1.2.0-releasecandidate.3`](#flame_test---v120-releasecandidate3)
 - [`flame_rive` - `v1.1.0-releasecandidate.3`](#flame_rive---v110-releasecandidate3)
 - [`flame_forge2d` - `v0.9.0-releasecandidate.3`](#flame_forge2d---v090-releasecandidate3)
 - [`flame_tiled` - `v1.3.0-releasecandidate.3`](#flame_tiled---v130-releasecandidate3)

Packages with dependency updates only:

> Packages listed below depend on other packages in this workspace that have had changes. Their versions have been incremented to bump the minimum dependency versions of the packages they depend upon in this project.

 - `flame_svg` - `v1.1.0-releasecandidate.2`
 - `flame_test` - `v1.2.0-releasecandidate.3`
 - `flame_rive` - `v1.1.0-releasecandidate.3`
 - `flame_forge2d` - `v0.9.0-releasecandidate.3`
 - `flame_tiled` - `v1.3.0-releasecandidate.3`

---

#### `flame` - `v1.1.0-releasecandidate.3`

 - **REFACTOR**: Parent change and component removal logic (#1385). ([8b9fa352](https://github.com/flame-engine/flame/commit/8b9fa3521cc44f7696c5ce0b396e3007c2ae7e8c))
 - **FIX**: viewfinders behavior under zoom (#1432). ([f3cf85b6](https://github.com/flame-engine/flame/commit/f3cf85b638cc71058e85756498e79971a1942491))
 - **FIX**: change strokeWidth in Component (#1431). ([0e174fe8](https://github.com/flame-engine/flame/commit/0e174fe8e5f1262af41c8659c0fce7ed060e69a9))
 - **FEAT**: allowing changing of the images prefix and allowing empty prefixes (#1433). ([de4d9416](https://github.com/flame-engine/flame/commit/de4d941654710add459cc1c923b92c3923556f15))

#### `flame_bloc` - `v1.2.0-releasecandidate.3`

 - **REFACTOR**: Parent change and component removal logic (#1385). ([8b9fa352](https://github.com/flame-engine/flame/commit/8b9fa3521cc44f7696c5ce0b396e3007c2ae7e8c))


## 2022-03-08

### Changes

---

Packages with breaking changes:

 - [`flame_svg` - `v1.1.0-releasecandidate.1`](#flame_svg---v110-releasecandidate1)
 - [`flame` - `v1.1.0-releasecandidate.2`](#flame---v110-releasecandidate2)
 - [`flame_bloc` - `v1.2.0-releasecandidate.2`](#flame_bloc---v120-releasecandidate2)
 - [`flame_test` - `v1.2.0-releasecandidate.2`](#flame_test---v120-releasecandidate2)

Packages with other changes:

 - [`flame_forge2d` - `v0.9.0-releasecandidate.2`](#flame_forge2d---v090-releasecandidate2)
 - [`flame_rive` - `v1.1.0-releasecandidate.2`](#flame_rive---v110-releasecandidate2)
 - [`flame_tiled` - `v1.3.0-releasecandidate.2`](#flame_tiled---v130-releasecandidate2)

Packages with dependency updates only:

> Packages listed below depend on other packages in this workspace that have had changes. Their versions have been incremented to bump the minimum dependency versions of the packages they depend upon in this project.

 - `flame_tiled` - `v1.3.0-releasecandidate.2`

---

#### `flame_svg` - `v1.1.0-releasecandidate.1`

 - **FIX**: flame svg perfomance (#1373). ([bce24173](https://github.com/flame-engine/flame/commit/bce2417330b5165842f15d0409a213a1c5ad1cd3))
 - **FIX**: preventing svg rendering from affecting other renderings (#1339). ([6e66baa1](https://github.com/flame-engine/flame/commit/6e66baa12fdad7b27f35ca274433acd55165f106))
 - **FEAT**: adding default constructor on SvgComponent (#1334). ([00619f80](https://github.com/flame-engine/flame/commit/00619f80475b1e66802a6d2020ea6d521c84059d))
 - **DOCS**: Fix various dartdoc warnings (#1353). ([9f096053](https://github.com/flame-engine/flame/commit/9f096053fd3c8ebd52d301710625a187db09704f))
 - **BREAKING** **FEAT**: Use a broadphase to make collision detection more efficient (#1252). ([29dd09ca](https://github.com/flame-engine/flame/commit/29dd09ca925e934f3ca4e266a8a0cdb8ad62ef3b))

#### `flame` - `v1.1.0-releasecandidate.2`

 - **REFACTOR**: Loadable mixin no longer declares onMount and onRemove (#1243). ([b1f6a34c](https://github.com/flame-engine/flame/commit/b1f6a34c198a732d51471bf0b79a71a4f3e60973))
 - **REFACTOR**: Organize tests in the game/ folder (#1403). ([102a27cc](https://github.com/flame-engine/flame/commit/102a27cc75d15e1c0ec867d739c9ce3f7feaff56))
 - **REFACTOR**: Clean up of top-level tests (#1386). ([e50003ed](https://github.com/flame-engine/flame/commit/e50003ed609fabe4268ceaa1e728b6f29f05939e))
 - **REFACTOR**: Resize logic in GameRenderBox (#1308). ([17c45c28](https://github.com/flame-engine/flame/commit/17c45c28291862ba2c7c079fe91e994a71b1d807))
 - **REFACTOR**: Simplify GameWidgetState.loaderFuture (#1232). ([eb30c2e5](https://github.com/flame-engine/flame/commit/eb30c2e5e9b10e388a9d56283b90e3f09c5f9379))
 - **REFACTOR**: Component.ancestors() is now an iterator (#1242). ([ce48d77a](https://github.com/flame-engine/flame/commit/ce48d77ad72a3c5f865c7ec40b753678a2fbebe4))
 - **REFACTOR**: Add a few more rules to flame_lint, including use_key_in_widget_constructors (#1248). ([bac6c8a4](https://github.com/flame-engine/flame/commit/bac6c8a4469f2c5c2926335f2f589eec9b1a5b5b))
 - **REFACTOR**: Removed parameter Component.updateTree({callOwnUpdate}) (#1224). ([ed227e7c](https://github.com/flame-engine/flame/commit/ed227e7c74bae51061e9622fe6852cf020ce6fa6))
 - **REFACTOR**: Remove Loadable, optional onLoads (#1333). ([05f7a4c3](https://github.com/flame-engine/flame/commit/05f7a4c3d6b1e3b67575c4ec920cf270691bbab4))
 - **REFACTOR**: Loadable no longer declares onGameResize (#1329). ([20776e86](https://github.com/flame-engine/flame/commit/20776e8659bda57813ddc14856502d4b07b85fef))
 - **REFACTOR**: Use canvas.drawImageNine in NineTileBox (#1314). ([d77e5efe](https://github.com/flame-engine/flame/commit/d77e5efee573ddcbc84a50be7728d7a9207287f7))
 - **PERF**: Allow components to have null children (#1231). ([66ad4b08](https://github.com/flame-engine/flame/commit/66ad4b08af6153fb767667a7bed42dac6fb8f2c7))
 - **FIX**: flame svg perfomance (#1373). ([bce24173](https://github.com/flame-engine/flame/commit/bce2417330b5165842f15d0409a213a1c5ad1cd3))
 - **FIX**: Fix collision detection comments and typo (#1422). ([dfeafdd6](https://github.com/flame-engine/flame/commit/dfeafdd6f3e962d6f5148340ab461a9e805652b7))
 - **FIX**: `ParallaxComponent` should have static `positionType` (#1350). ([cfa6bd12](https://github.com/flame-engine/flame/commit/cfa6bd127be620f6016442a269a479d162241a11))
 - **FIX**: Add missing `priority` argument for `JoystickComponent` (#1227). ([23b1dd8b](https://github.com/flame-engine/flame/commit/23b1dd8bbcc98ae3c59a86c10e03b074982b6adc))
 - **FIX**: Step time in SpriteAnimation must be positive (#1387). ([08e8eac1](https://github.com/flame-engine/flame/commit/08e8eac1734a63111a5b7aba4e1bfd20d503aaf4))
 - **FIX**: HudMarginComponent positioning on zoom (#1250). ([4f0fb2de](https://github.com/flame-engine/flame/commit/4f0fb2de6f12ad950705ddb75ebd2e80114321e5))
 - **FIX**: Call onCollisionEnd on removal of Collidable (#1247). ([5ddcc6f7](https://github.com/flame-engine/flame/commit/5ddcc6f7baaae60996747d37b4d92f4f890c7fa2))
 - **FIX**: Both places should have `strictMode = false` (#1272). ([72161ad8](https://github.com/flame-engine/flame/commit/72161ad8d2f2a0916f4448d67644272fdc9ceace))
 - **FIX**: remove vector_math dependency (#1361). ([56b33da2](https://github.com/flame-engine/flame/commit/56b33da29cfe547db75c89d97a09550a324fb0f5))
 - **FIX**: Deprecate pause and resume in GameLoop (#1240). ([dc37053f](https://github.com/flame-engine/flame/commit/dc37053fb6ed46bb68cebab0ed82248051ddf86a))
 - **FIX**: Deprecate Images.decodeImageFromPixels (#1318). ([1a80130c](https://github.com/flame-engine/flame/commit/1a80130c6632cc8b1f34c19aa928ac66364ecbe5))
 - **FIX**: Properly dispose images when cache is cleared (#1312). ([825fb0cc](https://github.com/flame-engine/flame/commit/825fb0cc7e5b30911e17a2075e28f74c8d69b593))
 - **FIX**: Fix SpriteAnimationWidget lifecycle (#1212). ([86394dd3](https://github.com/flame-engine/flame/commit/86394dd3e05079494c7c3c000c3104712faf7507))
 - **FIX**: redrawing bug in TextBoxComponent (#1279). ([8bef4805](https://github.com/flame-engine/flame/commit/8bef480597024f51ac2e4f534e1977f53d768df2))
 - **FIX**: Add missing paint argument to `SpriteComponent.fromImage` (#1294). ([254a60c8](https://github.com/flame-engine/flame/commit/254a60c8475da218a61d2b179d894f469efe5486))
 - **FIX**: black frame when activating overlays (#1093). ([85caf463](https://github.com/flame-engine/flame/commit/85caf463f48ce34fdf51bfd0f511c8188dcf4481))
 - **FIX**: `prepareComponent` should never run again on a prepared component (#1237). ([7d3eeb73](https://github.com/flame-engine/flame/commit/7d3eeb73c588f2465472cd6069f28d6136b0721d))
 - **FIX**: Allow most basic and advanced gesture detectors together (#1208). ([5828b6f3](https://github.com/flame-engine/flame/commit/5828b6f369b74b8f1ab2cc42905c647bbc7dfda5))
 - **FEAT**: Added SpeedEffectController (#1260). ([20f521f5](https://github.com/flame-engine/flame/commit/20f521f5beb5ee476d345d1766a30b4ba35c079b))
 - **FEAT**: Added SineEffectController (#1262). ([c888703d](https://github.com/flame-engine/flame/commit/c888703d6e002fe5f15a82d6204a0639f92aa66a))
 - **FEAT**: Added ZigzagEffectController (#1261). ([59adc5f3](https://github.com/flame-engine/flame/commit/59adc5f34c2eebd336f7d39a703a6845227b55ed))
 - **FEAT**: Add onReleased callback for HudButtonComponent (#1296). ([87ee34ca](https://github.com/flame-engine/flame/commit/87ee34cac72b6d09b8c8f870433541361ff383c1))
 - **FEAT**: Turn off `strictMode` for children (#1271). ([6936e1d9](https://github.com/flame-engine/flame/commit/6936e1d98b63c071787d3dea09fad7659bdf0473))
 - **FEAT**: `onCollisionStart` for `Collidable` and `HitboxShape` (#1251). ([9b95686b](https://github.com/flame-engine/flame/commit/9b95686ba57c16c9f029f920150e112d180bd584))
 - **FEAT**: adding has mounted to component (#1418). ([f8f9e045](https://github.com/flame-engine/flame/commit/f8f9e0451309bfdd29ec8cefbf9d8187209a314c))
 - **FEAT**: Added NoiseEffectController (#1356). ([fad9d1d5](https://github.com/flame-engine/flame/commit/fad9d1d54f4c3500611f82a9382ffa1fed9b52b8))
 - **FEAT**: exporting cache classes (#1368). ([3e058973](https://github.com/flame-engine/flame/commit/3e0589730c49663b5c4863fc28718b3fa81b7b60))
 - **FEAT**: Update scale events to contain pan info (#1327). ([70b96b07](https://github.com/flame-engine/flame/commit/70b96b071a8e936b5c5d6014cb18277b76c646db))
 - **FEAT**: Components are now always added in the correct order (#1337). ([c753fc46](https://github.com/flame-engine/flame/commit/c753fc4636d337d850a5a5cc684be8155f08b214))
 - **FEAT**: Added `transform` to `Rect` (#1360). ([1818be41](https://github.com/flame-engine/flame/commit/1818be41761015b33aee820a0a02f50327a4df4e))
 - **FEAT**: Camera as a component (#1355). ([c61a1c18](https://github.com/flame-engine/flame/commit/c61a1c18b5bdd0b27f3ab21d73d8bbddffd48ba2))
 - **FEAT**: Effect.onComplete callback as an alternative to onFinish() (#1201). ([932a8111](https://github.com/flame-engine/flame/commit/932a81118b0faba80def677cd0db28a598e15204))
 - **FEAT**: Add RandomEffectController (#1203). ([cdb2650b](https://github.com/flame-engine/flame/commit/cdb2650b29bee6e8412a666f9f49fabb68ce0265))
 - **FEAT**: `Component.childrenFactory` can be used to set up a global `ComponentSet` factory (#1193). ([223ab758](https://github.com/flame-engine/flame/commit/223ab75886ab018053cd75af33560a03e1b9d470))
 - **DOCS**: Added documentation for GameLoop class (#1234). ([b1d4e587](https://github.com/flame-engine/flame/commit/b1d4e5872e970f8bd4020a051c35b5cac4093b5e))
 - **DOCS**: Fix various dartdoc warnings (#1353). ([9f096053](https://github.com/flame-engine/flame/commit/9f096053fd3c8ebd52d301710625a187db09704f))
 - **BREAKING** **REFACTOR**: Separate ComponentSet from the Component (#1266). ([e2655b88](https://github.com/flame-engine/flame/commit/e2655b8817411ae6b1c505719fed75a170f67aeb))
 - **BREAKING** **FIX**: Remove pointerId from Draggable callbacks (#1313). ([27adda17](https://github.com/flame-engine/flame/commit/27adda17b7b4d8c229cca53799826c7b854eae95))
 - **BREAKING** **FEAT**: Use a broadphase to make collision detection more efficient (#1252). ([29dd09ca](https://github.com/flame-engine/flame/commit/29dd09ca925e934f3ca4e266a8a0cdb8ad62ef3b))
 - **BREAKING** **FEAT**: Added SequenceEffect (#1218). ([7c6ae6de](https://github.com/flame-engine/flame/commit/7c6ae6def36ae5feb813fb2ba15d6fb3b9aaf341))

#### `flame_bloc` - `v1.2.0-releasecandidate.2`

 - **REFACTOR**: Remove Loadable, optional onLoads (#1333). ([05f7a4c3](https://github.com/flame-engine/flame/commit/05f7a4c3d6b1e3b67575c4ec920cf270691bbab4))
 - **REFACTOR**: Loadable mixin no longer declares onMount and onRemove (#1243). ([b1f6a34c](https://github.com/flame-engine/flame/commit/b1f6a34c198a732d51471bf0b79a71a4f3e60973))
 - **FIX**: Fix collision detection comments and typo (#1422). ([dfeafdd6](https://github.com/flame-engine/flame/commit/dfeafdd6f3e962d6f5148340ab461a9e805652b7))
 - **FEAT**: adding FlameBloc mixin to allow its usage with enhanced FlameGame classes (#1399). ([78aab426](https://github.com/flame-engine/flame/commit/78aab42694c66c8b9ea749ac11187f1ed1789a4c))
 - **FEAT**: Components are now always added in the correct order (#1337). ([c753fc46](https://github.com/flame-engine/flame/commit/c753fc4636d337d850a5a5cc684be8155f08b214))
 - **FEAT**: Optional Camera argument in FlameBlocGame (#1331). ([bcb27f70](https://github.com/flame-engine/flame/commit/bcb27f706f3afcecfe417e065d6c16a6edb1463f))
 - **FEAT**: publish flame bloc (#1319). ([4d5adcb0](https://github.com/flame-engine/flame/commit/4d5adcb0d01d374ca807c71f2b8d963d0781a976))
 - **DOCS**: Upgrade documentation site (#1365). ([12cf8f70](https://github.com/flame-engine/flame/commit/12cf8f70963dc25b4e12182d0c7d80fe7d5a00e0))
 - **DOCS**: Fix various dartdoc warnings (#1353). ([9f096053](https://github.com/flame-engine/flame/commit/9f096053fd3c8ebd52d301710625a187db09704f))
 - **DOCS**: Fix typo in flame_bloc readme (#1332). ([9bff96bf](https://github.com/flame-engine/flame/commit/9bff96bf3a668fc107c0712aadc6b095ebd50788))
 - **BREAKING** **FEAT**: Use a broadphase to make collision detection more efficient (#1252). ([29dd09ca](https://github.com/flame-engine/flame/commit/29dd09ca925e934f3ca4e266a8a0cdb8ad62ef3b))
 - **BREAKING** **FEAT**: updating flame_bloc to bloc 8 (#1311). ([574e0ab5](https://github.com/flame-engine/flame/commit/574e0ab58baa14680cb0d0eded642b4729b062e7))

#### `flame_test` - `v1.2.0-releasecandidate.2`

 - **REFACTOR**: Add a few more rules to flame_lint, including use_key_in_widget_constructors (#1248). ([bac6c8a4](https://github.com/flame-engine/flame/commit/bac6c8a4469f2c5c2926335f2f589eec9b1a5b5b))
 - **FIX**: remove vector_math dependency (#1361). ([56b33da2](https://github.com/flame-engine/flame/commit/56b33da29cfe547db75c89d97a09550a324fb0f5))
 - **FEAT**: Components are now always added in the correct order (#1337). ([c753fc46](https://github.com/flame-engine/flame/commit/c753fc4636d337d850a5a5cc684be8155f08b214))
 - **FEAT**: Added parameter repeatCount into function testRandom (#1265). ([49a2d0b9](https://github.com/flame-engine/flame/commit/49a2d0b9ec00fa9067756dd975e8b3ffd19de0bc))
 - **FEAT**: Added closeToVector in flame_test (#1245). ([af45ea6c](https://github.com/flame-engine/flame/commit/af45ea6cc4b5de80ecb27f07b827f55567cf602b))
 - **DOCS**: Upgrade documentation site (#1365). ([12cf8f70](https://github.com/flame-engine/flame/commit/12cf8f70963dc25b4e12182d0c7d80fe7d5a00e0))
 - **DOCS**: Fix various dartdoc warnings (#1353). ([9f096053](https://github.com/flame-engine/flame/commit/9f096053fd3c8ebd52d301710625a187db09704f))
 - **BREAKING** **FEAT**: Added SequenceEffect (#1218). ([7c6ae6de](https://github.com/flame-engine/flame/commit/7c6ae6def36ae5feb813fb2ba15d6fb3b9aaf341))

#### `flame_forge2d` - `v0.9.0-releasecandidate.2`

 - **FIX**: PositionBodyComponent had an async onMount, without needing (#1424). ([7b0fd20a](https://github.com/flame-engine/flame/commit/7b0fd20a2c6d9f6cac0a88877c793608ab4d14c8))
 - **FEAT**: Make ContactCallback begin end methods optional overrides (#1415). ([29dd1891](https://github.com/flame-engine/flame/commit/29dd1891b6409ed71c54e05272100dbb180d18e7))

#### `flame_rive` - `v1.1.0-releasecandidate.2`

 - **REFACTOR**: Remove Loadable, optional onLoads (#1333). ([05f7a4c3](https://github.com/flame-engine/flame/commit/05f7a4c3d6b1e3b67575c4ec920cf270691bbab4))
 - **FEAT**: Components are now always added in the correct order (#1337). ([c753fc46](https://github.com/flame-engine/flame/commit/c753fc4636d337d850a5a5cc684be8155f08b214))
 - **FEAT**: update rive package to 0.8.1 (now support raster graphics) (#1343). ([062962de](https://github.com/flame-engine/flame/commit/062962de087cd2a8107b1ae27472095e72bdf847))
 - **DOCS**: Fix various dartdoc warnings (#1353). ([9f096053](https://github.com/flame-engine/flame/commit/9f096053fd3c8ebd52d301710625a187db09704f))


## 2022-02-28

### Changes

---

Packages with breaking changes:

 - [`flame_forge2d` - `v0.9.0-releasecandidate.1`](#flame_forge2d---v090-releasecandidate1)

Packages with other changes:

 - There are no other changes in this release.

---

#### `flame_forge2d` - `v0.9.0-releasecandidate.1`

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


## 2022-02-28

### Changes

---

Packages with breaking changes:

 - [`flame` - `v1.1.0-releasecandidate.1`](#flame---v110-releasecandidate1)
 - [`flame_test` - `v1.2.0-releasecandidate.1`](#flame_test---v120-releasecandidate1)
 - [`flame_tiled` - `v1.3.0-releasecandidate.1`](#flame_tiled---v130-releasecandidate1)

Packages with other changes:

 - [`flame_bloc` - `v1.2.0-releasecandidate.1`](#flame_bloc---v120-releasecandidate1)
 - [`flame_rive` - `v1.1.0-releasecandidate.1`](#flame_rive---v110-releasecandidate1)

---

#### `flame` - `v1.1.0-releasecandidate.1`

 - **REFACTOR**: Clean up of top-level tests (#1386). ([e50003ed](https://github.com/flame-engine/flame/commit/e50003ed609fabe4268ceaa1e728b6f29f05939e))
 - **REFACTOR**: Remove Loadable, optional onLoads (#1333). ([05f7a4c3](https://github.com/flame-engine/flame/commit/05f7a4c3d6b1e3b67575c4ec920cf270691bbab4))
 - **REFACTOR**: Loadable no longer declares onGameResize (#1329). ([20776e86](https://github.com/flame-engine/flame/commit/20776e8659bda57813ddc14856502d4b07b85fef))
 - **REFACTOR**: Organize tests in the game/ folder (#1403). ([102a27cc](https://github.com/flame-engine/flame/commit/102a27cc75d15e1c0ec867d739c9ce3f7feaff56))
 - **REFACTOR**: Use canvas.drawImageNine in NineTileBox (#1314). ([d77e5efe](https://github.com/flame-engine/flame/commit/d77e5efee573ddcbc84a50be7728d7a9207287f7))
 - **REFACTOR**: Resize logic in GameRenderBox (#1308). ([17c45c28](https://github.com/flame-engine/flame/commit/17c45c28291862ba2c7c079fe91e994a71b1d807))
 - **REFACTOR**: Loadable mixin no longer declares onMount and onRemove (#1243). ([b1f6a34c](https://github.com/flame-engine/flame/commit/b1f6a34c198a732d51471bf0b79a71a4f3e60973))
 - **REFACTOR**: Removed parameter Component.updateTree({callOwnUpdate}) (#1224). ([ed227e7c](https://github.com/flame-engine/flame/commit/ed227e7c74bae51061e9622fe6852cf020ce6fa6))
 - **REFACTOR**: Add a few more rules to flame_lint, including use_key_in_widget_constructors (#1248). ([bac6c8a4](https://github.com/flame-engine/flame/commit/bac6c8a4469f2c5c2926335f2f589eec9b1a5b5b))
 - **REFACTOR**: Component.ancestors() is now an iterator (#1242). ([ce48d77a](https://github.com/flame-engine/flame/commit/ce48d77ad72a3c5f865c7ec40b753678a2fbebe4))
 - **REFACTOR**: Simplify GameWidgetState.loaderFuture (#1232). ([eb30c2e5](https://github.com/flame-engine/flame/commit/eb30c2e5e9b10e388a9d56283b90e3f09c5f9379))
 - **PERF**: Allow components to have null children (#1231). ([66ad4b08](https://github.com/flame-engine/flame/commit/66ad4b08af6153fb767667a7bed42dac6fb8f2c7))
 - **FIX**: `prepareComponent` should never run again on a prepared component (#1237). ([7d3eeb73](https://github.com/flame-engine/flame/commit/7d3eeb73c588f2465472cd6069f28d6136b0721d))
 - **FIX**: flame svg perfomance (#1373). ([bce24173](https://github.com/flame-engine/flame/commit/bce2417330b5165842f15d0409a213a1c5ad1cd3))
 - **FIX**: Deprecate pause and resume in GameLoop (#1240). ([dc37053f](https://github.com/flame-engine/flame/commit/dc37053fb6ed46bb68cebab0ed82248051ddf86a))
 - **FIX**: Deprecate Images.decodeImageFromPixels (#1318). ([1a80130c](https://github.com/flame-engine/flame/commit/1a80130c6632cc8b1f34c19aa928ac66364ecbe5))
 - **FIX**: Properly dispose images when cache is cleared (#1312). ([825fb0cc](https://github.com/flame-engine/flame/commit/825fb0cc7e5b30911e17a2075e28f74c8d69b593))
 - **FIX**: Add missing paint argument to `SpriteComponent.fromImage` (#1294). ([254a60c8](https://github.com/flame-engine/flame/commit/254a60c8475da218a61d2b179d894f469efe5486))
 - **FIX**: Add missing `priority` argument for `JoystickComponent` (#1227). ([23b1dd8b](https://github.com/flame-engine/flame/commit/23b1dd8bbcc98ae3c59a86c10e03b074982b6adc))
 - **FIX**: remove vector_math dependency (#1361). ([56b33da2](https://github.com/flame-engine/flame/commit/56b33da29cfe547db75c89d97a09550a324fb0f5))
 - **FIX**: redrawing bug in TextBoxComponent (#1279). ([8bef4805](https://github.com/flame-engine/flame/commit/8bef480597024f51ac2e4f534e1977f53d768df2))
 - **FIX**: Fix SpriteAnimationWidget lifecycle (#1212). ([86394dd3](https://github.com/flame-engine/flame/commit/86394dd3e05079494c7c3c000c3104712faf7507))
 - **FIX**: black frame when activating overlays (#1093). ([85caf463](https://github.com/flame-engine/flame/commit/85caf463f48ce34fdf51bfd0f511c8188dcf4481))
 - **FIX**: Call onCollisionEnd on removal of Collidable (#1247). ([5ddcc6f7](https://github.com/flame-engine/flame/commit/5ddcc6f7baaae60996747d37b4d92f4f890c7fa2))
 - **FIX**: HudMarginComponent positioning on zoom (#1250). ([4f0fb2de](https://github.com/flame-engine/flame/commit/4f0fb2de6f12ad950705ddb75ebd2e80114321e5))
 - **FIX**: Both places should have `strictMode = false` (#1272). ([72161ad8](https://github.com/flame-engine/flame/commit/72161ad8d2f2a0916f4448d67644272fdc9ceace))
 - **FIX**: `ParallaxComponent` should have static `positionType` (#1350). ([cfa6bd12](https://github.com/flame-engine/flame/commit/cfa6bd127be620f6016442a269a479d162241a11))
 - **FIX**: Allow most basic and advanced gesture detectors together (#1208). ([5828b6f3](https://github.com/flame-engine/flame/commit/5828b6f369b74b8f1ab2cc42905c647bbc7dfda5))
 - **FIX**: Step time in SpriteAnimation must be positive (#1387). ([08e8eac1](https://github.com/flame-engine/flame/commit/08e8eac1734a63111a5b7aba4e1bfd20d503aaf4))
 - **FEAT**: Update scale events to contain pan info (#1327). ([70b96b07](https://github.com/flame-engine/flame/commit/70b96b071a8e936b5c5d6014cb18277b76c646db))
 - **FEAT**: Add RandomEffectController (#1203). ([cdb2650b](https://github.com/flame-engine/flame/commit/cdb2650b29bee6e8412a666f9f49fabb68ce0265))
 - **FEAT**: Components are now always added in the correct order (#1337). ([c753fc46](https://github.com/flame-engine/flame/commit/c753fc4636d337d850a5a5cc684be8155f08b214))
 - **FEAT**: Effect.onComplete callback as an alternative to onFinish() (#1201). ([932a8111](https://github.com/flame-engine/flame/commit/932a81118b0faba80def677cd0db28a598e15204))
 - **FEAT**: exporting cache classes (#1368). ([3e058973](https://github.com/flame-engine/flame/commit/3e0589730c49663b5c4863fc28718b3fa81b7b60))
 - **FEAT**: Added NoiseEffectController (#1356). ([fad9d1d5](https://github.com/flame-engine/flame/commit/fad9d1d54f4c3500611f82a9382ffa1fed9b52b8))
 - **FEAT**: Added SineEffectController (#1262). ([c888703d](https://github.com/flame-engine/flame/commit/c888703d6e002fe5f15a82d6204a0639f92aa66a))
 - **FEAT**: Added SpeedEffectController (#1260). ([20f521f5](https://github.com/flame-engine/flame/commit/20f521f5beb5ee476d345d1766a30b4ba35c079b))
 - **FEAT**: Added ZigzagEffectController (#1261). ([59adc5f3](https://github.com/flame-engine/flame/commit/59adc5f34c2eebd336f7d39a703a6845227b55ed))
 - **FEAT**: Turn off `strictMode` for children (#1271). ([6936e1d9](https://github.com/flame-engine/flame/commit/6936e1d98b63c071787d3dea09fad7659bdf0473))
 - **FEAT**: `onCollisionStart` for `Collidable` and `HitboxShape` (#1251). ([9b95686b](https://github.com/flame-engine/flame/commit/9b95686ba57c16c9f029f920150e112d180bd584))
 - **FEAT**: `Component.childrenFactory` can be used to set up a global `ComponentSet` factory (#1193). ([223ab758](https://github.com/flame-engine/flame/commit/223ab75886ab018053cd75af33560a03e1b9d470))
 - **FEAT**: Added `transform` to `Rect` (#1360). ([1818be41](https://github.com/flame-engine/flame/commit/1818be41761015b33aee820a0a02f50327a4df4e))
 - **FEAT**: Add onReleased callback for HudButtonComponent (#1296). ([87ee34ca](https://github.com/flame-engine/flame/commit/87ee34cac72b6d09b8c8f870433541361ff383c1))
 - **DOCS**: Fix various dartdoc warnings (#1353). ([9f096053](https://github.com/flame-engine/flame/commit/9f096053fd3c8ebd52d301710625a187db09704f))
 - **DOCS**: Added documentation for GameLoop class (#1234). ([b1d4e587](https://github.com/flame-engine/flame/commit/b1d4e5872e970f8bd4020a051c35b5cac4093b5e))
 - **BREAKING** **REFACTOR**: Separate ComponentSet from the Component (#1266). ([e2655b88](https://github.com/flame-engine/flame/commit/e2655b8817411ae6b1c505719fed75a170f67aeb))
 - **BREAKING** **FIX**: Remove pointerId from Draggable callbacks (#1313). ([27adda17](https://github.com/flame-engine/flame/commit/27adda17b7b4d8c229cca53799826c7b854eae95))
 - **BREAKING** **FEAT**: Added SequenceEffect (#1218). ([7c6ae6de](https://github.com/flame-engine/flame/commit/7c6ae6def36ae5feb813fb2ba15d6fb3b9aaf341))

#### `flame_test` - `v1.2.0-releasecandidate.1`

 - **REFACTOR**: Add a few more rules to flame_lint, including use_key_in_widget_constructors (#1248). ([bac6c8a4](https://github.com/flame-engine/flame/commit/bac6c8a4469f2c5c2926335f2f589eec9b1a5b5b))
 - **FIX**: remove vector_math dependency (#1361). ([56b33da2](https://github.com/flame-engine/flame/commit/56b33da29cfe547db75c89d97a09550a324fb0f5))
 - **FEAT**: Components are now always added in the correct order (#1337). ([c753fc46](https://github.com/flame-engine/flame/commit/c753fc4636d337d850a5a5cc684be8155f08b214))
 - **FEAT**: Added parameter repeatCount into function testRandom (#1265). ([49a2d0b9](https://github.com/flame-engine/flame/commit/49a2d0b9ec00fa9067756dd975e8b3ffd19de0bc))
 - **FEAT**: Added closeToVector in flame_test (#1245). ([af45ea6c](https://github.com/flame-engine/flame/commit/af45ea6cc4b5de80ecb27f07b827f55567cf602b))
 - **DOCS**: Upgrade documentation site (#1365). ([12cf8f70](https://github.com/flame-engine/flame/commit/12cf8f70963dc25b4e12182d0c7d80fe7d5a00e0))
 - **DOCS**: Fix various dartdoc warnings (#1353). ([9f096053](https://github.com/flame-engine/flame/commit/9f096053fd3c8ebd52d301710625a187db09704f))
 - **BREAKING** **FEAT**: Added SequenceEffect (#1218). ([7c6ae6de](https://github.com/flame-engine/flame/commit/7c6ae6def36ae5feb813fb2ba15d6fb3b9aaf341))

#### `flame_tiled` - `v1.3.0-releasecandidate.1`

 - **FEAT**: Added getImageLayer to flame_tiled (#1405). ([a037ada5](https://github.com/flame-engine/flame/commit/a037ada5ea18b0d1b0be68f9b3d3cceabc8c3b2b))
 - **FEAT**: modifiable Layer and TileData in RenderableTileMap (#1324). ([b56d5f3c](https://github.com/flame-engine/flame/commit/b56d5f3cd7d87a07ab0063defbf14a56c0cca1a5))
 - **FEAT**: Expose priority for TiledComponent (#1259). ([f6be66ab](https://github.com/flame-engine/flame/commit/f6be66abd5321a8c48f7200d62bd9e35a5aa71ff))
 - **DOCS**: Fix various dartdoc warnings (#1353). ([9f096053](https://github.com/flame-engine/flame/commit/9f096053fd3c8ebd52d301710625a187db09704f))
 - **DOCS**: Update flame_tiled readme (#1286). ([ee7298cb](https://github.com/flame-engine/flame/commit/ee7298cbe5cd02825cd7246f86ccb0c3655985a0))
 - **DOCS**: Update contributions to flame_tiled (#1197). ([93b763e1](https://github.com/flame-engine/flame/commit/93b763e1c000b1ebc538e393723aae2a85eb4838))
 - **BREAKING** **FIX**: fix multiple external tilesets (#1344). ([80a483f8](https://github.com/flame-engine/flame/commit/80a483f80df57ce6339f84d03d836efcbbf09579))
 - **BREAKING** **FIX**: Change Tiled batched rendering to batched rendering per layer (#1317). ([30fce398](https://github.com/flame-engine/flame/commit/30fce398dbe397d4368a0f721b20afcd663c489f))

#### `flame_bloc` - `v1.2.0-releasecandidate.1`

#### `flame_rive` - `v1.1.0-releasecandidate.1`

 - **REFACTOR**: Remove Loadable, optional onLoads (#1333). ([05f7a4c3](https://github.com/flame-engine/flame/commit/05f7a4c3d6b1e3b67575c4ec920cf270691bbab4))
 - **FEAT**: Components are now always added in the correct order (#1337). ([c753fc46](https://github.com/flame-engine/flame/commit/c753fc4636d337d850a5a5cc684be8155f08b214))
 - **FEAT**: update rive package to 0.8.1 (now support raster graphics) (#1343). ([062962de](https://github.com/flame-engine/flame/commit/062962de087cd2a8107b1ae27472095e72bdf847))
 - **DOCS**: Fix various dartdoc warnings (#1353). ([9f096053](https://github.com/flame-engine/flame/commit/9f096053fd3c8ebd52d301710625a187db09704f))


## 2022-02-01

### Changes

---

Packages with breaking changes:

- [`flame_tiled` - `v1.2.1`](#flame_tiled---v121)

Packages with other changes:

- There are no other changes in this release.

---

#### `flame_tiled` - `v1.2.1`

 - **BREAKING** **FIX**: fix multiple external tilesets (#1344).


## 2022-01-20

### Changes

---

Packages with breaking changes:

- There are no breaking changes in this release.

Packages with other changes:

- [`flame_tiled` - `v1.2.0`](#flame_tiled---v120)

---

#### `flame_tiled` - `v1.2.0`

 - **FEAT**: modifiable Layer and TileData in RenderableTileMap (#1324).
