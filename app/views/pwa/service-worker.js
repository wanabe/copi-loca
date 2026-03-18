// Service Worker for Copi Loca PWA: Dynamic Asset Caching & Explicit HTML Fetching
const CACHE_NAME = 'copi-loca-offline-v1';
const PAGES_TO_CACHE = [
  '/',
  '/memos'
];

self.addEventListener('install', event => {
  event.waitUntil(
    caches.open(CACHE_NAME).then(async cache => {
      const requests = PAGES_TO_CACHE.map(url => new Request(url, {
        headers: {
          'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8'
        }
      }));

      try {
        await cache.addAll(requests);
        return console.log('Pages cached with full layout');
      } catch (err) {
        return console.error('Failed to cache pages:', err);
      }
    })
  );
  self.skipWaiting();
});

self.addEventListener('activate', event => {
  event.waitUntil(
    caches.keys().then(async keys =>
      await Promise.all(keys.filter(k => k !== CACHE_NAME).map(k => caches.delete(k)))
    )
  );
  self.clients.claim();
});

self.addEventListener("fetch", event => {
  if (event.request.method !== 'GET' || event.request.url.startsWith('chrome-extension')) {
    return;
  }

  event.respondWith(
    (async () => {
      try {
        const networkResponse = await fetch(event.request);
        // Currently, we are not caching new responses on fetch to avoid stale content issues.
        /*
        if (networkResponse.ok) {
          const cache = await caches.open(CACHE_NAME);
          cache.put(event.request, networkResponse.clone());
        }
        */
        return networkResponse;
      } catch (error) {
        const cachedResponse = await caches.match(event.request);
        if (cachedResponse) {
          return cachedResponse;
        }
        return new Response('Offline', { status: 503, statusText: 'Offline' });
      }
    })()
  );
});
