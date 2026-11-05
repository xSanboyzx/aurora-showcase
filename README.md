# Aurora · Showcase release

A bounded polish release of the original five-person Flutter course project. The browser demo reuses the real dashboard, journal, timeline, and support tools with a fictional, session-only journal. AI examples are prerecorded. No account, location permission, notification permission, Firebase connection, or API key is required.

## Run the demo

Use **Flutter 3.35.3 / Dart 3.9.2**, matching CI and the verified release toolchain:

```sh
cd aurora_app
flutter pub get --enforce-lockfile
flutter run -d chrome -t lib/main_demo.dart
```

The seed contains 30 days of fictional entries. Create, edit, delete, search, filter, and inspect trends through the existing journal UI. Reset demo restores the sample journal and disposes active timers; refreshing starts a new session. Please use fictional text. No browser storage persists journal changes.

```sh
flutter analyze
flutter test
flutter build web --release -t lib/main_demo.dart --no-web-resources-cdn --pwa-strategy=none
```

Serve `aurora_app/build/web` over HTTP. `node tools/prepare-demo.mjs` adds the standalone demo's response headers. Its Cloudflare assets configuration is in `wrangler.jsonc`. The renderer and fonts are hosted locally. This demo has its own policy because Flutter's WebAssembly renderer requires `wasm-unsafe-eval`; the portfolio's script policy does not need that permission.

For the production browser smoke test, run `npm ci`, `npx playwright install chromium ffmpeg`, then `npm run test:browser` from the repository root after building and preparing the demo. The test launches its own local server and checks journal creation, edits, chart updates, reset, focus timer, mobile navigation, and absence of external requests/CSP errors. Screenshots and a recording are saved under ignored `.artifacts/`. `npm run preview` starts a persistent preview on port 8790. Set `AURORA_BROWSER_CHANNEL=chrome` to test an installed Chrome instead of Playwright's Chromium.

## Run the Firebase-backed app locally

The fork never defaults to the original team's Firebase project. For an isolated local environment, use Node 22, Java 21, and the Firebase emulators:

```sh
# Repository root
npm ci
npx firebase emulators:start --project demo-aurora --only auth,firestore
```

In a second terminal:

```sh
cd aurora_app
flutter run -d chrome --dart-define=USE_FIREBASE_EMULATORS=true
```

Create a fictional account in the app. Auth runs on port 9099 and Firestore on 8080. The emulators are separate from the demo and do not contact the team's backend. Set `FIREBASE_EMULATOR_HOST` if the browser/device cannot reach `127.0.0.1`.

For your own Firebase project, enable email/password authentication and Firestore, configure authorized domains, review and deploy `firestore.rules` to that project explicitly, then pass public client configuration:

```sh
flutter run -d chrome --dart-define=FIREBASE_PROJECT_ID=YOUR_PROJECT --dart-define=FIREBASE_API_KEY=YOUR_PUBLIC_FIREBASE_CLIENT_KEY --dart-define=FIREBASE_APP_ID=YOUR_WEB_APP_ID --dart-define=FIREBASE_AUTH_DOMAIN=YOUR_PROJECT.firebaseapp.com --dart-define=FIREBASE_MESSAGING_SENDER_ID=YOUR_SENDER_ID
```

Firebase client configuration is public identification, not authorization; the security rules enforce ownership. Legacy generated mobile platform configuration is retained from the academic project and must be regenerated for your own project before mobile distribution.

## AI and notifications

Release builds intentionally disable direct Gemini calls. There is no `.env` asset and no live AI in the demo. Personal debug builds can opt in with `--dart-define=GEMINI_API_KEY=...`; that key is exposed to the client and must never be used in a public distribution. A real-user AI product needs an authenticated, rate-limited backend proxy, which is outside this release.

Native notification initialization is optional; permission requests occur through Settings. Web notifications are unsupported. Android/iOS release artifacts have not been certified by this web-focused release.

## Tests and release scope

`npm run test:rules` starts an isolated Firestore emulator and tests journal ownership, guest denial, valid edits/deletion, and invalid writes. CI also runs Dart analysis, Flutter tests, and the web release build.

See `docs/REVIEW.md` for reviewed issues, changes, and remaining work. This is a student wellness prototype, not a medical service. It is not offered as an operated real-user service and has no promised maintenance cadence. Original academic documentation is retained in `docs/ORIGINAL_README.md`.

## Credits and license

Original project: Sunny Patel, Sanhith Amarathunge, Aakanksha Parekh, Paul Joseph, and Suthashan Tharmarajah. Showcase polish by Sanhith Amarathunge. Original MIT license retained in `LICENSE`.
