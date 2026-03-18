// Service Worker for Copi Loca PWA: Home-only offline support

const HOME_PATH = '/';
const CACHE_NAME = 'copi-loca-home-v1';
const OFFLINE_URLS = [HOME_PATH];

self.addEventListener('install', event => {
  event.waitUntil(
    caches.open(CACHE_NAME).then(cache => {
      return cache.addAll(OFFLINE_URLS);
    })
  );
  self.skipWaiting();
});

self.addEventListener('activate', event => {
  event.waitUntil(
    caches.keys().then(keys =>
      Promise.all(keys.filter(k => k !== CACHE_NAME).map(k => caches.delete(k)))
    )
  );
  self.clients.claim();
});

self.addEventListener("fetch", event => {
  event.respondWith(
    ( async () => {
      try {
        const response = await fetch(event.request);
        return response;
      } catch (error) {
        const cachedResponse = await caches.match(event.request.url);
        return cachedResponse || new Response('Offline', { status: 503, statusText: 'Offline' });
      }
    })()
  );
});
