'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"assets/AssetManifest.bin": "4b791e952315983f3e1893d00600eb73",
"assets/AssetManifest.bin.json": "9767dd30e6857e3cd8462494ee3358a5",
"assets/AssetManifest.json": "8cf38cf6b7ac0bd0d423497a3534dd50",
"assets/assets/FitClub%2520AI/Exercises/Alternating_Lunge.py": "01125e7389547249b6e72a6a5ab5196f",
"assets/assets/FitClub%2520AI/Exercises/Barbell_Chest_Press.py": "b041633a1a26718771500d5dc1896d1b",
"assets/assets/FitClub%2520AI/Exercises/Bent_Over_Barbell_Row.py": "ba0d21225da5551b91142836870b074e",
"assets/assets/FitClub%2520AI/Exercises/Bicep_Curl.py": "0cb3ca4605bad5b6251cad43acc26516",
"assets/assets/FitClub%2520AI/Exercises/Bulgarian_Split_Squat.py": "3a23037f27a908a7818b19e4c7ffa835",
"assets/assets/FitClub%2520AI/Exercises/Concentration_Curl.py": "05a016d0d9926a82cd3423910c718fba",
"assets/assets/FitClub%2520AI/Exercises/Conventional_Deadlift.py": "cb91d629726757a830dfbb99d466418c",
"assets/assets/FitClub%2520AI/Exercises/Isometric_Plank.py": "f5ab0b86643a84d912d6df7f030d68dc",
"assets/assets/FitClub%2520AI/Exercises/Lateral_Raises.py": "0cd2e1306a437d9c56099e6d6b023e1c",
"assets/assets/FitClub%2520AI/Exercises/One_Arm_Dumbbell_Row.py": "6110744884e5b2033ba5321d6ffe781d",
"assets/assets/FitClub%2520AI/Exercises/Push_Ups.py": "dc8213f2fd1432e4d79631dd5cc34f69",
"assets/assets/FitClub%2520AI/Exercises/Romanian_Deadlift.py": "c95886d60bde842ef655e0a4fd301f79",
"assets/assets/FitClub%2520AI/Exercises/Rowing_Crunch.py": "c43e23531fb1cc5fdc58c2a399b61ff5",
"assets/assets/FitClub%2520AI/Exercises/Seated_Dumbbell_Shoulder_Press.py": "49d6a82f91bb17ca35a64d863cc1c009",
"assets/assets/FitClub%2520AI/Exercises/Short_Crunch.py": "f999ff7c08f0f65e8f2d88c5da192f01",
"assets/assets/FitClub%2520AI/Exercises/Single_Leg_Calf_Raise_Step.py": "5c2f3d198277944dd852dec392f29938",
"assets/assets/FitClub%2520AI/Exercises/Squat.py": "7c925950b68c02848df788b3e1107cbd",
"assets/assets/FitClub%2520AI/Exercises/Stiff_Leg_Deadlift.py": "0dcabe1bdfb3ed4537e4ad8df72087a6",
"assets/assets/FitClub%2520AI/Exercises/Sumo_Squat.py": "c9f829af9df99524503a12567ca28273",
"assets/assets/FitClub%2520AI/Exercises/testinggg.py": "3349b47114cb9ff642cd4b5431cc82b1",
"assets/assets/FitClub%2520AI/Exercises/__init__.py": "d41d8cd98f00b204e9800998ecf8427e",
"assets/assets/FitClub%2520AI/form_check_server.py": "36d16ae7cbe4a9712cdac26ebb1dd366",
"assets/assets/FitClub%2520AI/form_correction_service.py": "e20a9e39ef59a46b6d15e0127c435b24",
"assets/assets/FitClub%2520AI/LICENSE": "3801f15b3ba2daa81f1a003c728c5602",
"assets/assets/FitClub%2520AI/README.txt": "3183341fe1efe16b4286b9dd39369778",
"assets/assets/FitClub%2520AI/requirements.txt": "e462ee411af15acb60ee2f9f6928465e",
"assets/assets/FitClub%2520Context/FitClub%2520Branding%2520package.pdf": "23736e986e18df2b2dec36c7f544ce2e",
"assets/assets/FitClub%2520Context/FitClub%2520Branding%2520package.txt": "c41392567b1af0bfc7016f6132231c65",
"assets/assets/FitClub%2520Context/fitclub_logo.png": "f6ef984c6f2d9511136e5d1923aeb1a5",
"assets/assets/FitClub%2520Context/nexur_bg.png": "262b6256be9393694c80c871f7e06be2",
"assets/assets/FitClub%2520Context/UIUX%2520flow%2520guide.md": "f7db59dfcef7b4adc0572d067cd429e3",
"assets/assets/Landing%2520page%2520videos/Landing%2520page%2520video%2520background/3196428-uhd_3840_2160_25fps.mp4": "1591db758cd31c25e894f48340ac71bb",
"assets/assets/Landing%2520page%2520videos/Landing%2520page%2520video%2520background/4812848-uhd_3840_2160_25fps.mp4": "09550a6fc9cd1f839a4bd0f73fae6cfd",
"assets/assets/Landing%2520page%2520videos/Landing%2520page%2520video%2520background/5319755-uhd_3840_2160_25fps.mp4": "24c8eaa64749955546502f7824da6bd2",
"assets/assets/Landing%2520page%2520videos/Landing%2520page%2520video%2520background/5319759-uhd_3840_2160_25fps.mp4": "e5084b7b712d36293dbadf4b4a4b3b85",
"assets/assets/Landing%2520page%2520videos/Landing%2520page%2520video%2520background/5320007-uhd_3840_2160_25fps.mp4": "d0c02368176c27a8fc8e546499ecd1bd",
"assets/assets/Landing%2520page%2520videos/Landing%2520page%2520video%2520background/6388436-uhd_3840_2160_25fps.mp4": "62b8f2815f39c009b8e935e0a8403ede",
"assets/FontManifest.json": "dc3d03800ccca4601324923c0b1d6d57",
"assets/fonts/MaterialIcons-Regular.otf": "4274a3b469649345b40b99d8b7976608",
"assets/NOTICES": "49f2ff7989722fd31806994e16f5b8ce",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "33b7d9392238c04c131b6ce224e13711",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"canvaskit/canvaskit.js": "6cfe36b4647fbfa15683e09e7dd366bc",
"canvaskit/canvaskit.js.symbols": "68eb703b9a609baef8ee0e413b442f33",
"canvaskit/canvaskit.wasm": "efeeba7dcc952dae57870d4df3111fad",
"canvaskit/chromium/canvaskit.js": "ba4a8ae1a65ff3ad81c6818fd47e348b",
"canvaskit/chromium/canvaskit.js.symbols": "5a23598a2a8efd18ec3b60de5d28af8f",
"canvaskit/chromium/canvaskit.wasm": "64a386c87532ae52ae041d18a32a3635",
"canvaskit/skwasm.js": "f2ad9363618c5f62e813740099a80e63",
"canvaskit/skwasm.js.symbols": "80806576fa1056b43dd6d0b445b4b6f7",
"canvaskit/skwasm.wasm": "f0dfd99007f989368db17c9abeed5a49",
"canvaskit/skwasm_st.js": "d1326ceef381ad382ab492ba5d96f04d",
"canvaskit/skwasm_st.js.symbols": "c7e7aac7cd8b612defd62b43e3050bdd",
"canvaskit/skwasm_st.wasm": "56c3973560dfcbf28ce47cebe40f3206",
"favicon.png": "5dcef449791fa27946b3d35ad8803796",
"flutter.js": "76f08d47ff9f5715220992f993002504",
"flutter_bootstrap.js": "c379f03a484f14c0b840ca51e0c21b1d",
"icons/Icon-192.png": "ac9a721a12bbc803b44f645561ecb1e1",
"icons/Icon-512.png": "96e752610906ba2a93c65f8abe1645f1",
"icons/Icon-maskable-192.png": "c457ef57daa1d16f64b27b786ec2ea3c",
"icons/Icon-maskable-512.png": "301a7604d45b3e739efc881eb04896ea",
"index.html": "8bcb5b26162ba9ee1ee046157e153203",
"/": "8bcb5b26162ba9ee1ee046157e153203",
"main.dart.js": "403158b5f08e7d0221837541ad8507de",
"manifest.json": "9986b2f1f7ee0cee609eece98cee445e",
"version.json": "2adc29fe3c9736ae7534f672064a9603"};
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
