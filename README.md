# CSC 4360 — Activity 14: Firebase Cloud Messaging

Android Flutter app for campus updates. A notification with `action=update_ui` and
`asset=default` or `asset=promo` updates its title and bundled image. Invalid data
updates diagnostics and receipt metadata while preserving the last valid UI.

**Status:** configured and rebuilt for `csc4360-activity14-mo-6f0a4` using the
correct account, `mohamedmudhirmoyow9@gmail.com`. All four real FCM tests passed
on the Android emulator on November 9–10, 2026 (EST). See the four labeled
[evidence composites](evidence/README.md) and [reflection](reflection.md).
Analysis, all three local tests, and the configured debug APK build passed.
Repository: [CSC4360-Activity14-FCM](https://github.com/mmohamed05/CSC4360-Activity14-FCM).
LMS submission remains outstanding.

## Environment

Flutter 3.47.2 / Dart 3.13.2. Dependencies are constrained to Firebase Core 4.x
and Messaging 16.x; the lockfile resolves 4.15.2 and 16.7.1 respectively.
Android application ID: `edu.gsu.csc4360.activity14_fcm`.
Firebase CLI 15.35.0 and FlutterFire CLI 1.5.0 installed during setup.

## Configure and run

Install Flutter, Firebase CLI, and FlutterFire CLI, and ensure they are on your PATH.
From this directory:

```sh
firebase login
firebase projects:list
flutterfire configure --project=csc4360-activity14-mo-6f0a4 --platforms=android --android-package-name=edu.gsu.csc4360.activity14_fcm
flutter pub get
flutter run -d emulator-5554
```

The commands above target the project used for this evidence. A grader without
access should substitute their own Firebase project ID. Verify that
`android/app/google-services.json` contains that project ID and exactly the Android
package above. FlutterFire generates `lib/firebase_options.dart`; this Android-only
app initializes using native resources generated from `google-services.json`.
The Google Services Gradle plugin is applied when that file is present. Rebuild
after configuration. Without configuration, the app explicitly displays a block.
The local configuration files are ignored; share them privately with a grader if
needed, or let the grader configure their own Firebase project. Never add service
account keys, login credentials, or FCM tokens to Git.

Accept the Android notification permission prompt. The app shows permission status
and whether a token was retrieved. “Copy token privately” copies the current token
without displaying it. Paste it only into Console's test-device token field; do not
capture the Console token field or Android clipboard overlay in evidence.

## Actual Firebase tests

Use Firebase Console → your project → Messaging (under Engage/Run, depending on
Console layout) → create a Firebase Notification campaign. Enter title **New
promotion**, body **Switch the screen to the promo asset**. Expand **Additional
options → Custom data**, adding string pairs `action` = `update_ui` and `asset` =
`promo`. Return to **Send test message**, paste the current device token, select
that device, and send. If custom data is hidden in the first composer step, advance
through the draft to Additional options, enter it, then return to the test action.
Do not publish a broad campaign. Verify that the received app diagnostic confirms
the custom fields were included.

1. **T1:** keep app visible, send. Expect `onMessage`, incremented receipt count,
   fresh message ID, New promotion title and promo image. Capture `evidence/T1_foreground.png`.
2. **T2:** press Home, send, capture notification shade, tap notification, capture
   `onMessageOpenedApp` and updated UI. Save labeled T2 evidence.
3. **T3:** dismiss app from Recents (do not force-stop in Settings or use
   `adb am force-stop`), send, capture notification, tap. Expect
   `getInitialMessage`, count 1 for this launch and promo UI. Capture before
   launching from the app icon. Save labeled T3 evidence.
4. **T4:** with previous promo result visible, change only `asset` to `unknown`,
   keep `action=update_ui`, and send while foregrounded. Capture before and after:
   `onMessage`, new ID/count and rejection diagnostic; title and image unchanged.

Use real sends only for these rows. A notification tray image alone does not prove
UI handling. Submission requires one recording or four labeled composite screenshots
covering handler/UI, with T4 preservation visible. Keep any raw captures for assembly.
An actual device capture can be saved using:

```sh
adb -s emulator-5554 exec-out screencap -p > evidence/T1_foreground.png
```

Foreground messages do not automatically show a system banner. The separately
registered `onBackgroundMessage` runs outside widget state and is not equivalent
to notification taps. Receipt counts are per process launch, not persistent.

## Verification and source map

```sh
flutter pub get
dart format lib test
flutter analyze
flutter test
flutter build apk --debug
```

- `lib/main.dart`: awaited initialization, top-level background registration, UI,
  permission refresh on resume and lifecycle cleanup.
- `lib/fcm_service.dart`: service-owned streams, initial-message handling, token
  refresh, disposal guards, and atomic payload validation.
- `assets/`: two locally generated geometric illustrations (campus and gift).
- `test/widget_test.dart`: valid mapping, invalid-data preservation and setup-block UI.
  These unit/widget tests construct messages; they are not real delivery evidence.
- `reflection.md`: reflection, four test rows and rubric completion status.
- `evidence/`: actual emulator captures only; setup evidence is labeled separately.

## GitHub and submission

Repository: https://github.com/mmohamed05/CSC4360-Activity14-FCM

The repository contains the Android Flutter source, bundled assets, dependency
lockfile, README, reflection, and original T1–T4 evidence with its send ledger.
Local Firebase configuration, credentials, tokens, and build outputs are ignored.
Configure Firebase as described above before running a fresh clone.

For the LMS, paste the repository URL and upload `reflection.md` plus
`evidence/T1_composite.png`, `evidence/T2_composite.png`,
`evidence/T3_composite.png`, and `evidence/T4_composite.png`.
The README and supporting raw evidence are included in the repository.
LMS submission has not been performed.

Implementation follows the assignment PDF and Firebase's official
[Flutter setup](https://firebase.google.com/docs/flutter/setup) and
[message reception](https://firebase.google.com/docs/cloud-messaging/flutter/receive-messages)
guides. AI assistance: Codex generated the implementation, local tests and draft
documentation; review the reflection to ensure it represents your understanding.
