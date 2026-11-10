# Activity 14 — submission draft (real delivery tests pending)

## Exact-project access check — November 9, 2026, 11:52 PM EST

The user supplied the exact Firebase Project ID: `csc4360-activity14-mo-6f0a4`.
Firebase CLI 15.35.0 is authenticated. `firebase projects:list --json` succeeded
with an empty list. A direct `firebase apps:list ANDROID --project
csc4360-activity14-mo-6f0a4 --json` request failed; the Firebase API returned
**403 PERMISSION_DENIED: The caller does not have permission** for this exact
project. Thus the missing ID is resolved, but CLI access is not.

The emulator returned `device`. No configuration was generated, configured rebuild
performed, or real FCM message sent in this continuation. Existing screenshots
remain setup evidence only. T1–T4 are **BLOCKED / NOT VERIFIED**, not passed.
The account owner must reconcile Console and CLI account/project access before
configuration can continue. See [sanitized access evidence](evidence/project_access_check.md).

## Earlier project-creation continuation — November 9, 2026

- Firebase login completed successfully through Google in the Mac browser.
- Authenticated `firebase projects:list` succeeded and returned no Firebase projects.
- The requested ID `csc4360-activity14-mo` was available. Google Cloud created
  **Activity 14**, project number `673951889087`, with lifecycle state **ACTIVE**.
- Adding Firebase failed with **403 PERMISSION_DENIED**, including a separate
  `firebase projects:addfirebase csc4360-activity14-mo` retry. This is now an
  activation/permission block, not a failed login. Firebase Console was opened
  for the account owner to complete any required terms or approval. The exact
  cause is not yet confirmed.
- FlutterFire configuration, a configured rebuild, and real T1–T4 delivery remain
  pending access to the replacement Firebase project. No new delivery screenshots or passing results
  are claimed. Earlier setup captures remain setup evidence only.
- Credentials, authorization codes, and tokens are omitted from this report.

## Earlier continuation check — November 9, 2026, 11:40 PM EST

- Rechecked the installed Firebase CLI outside the sandbox:
  `firebase projects:list` returned **Failed to authenticate** and
  `firebase login:list` returned **No authorized accounts**. The reported login
  completion is not available to this CLI; no project ID could be verified.
- `android/app/google-services.json` and `lib/firebase_options.dart` are absent.
  FlutterFire configuration remains blocked on authenticated project access.
- Rebuilt with `flutter build apk --debug` successfully, installed with `adb install -r`,
  and launched `edu.gsu.csc4360.activity14_fcm/.MainActivity` on `emulator-5554`.
  Android reports version 17 / API 37. The displayed result is **Firebase setup required**.
- Fresh, unmodified device capture: [rebuilt app setup block](evidence/01_rebuilt_setup_blocked.png).
  This is setup evidence only, not T1–T4 evidence. No real FCM send occurred in this check.
- Required interaction: complete `/Users/2fly/Downloads/Lab7/.tools/firebase login`
  in Terminal and identify the intended Firebase project ID. Do not share credentials
  or tokens in the reflection. Then configure Android, rebuild, and execute T1–T4.
  Repository publication/access and LMS submission also remain outstanding.

## Three responses (approximately 200 words)

**1. Setup and payload.** The Android application ID is
`edu.gsu.csc4360.activity14_fcm`; its Firebase registration must match exactly.
Dependencies stay within Firebase Core 4.x and Messaging 16.x. The two custom
string keys have separate jobs: `action=update_ui` authorizes the supported UI
operation, while `asset=default` or `asset=promo` selects a bundled image. This is
input validation, not user authentication. Codex assisted with implementation,
local tests, and this draft; account configuration and real delivery remain pending.

**2. Lifecycle and evidence.** `onMessage` handles foreground receipt;
`onMessageOpenedApp` handles a background notification tap; `getInitialMessage`
checks a notification-triggered cold start. The separately registered
`onBackgroundMessage` runs in an Android background isolate and cannot directly
change widgets. T1–T3 currently have no delivery evidence. The setup screenshot
only documents the configuration block. Passing local tests and building an APK
do not establish cloud delivery or notification permission.

