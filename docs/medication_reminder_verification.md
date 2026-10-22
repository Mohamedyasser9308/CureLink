# Medication reminder deployment and device checks

## Deploy the caregiver alert backend

The Flutter app saves each signed-in device's FCM token in `users/{uid}.fcmTokens`.
The scheduled function marks an overdue dose `missed` after 10 minutes. A Firestore
trigger sends an FCM notification to accepted caregiver connections and stores an
idempotency claim on that dose.

From the project root, with Node.js 20+, Firebase CLI authentication, and billing
enabled for Cloud Scheduler, deploy the indexes and functions:

```powershell
cd functions
npm install
npm run build
cd ..
firebase deploy --only firestore:indexes,functions --project curelink-3f36f
```

Both the patient and caregiver must sign in on a device, allow notifications, and
have a current FCM token. The caregiver connection must have `status: accepted`.

## Android device matrix

Use two physical Android devices or one device plus an emulator signed into separate
patient and caregiver accounts. Keep the device online for the caregiver push test.

| Case | Steps | Expected result |
| --- | --- | --- |
| App open | Schedule a dose about one minute ahead and leave CureLink open. | At due time Android posts the dose notification. Opening it shows medication, dose, scheduled time, and both actions. |
| Background | Schedule a dose, then switch to another app. | Dose notification appears at the scheduled time and opens the reminder page. |
| Swiped from recents | Schedule a dose, swipe CureLink away from Recents, and wait. | Android alarm still posts the notification; tapping it launches CureLink on the reminder page. |
| Locked screen | Schedule a dose, lock the phone, and keep the display off. | Notification appears on the lock screen at the scheduled time. |
| Taken before deadline | Open a reminder and press “I took it” before 10 minutes. | Firestore status becomes `taken`; both pending local notifications are cancelled; no caregiver push is sent. |
| Snooze | Press “Snooze 10 minutes”. | Firestore status becomes `snoozed` with `snoozedUntil`; another reminder is scheduled for that time. |
| Missed after snooze | Do not confirm the snoozed reminder. | At the 10-minute deadline Firestore becomes `missed`; the accepted caregiver receives an FCM notification. |
| Duplicate protection | Keep the function trigger and scheduled sweep active while a dose becomes missed. | The dose has one `caregiverAlertClaimed` value and only one logical FCM send is attempted for that dose. |
| Reboot | Schedule a future dose, reboot the phone, then wait for its time. | The Android boot receiver restores the pending alarm and the notification appears. |
| Permission denied | Deny exact-alarm permission, then schedule a dose. | The app falls back to an inexact idle alarm; Android may deliver it later than the selected minute. |

For each case, inspect the dose document at
`users/{patientUid}/doses/{doseId}` and the caregiver device's notification tray.
Test “app terminated” by swiping it away from Recents; Android force-stop from
Settings suppresses alarms until the user opens the app again.
