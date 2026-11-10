# Activity 14 — actual FCM evidence

Four labeled composites, assembled from unmodified emulator screenshots:

- [T1: foreground before/after](T1_composite.png) — `onMessage`, promo accepted.
- [T2: background notification and tap result](T2_composite.png) — `onMessageOpenedApp`.
- [T3: terminated notification and cold-start result](T3_composite.png) — `getInitialMessage`.
- [T4: invalid-payload before/after](T4_composite.png) — rejection, new ID/count, preserved UI.

Raw images retain their descriptive T1–T4 filenames. Composite labels are outside
screenshots; screenshots were not synthesized or retouched. Tokens are hidden by the app.

[Send ledger](send_results.jsonl) records real HTTP v1 responses with notification/data
and timestamps, without credentials or device tokens. It includes the early T2 attempt
that arrived during the Home transition; the passing T2 ID is listed in the reflection.
[T3 process check](T3_process_state.txt) confirms no process and `stopped=false` before send.
[Project access](verified_project_access.json) confirms access after the account switch.

See [reflection](../reflection.md) for expected/observed results, timestamps, conditions,
retries, and limitations. Setup-block screenshots and earlier access/reflection files
are historical records, not delivery evidence.
