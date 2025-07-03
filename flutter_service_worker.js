'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"canvaskit/skwasm.wasm": "39dd80367a4e71582d234948adc521c0",
"canvaskit/chromium/canvaskit.wasm": "f504de372e31c8031018a9ec0a9ef5f0",
"canvaskit/chromium/canvaskit.js": "8191e843020c832c9cf8852a4b909d4c",
"canvaskit/chromium/canvaskit.js.symbols": "b61b5f4673c9698029fa0a746a9ad581",
"canvaskit/canvaskit.wasm": "7a3f4ae7d65fc1de6a6e7ddd3224bc93",
"canvaskit/canvaskit.js": "728b2d477d9b8c14593d4f9b82b484f3",
"canvaskit/skwasm.js": "ea559890a088fe28b4ddf70e17e60052",
"canvaskit/skwasm.js.symbols": "e72c79950c8a8483d826a7f0560573a1",
"canvaskit/canvaskit.js.symbols": "bdcd3835edf8586b6d6edfce8749fb77",
"manifest.json": "88a09d3520ee1c1fd7ad820a705bfc83",
"main.dart.js": "a9a136645dc51b85c99b261a4905c06d",
"flutter.js": "83d881c1dbb6d6bcd6b42e274605b69c",
"index.html": "b2477219784904731afab563fd371ff2",
"/": "b2477219784904731afab563fd371ff2",
"assets/packages/tutorials_space_shooter/assets/images/stars.png": "5e766afbd74a090f1768f15be8c6bc6e",
"assets/packages/tutorials_space_shooter/assets/images/stars_2.png": "e102b859da519cb4546956dde49625ed",
"assets/packages/tutorials_space_shooter/assets/images/player-sprite.png": "8acd2b8d25ac4bbcaf8c9cdc8492fd1e",
"assets/packages/tutorials_space_shooter/assets/images/explosion.png": "399d7b06e79778a152fe05204ac77585",
"assets/packages/tutorials_space_shooter/assets/images/stars_0.png": "41b0c56bf48e1ffd6b726d2e0bde1b2d",
"assets/packages/tutorials_space_shooter/assets/images/enemy.png": "67c6e50b589a02489ac42d18ad0468ee",
"assets/packages/tutorials_space_shooter/assets/images/bullet.png": "6d57d87204c173af8572806d93ae3ec6",
"assets/packages/tutorials_space_shooter/assets/images/stars_1.png": "afba542fdca04292a991faf1b2a8bbd1",
"assets/packages/tutorials_space_shooter/assets/images/player.png": "7e103ea127c72b067bb069cae7a27903",
"assets/packages/devtools_app_shared/fonts/Roboto/Roboto-Bold.ttf": "ee7b96fa85d8fdb8c126409326ac2d2b",
"assets/packages/devtools_app_shared/fonts/Roboto/Roboto-Thin.ttf": "89e2666c24d37055bcb60e9d2d9f7e35",
"assets/packages/devtools_app_shared/fonts/Roboto/Roboto-Light.ttf": "fc84e998bc29b297ea20321e4c90b6ed",
"assets/packages/devtools_app_shared/fonts/Roboto/Roboto-Medium.ttf": "d08840599e05db7345652d3d417574a9",
"assets/packages/devtools_app_shared/fonts/Roboto/Roboto-Regular.ttf": "3e1af3ef546b9e6ecef9f3ba197bf7d2",
"assets/packages/devtools_app_shared/fonts/Roboto/Roboto-Black.ttf": "ec4c9962ba54eb91787aa93d361c10a8",
"assets/packages/devtools_app_shared/fonts/Roboto_Mono/RobotoMono-Medium.ttf": "7cfbd4284ec01b7ace2f8edb5cddae84",
"assets/packages/devtools_app_shared/fonts/Roboto_Mono/RobotoMono-Light.ttf": "9d1044ccdbba0efa9a2bfc719a446702",
"assets/packages/devtools_app_shared/fonts/Roboto_Mono/RobotoMono-Regular.ttf": "b4618f1f7f4cee0ac09873fcc5a966f9",
"assets/packages/devtools_app_shared/fonts/Roboto_Mono/RobotoMono-Bold.ttf": "7c13b04382bb3c4a6a50211300a1b072",
"assets/packages/devtools_app_shared/fonts/Roboto_Mono/RobotoMono-Thin.ttf": "288302ea531af8be59f6ac2b5bbbfdd3",
"assets/packages/spine_flutter/src/spine-cpp-lite/spine-cpp-lite.cpp": "852f851775c61a8dfb34a4460ef7d0f0",
"assets/packages/spine_flutter/src/spine-cpp-lite/spine-cpp-lite.h": "0f25a1e1148b878172e430b582dd4f50",
"assets/packages/spine_flutter/lib/assets/libspine_flutter.js": "76118d0ae9421e1b33e6a0da97700289",
"assets/packages/spine_flutter/lib/assets/libspine_flutter.wasm": "8d2df357686c13a68fc4269e06ce8049",
"assets/packages/flutter_shaders/shaders/pixelation.frag": "75e19674d21828cc7a5a358d8378d6d7",
"assets/packages/crystal_ball/shaders/firefly.frag": "2d8f52214967b989f5cb13592860c97e",
"assets/packages/crystal_ball/shaders/fog.frag": "fde72d76221ad23e5a7017cf3d5616b4",
"assets/packages/crystal_ball/shaders/ground.frag": "fa78be2a0e4de2c0509dbd05f99852e2",
"assets/packages/crystal_ball/shaders/the_ball.frag": "05af0d9bc0ee28a49e05e3c36fc0272a",
"assets/packages/flame_audio_example/assets/audio/music/bg_music.ogg": "e0ee19692c51bd7e07713a82d570c099",
"assets/packages/flame_audio_example/assets/audio/sfx/fire_1.mp3": "458f08df07b70378a4dc37ca64af311f",
"assets/packages/flame_audio_example/assets/audio/sfx/fire_2.mp3": "f8d02b968e3f3eaa373d7cc44a4c0102",
"assets/packages/flame_bloc_example/assets/images/stars.png": "839baa9b3605e008cb4008d3be7f048a",
"assets/packages/flame_bloc_example/assets/images/laser.png": "563ebc4413d8a94a680edfe87ccd2296",
"assets/packages/flame_bloc_example/assets/images/explosion.png": "81a3691935a18a30572870b759ad1683",
"assets/packages/flame_bloc_example/assets/images/enemy.png": "8dfb2f04967b1156a257c05f282ff8c6",
"assets/packages/flame_bloc_example/assets/images/bullet.png": "8eca41372586b4d2446c22bee1fe77f2",
"assets/packages/flame_bloc_example/assets/images/plasma.png": "82dd7288ba22ee9dd422d8adbce1e854",
"assets/packages/flame_bloc_example/assets/images/player.png": "b2feeca37713e6e35e8915d1e2028ac3",
"assets/packages/flame_fire_atlas_example/assets/cave_ace.fa": "d3b67a07a9c5165e720d908ef29b99d4",
"assets/packages/flame_svg_example/assets/android.svg": "4b3cdf571cca5f66cbabf9241d90acbe",
"assets/packages/ember_quest/assets/images/ember.png": "4dfe185b14556722bec4d4aefeb000b0",
"assets/packages/ember_quest/assets/images/block.png": "2d39dcc65f7bab4c6ad7aaa94860a32b",
"assets/packages/ember_quest/assets/images/star.png": "35b1abf4b0b34cce83027006f5fd9fea",
"assets/packages/ember_quest/assets/images/ground.png": "55ff488305e5543b99265bf46b3d3094",
"assets/packages/ember_quest/assets/images/water_enemy.png": "6702a02c0d411c023491e68a3a00ac0d",
"assets/packages/ember_quest/assets/images/heart_half.png": "946fe784a7d50a0f52b28378d4ea8f84",
"assets/packages/ember_quest/assets/images/heart.png": "1ec544e61939a21e6fdc9038d356cdf4",
"assets/packages/flame_3d/assets/shaders/spatial_material.shaderbundle": "a51da39687b934c33ae0d2be5bf2d28a",
"assets/packages/rogue_shooter/assets/images/rogue_shooter/stars.png": "5e766afbd74a090f1768f15be8c6bc6e",
"assets/packages/rogue_shooter/assets/images/rogue_shooter/explosion.png": "399d7b06e79778a152fe05204ac77585",
"assets/packages/rogue_shooter/assets/images/rogue_shooter/enemy.png": "67c6e50b589a02489ac42d18ad0468ee",
"assets/packages/rogue_shooter/assets/images/rogue_shooter/bullet.png": "6d57d87204c173af8572806d93ae3ec6",
"assets/packages/rogue_shooter/assets/images/rogue_shooter/player.png": "6455b7f3b2a1140a6562ffcaa157454d",
"assets/packages/flame_texturepacker_example/assets/images/sprite_sheet3.png": "8c3a5992bd525b26fabd2eba924884e0",
"assets/packages/flame_texturepacker_example/assets/images/atlas_map.atlas": "c5425574114b6466037d306e696cba68",
"assets/packages/flame_texturepacker_example/assets/images/sprite_sheet2.png": "d4e872771d79f22337b6fde16de59ad0",
"assets/packages/flame_texturepacker_example/assets/images/sprite_sheet1.png": "3394ef1408d32eec3b7162942722ecbb",
"assets/packages/flame_sprite_fusion_example/assets/tiles/map.json": "413f25ab0f469861f8388dcf9a961dda",
"assets/packages/flame_sprite_fusion_example/assets/images/spritesheet.png": "000a30aa1fdb8621b8d292930341925e",
"assets/packages/klondike/assets/images/klondike-sprites.png": "e845f90161e975ed1ed4485178676b40",
"assets/packages/flame_rive_example/assets/skills.riv": "ef57c58346dcd084eebbc777ccbd0c53",
"assets/packages/flame_markdown_example/assets/fire_and_ice.md": "8c925e3edba213b89d72947abbc64493",
"assets/packages/example/assets/images/crate.jpg": "f862e95d137614c0389d4956d6a73297",
"assets/packages/flame_oxygen_example/assets/images/pizza.png": "e9b30fb29ca158301577d7928efb1a56",
"assets/packages/flame_oxygen_example/assets/images/chopper.png": "530485b0033f6debb146c0f2714126bb",
"assets/packages/flame_kenney_xml_example/assets/license.txt": "96a0d0a9da31ecf12b90c454398af406",
"assets/packages/flame_kenney_xml_example/assets/spritesheet_stone.xml": "37e1a4a191423b41f13ea2258046093f",
"assets/packages/flame_kenney_xml_example/assets/images/spritesheet_stone.png": "e060e6157a689a43d0b4fae82fc30325",
"assets/packages/flame_tiled_example/assets/tiles/map.tmx": "15379e90c79d53dfbed94479193c0bfc",
"assets/packages/flame_tiled_example/assets/images/level_standard_tileset.png": "e8f3448a86101141292356a460b88b9a",
"assets/packages/flame_tiled_example/assets/images/level_ice_tileset.png": "62ac9564d39f707a9b454761d666f354",
"assets/packages/flame_tiled_example/assets/images/repeatable_background.png": "9df0d1e4d448be9922a9859cfbefb543",
"assets/packages/flame_tiled_example/assets/images/coins.png": "d11a64e775683054fd566e4cf1465d1b",
"assets/packages/flame_test_example/assets/images/city.png": "a33b2eff67445ebb0512b8b5e3b1d4b4",
"assets/packages/flame_spine_example/assets/spineboy-pro.skel": "01f6b4f75adefe54e706cd06996346dd",
"assets/packages/flame_spine_example/assets/spineboy.atlas": "0252ad0c8f0c40dff09f6854a95fda09",
"assets/packages/flame_spine_example/assets/LICENSE": "2896607b2195b46995804daba87636e6",
"assets/packages/flame_isolate_example/assets/images/cheese.png": "18617e49e02d92ac42cd2374041987fb",
"assets/packages/flame_isolate_example/assets/images/ant_walk.png": "186b70f7145c327a3873dc946974d061",
"assets/packages/flame_isolate_example/assets/images/bread.png": "0a29f4ba85e8c6378563d1ba89091666",
"assets/packages/trex_game/assets/images/trex.png": "b49d612bb89af5f8609fbcf7dbae0afb",
"assets/packages/doc_flame_examples/assets/skills.riv": "ef57c58346dcd084eebbc777ccbd0c53",
"assets/packages/doc_flame_examples/assets/images/ember.png": "4dfe185b14556722bec4d4aefeb000b0",
"assets/packages/flame_lottie_example/assets/LottieLogo1.json": "07e6d1f37a8ff5a69e540ee85d2fb6e3",
"assets/packages/flame_splash_screen/assets/layer1.png": "31625c711892b1d250fe3bb58ad32850",
"assets/packages/flame_splash_screen/assets/layer2.png": "51efb74c8ec5a2fd21f622392678f607",
"assets/packages/flame_splash_screen/assets/layer3.png": "24a8fdc53b85d6d749cc2857c708de49",
"assets/AssetManifest.bin.json": "729cd97051cdc5694265da6ebf92d97b",
"assets/AssetManifest.bin": "b4c63f24536ce405c94fa2d896011564",
"assets/NOTICES": "076fc1c9bfdd9dc138fae0e4ab045711",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"assets/assets/yarn/advanced.yarn": "064ca2d4681b9621235fd7056d928d4e",
"assets/assets/yarn/simple.yarn": "0004189432fcf193cd55c55ef2381be3",
"assets/assets/yarn/command_lifecycle.yarn": "00fac03ce06717f611d9e625a2ebc144",
"assets/assets/tiles/0x72_DungeonTilesetII_v1.4.tsx": "854a57933f4dff949837c0c60e0e5fed",
"assets/assets/tiles/dungeon.tmx": "a68f8f8a385c7113781ebb4fbfe880bc",
"assets/assets/svgs/green_balloons.svg": "3d61f785b2499c41365ceec5f6096717",
"assets/assets/svgs/checkerboard.svg": "2375139eb8b48d6a3b10d75f36cb0886",
"assets/assets/svgs/red_balloons.svg": "767935610e45c2201655aa79da84c8c4",
"assets/assets/svgs/happy_player.svg": "9b99470a5aec73cfc3f405c7ad6bc8cd",
"assets/assets/audio/music/bg_music.ogg": "e0ee19692c51bd7e07713a82d570c099",
"assets/assets/audio/sfx/fire_1.mp3": "458f08df07b70378a4dc37ca64af311f",
"assets/assets/audio/sfx/fire_2.mp3": "f8d02b968e3f3eaa373d7cc44a4c0102",
"assets/assets/images/tile_maps/tiles.png": "171922a3ad7ff4c2ac860808680689c5",
"assets/assets/images/tile_maps/tiles-short.png": "8cd3599f377940ecef78cadc8b1ef182",
"assets/assets/images/tile_maps/selector.png": "af5d834438ad6a737075d8a161f83ded",
"assets/assets/images/tile_maps/selector-short.png": "3c528bed4b68461338418b230eb32155",
"assets/assets/images/parallax/heavy_clouded.png": "c65d8861bd2612791832b362973dc0f6",
"assets/assets/images/parallax/mountains.png": "ed6474157918bb521b7657076f49fd24",
"assets/assets/images/parallax/foreground-trees.png": "d507d6ccb000123631a49e84e050eea6",
"assets/assets/images/parallax/license.txt": "7d7af04eb247cd4cb9431659e38873f2",
"assets/assets/images/parallax/airplane.png": "488103bd4bdf2815cd07d06b768855e2",
"assets/assets/images/parallax/rain.png": "5529061587eb3169beba8708f9bc3199",
"assets/assets/images/parallax/city.png": "4af3a23206b39e8d3011846c04ff1cf1",
"assets/assets/images/parallax/mountain-far.png": "d29a3f7182bc85e258a28325e9a66b5e",
"assets/assets/images/parallax/bg.png": "8400f2e43cdb2df53c7b459ede375c3a",
"assets/assets/images/parallax/trees.png": "a8799976ec897f5d83d278e530e7e81b",
"assets/assets/images/pizza.png": "51b877a283fd34dbd6e8090722449054",
"assets/assets/images/knight.png": "a86e3ed53272591b0fda5f0d4f04c8c7",
"assets/assets/images/nine-box.png": "c37ca5bd3a3eed3dd80fa7386ac54948",
"assets/assets/images/flame.png": "b598699b0cff697ce00e9360903c720e",
"assets/assets/images/boom.png": "7b69f63eb3aeecdba484e734fcdbecc0",
"assets/assets/images/zap.png": "4afa5dd9016945905b0a350248885125",
"assets/assets/images/mage.png": "84905149dddace46b6d8c51c7ebcde04",
"assets/assets/images/ranger.png": "92f0fe20fe330a652618ed35aeafbb0e",
"assets/assets/images/shield.png": "0285cfbc54499a4ee6e34c1fdad4b8ec",
"assets/assets/images/retro_tiles.png": "e9b8106ed0b572b236d67232bc0b2df2",
"assets/assets/images/layers/background.png": "d19cfe556a8a2c67094f5810251b8509",
"assets/assets/images/layers/enemy.png": "7a150554055563130bcc44042320b72f",
"assets/assets/images/layers/player.png": "ffd0a6b95b419afa16e963ce07c84eb4",
"assets/assets/images/0x72_DungeonTilesetII_v1.4.png": "6a95780642ec8c3574e3ba8906638991",
"assets/assets/images/rogue_shooter/stars.png": "5e766afbd74a090f1768f15be8c6bc6e",
"assets/assets/images/rogue_shooter/explosion.png": "399d7b06e79778a152fe05204ac77585",
"assets/assets/images/rogue_shooter/enemy.png": "67c6e50b589a02489ac42d18ad0468ee",
"assets/assets/images/rogue_shooter/bullet.png": "6d57d87204c173af8572806d93ae3ec6",
"assets/assets/images/rogue_shooter/player.png": "6455b7f3b2a1140a6562ffcaa157454d",
"assets/assets/images/Car.png": "b2a6d1492d10698cdc2b3cabd79caa07",
"assets/assets/images/dialogue_box.png": "da8b8d446e01f9892e6173291662e733",
"assets/assets/images/trex.png": "b49d612bb89af5f8609fbcf7dbae0afb",
"assets/assets/images/green_button_sqr.png": "96d513e58e934dd3986eb5f87ba7cf4e",
"assets/assets/images/bomb_ptero.png": "a9b2d14b45f32ae8e38f5c34040122ae",
"assets/assets/images/animations/chopper.json": "3a292092669b53cae0f334548a9641ee",
"assets/assets/images/animations/robot-idle.png": "69c1af7696eee5dc5393d791b0844d78",
"assets/assets/images/animations/ember.png": "4dfe185b14556722bec4d4aefeb000b0",
"assets/assets/images/animations/creature.png": "3f60ff8ed152aff011051fdf721324e9",
"assets/assets/images/animations/lottieLogo.json": "07e6d1f37a8ff5a69e540ee85d2fb6e3",
"assets/assets/images/animations/robot.png": "26d09c378437120724121a3c017eb644",
"assets/assets/images/animations/chopper.png": "ab0c9cb1d51cdd7a6dd5eea0a7726863",
"assets/assets/images/buttons.png": "017f2981a1164342d4219080b66beabf",
"assets/assets/images/sprite_sheet.png": "45579c7acf423bf3ba2c24189410ed45",
"assets/assets/images/joystick.png": "9056ad96ea8b2a8834995a7a90a36cfa",
"assets/assets/images/speech-bubble.png": "c163f08feb03fdde50da9522b2c62e53",
"assets/assets/images/red_button_sqr.png": "8c109fb14b7ada8a396287c7869531ad",
"assets/assets/spine/spineboy.png": "79a6229f6a5101c0cf44e8e80dd6f641",
"assets/assets/spine/spineboy-pro.skel": "01f6b4f75adefe54e706cd06996346dd",
"assets/assets/spine/spineboy.atlas": "0252ad0c8f0c40dff09f6854a95fda09",
"assets/assets/spine/LICENSE": "2896607b2195b46995804daba87636e6",
"assets/assets/spine/spineboy-pro.json": "ac06a008422596e6e64c946513103be2",
"assets/AssetManifest.json": "7e44d5bfa8b3d49ba4b46ba95885511a",
"assets/fonts/MaterialIcons-Regular.otf": "30c137b2a9cdd154f182ac28a75bb90b",
"assets/FontManifest.json": "87d3db7932d6cb734bc450e9ac11b35e",
"favicon.png": "ea19c77937c794c05106d010145dfead",
"CNAME": "8e32dacbd784540bf8395759dbf64cef",
"icons/Icon-512.png": "5a37de5f6a1f891f0432e3fee88c00af",
"icons/Icon-192.png": "e1301f376c0dbba27acf9c635bbd3cd7",
"flutter_bootstrap.js": "7dfdcb46bdac150690596470e0bb1c0a",
"version.json": "4653b2532bbba4b978e96a6ac540b654"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
"flutter_bootstrap.js",
"assets/AssetManifest.bin.json",
"assets/FontManifest.json"];

// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});
// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        // Claim client to enable caching on first launch
        self.clients.claim();
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      // Claim client to enable caching on first launch
      self.clients.claim();
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});
// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache only if the resource was successfully fetched.
        return response || fetch(event.request).then((response) => {
          if (response && Boolean(response.ok)) {
            cache.put(event.request, response.clone());
          }
          return response;
        });
      })
    })
  );
});
self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});
// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}
// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
