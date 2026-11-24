# Rajasthani Ras

A Flutter app for browsing Rajasthani idioms, saving favorites locally, and sharing idiom cards.

## Firebase setup

The app reads Firebase options from compile-time `dart-define` values. Get the values for the Firebase app you registered for the target platform, then run with:

```powershell
flutter run `
  --dart-define=FIREBASE_API_KEY=your-api-key `
  --dart-define=FIREBASE_APP_ID=your-app-id `
  --dart-define=FIREBASE_MESSAGING_SENDER_ID=your-sender-id `
  --dart-define=FIREBASE_PROJECT_ID=your-project-id
```

`FIREBASE_AUTH_DOMAIN` is optional and is only needed by web authentication features. No authentication is used for browsing.

Create these Firestore collections:

- `idioms`: `rajasthaniText` (string), `hindiMeaning` (string), `englishMeaning` (string), `categoryId` (string), `isPublished` (boolean), `sortOrder` (number, optional), and `romanTransliteration` (string, optional).
- `themes`: `name` (string), `imageUrl` (public HTTP(S) image URL), `isActive` (boolean), and `sortOrder` (number, optional).

Supported `categoryId` values are `funny`, `wisdom`, `relationships`, `work_life`, `advice`, and `culture_festivals`. Theme images may be hosted on different domains. On web, image hosts must allow the app to load their images; image export and sharing are mobile-only.

On Android and iOS, `cached_network_image` uses a disk cache with a one-year stale period (up to 500 images). The cache is keyed by the full image URL, including its domain. To publish an updated image, change its URL so clients fetch a new cache entry. Cache data can still be removed by the operating system. Web uses browser image loading and does not have the same persistent disk-cache guarantee.

Use Firestore security rules to allow public reads only for published idioms and active themes, and deny client writes. Manage content through the Firebase console or a trusted admin tool. The Firebase client configuration values are not authorization; never rely on them to secure Firestore.

## Local data

Favorites are stored in a local Sembast database (mobile file storage and browser IndexedDB). They are device/browser-local and are not synced between devices.

## Run and test

```powershell
flutter pub get
flutter run
flutter test
flutter analyze
```

Google Mobile Ads uses Google's test app and banner IDs during development. Replace the test IDs in `AndroidManifest.xml`, `Info.plist`, and `BannerAdSlot` with your own before release. Banner ads are shown on Android/iOS only; no interstitials are used.
