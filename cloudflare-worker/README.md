# CureLink dose monitor on Cloudflare Workers

This Worker keeps Firebase Authentication, Firestore, and Firebase Cloud
Messaging. It replaces Firebase Cloud Functions and Cloud Scheduler.

The one-minute Cron Trigger finds doses that have been overdue for ten minutes,
marks them missed in Firestore, and atomically creates a caregiver alert job.
The Worker processes those jobs with a lease and retries failures. It writes the
caregiver's in-app notification and sends a push through FCM HTTP v1.

## Google Cloud setup

1. Select Firebase project `curelink-3f36f` in Google Cloud Console.
2. Enable **Cloud Firestore API** and **Firebase Cloud Messaging API** if they
   are not already enabled.
3. Create a dedicated service account, for example `curelink-dose-monitor`.
4. Grant it only these project roles:
   - **Cloud Datastore User** (`roles/datastore.user`) for Firestore REST access.
   - **Firebase Cloud Messaging API Admin** (`roles/firebasecloudmessaging.admin`)
     to send caregiver pushes.
5. Create a JSON key for this service account and store it somewhere private.
   Never commit the key or put it in Flutter code. The root `.gitignore` ignores
   common service-account JSON filenames.

No Firebase Cloud Scheduler API setup is needed. The Cron Trigger is owned by
Cloudflare.

## Deploy

From this directory, with Node.js installed:

```powershell
npm.cmd install
npx.cmd wrangler login
npx.cmd wrangler secret put GOOGLE_SERVICE_ACCOUNT_JSON
```

When prompted for `GOOGLE_SERVICE_ACCOUNT_JSON`, paste the entire contents of
the service-account JSON key. Then deploy:

```powershell
npm.cmd run typecheck
npm.cmd run deploy
```

`FIREBASE_PROJECT_ID` is set in `wrangler.toml`. The Cron Trigger is configured
for every minute in UTC. Verify it in Cloudflare Dashboard under **Workers &
Pages > curelink-dose-monitor > Settings > Triggers**.

## Verify delivery

1. Confirm the patient and caregiver have an accepted connection.
2. Sign into CureLink as the caregiver once and allow notifications. The app
   stores its FCM registration token under that caregiver's user document.
3. Schedule a patient dose, close the app, and leave it unconfirmed and
   unsnoozed for 11 to 12 minutes.
4. Check the dose status in Firestore (`missed`), then the caregiver's
   `users/{caregiverUid}/notifications` collection and device notification.
5. In Cloudflare, inspect the Worker logs if the Firestore or FCM step fails.

The Worker Free plan currently limits Cron CPU to 10 ms per invocation. This
implementation limits each run to small batches; check Cloudflare's invocation
metrics after deployment. If it exceeds that CPU limit, use the Cloudflare
Workers Paid plan or reduce batch sizes. Firestore usage still counts against
the Firebase project's Firestore quotas.
