## 0.1.0-dev.14

 - Update a dependency to the latest release.

## 0.1.0-dev.13

 - Update a dependency to the latest release.

## 0.1.0-dev.12

 - **FIX**: Only expose `ReadOnlyOrderedset` from `component.children` ([#3606](https://github.com/flame-engine/flame/issues/3606)). ([79351d19](https://github.com/flame-engine/flame/commit/79351d195ea968b8016129e79a489ef113a0fdf3))

## 0.1.0-dev.11

 - **FEAT**: Add flame_console to flame_3d example to enable more complex setups ([#3580](https://github.com/flame-engine/flame/issues/3580)). ([15a6f8b0](https://github.com/flame-engine/flame/commit/15a6f8b001deb714134976d7cbb5ef0a6ec31c86))
 - **DOCS**: Update flame_3d example to fix movement and camera, organize files ([#3573](https://github.com/flame-engine/flame/issues/3573)). ([54ca8433](https://github.com/flame-engine/flame/commit/54ca8433f20b451eb1a2c3c5f5a47a3430e71a6e))

## 0.1.0-dev.10

 - **FIX**: Update ordered_set, remove ComponentSet ([#3554](https://github.com/flame-engine/flame/issues/3554)). ([728e13f8](https://github.com/flame-engine/flame/commit/728e13f855d988e8f8e24976557b213b98221603))

## 0.1.0-dev.9

 - **FEAT**: Bump to new lint package ([#3545](https://github.com/flame-engine/flame/issues/3545)). ([bf6ee518](https://github.com/flame-engine/flame/commit/bf6ee51897591b7ad6e5f9da2193b1eeeaf026f4))

## 0.1.0-dev.8

 - Update a dependency to the latest release.

## 0.1.0-dev.7

 - **DOCS**: Fix workflow status badge paths ([#3517](https://github.com/flame-engine/flame/issues/3517)). ([149f16fe](https://github.com/flame-engine/flame/commit/149f16fe29f1fb14b3612964b2226c9c5c7daf95))

## 0.1.0-dev.6

 - **FEAT**: Add helper methods to create matrix4 with sensible defaults ([#3486](https://github.com/flame-engine/flame/issues/3486)). ([9345c870](https://github.com/flame-engine/flame/commit/9345c870d4de57d8d3a4d07a014d18cb71c01618))
 - **FEAT**: Add setFromMatrix4 to Transform3D ([#3484](https://github.com/flame-engine/flame/issues/3484)). ([1dbb4433](https://github.com/flame-engine/flame/commit/1dbb4433ca9e06b93a49b430fe9c084885551ff2))
 - **FEAT**: Add Line3D mesh component [flame_3d] ([#3412](https://github.com/flame-engine/flame/issues/3412)). ([c332c965](https://github.com/flame-engine/flame/commit/c332c9651ad8b930281c1d0bc13b89754fd0b2c1))

## 0.1.0-dev.5

> Note: This release has breaking changes.

 - **BREAKING** **FEAT**: Make resource creation be on demand to enable testing (#3411).

## 0.1.0-dev.4

> Note: This release has breaking changes.

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

## 0.1.0-dev.3

 - **FIX**: Improve behavior of Quaternion.slerp function [flame_3d] ([#3306](https://github.com/flame-engine/flame/issues/3306)). ([b9d6a0f1](https://github.com/flame-engine/flame/commit/b9d6a0f1d34e009cd91ae9d2ab0eed09b546d110))
 - **DOCS**: Update README.md docs to reflect current state of affairs ([#3305](https://github.com/flame-engine/flame/issues/3305)). ([be72daee](https://github.com/flame-engine/flame/commit/be72daee6b92bcef2af3af78c1f64abe94c49d18))

## 0.1.0-dev.2

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

## 0.1.0-dev.1

- Initial experimental release of `flame_3d`.
