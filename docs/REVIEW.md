# Aurora code review and release notes

Baseline: upstream `e82bfa1ba5a9c1a0a4887f3380c1000f8978288c` (2025-12-01). The adjacent local checkout was clean and matched upstream when this work started.

## Addressed

| Finding | Change |
| --- | --- |
| Application startup required the original Firebase project and notification initialization | Separate demo entry point; explicit user-owned Firebase or emulator configuration; useful setup/failure screen |
| `.env` was declared as a distributable asset; Gemini was called directly from client code | Removed `.env` packaging and dotenv dependency; release builds disable client-key AI |
| UI journal/timeline depended on Firestore snapshots | `JournalEntry` application model and injectable `JournalService`, backed by either Firestore or per-session memory |
| Demo would otherwise need real user data and third-party API availability | Fictional month of entries; deterministic local quote; clearly labeled chat examples; no location or notification requests |
| Swipe deletion discarded its Future | Await deletion before dismissal and show a recoverable failure message |
| HTTP calls could wait indefinitely | Bounded quote and AI request timeouts |
| No committed Firestore access policy | Owner-only rules for profiles, journals, conversations, and reasons; journal validation and emulator rule tests |
| CI only ran static analysis | Pin toolchain; run tests, build the demo, and test rules |
| Dependency versions drifted between setups | Commit Flutter and Node lockfiles |

## Architecture

`main_demo.dart` selects demo mode before touching services and installs `MemoryJournalService`. Existing dashboard, journal, timeline, and resource screens are reused. Session reset resets repository data and reconstructs the shell to dispose timers and form controllers. The normal `main.dart` supports user-provided Firebase configuration and local emulators.

## Remaining work before operating a real-user service

- Replace client-side AI with an authenticated server proxy, quotas, request timeouts, and operational monitoring.
- Finish account/data deletion and export, privacy documentation, and a review of any personal data collected by profile forms.
- Move remaining direct Firestore access in chat/profile/resource screens behind typed services. The journal boundary is extracted in this release; a wholesale application rewrite is intentionally avoided.
- Validate location/provider behavior and resource links for each supported region. Demo location services are disabled; resource content is inherited academic material.
- Verify Android/iOS build signing, platform Firebase configuration, notification permissions, timezone behavior, and accessibility on actual devices.
- Consider SDK/package major upgrades separately: older mapping/location packages prevent a Wasm-target build. The supported web demo uses JavaScript plus local CanvasKit.
- Review accessibility and keyboard behavior across all resource widgets. The core web flows are tested; this is not a certification of the entire app.

Do not describe the release as a clinically validated wellness product or an actively operated service.

## Verification on 2026-11-05

- Flutter 3.35.3 / Dart 3.9.2: analysis clean, six Flutter tests passing, JavaScript web release build passing.
- Chrome release smoke test: create/edit/search journal entries, reactive 7/30-day charts, reset, focus timer, and mobile navigation passed. No external HTTP requests, CSP violations, or browser errors were observed in those flows.
- Firestore emulator: owner CRUD allowed; guest and cross-user access denied; oversized journal writes rejected. This verifies rules, not a full real-backend account lifecycle.
- The demo JavaScript does not contain the original Firebase project ID or a Gemini key configuration marker; no `.env` asset is packaged.
- Firebase/Playwright test tooling audit: zero critical/high findings, 15 moderate findings in development dependencies. The browser demo deploys only static Flutter output, not these Node packages.
- During visual review, repeated chart axis labels were fixed; journal edits now handle save failures before closing, and resource navigation has a Back tooltip.

The Firebase-backed app's complete account lifecycle and native device builds remain unverified. They require separate validation before real-user distribution.
