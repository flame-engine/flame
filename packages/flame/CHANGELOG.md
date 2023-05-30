## 1.8.0

> Note: This release has breaking changes.

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


### Migration instructions

In the future (maybe as early as v1.9.0) this camera will be removed,
please use the CameraComponent instead.

This is the simplest way of using the CameraComponent:
1. Add variables for a CameraComponent and a World to your game class

   ```dart
   final world = World();
   late final CameraComponent cameraComponent;
   ```

2. In your `onLoad` method, initialize the cameraComponent and add the world
   to it.

   ```dart
   @override
   void onLoad() {
     cameraComponent = CameraComponent(world: world);
     addAll([cameraComponent, world]);
   }
   ```

3. Instead of adding the root components directly to your game with `add`,
   add them to the world.

   ```dart
   world.add(yourComponent);
   ```

4. (Optional) If you want to add a HUD component, instead of using
   PositionType, add the component as a child of the viewport.

   ```dart
   cameraComponent.viewport.add(yourHudComponent);
   ```


## 1.7.3

 - **REFACTOR**: Make atlas status to be more readable ([#2502](https://github.com/flame-engine/flame/issues/2502)). ([643793d0](https://github.com/flame-engine/flame/commit/643793d06e1c9264ce8fd557552ad8405bc65ec1))
 - **REFACTOR**: Add new lint rules ([#2477](https://github.com/flame-engine/flame/issues/2477)). ([dbda37b8](https://github.com/flame-engine/flame/commit/dbda37b81a9a7411559a6ba919ffbda6018b85c2))
 - **FIX**: Reverse invalid polygon definitions ([#2503](https://github.com/flame-engine/flame/issues/2503)). ([c4c516eb](https://github.com/flame-engine/flame/commit/c4c516ebf8fe6b8eaf82a3e49454b64faf6a7cd2))
 - **FIX**: Fill in mount implementation in `HasTappables` ([#2496](https://github.com/flame-engine/flame/issues/2496)). ([d51a612f](https://github.com/flame-engine/flame/commit/d51a612f8bed2a7a294444e5f11402394dfbc3cd))
 - **FIX**: Modify size only if changed while auto-resizing ([#2498](https://github.com/flame-engine/flame/issues/2498)). ([aa8d49da](https://github.com/flame-engine/flame/commit/aa8d49da9eb77c47d252ac3cc46d268eb10a2f20))
 - **FIX**: RecycleQueue cannot extends and implements Iterable at the same time ([#2497](https://github.com/flame-engine/flame/issues/2497)). ([3e5be3d6](https://github.com/flame-engine/flame/commit/3e5be3d6c23bfc61237befa5d17311474c6d4234))
 - **FIX**: Remove memory leak when creating the image from PictureRecorder ([#2493](https://github.com/flame-engine/flame/issues/2493)). ([a66f2bc0](https://github.com/flame-engine/flame/commit/a66f2bc0a97415f4f57b6c55174a2930cdf9e61b))
 - **FEAT**: Bump ordered_set version ([#2500](https://github.com/flame-engine/flame/issues/2500)). ([81303ea9](https://github.com/flame-engine/flame/commit/81303ea9d805c04c5d85c8e7c2f40ab8e43ae811))
 - **FEAT**: Deprecate `Component.changeParent` ([#2478](https://github.com/flame-engine/flame/issues/2478)). ([bd3e7886](https://github.com/flame-engine/flame/commit/bd3e7886125e60ad1386ec864a5ef33382f7f7f5))

## 1.7.2

 - **FIX**: A mistake in auto-resizing disabling logic ([#2471](https://github.com/flame-engine/flame/issues/2471)). ([e7ebf8e5](https://github.com/flame-engine/flame/commit/e7ebf8e55a0ad7b0f3aaae769c0b8855fb1efd96))
 - **FIX**: It should be possible to re-add `ColorEffect` ([#2469](https://github.com/flame-engine/flame/issues/2469)). ([6fa9e9d5](https://github.com/flame-engine/flame/commit/6fa9e9d5470eaf36c2db5f3b040e708615dbfcf1))
 - **FEAT**: Add `isDragged` in `DragCallbacks` mixin ([#2472](https://github.com/flame-engine/flame/issues/2472)). ([de630a1c](https://github.com/flame-engine/flame/commit/de630a1c3a779cefe49a598b46e105f19aacebfb))

## 1.7.1

 - **FIX**: Stop auto-resizing on external size change in sprite based components ([#2467](https://github.com/flame-engine/flame/issues/2467)). ([df236af4](https://github.com/flame-engine/flame/commit/df236af4f0164cc20b664ab973d91b4554b13b62))

## 1.7.0

> Note: This release has breaking changes.

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


### Migration instructions

If you have components that rely on receiving onGameResize calls before they load, then
you can retrieve the game's size in onLoad manually via findGame()!.size.

The HasDraggableComponents mixin is now empty & deprecated. If your game used this mixin overriding
its methods onDragStart, onDragUpdate, etc -- then they will no longer work. If you want to receive
drag events at the top level of the game, then simply add a DragCallbacks component to the top
level of the game.

The HasTappableComponents mixin is now empty & deprecated. If your game used this mixin overriding
its methods onTapDown, onTapUp, etc -- then they will no longer work. If you want to receive tap
events at the top level of the game, then simply add a TapCallbacks component to the top level of
the game.


## 1.6.0

> Note: This release has breaking changes.

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

## 1.5.0

> Note: This release has breaking changes.

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

## 1.4.0

> Note: This release has breaking changes.

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
   Migration instructions:
   For most methods Component has the corresponding methods directly on it already.
   For example, instead of using component.children.addAll you should do component.addAll.

 - **BREAKING** **CHORE**: Remove functions/classes that were scheduled for removal in v1.3.0 ([#1867](https://github.com/flame-engine/flame/issues/1867)). ([00ab347c](https://github.com/flame-engine/flame/commit/00ab347c57b151c9232c85150e36a8a7781511a3))
   For each deleted function/method/class, the deprecation comment already specifies what functionality should be used instead.

## 1.3.0

> Note: This release has breaking changes.

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

## 1.2.1

> Note: This release has breaking changes.

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
 - **BREAKING** **PERF**: Game.images/assets are now same as Flame.images/assets by default ([#1775](https://github.com/flame-engine/flame/issues/1775)). ([0ccb0e2e](https://github.com/flame-engine/flame/commit/0ccb0e2ef525661830c7b4662662ba64fda830fe))

## 1.2.0

> Note: This release has breaking changes.

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
 - **BREAKING** **FEAT**: Adding GameWidget.controlled ([#1650](https://github.com/flame-engine/flame/issues/1650)). ([7ef6a51e](https://github.com/flame-engine/flame/commit/7ef6a51ec60a70807a126b6121a1fd4379b8e19b))
 - **BREAKING** **FEAT**: remove `onTimingsCallback` for Flutter 3.0 ([#1626](https://github.com/flame-engine/flame/issues/1626)). ([0761a79d](https://github.com/flame-engine/flame/commit/0761a79df6c88a5a6ba74ec78d4f600983657c06))

 - **BREAKING** **FIX**: Game.mouseCursor and Game.overlays can now be safely set during onLoad ([#1498](https://github.com/flame-engine/flame/issues/1498)). ([821d01c3](https://github.com/flame-engine/flame/commit/821d01c3fab3cdd9e80d6ead8d491ea2e8ec0643))
   Migration instructions:
   The mouseCursor property is now a plain property with a setter, not a ChangeNotifier.
   Consequently, instead of writing game.mouseCursor.value = ...,
   one needs to write game.mouseCursor = ... now.

 - **BREAKING** **FEAT**: Added anchor for the Viewport ([#1611](https://github.com/flame-engine/flame/issues/1611)). ([c3bb14b7](https://github.com/flame-engine/flame/commit/c3bb14b7ca9513fc75f51b0a5cbc9d986db48dd6))
   Migration instructions:
   The coordinate system of the Viewport now always has the origin in the top-left corner
   of its bounding box (previously it was in the center) -- similar to the local coordinate
   system of a PositionComponent.

 - **BREAKING** **FEAT**: Add ability to render without loading on image related widgets ([#1674](https://github.com/flame-engine/flame/issues/1674)). ([40a061bc](https://github.com/flame-engine/flame/commit/40a061bcf06b5bf028911964617c1d1e2599460a))
   Migration instructions:
   It only breaks SpriteButton when you are using future as a sprite or pressedSprite parameter.
   You should use SpriteButton.future if previously you are using future as a parameter.

 - **BREAKING** **FEAT**: Size effects will now work only on components implementing SizeProvider ([#1571](https://github.com/flame-engine/flame/issues/1571)). ([1bfed571](https://github.com/flame-engine/flame/commit/1bfed57132330fb948962261735a0545eb37e7b9))
   Migration instructions:
   It only breaks SpriteButton when you are using future as a sprite or pressedSprite parameter.
   You should use SpriteButton.future if previously you are using future as a parameter.

## 1.1.1

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

## 1.1.0

 - Graduate package to a stable release. See pre-releases prior to this version for changelog entries.

## 1.1.0-releasecandidate.6

 - **FIX**: Only end collisions where there was a collision (#1471). ([e1e87fc4](https://github.com/flame-engine/flame/commit/e1e87fc42226c1db2f472377901031277349beb3))
 - **FIX**: `debugMode` should be inherited from parent when mounted (#1469). ([e894d201](https://github.com/flame-engine/flame/commit/e894d20133f6e142c67286c449135e37e892f35b))
 - **FEAT**: Added method that returned descendants (#1461). ([a41f5376](https://github.com/flame-engine/flame/commit/a41f53762ab49bb3d51f1f96c37b934a7ab83844))
 - **FEAT**: Possibility to mark gesture events as handled (#1465). ([4c3960c3](https://github.com/flame-engine/flame/commit/4c3960c3418f8ff4d557c1764c6793468238a8da))
 - **FEAT**: adding loaded future to the component (#1466). ([6434829b](https://github.com/flame-engine/flame/commit/6434829b45cc131719fd950ef2d262d0bfbdff1b))
 - **FEAT**: Deprecating Rect methods (#1455). ([4ddd90aa](https://github.com/flame-engine/flame/commit/4ddd90aafc40a3f5ce3d9b181a66369436de3c9c))
 - **FEAT**: Added .anchor property to CameraComponent.Viewfinder (#1458). ([d51dc5e1](https://github.com/flame-engine/flame/commit/d51dc5e132bc3ba5763be4de36131d3739a6c906))
 - **DOCS**: `Rect` extension docs is out of date (#1451). ([7e505722](https://github.com/flame-engine/flame/commit/7e505722491dd03fea6d2329ff4df2447143d45b))

## 1.1.0-releasecandidate.5

 - **FIX**: `@mustCallSuper` missing on components (#1443). ([e01b4b1a](https://github.com/flame-engine/flame/commit/e01b4b1ac3e423037fa313672b4882e7d29210b8))
 - **FEAT**: Add setter to priority (#1444). ([34284686](https://github.com/flame-engine/flame/commit/342846860af36ed73a1fc0a9a76ed9add12cec71))

## 1.1.0-releasecandidate.4

 - **FIX**: Setting images.prefix to empty string (#1437). ([694102bd](https://github.com/flame-engine/flame/commit/694102bd0304736ed3bdfbd596d64901d7adf57f))

## 1.1.0-releasecandidate.3

 - **REFACTOR**: Parent change and component removal logic (#1385). ([8b9fa352](https://github.com/flame-engine/flame/commit/8b9fa3521cc44f7696c5ce0b396e3007c2ae7e8c))
 - **FIX**: viewfinders behavior under zoom (#1432). ([f3cf85b6](https://github.com/flame-engine/flame/commit/f3cf85b638cc71058e85756498e79971a1942491))
 - **FIX**: change strokeWidth in Component (#1431). ([0e174fe8](https://github.com/flame-engine/flame/commit/0e174fe8e5f1262af41c8659c0fce7ed060e69a9))
 - **FEAT**: allowing changing of the images prefix and allowing empty prefixes (#1433). ([de4d9416](https://github.com/flame-engine/flame/commit/de4d941654710add459cc1c923b92c3923556f15))

## 1.1.0-releasecandidate.2

> Note: This release has breaking changes.

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

## 1.1.0-releasecandidate.1

> Note: This release has breaking changes.

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

# CHANGELOG

## [1.0.0]
 - Add `ButtonComponent` backed by two `PositionComponent`s
 - Add `SpriteButtonComponent` backed by two `Sprite`s
 - Allow more flexible construction of `EffectController`s and make them able to run back in time
 - Remove old effects system
 - Export new effects system
 - Introduce `updateTree` to follow the `renderTree` convention
 - Fix `Parallax.load` with different loading times
 - Fix render order of components and add tests
 - Fix `HitboxCircle` when component is flipped
 - Add `ColorEffect`
 - `MoveAlongPathEffect` can now be absolute, and can auto-orient the object along the path
 - `ScaleEffect.by` now applies multiplicatively instead of additively
 - `isHud` replaced with `PositionType`
 - Remove web fallback for `drawAtlas` in SpriteBatch, but added flag `useAtlas` to activate it

## [1.0.0-releasecandidate.18]
 - Forcing portrait and landscape mode is now supported on web
 - Fixed margin calculation in `HudMarginComponent` when using a viewport
 - Fixed position calculation in `HudMarginComponent` when using a viewport
 - Add noClip option to `FixedResolutionViewport`
 - Add a few missing helpers to SpriteAnimation

## [1.0.0-releasecandidate.17]
 - Added `StandardEffectController` class
 - Refactored `Effect` class to use `EffectController`, added `Transform2DEffect` class
 - Clarified `TimerComponent` example
 - Fixed pause and resume engines when `GameWidget` had rebuilds
 - Removed `runOnCreation` attribute in favor of the `paused` attribute on `FlameGame`
 - Add `CustomPainterComponent`
 - Alternative implementation of `RotateEffect`, based on `Transform2DEffect`
 - Alternative implementation of `MoveEffect`, based on `Transform2DEffect`
 - Fix `onGameResize` margin bug in `HudMarginComponent`
 - `PositionComponent.size` now returns a `NotifyingVector2`
 - Possibility to manually remove `TimerComponent`
 - Rename `Hitbox` mixin to `HasHitboxes`
 - Added `RemoveEffect` and `SimpleEffectController`
 - Create default implementations of `RectangleComponent`, `CircleComponent` and `PolygonComponent`
 - Streamlined the argument list for all components extending `PositionComponent`
 - Improved interaction between viewport and isHud components
 - `randomColor` method in the `Color` extension
 - Calling super-method in `.render()` is now optional
 - Components that manipulate canvas state are now responsible for saving/restoring that state
 - Remove `super.render` calls that are no longer needed
 - Fixed typo in error message
 - `TextPaint` to use `TextStyle` (material) instead of `TextPaintConfig`
 - Underlying `Shape`s in `ShapeComponent` transform with components position, size and angle
 - `HitboxShape` takes parents ancestors transformations into consideration (not scaling)
 - Fixed black frame when updating game widget (ex: adding overlays)
 - Added possibility to extend `JoystickComponent`
 - Renamed `FlameTester` to `GameTester`
 - Modified `FlameTester` to be specific for `T extends FlameGame`
 - Improved `TimerComponent`
 - Removed methods `preRender()` and `postRender()` in `Component`
 - Use `FlameTester` everywhere where it makes sense in the tests
 - Improved `IsometricTileMap`
 - Fix `PositionComponent`'s `flipHorizontallyAroundCenter` and `flipVerticallyAroundCenter`
 - Initialization of all `PositionComponent`s can be done from `onLoad` instead of the constructor
 - Rename `HasTappableComponents` to `HasTappables`
 - Rename `HasDraggableComponents` to `HasDraggables`
 - Rename `HasHoverableComponents` to `HasHoverableis`
 - Added `SizeEffect` backed by the new effects engine
 - Added `ScaleEffect` backed by the new effects engine
 - Added `OpacityEffect` backed by the new effects engine
 - Update `OrderedSet` to 4.1.0
 - Update `OrderedSet` to 5.0.0

## [1.0.0-releasecandidate.16]
 - `changePriority` no longer breaks game loop iteration
 - Move component mixin checks to their own files
 - Fix exception when game was rebuilt
 - Add `@mustCallSuper` on `Component.render`
 - Add `SpriteSheet.createAnimationVariable` method to allow animations with different `stepTime` for each sprite
 - Use the full delta in `JoystickComponent` so that it can't go to the wrong direction on the wrong side
 - Improved the menu for documentation version selection
 - Introduce `onDoubleTapDown` with info and `onDoubleTapCancel`
 - Changed `onHoverEnter` and `onHoverLeave` to return `bool` (breaking change)
 - Improved "move effect" example in the Dashbook
 - Use documentation versions generated from flame-docs-site

## [1.0.0-releasecandidate.15]
 - Fix issue with `Draggable`s not being removed from `draggables` list
 - Increase Flutter SDK constraint to `>= 2.5.0`.
 - Method `PositionComponent.toRect()` now works for flipped/rotated components.
 - Make the root bundle exposed via `Flame.bundle` actually configurable
 - Take in an optional `Camera` as a parameter to `FlameGame`
 - Make super.onLoad mandatory to avoid memory leaks
 - `QueryableOrderedSet`'s `strictMode` is configurable so it is no longer necessary to call `register` before `query`
 - Add option to rotate `SpriteWidget`
 - Fix bug where `onRemove` was called during resizing
 - Add `onAttach` and `onDetach` to `Game`

## [1.0.0-releasecandidate.14]
 - Reset effects after they are done so that they can be repeated
 - Remove integrated joystick buttons
 - Add `MarginHudComponent`, used when components need to have a margin to the viewport edge
 - Refactor `JoystickComponent`
 - Add `SpriteAnimationWidget.asset`
 - Add `SpriteWidget.asset`
 - Add `SpriteButton.asset`
 - Add `NineTileBox.asset`
 - Fix resolution of `TextBoxComponent`
 - Add `BaseGame.remove` and `BaseGame.removeAll` helpers for removing components
 - Add `BaseComponent.remove` and `BaseComponent.removeAll` helpers for removing children
 - Rename `Camera.cameraSpeed` to `Camera.speed`
 - Rename `addShape` to `addHitbox` in `Hitbox` mixin
 - Fix bug with Events and Draggables
 - Add generics to components with HasGameRef so that they can be extended and have another gameRef
 - Fix parallax fullscreen bug when game is resized
 - Generalize `paint` usage on components
 - Create `OpacityEffect`
 - Create `ColorEffect`
 - Adding ability to pause `SpriteAnimationComponent`
 - Adding `SpriteGroupComponent`
 - Fix truncated last frame in non-looping animations
 - Default size of `SpriteComponent` is `srcSize` instead of spritesheet size
 - Export test helper methods
 - Rename `ScaleEffect` to `SizeEffect`
 - Introduce `scale` on `PositionComponent`
 - Add `ScaleEffect` that works on `scale` instead of `size`
 - Add class `NotifyingVector2`
 - Add class `Transform2D`
 - Added helper functions `testRandom()` and `testWidgetsRandom()`
 - Remove `FPSCounter` from `BaseGame`
 - Refactor `PositionComponent` to work with `Transform2D`: the component now works more reliably
   when nested
 - Properties `renderFlipX`, `renderFlipY` removed and replaced with methods
   `flipHorizontally()` and `flipVertically()`.
 - Method `.angleTo` removed as it was not working properly.
 - In debug mode `PositionComponent` now displays an indicator for the anchor position.
 - Update `Camera` docs to showcase usage with `Game` class
 - Fixed a bug with `worldBounds` being set to `null` in `Camera`
 - Remove `.viewport` from `BaseGame`, use `camera.viewport` instead
 - `MockCanvas` is now strongly typed and matches numeric coordinates up to a tolerance
 - Add `loadAllImages` to `Images`, which loads all images from the prefixed path
 - Reviewed the keyboard API with new mixins (`KeyboardHandler` and `HasKeyboardHandlerComponents`)
 - Added `FocusNode` on the game widget and improved keyboard handling in the game.
 - Added ability to have custom mouse cursor on the `GameWidget` region
 - Change sprite component to default to the Sprite size if not provided
 - `TextBoxComponent` waits for cache to be filled on `onLoad`
 - `TextBoxComponent` can have customizable `pixelRatio`
 - Add `ContainsAtLeastMockCanvas` to facilitate testing with `MockCanvas`
 - Support for `drawImage` for `MockCanvas`
 - `Game` is now a `Component`
 - `ComponentEffect` is now a `Component`
 - `HasGameRef` can now operate independently from `Game`
 - `initialDelay` and `peakDelay` for effects to handle time before and after an effect
 - `component.onMount` now runs every time a component gets a new parent
 - Add collision detection between child components

## [1.0.0-releasecandidate.13]
 - Fix camera not ending up in the correct position on long jumps
 - Make the `JoystickPlayer` a `PositionComponent`
 - Extract shared logic when handling components set in BaseComponent and BaseGame to ComponentSet.
 - Rename `camera.shake(amount: x)` to `camera.shake(duration: x)`
 - Fix `SpriteAnimationComponent` docs to use `Future.wait`
 - Add an empty `postRender` method that will run after each components render method
 - Rename `Tapable` to `Tappable`
 - Fix `SpriteAnimationComponent` docs to use `Future.wait`
 - Add an empty `postRender` method that will run after each components render method
 - Rename `HasTapableComponents` to `HasTappableComponents`
 - Rename `prepareCanvas` to `preRender`
 - Add `intensity` to `Camera.shake`
 - `FixedResolutionViewport` to use matrix transformations for `Canvas`

## [1.0.0-releasecandidate.12]
 - Fix link to code in example stories
 - Fix RotateEffect with negative deltas
 - Add isDragged to Draggable
 - Fix anchor of rendered text in TextComponent
 - Add new extensions to handle math.Rectangles nicely
 - Implement color parsing methods
 - Migrated the `Particle` API to `Vector2`
 - Add copyWith function to TextRenderer
 - Fix debug mode is not propagated to children of non-Position components
 - Fix size property of TextComponent was not correctly set
 - Fix anchor property was being incorrectly passed along to text renderer
 - All components take priority as an argument on their constructors
 - Fix renderRotated
 - Use QueryableOrderedSet for Collidables
 - Refactor TextBoxComponent
 - Fix bugs with TextBoxComponent
 - Improve error message for composed components
 - Fix `game.size` to take zoom into consideration
 - Fix `camera.followComponent` when `zoom != 1`
 - Add `anchor` for `ShapeComponent` constructor
 - Fix rendering of polygons in `ShapeComponent`
 - Add `SpriteAnimation` support to parallax
 - Fix `Parallax` alignment for images with different width and height
 - Fix `ImageComposition` image bounds validation
 - Improved the internal `RenderObject` widget performance
 - Add `Matrix4` extensions
 - `Camera.apply` is done with matrix transformations
 - `Camera` zooming is taking current `relativeOffset` into account
 - Fix gestures for when `isHud = true` and `Camera` is modified
 - Fix `Camera` zoom behavior with offset/anchor

## [1.0.0-releasecandidate.11]
 - Replace deprecated analysis option lines-of-executable-code with source-lines-of-code
 - Fix the anchor of SpriteWidget
 - Add test for re-adding previously removed component
 - Add possibility to dynamically change priority of components
 - Add onCollisionEnd to make it possible for the user to easily detect when a collision ends
 - Adding test coverage to packages
 - Possibility to have non-fullscreen ParallaxComponent
 - No need to send size in ParallaxComponent.fromParallax since Parallax already contains it
 - Fix Text Rendering not working properly
 - Add more useful methods to the IsometricTileMap component
 - Add Hoverables
 - Brief semantic update to second tutorial.

## [1.0.0-rc10]
 - Updated tutorial documentation to indicate use of new version
 - Fix bounding box check in collision detection
 - Refactor on flame input system to correctly take camera into account
 - Adding `SpriteAnimationGroupComponent`
 - Allow isometric tile maps with custom heights
 - Add a new renderRect method to Sprite
 - Addresses the TODO to change the camera public APIs to take Anchors for relativePositions
 - Adds methods to support moving the camera relative to its current position
 - Abstracting the text api to allow custom text renderers on the framework
 - Set the same debug mode for children as for the parent when added
 - Fix camera projections when camera is zoomed
 - Fix collision detection system with angle and parentAngle
 - Fix rendering of shapes that aren't HitboxShape

## [1.0.0-rc9]
 - Fix input bug with other anchors than center
 - Fixed `Shape` so that the `position` is now a `late`
 - Updated the documentation for the supported platforms
 - Add clear function to BaseGame to allow the removal of all components
 - Moving tutorials to the Flame main repository
 - Transforming `PaletteEntry.paint` to be a method instead of a getter
 - Adding some more basic colors entries to the `BasicPalette`
 - Fixing Flutter and Dart version constraints
 - Exporting Images and AssetsCache
 - Make `size` and `position` in `PositionComponent` final
 - Add a `snapTo` and `onPositionUpdate` method to the `Camera`
 - Remove the SpriteAnimationComponent when the animation is really done, not when it is on the last frame
 - Revamp all the docs to be up to date with v1.0.0
 - Make Assets and Images caches have a configurable prefix
 - Add `followVector2` method to the `Camera`
 - Make `gameRef` late
 - Fix Scroll example
 - Add a `renderPoint` method to `Canvas`
 - Add zoom to the camera
 - Add `moveToTarget` as an extension method to `Vector2`
 - Bring back collision detection examples
 - Fix collision detection in Collidable with multiple offset shapes
 - Publishing Flame examples on github pages

## 1.0.0-rc8
 - Migrate to null safety
 - Refactor the joystick code
 - Fix example app
 - Rename points to intersectionPoints for collision detection
 - Added CollidableType to make collision detection more efficient
 - Rename CollidableType.static to passive
 - Add srcPosition and srcSize for SpriteComponent
 - Improve collision detection with bounding boxes

## 1.0.0-rc7
 - Moving device related methods (like `fullScreen`) from `util.dart` to `device.dart`
 - Moving render functions from `util.dart` to `extensions/canvas.dart`
 - Adapting ParallaxComponent contructors to match the pattern followed on other components
 - Adapting SpriteBatchComponent constructors to match the pattern used on other components
 - Improving Parallax APIs regarding handling its size and the use outside FCS
 - Enabling direct import of Sprite and SpriteAnimation
 - Renamed `Composition` to `ImageComposition` to prevent confusion with the composition component
 - Added `rotation` and `anchor` arguments to `ImageComposition.add`
 - Added `Image` extensions
 - Added `Color` extensions
 - Change RaisedButton to ElevatedButton in timer example
 - Overhaul the draggables api to fix issues relating to local vs global positions
 - Preventing errors caused by the premature use of size property on game
 - Added a hitbox mixin for PositionComponent to make more accurate gestures
 - Added a collision detection system
 - Added geometrical shapes
 - Fix `SpriteAnimationComponent.shouldRemove` use `Component.shouldRemove`
 - Add assertion to make sure Draggables are safe to add
 - Add utility methods to the Anchor class to make it more "enum like"
 - Enable user-defined anchors
 - Added `toImage` method for the `Sprite` class
 - Uniform use of `dt` instead of `t` in all update methods
 - Add more optional arguments for unified constructors of components
 - Fix order that parent -> children render in

## 1.0.0-rc6
 - Use `Offset` type directly in `JoystickAction.update` calculations
 - Changed `parseAnchor` in `examples/widgets` to throw an exception instead of returning null when it cannot parse an anchor name
 - Code improvements and preparing APIs to null-safety
 - BaseComponent removes children marked as shouldRemove during update
 - Use `find` instead of `globstar` pattern in `scripts/lint.sh` as the later isn't enabled by default in bash
 - Fixes Aseprite constructor bug
 - Improve error handling for the onLoad function
 - Add test for child removal
 - Fix bug where `Timer` callback doesn't fire for non-repeating timers, also fixing bug with `Particle` lifespan
 - Adding shortcut for loading Sprites and SpriteAnimation from the global cache
 - Adding loading methods for the different `ParallaxComponent` parts and refactor how the delta velocity works
 - Add tests for `Timer` and fix a bug where `progress` was not reported correctly
 - Refactored the `SpriteBatch` class to be more elegant and to support `Vector2`.
 - Added fallback support for the web on the `SpriteBatch` class
 - Added missing documentation on the `SpriteBatch` class
 - Added an utility method to load a `SpriteBatch` on the `Game` class
 - Updated the `widgets.md` documentation
 - Removing methods `initialDimensions` and `removeGestureRecognizer` to avoid confusion
 - Adding standard for `SpriteComponent` and `SpriteAnimationComponent` constructors
 - Added `Composition`, allows for composing multiple images into a single image.
 - Move files to comply with the dart package layout convention
 - Fix gesture detection bug of children of `PositionComponent`
 - The `game` argument on `GameWidget` is now required

## 1.0.0-rc5
 - Option for overlays to be already visible on the GameWidget
 - Adding game to the overlay builder
 - Rename retreive -> Retrieve
 - Use internal children set in BaseComponent (fixes issue adding multiple children)
 - Remove develop branches from github workflow definition
 - BaseComponent to return UnmodifiableListView for children

## 1.0.0-rc4
 - Rename Dragable -> Draggable
 - Set loop member variable when constructing SpriteAnimationComponent from SpriteAnimationData
 - Effect shouldn't affect unrelated properties on component
 - Fix rendering of children
 - Explicitly define what fields an effect on PositionComponent modifies
 - Properly propagate onMount and onRemove to children
 - Adding Canvas extensions
 - Remove Resizable mixin
 - Use config defaults for TextBoxComponent
 - Fixing Game Render Box for flutter >= 1.25
 - DebugMode to be variable instead of function on BaseGame

## 1.0.0-rc3
 - Fix TextBoxComponent rendering
 - Add TextBoxConfig options; margins and growingBox
 - Fix debugConfig strokeWidth for web
 - Update Forge2D docs
 - Update PR template with removal of develop branch
 - Translate README to Russian
 - Split up Component and PositionComponent to BaseComponent
 - Unify multiple render methods on Sprite
 - Refactored how games are inserted into a flutter tree
 - Refactored the widgets overlay API
 - Creating new way of loading animations and sprites
 - Dragable mixin for components
 - Fix update+render of component children
 - Update documentation for SVG component
 - Update documentation for PositionComponent
 - Adding Component#onLoad
 - Moving size to Game instead of BaseGame
 - Fix bug with ConcurrentModificationError on add in onMount

## 1.0.0-rc2
 - Improve IsometricTileMap and Spritesheet classes
 - Export full vector_math library from extension
 - Added warning about basic and advanced detectors
 - Ensuring sprite animation and sprite animation components don't get NPEs on initialization
 - Refactor timer class
 - include all changed that are included on 0.28.0
 - Rename game#resize to game#onResize
 - Test suite for basic effects
 - Effects duration and test suite for basic effects
 - Pause and resume for effects
 - Fix position bug in parallax effect
 - Simplification of BaseGame. Removal of addLater (add is now addLater) and rename markForRemoval.
 - Unify naming for removal of components from BaseGame

## 1.0.0-rc1
 - Move all box2d related code and examples to the flame_box2d repo
 - Rename Animation to SpriteAnimation
 - Create extension of Vector2 and unify all tuples to use that class
 - Remove Position class in favor of new Vector2 extension
 - Remove Box2D as a dependency
 - Rebuild of Images, Sprite and SpriteAnimation initialization
 - Use isRelative on effects
 - Use Vector2 for position and size on PositionComponent
 - Removing all deprecated methods
 - Rename `resize` method on components to `onGameResize`
 - Make `Resizable` have a `gameSize` property instead of `size`
 - Fix bug with CombinedEffect inside SequenceEffect
 - Fix wrong end angle for relative rotational effects
 - Use a list of Vector2 for Move effect to open up for more advanced move effects
 - Generalize effects api to include all components
 - Extract all the audio related capabilities to a new package, flame_audio
 - Fix bug that sprite crashes without a position

## 0.29.1-beta
 - Fixing Game Render Box for flutter >= 1.25

## 0.29.0
- Update audioplayers to latest version (now `assets` will not be added to prefixes automatically)
- Fix lint issues with 0.28.0

## 0.28.0
- Fix spriteAsWidget deprecation message
- Add `lineHeight` property to `TextConfig`
- Adding pause and resume methods to time class

## 0.27.0
 - Improved the accuracy of the `FPSCounter` by using Flutter's internal frame timings.
 - Adding MouseMovementDetector
 - Adding ScrollDetector
 - Fixes BGM error
 - Adding Isometric Tile Maps

## 0.26.0
 - Improving Flame image auto cache
 - Fix bug in the Box2DGame's add and addLater method , when the Component extends BodyComponent and mixin HasGameRef or other mixins ,the mixins will not be set correctly

## 0.25.0
 - Externalizing Tiled support to its own package `flame_tiled`
 - Preventing some crashs that could happen on web when some methods were called
 - Add mustCallSuper to BaseGame `update` and `render` methods
 - Moved FPS code from BaseGame to a mixin, BaseGame uses the new mixin.
 - Deprecate flare API in favor of the package `flame_flare`

## 0.24.0
 - Outsourcing SVG support to an external package
 - Adding MemoryCache class
 - Fixing games crashes on Web
 - Update tiled dependency to 0.6.0 (objects' properties are now double)

## 0.23.0
 - Add Joystick Component
 - Adding BaseGame#markToRemove
 - Upgrade tiled and flutter_svg dependencies
 - onComplete callback for effects
 - Adding Layers
 - Update tiled dep to 0.5.0 and add support for rotation with improved api

## 0.22.1
 - Fix Box2DComponent render priority
 - Fix PositionComponentEffect drifting
 - Add possibility to combine effects
 - Update to newest box2d_flame which fixes torque bug
 - Adding SpriteSheet.fromImage

## 0.22.0
 - Fixing BaseGame tap detectors issues
 - Adding SpriteWidget
 - Adding AnimationWidget
 - Upgrade Flutter SVG to fix for flame web
 - Add linting to all the examples
 - Run linting only on affected and changed examples
 - Add SequenceEffect
 - Fixed bug with travelTime in RotateEffect

## 0.21.0
- Adding AssetsCache.readBinaryFile
- Splitting debugMode from recordFps mode
- Adding support for multi touch tap and drag events
- Fix animations example
- Add possibility for infinite and alternating effects
- Add rotational effect for PositionComponents

## 0.20.2
- Fix text component bug with anchor being applied twice

## 0.20.1
- Adding method to load image bases on base64 data url.
- Fix Box2DGame to follow render priority
- Fix games trying to use gameRef inside the resize function

## 0.20.0
- Refactor game.dart classes into separate files
- Adding a GameLoop class which uses a Ticker for updating game
- Adding sprites example
- Made BaseGame non-abstract and removed SimpleGame
- Adding SpriteButton Widget
- Added SpriteBatch API, which renders sprites effectively using Canvas.drawAtlas
- Introducing basic effects API, including MoveEffect and ScaleEffect
- Adding ContactCallback controls in Box2DGame

## 0.19.1
 - Bump AudioPlayers version to allow for web support
 - Adding Game#pauseEngine and Game#resumeEngine methods
 - Removing FlameBinding since it isn't used and clashes with newest flutter

## 0.19.0
 - Fixing component lifecycle calls on BaseGame#addLater
 - Fixing Component#onDestroy, which was been called multiple times sometimes
 - Fixing Widget Overlay usage over many game instances

## 0.18.3
- Adding Component#onDestroy
- Adding Keyboard events API
- Adding Box2DGame, an extension of BaseGame to simplify lifecycle of Box2D components
- Add onAnimateComplete for Animation (thanks @diegomgarcia)
- Adding AnimationComponent#overridePaint
- Adding SpriteComponent#overridePaint
- Updating AudioPlayers to enable Web Audio support

## 0.18.2
- Add loop for AnimationComponent.sequenced() (thanks @wenxiangjiang)
- TextComponent optimization (thanks @Gericop)
- Adding Component#onMount
- Check if chidren are loaded before rendering on ComposedComponent (thanks @wenxiangjiang)
- Amend type for width and height properties on Animation.sequenced (thanks @wenxiangjiang)
- Fixing Tapable position checking
- Support line feed when create animation from a single image source (thanks @wenxiangjiang)
- Fixing TextBoxComponent start/end of line bugs (thanks @kurtome)
- Prevent widgets overlay controller from closing when in debug mode


## 0.18.1
- Expose stepTime paramter from the Animation class to the animation component
- Updated versions for bugfixes + improved macOS support. (thanks @flowhorn)
- Update flutter_svg to 0.17.1 (thanks @flowhorn)
- Update audioplayers to 0.14.0 (thanks @flowhorn)
- Update path_provider to 1.6.0 (thanks @flowhorn)
- Update ordered_set to 1.1.5 (thanks @flowhorn)

## 0.18.0
- Improving FlareComponent API and updating FlareFlutter dependency
- Adding HasWidgetsOverlay mixin
- Adding NineTileBox widget

## 0.17.4
- Fixing compilations errors regarding changes on `box2_flame`
- Add splash screen docs

## 0.17.3
- Tweaking text box rendering to reduce pixelated text (thanks, @kurtome)
- Adding NineTileBox component

## 0.17.2
- Added backgroundColor method for overriding the game background (thanks @wolfenrain)
- Update AudioPlayers version to 0.13.5
- Bump SVG dependency plus fix example app

## 0.17.1
- Added default render function for Box2D ChainShape
- Adding TimerComponent
- Added particles subsystem (thanks @av)

## 0.17.0
- Fixing FlareAnimation API to match convention
- Fixing FlareComponent renderization
- New GestureDetector API to Game

## 0.16.1
- Added `Bgm` class for easy looping background music management.
- Added options for flip rendering of PositionComponents easily (horizontal and vertical).

## 0.16.0
- Improve our mixin structure (breaking change)
- Adds HasGameRef mixin
- Fixes for ComposedComponent (for tapables and other apis using preAdd)
- Added no-parameter alias functions for setting the game's orientation.
- Prevent double completion on onMetricsChanged callback

## 0.15.2
- Exposing tile objects on TiledComponent (thanks @renatoferreira656)
- Adding integrated API for taps on Game class and adding Tapeables mixin for PositionComponents

## 0.15.1
- Bumped version of svg dependency
- Fixed warnings

## 0.15.0
- Refactoring ParallaxComponent (thanks @spydon)
- Fixing flare animation with embed images
- Adding override paint parameter to Sprite, and refactoring it have named optional parameters

## 0.14.2
- Refactoring BaseGame debugMode
- Adding SpriteSheet class
- Adding Flame.util.spriteAsWidget
- Fixing AnimationComponent.empty()
- Fixing FlameAudio.loopLongAudio

## 0.14.1
- Fixed build on travis
- Updated readme badges
- Fixed changelog
- Fixed warning on AudioPool, added AudioPool example in docs

## 0.14.0
- Adding Timer#isRunning method
- Adding Timer#progress getter
- Updating Flame to work with Flutter >= 1.6.0

## 0.13.1
- Adding Timer utility class
- Adding `destroyOnFinish` flag for AnimationComponent
- Fixing release mode on examples that needed screen size
- Bumping dependencies versions (audioplayers and path_provider)

## 0.13.0
- Downgrading flame support to stable channel.

## 0.12.2
- Added more functionality to the Position class (thanks, @illiapoplawski)

## 0.12.1
- Fixed PositionComponent#setByRect to comply with toRect (thanks, @illiapoplawski)

## 0.12.0
- Updating flutter_svg and pubspec to support the latest flutter version (1.6.0)
- Adding Flare Support
- Fixing PositionComponent#toRect which was not considering the anchor property (thanks, @illiapoplawski)

## [0.11.2]
- Fixed bug on animations with a single frame
- Fixed warning on using specific version o flutter_svg on pubspec
- ParallaxComponent is not abstract anymore, as it does not include any abstract method
- Added some functionality to Position class

## [0.11.1]
- Fixed lack of paint update when using AnimationAsWidget as pointed in #78
- Added travis (thanks, @renancarujo)

## [0.11.0]
- Implementing low latency api from audioplayers (breaking change)
- Improved examples by adding some instructions on how to run
- Add notice on readme about the channel
- Upgrade path_provider to fix conflicts

## [0.10.4]
- Fix breaking change on svg plugin

## [0.10.3]
- Svg support
- Adding `Animation#reversed` allowing a new reversed animation to be created from an existing animation.
- Fix games inside regular apps when the component is inside a sliver
- Support Aseprite animations

## [0.10.2]
- Fixed some warnings and formatting

## [0.10.1]
- Fixes some typos
- Improved docs
- Extracted gamepads to a new lib, lots of improvements there (thanks, @erickzanardo)
- Added more examples and an article

## [0.10.0]
- Fixing a few minor bugs, typos, improving docs
- Adding the Palette concept: easy access to white and black colors/paints, create your palette to keep your game organized.
- Adding the Anchor concept: specify where thins should anchor, added to PositionComponent and to the new text related features.
- Added a whole bunch of text related components: TextConfig allows you to easily define your typography information, TextComponent allows for easy rendering of stuff and TextBox can make sized texts and also typing effects.
- Improved Utils to have better and more concise APIs, removed unused stuff.
- Adding TiledComponent to integrate with tiled

## [0.9.5]
- Add `elapsed` property to Animation (thanks, @ianliu)
- Fixed minor typo on documentation

## [0.9.4]
- Bumps audioplayers version

## [0.9.3]
- Fixes issue when switching between games where new game would not attach

## [0.9.2]
- Fixes to work with Dart 2.1

## [0.9.1]
- Updated audioplayers and box2d to fix bugs

## [0.9.0]
- Several API changes, using new audioplayers 0.6.x

## [0.8.4]
- Added more consistent APIs and tests

## [0.8.3]
- Need to review audioplayers 0.5.x

## [0.8.2]
- Added better documentation, tutorials and examples
- Minor tweaks in the API
- New audioplayers version

## [0.8.1]
- The Components Overhaul Update: This is major update, even though we are keeping things in alpha (version 0.*)
- Several major upgrades regarding the component system, new component types, Sprites and SpriteSheets, better image caching, several improvements with structure, a BaseGame, a new Game as a widget, that allows you to embed inside apps and a stop method. More minor changes.

## [0.6.1]
 - Bump required dart version

## [0.6.0]
 - Adding audio support for iOS (bumping audioplayers version)

## [0.5.0]
 - Adding a text method to Util to more easily render a Paragraph

## [0.4.0]
 - Upgraded AudioPlayers, added method to disable logging
 - Created PositionComponent with some useful methods
 - A few refactorings

## [0.3.0]
 - Added a pre-load method for Audio module

## [0.2.0]
 - Added a loop method for playing audio on loop
 - Added the option to make rectangular SpriteComponents, not just squares

## [0.1.0]
 - First release, basic utilities
