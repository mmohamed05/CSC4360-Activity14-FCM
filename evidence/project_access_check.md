> Historical check with the incorrect account. Resolved after switching accounts; see [verified access](verified_project_access.json) and the current [reflection](../reflection.md).

# Firebase project access check — November 9, 2026, 11:52 PM EST

Target: `csc4360-activity14-mo-6f0a4` (exact ID supplied by user).

Actual checks outside the sandbox:

- Firebase CLI 15.35.0 `login:list`: an authenticated account is present.
- `firebase projects:list --json`: exit 0, `{"status":"success","result":[]}`.
- `firebase apps:list ANDROID --project csc4360-activity14-mo-6f0a4 --json`:
  exit 2, failed to list Android apps.
- Underlying API: `GET https://firebase.googleapis.com/v1beta1/projects/csc4360-activity14-mo-6f0a4/androidApps`
  returned HTTP **403** with `PERMISSION_DENIED`, `The caller does not have permission`.
- `adb -s emulator-5554 get-state`: `device`.

The Firebase request reached Google; this denial also occurred outside the local
sandbox. Project visibility in Console does not establish access for the current
CLI account. The precise cause of the account/project access mismatch remains
unconfirmed. No credentials, access tokens, or registration tokens are included.

Android configuration files remain absent. No configured rebuild or real FCM
send occurred. T1–T4 remain unverified; existing screenshots document setup only.
The required next step is to reconcile the owning Console account and CLI account,
or grant the CLI account appropriate project access, then retry this exact ID.
