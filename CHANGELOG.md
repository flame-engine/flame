# Change Log

All notable changes to this project will be documented in this file.
See [Conventional Commits](https://conventionalcommits.org) for commit guidelines.

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
