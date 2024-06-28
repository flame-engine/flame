'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"icons/Icon-512.png": "5a37de5f6a1f891f0432e3fee88c00af",
"icons/Icon-192.png": "e1301f376c0dbba27acf9c635bbd3cd7",
"flutter.js": "383e55f7f3cce5be08fcf1f3881f585c",
"canvaskit/skwasm.worker.js": "bfb704a6c714a75da9ef320991e88b03",
"canvaskit/skwasm.js": "5d4f9263ec93efeb022bb14a3881d240",
"canvaskit/canvaskit.js.symbols": "74a84c23f5ada42fe063514c587968c6",
"canvaskit/skwasm.js.symbols": "c3c05bd50bdf59da8626bbe446ce65a3",
"canvaskit/chromium/canvaskit.js.symbols": "ee7e331f7f5bbf5ec937737542112372",
"canvaskit/chromium/canvaskit.js": "901bb9e28fac643b7da75ecfd3339f3f",
"canvaskit/chromium/canvaskit.wasm": "399e2344480862e2dfa26f12fa5891d7",
"canvaskit/canvaskit.js": "738255d00768497e86aa4ca510cce1e1",
"canvaskit/canvaskit.wasm": "9251bb81ae8464c4df3b072f84aa969b",
"canvaskit/skwasm.wasm": "4051bfc27ba29bf420d17aa0c3a98bce",
"flutter_bootstrap.js": "50d73953bbe68dc8ff3d34910aa22478",
"version.json": "4653b2532bbba4b978e96a6ac540b654",
"favicon.png": "ea19c77937c794c05106d010145dfead",
"main.dart.js": "27cf302b42b1947197311b38d8c909d5",
"assets/NOTICES": "5cadd5e30536287ddee1eb6b4f61bc26",
"assets/AssetManifest.bin": "23d5e920066e24e7102a2e4e08a0e338",
"assets/assets/yarn/advanced.yarn": "064ca2d4681b9621235fd7056d928d4e",
"assets/assets/yarn/simple.yarn": "0004189432fcf193cd55c55ef2381be3",
"assets/assets/images/tile_maps/selector-short.png": "3c528bed4b68461338418b230eb32155",
"assets/assets/images/tile_maps/tiles.png": "171922a3ad7ff4c2ac860808680689c5",
"assets/assets/images/tile_maps/selector.png": "af5d834438ad6a737075d8a161f83ded",
"assets/assets/images/tile_maps/tiles-short.png": "8cd3599f377940ecef78cadc8b1ef182",
"assets/assets/images/knight.png": "a86e3ed53272591b0fda5f0d4f04c8c7",
"assets/assets/images/green_button_sqr.png": "96d513e58e934dd3986eb5f87ba7cf4e",
"assets/assets/images/0x72_DungeonTilesetII_v1.4.png": "6a95780642ec8c3574e3ba8906638991",
"assets/assets/images/dialogue_box.png": "da8b8d446e01f9892e6173291662e733",
"assets/assets/images/nine-box.png": "c37ca5bd3a3eed3dd80fa7386ac54948",
"assets/assets/images/zap.png": "4afa5dd9016945905b0a350248885125",
"assets/assets/images/pizza.png": "51b877a283fd34dbd6e8090722449054",
"assets/assets/images/joystick.png": "9056ad96ea8b2a8834995a7a90a36cfa",
"assets/assets/images/Car.png": "b2a6d1492d10698cdc2b3cabd79caa07",
"assets/assets/images/red_button_sqr.png": "8c109fb14b7ada8a396287c7869531ad",
"assets/assets/images/rogue_shooter/explosion.png": "399d7b06e79778a152fe05204ac77585",
"assets/assets/images/rogue_shooter/bullet.png": "6d57d87204c173af8572806d93ae3ec6",
"assets/assets/images/rogue_shooter/stars.png": "5e766afbd74a090f1768f15be8c6bc6e",
"assets/assets/images/rogue_shooter/enemy.png": "67c6e50b589a02489ac42d18ad0468ee",
"assets/assets/images/rogue_shooter/player.png": "6455b7f3b2a1140a6562ffcaa157454d",
"assets/assets/images/ranger.png": "92f0fe20fe330a652618ed35aeafbb0e",
"assets/assets/images/sprite_sheet.png": "45579c7acf423bf3ba2c24189410ed45",
"assets/assets/images/retro_tiles.png": "e9b8106ed0b572b236d67232bc0b2df2",
"assets/assets/images/buttons.png": "017f2981a1164342d4219080b66beabf",
"assets/assets/images/boom.png": "7b69f63eb3aeecdba484e734fcdbecc0",
"assets/assets/images/mage.png": "84905149dddace46b6d8c51c7ebcde04",
"assets/assets/images/layers/enemy.png": "7a150554055563130bcc44042320b72f",
"assets/assets/images/layers/player.png": "ffd0a6b95b419afa16e963ce07c84eb4",
"assets/assets/images/layers/background.png": "d19cfe556a8a2c67094f5810251b8509",
"assets/assets/images/speech-bubble.png": "c163f08feb03fdde50da9522b2c62e53",
"assets/assets/images/trex.png": "b49d612bb89af5f8609fbcf7dbae0afb",
"assets/assets/images/shield.png": "0285cfbc54499a4ee6e34c1fdad4b8ec",
"assets/assets/images/animations/ember.png": "4dfe185b14556722bec4d4aefeb000b0",
"assets/assets/images/animations/robot-idle.png": "69c1af7696eee5dc5393d791b0844d78",
"assets/assets/images/animations/chopper.png": "ab0c9cb1d51cdd7a6dd5eea0a7726863",
"assets/assets/images/animations/creature.png": "3f60ff8ed152aff011051fdf721324e9",
"assets/assets/images/animations/chopper.json": "3a292092669b53cae0f334548a9641ee",
"assets/assets/images/animations/robot.png": "26d09c378437120724121a3c017eb644",
"assets/assets/images/animations/lottieLogo.json": "07e6d1f37a8ff5a69e540ee85d2fb6e3",
"assets/assets/images/flame.png": "b598699b0cff697ce00e9360903c720e",
"assets/assets/images/parallax/heavy_clouded.png": "c65d8861bd2612791832b362973dc0f6",
"assets/assets/images/parallax/license.txt": "7d7af04eb247cd4cb9431659e38873f2",
"assets/assets/images/parallax/mountains.png": "ed6474157918bb521b7657076f49fd24",
"assets/assets/images/parallax/city.png": "4af3a23206b39e8d3011846c04ff1cf1",
"assets/assets/images/parallax/rain.png": "5529061587eb3169beba8708f9bc3199",
"assets/assets/images/parallax/bg.png": "8400f2e43cdb2df53c7b459ede375c3a",
"assets/assets/images/parallax/foreground-trees.png": "d507d6ccb000123631a49e84e050eea6",
"assets/assets/images/parallax/trees.png": "a8799976ec897f5d83d278e530e7e81b",
"assets/assets/images/parallax/mountain-far.png": "d29a3f7182bc85e258a28325e9a66b5e",
"assets/assets/images/parallax/airplane.png": "488103bd4bdf2815cd07d06b768855e2",
"assets/assets/images/bomb_ptero.png": "a9b2d14b45f32ae8e38f5c34040122ae",
"assets/assets/spine/spineboy.atlas": "472d7e7fbe884935850f012452bd9f46",
"assets/assets/spine/spineboy-pro.skel": "04df1d1470a63f9cc5435d8446fea273",
"assets/assets/spine/LICENSE": "2896607b2195b46995804daba87636e6",
"assets/assets/spine/spineboy-pro.json": "968f6f4ebddae191e2e112f02f213214",
"assets/assets/spine/spineboy.png": "ec577ee2c9fa665b5606b6c8bd4798d7",
"assets/assets/audio/music/bg_music.ogg": "e0ee19692c51bd7e07713a82d570c099",
"assets/assets/audio/sfx/fire_1.mp3": "458f08df07b70378a4dc37ca64af311f",
"assets/assets/audio/sfx/fire_2.mp3": "f8d02b968e3f3eaa373d7cc44a4c0102",
"assets/assets/tiles/0x72_DungeonTilesetII_v1.4.tsx": "854a57933f4dff949837c0c60e0e5fed",
"assets/assets/tiles/dungeon.tmx": "a68f8f8a385c7113781ebb4fbfe880bc",
"assets/assets/svgs/checkerboard.svg": "2375139eb8b48d6a3b10d75f36cb0886",
"assets/assets/svgs/red_balloons.svg": "767935610e45c2201655aa79da84c8c4",
"assets/assets/svgs/happy_player.svg": "9b99470a5aec73cfc3f405c7ad6bc8cd",
"assets/assets/svgs/green_balloons.svg": "3d61f785b2499c41365ceec5f6096717",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"assets/packages/spine_flutter/lib/assets/libspine_flutter.js": "98ba44bcbfa5ba3482f42af8059e0152",
"assets/packages/spine_flutter/lib/assets/libspine_flutter.wasm": "bc93fee1a676f2e14d163c790180d8d1",
"assets/packages/spine_flutter/src/spine-cpp-lite/spine-cpp-lite.h": "75f14be6c4835d2a37842467aab57f66",
"assets/packages/spine_flutter/src/spine-cpp-lite/spine-cpp-lite.cpp": "78df23801141bd4baa39c58acbc4c876",
"assets/packages/trex_game/assets/images/trex.png": "b49d612bb89af5f8609fbcf7dbae0afb",
"assets/packages/rogue_shooter/assets/images/rogue_shooter/explosion.png": "399d7b06e79778a152fe05204ac77585",
"assets/packages/rogue_shooter/assets/images/rogue_shooter/bullet.png": "6d57d87204c173af8572806d93ae3ec6",
"assets/packages/rogue_shooter/assets/images/rogue_shooter/stars.png": "5e766afbd74a090f1768f15be8c6bc6e",
"assets/packages/rogue_shooter/assets/images/rogue_shooter/enemy.png": "67c6e50b589a02489ac42d18ad0468ee",
"assets/packages/rogue_shooter/assets/images/rogue_shooter/player.png": "6455b7f3b2a1140a6562ffcaa157454d",
"assets/AssetManifest.bin.json": "6dd34544092f074694f798eeff46a4eb",
"assets/FontManifest.json": "7b2a36307916a9721811788013e65289",
"assets/fonts/MaterialIcons-Regular.otf": "bd16807ced54f1c30c7c85d8510ce8f7",
"assets/AssetManifest.json": "5e8faae9089b48f07f93f700b34282d7",
"CNAME": "8e32dacbd784540bf8395759dbf64cef",
"index.html": "02df5360ca677c37146e64896fae22f6",
"/": "02df5360ca677c37146e64896fae22f6",
"manifest.json": "88a09d3520ee1c1fd7ad820a705bfc83"};
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
