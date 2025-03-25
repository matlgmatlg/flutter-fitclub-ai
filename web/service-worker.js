const CACHE_NAME = 'flutter-app-cache';
const RESOURCES = {
  '/index.html': null,
  '/main.dart.js': null,
  '/assets/AssetManifest.json': null,
  '/assets/FontManifest.json': null,
  '/assets/packages/cupertino_icons/assets/CupertinoIcons.ttf': null,
  '/assets/fonts/MaterialIcons-Regular.otf': null,
  '/assets/images/': null,
  '/assets/icons/': null,
  '/assets/fonts/': null
};

self.addEventListener('install', (event) => {
  event.waitUntil(
    caches.open(CACHE_NAME)
      .then((cache) => {
        return cache.addAll(Object.keys(RESOURCES));
      })
  );
});

self.addEventListener('fetch', (event) => {
  event.respondWith(
    caches.match(event.request)
      .then((response) => {
        if (response) {
          return response;
        }
        return fetch(event.request);
      })
  );
}); 