**3. Validation and next step.** Local tests confirmed that missing, unsupported,
and non-string payload fields preserve the previous title and image while changing
receipt metadata and the rejection diagnostic. Real-message T4 is still unverified.
An asset allowlist prevents arbitrary paths; disposal guards prevent asynchronous
updates after the service closes. The next improvement is to complete authenticated
configuration and the four real sends, with fresh message IDs and handler/UI captures
as the observable success condition. Android force-stop must not substitute for T3.

## Device and verification context

- Device: Android Studio Pixel 7 emulator, arm64, Google Play system image.
- Observed OS: Android 17, API 37; AVD image `android-37.1/google_apis_playstore_ps16k`.
- Notification permission: not yet requested by a Firebase-configured app; not verified.
- FCM token: not retrieved; no token appears in this document or evidence.
- Firebase project: `csc4360-activity14-mo-6f0a4`; exact ID supplied, direct CLI access denied (403). The old `csc4360-activity14-mo` is no longer the intended target. Android registration not yet completed.
- Local verification: pub get passed; Dart formatting completed; analyzer reported no issues;
  all 3 unit/widget tests passed. Debug APK build passed; installation succeeded and the app launched on the emulator.
  The observed screen reports missing Firebase setup, not successful messaging.
  Actual capture: [setup block](evidence/00_setup_blocked.png).
- Repository URL: pending; local project has an isolated Git repository and no remote.

## Valid payload (notification plus custom string data)

```json
{
  "notification": {
    "title": "New promotion",
    "body": "Switch the screen to the promo asset"
  },
  "data": {
    "action": "update_ui",
    "asset": "promo"
  }
}
```

For T4, change only `asset` from `promo` to `unknown`, after a valid promo result.
This is conceptual message content; Console supplies the target token/envelope.

## Required real-message results

| Test | Expected | Observed | Status / evidence |
| --- | --- | --- | --- |
| T1 foreground | `onMessage`, new ID/count, promotion title/image | No real message sent; exact project supplied, direct Android-app request denied (403) | BLOCKED; no T1 evidence |
| T2 background tap | Notification tap → `onMessageOpenedApp`, promotion UI | No real message sent or tapped | BLOCKED; no T2 evidence |
| T3 terminated tap | Notification-triggered launch → `getInitialMessage`, promotion UI | No real message sent or tapped | BLOCKED; no T3 evidence |
| T4 invalid payload | `onMessage`, rejection diagnostic, new ID/count, previous title/image preserved | Local validation test passed, but no real invalid Firebase message received | BLOCKED; local test does not satisfy T4 |

## Rubric completion and limitations

- **Engagement/ownership (10):** specific configuration decisions, checks, limitations,
  and AI assistance documented; student review and explanation still needed.
- **Conceptual understanding (25):** four APIs, receipt versus tap, background-isolate
  restriction and the two payload keys explained; no claim of observed cloud behavior.
- **Effective application (30):** initialization, background registration, owned
  subscriptions/cleanup, UI mapping and rejection implemented. Correct Firebase
  project initialization and real T1–T4 behavior remain unverified.
- **Testing/evidence (20):** four accurate blocked rows and device context included;
  permission, real sends, and required recording/four composites are incomplete.
- **Creative problem-solving (15):** asset validation and disposal risks addressed;
  next step and observable success condition stated. No numerical grade claimed.

The SDK lacked command-line tools, so `flutter doctor` could not determine license
status; Gradle found accepted licenses and installed its needed platform. iOS setup
is outside scope. Firebase config is excluded from Git and must be supplied locally
for a runnable messaging build. Delivery depends on network, Google Play services,
permissions and lifecycle; a successful send response alone is insufficient proof.
The assignment is **not complete** until real tests and evidence are verified,
repository access is established, and the required materials are submitted to the LMS.
