// Service Worker para Kara Clan Official
const CACHE_NAME = 'kara-clan-v2';
const urlsToCache = [
  '/kara-clan-official-web/',
  '/kara-clan-official-web/index.html',
  '/kara-clan-official-web/manifest.json'
];

self.addEventListener('install', event => {
  event.waitUntil(
    caches.open(CACHE_NAME).then(cache => cache.addAll(urlsToCache))
  );
});

self.addEventListener('activate', event => {
  event.waitUntil(
    caches.keys().then(cacheNames =>
      Promise.all(cacheNames.filter(n => n !== CACHE_NAME).map(n => caches.delete(n)))
    )
  );
});

self.addEventListener('fetch', event => {
  event.respondWith(
    fetch(event.request)
      .then(response => {
        const clone = response.clone();
        caches.open(CACHE_NAME).then(cache => cache.put(event.request, clone));
        return response;
      })
      .catch(() => caches.match(event.request))
  );
});

self.addEventListener('push', event => {
  const data = event.data ? event.data.json() : {};
  event.waitUntil(
    self.registration.showNotification(data.title || 'Kara Clan Update', {
      body: data.body || 'A new version is available!',
      icon: 'data:image/svg+xml,<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100"><rect width="100" height="100" rx="20" fill="%23000"/><text x="50" y="55" dominant-baseline="middle" text-anchor="middle" font-family="serif" font-weight="bold" font-size="72" fill="%23c9a84c">K</text></svg>',
      vibrate: [200, 100, 200],
      tag: 'kara-clan-update'
    })
  );
});

self.addEventListener('notificationclick', event => {
  event.notification.close();
  event.waitUntil(clients.openWindow('https://tkpain.github.io/kara-clan-official-web/'));
});
