// Service Worker para Kara Clan Official
const CACHE_NAME = 'kara-clan-v1';
const urlsToCache = [
  '/kara-clan-official-web/',
  '/kara-clan-official-web/index.html',
  '/kara-clan-official-web/manifest.json'
];

// Instalación: cachear archivos esenciales
self.addEventListener('install', event => {
  event.waitUntil(
    caches.open(CACHE_NAME).then(cache => {
      return cache.addAll(urlsToCache);
    })
  );
});

// Activación: limpiar caches antiguas
self.addEventListener('activate', event => {
  event.waitUntil(
    caches.keys().then(cacheNames => {
      return Promise.all(
        cacheNames.filter(name => name !== CACHE_NAME).map(name => caches.delete(name))
      );
    })
  );
});

// Estrategia: network first, fallback a cache
self.addEventListener('fetch', event => {
  event.respondWith(
    fetch(event.request)
      .then(response => {
        // Cachear la respuesta para offline
        const responseClone = response.clone();
        caches.open(CACHE_NAME).then(cache => {
          cache.put(event.request, responseClone);
        });
        return response;
      })
      .catch(() => {
        return caches.match(event.request);
      })
  );
});

// Push notifications
self.addEventListener('push', event => {
  const data = event.data ? event.data.json() : {};
  const title = data.title || 'Kara Clan Update';
  const options = {
    body: data.body || 'A new version of the optimizer is available!',
    icon: 'data:image/svg+xml,<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100"><rect width="100" height="100" rx="20" fill="%23000"/><text x="50" y="55" dominant-baseline="middle" text-anchor="middle" font-family="serif" font-weight="bold" font-size="72" fill="%23c9a84c">K</text></svg>',
    vibrate: [200, 100, 200],
    tag: 'kara-clan-update'
  };
  event.waitUntil(self.registration.showNotification(title, options));
});

self.addEventListener('notificationclick', event => {
  event.notification.close();
  event.waitUntil(clients.openWindow('https://tkpain.github.io/kara-clan-official-web/'));
});
