/* Not So Civilised — service worker
 *
 * Strategy:
 *   Cache-first for static media (logos, fonts, posters, journal/standards images,
 *   carousel preview clips). Network-first with cache fallback for HTML.
 *   Bumping CACHE_VERSION invalidates everything.
 */
const CACHE_VERSION = "nsc-v13";
const STATIC_CACHE = `${CACHE_VERSION}-static`;
const MEDIA_CACHE = `${CACHE_VERSION}-media`;

const PRECACHE_URLS = [
  "/",
  "/index.html",
  "/assets/web/homepage/optimized/NOT-SO-CIVILISED-logo-white.png",
  "/assets/web/homepage/optimized/NOT-SO-CIVILISED-logo-Black.png",
  "/assets/web/homepage/optimized/homepage-video-poster.jpg",
];

const isMediaRequest = (url) => {
  if (url.pathname.startsWith("/assets/")) {
    return /\.(?:mp4|webm|m4v|jpg|jpeg|png|webp|avif|gif|svg|woff2?|otf|ttf|json)$/i.test(
      url.pathname
    );
  }
  return false;
};

self.addEventListener("install", (event) => {
  event.waitUntil(
    caches
      .open(STATIC_CACHE)
      .then((cache) => cache.addAll(PRECACHE_URLS).catch(() => undefined))
      .then(() => self.skipWaiting())
  );
});

self.addEventListener("activate", (event) => {
  event.waitUntil(
    caches
      .keys()
      .then((keys) =>
        Promise.all(
          keys
            .filter((k) => !k.startsWith(CACHE_VERSION))
            .map((k) => caches.delete(k))
        )
      )
      .then(() => self.clients.claim())
  );
});

self.addEventListener("fetch", (event) => {
  const request = event.request;
  if (request.method !== "GET") return;
  let url;
  try {
    url = new URL(request.url);
  } catch (_) {
    return;
  }
  if (url.origin !== self.location.origin) return;

  // Don't try to cache range/byte-range requests (Safari uses these for video).
  if (request.headers.has("range")) return;

  if (isMediaRequest(url)) {
    const isStandardsManifest =
      url.pathname.endsWith("/assets/web/standards/optimized/standards-manifest.json");

    if (isStandardsManifest) {
      event.respondWith(
        fetch(request)
          .then((response) => {
            if (response && response.ok && response.type !== "opaqueredirect") {
              caches
                .open(MEDIA_CACHE)
                .then((cache) => cache.put(request, response.clone()))
                .catch(() => undefined);
            }
            return response;
          })
          .catch(() =>
            caches.open(MEDIA_CACHE).then((cache) => cache.match(request))
          )
      );
      return;
    }

    event.respondWith(
      caches.open(MEDIA_CACHE).then((cache) =>
        cache.match(request).then((cached) => {
          if (cached) return cached;
          return fetch(request)
            .then((response) => {
              if (response && response.ok && response.type !== "opaqueredirect") {
                cache.put(request, response.clone()).catch(() => undefined);
              }
              return response;
            })
            .catch(() => cached);
        })
      )
    );
    return;
  }

  // HTML (navigation) — network first with cache fallback.
  if (request.mode === "navigate" || request.destination === "document") {
    event.respondWith(
      fetch(request)
        .then((response) => {
          const copy = response.clone();
          caches.open(STATIC_CACHE).then((cache) => cache.put(request, copy)).catch(() => undefined);
          return response;
        })
        .catch(() => caches.match(request).then((res) => res || caches.match("/index.html")))
    );
  }
});
