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
 - Fix `Camera` zoom behaviour with offset/anchor

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
 - Fixes aseprite constructor bug
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
- Fixed warning on audiopool, added audiopool example in docs

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
- Fixed bug on animatons with a single frame
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
- Support asesprite animations

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
- Adding the Anchor concept: specify where thins should anchor, added to PositionComponent and to the new text releated features.
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
 - Adding audio suport for iOS (bumping audioplayers version)

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
