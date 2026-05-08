self.addEventListener('push', event => {
  const data = event.data ? event.data.json() : {};
  const title = data.title || 'Kara Clan Update';
  const options = {
    body: data.body || 'A new version of the optimizer is available!',
    icon: 'data:image/svg+xml,<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100"><rect width="100" height="100" rx="20" fill="%23000"/><text x="50" y="55" dominant-baseline="middle" text-anchor="middle" font-family="serif" font-weight="bold" font-size="72" fill="%23c9a84c">K</text></svg>',
    vibrate: [200, 100, 200],
    tag: 'kara-clan-update'
  };

  event.waitUntil(
    self.registration.showNotification(title, options)
  );
});

self.addEventListener('notificationclick', event => {
  event.notification.close();
  event.waitUntil(
    clients.openWindow('https://tkpain.github.io/kara-clan-official-web/')
  );
});
