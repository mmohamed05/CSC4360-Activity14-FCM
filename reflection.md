# Activity 14 — Firebase Cloud Messaging reflection

**Result:** Firebase configuration, Android rebuild, and all four real FCM tests
passed. Tests ran November 9–10, 2026, EST. Repository: [CSC4360-Activity14-FCM](https://github.com/mmohamed05/CSC4360-Activity14-FCM).
LMS submission remains outstanding; this document does not claim coursework submission.

## Three responses (approximately 230 words)

**1. Setup and payload.** The configuration decision was to match Android package
`edu.gsu.csc4360.activity14_fcm` to project `csc4360-activity14-mo-6f0a4`.
The user identified the account mismatch; switching Firebase CLI to
`mohamedmudhirmoyow9@gmail.com` resolved the empty project list and permission error.
FlutterFire then registered Android and generated matching configuration.
`action=update_ui` selects the supported operation; `asset=promo` selects a bundled
image through an allowlist. These keys validate input; they do not authenticate
senders. Codex assisted with implementation, configuration, testing, evidence, and
this reflection; the user completed Google authentication.

**2. Lifecycle and evidence.** [T1](evidence/T1_composite.png) shows foreground
`onMessage`, receipt count 1, and the promotion UI.
[T2](evidence/T2_composite.png) shows the notification and, after tapping,
`onMessageOpenedApp`. [T3](evidence/T3_composite.png) shows a notification-triggered
cold start with `getInitialMessage` and count 1. The separately registered
`onBackgroundMessage` runs outside widget state in an Android background isolate;
it cannot directly update widgets. These observations cover one Android emulator
and notification-plus-data messages, not guaranteed delivery across devices or
payload types.

**3. Validation and next step.** [T4](evidence/T4_composite.png) changed only the
asset to `unknown`. The app rejected it, advanced the count from 1 to 2, and
preserved the promotion title/image. An allowlist avoids arbitrary asset paths;
service cleanup and disposal guards protect asynchronous widget updates. The first
T2 attempt arrived during the Home transition, so the test was repeated after
confirming the launcher was foregrounded. A useful improvement is an explicit
lifecycle-state diagnostic, verified by showing the expected state before each send.

## Environment and configuration

- Device: Pixel 7 Android emulator, `emulator-5554`, Google Play services image.
- OS: Android 17, API 37; arm64.
- Notification permission: **authorized**, granted through the app's Android prompt.
- FCM token: retrieved successfully; kept private and absent from evidence.
- Project: `csc4360-activity14-mo-6f0a4`, number `1071629030951`.
- Android package: `edu.gsu.csc4360.activity14_fcm`.
- Firebase app ID: `1:1071629030951:android:ec89eb56416d4490aee002`.
- CLI account: `mohamedmudhirmoyow9@gmail.com`; old account logged out.
- `firebase projects:list --json`: success, intended project listed as ACTIVE;
  [sanitized output](evidence/verified_project_access.json).
- `flutterfire configure --project=csc4360-activity14-mo-6f0a4 --platforms=android --android-package-name=edu.gsu.csc4360.activity14_fcm --yes`: passed.
- Generated `google-services.json` and `firebase_options.dart` match the project.
  Android initialization uses the generated native resources.
- `flutter analyze`: no issues. `flutter test`: all three tests passed.
  `flutter build apk --debug`: passed; APK installed and launched successfully.
- Flutter 3.47.2 / Dart 3.13.2; Firebase Core 4.15.2 and Messaging 16.7.1.

## Payload and sender

Real sends used the [FCM HTTP v1 API](https://firebase.google.com/docs/cloud-messaging/send/v1-api)
with the authenticated account and this emulator's current registration token.
No broad campaign was published. Credentials and device tokens were kept out of
screenshots and the [send ledger](evidence/send_results.jsonl).

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

The HTTP envelope targeted the emulator token and specified Android HIGH priority
and TTL 300 seconds. T4 changed only `data.asset` to `unknown`.

## Four required real-message results

Times below are EST; message IDs correspond to the sanitized send ledger and
visible app diagnostics. Receipt counts reset with the app process.

| Test | Expected | Observed | Status / evidence |
| --- | --- | --- | --- |
| T1 foreground | `onMessage`, new ID/count, promo title/image | Nov 9, 23:59:45: `onMessage`, count 1, accepted `update_ui / promo`, “New promotion” and gift image | **PASS** — [T1 composite](evidence/T1_composite.png) |
| T2 background tap | Notification → tap → `onMessageOpenedApp`, promo UI | Nov 10, 00:00:39: real notification tapped; `onMessageOpenedApp`, count 3, accepted promo | **PASS** — [T2 composite](evidence/T2_composite.png) |
| T3 terminated tap | Notification-triggered cold start → `getInitialMessage`, promo UI | Nov 10, 00:01:36: notification tapped after verified process termination; `getInitialMessage`, count 1, accepted promo | **PASS** — [T3 composite](evidence/T3_composite.png), [process check](evidence/T3_process_state.txt) |
| T4 invalid payload | `onMessage`, new ID/count, rejection, prior title/image preserved | Nov 10, 00:01:48: `onMessage`, count 2, “Rejected: asset must be default or promo. Previous UI preserved.” Title/image unchanged | **PASS** — [T4 before/after composite](evidence/T4_composite.png) |

Message IDs:

- T1: `0:1794286784643451%3eea23023eea2302`
- T2 passing retry: `0:1794286821646494%3eea23023eea2302`
- T3: `0:1794286881020951%3eea23023eea2302`
- T4: `0:1794286908259710%3eea23023eea2302`

## Conditions, retries, and limitations

The initial Python HTTP request stalled and was stopped before a send response;
a timeout-controlled request produced T1's verified delivery. T2's first send at
23:59:55 happened too close to pressing Home and was received as another foreground
message. It does not count as the background pass. After confirming the launcher
was resumed, the second send produced the notification and correct tap handler.
This extra receipt explains count 3 in the T2 screenshot. Both API responses remain
in the send ledger.

For T3, swiping the app from Recents left its process cached. `adb shell am kill`
terminated that background process. Before sending, `pidof` returned no process and
Android reported `stopped=false`. No Settings force-stop or `am force-stop` was used.
The app was opened through its notification, not its launcher icon.

The composites only place actual screenshots beside each other with labels above;
raw screenshots are retained. T4 demonstrates preservation with the same notification
title and an unsupported asset; it does not independently prove rejection of a changed
title. Local tests additionally cover missing, unsupported, and non-string fields.
No optional background-processing or iOS test is claimed. A successful send response
alone was not treated as a pass; each pass has visible handler/UI evidence.

The tests crossed midnight: T2–T4 completed November 10, after the assignment's
stated November 9, 11:59 PM EST deadline. No on-time submission is claimed.
The repository is published publicly at the link above. LMS submission has not been performed.
Firebase configuration remains local and ignored by Git; a grader needs the matching
configuration or must configure their own project. Review this AI-assisted reflection
to ensure it represents your understanding before submitting.

Previous blocked status is retained only as [historical context](evidence/reflection_before_account_fix.md).
