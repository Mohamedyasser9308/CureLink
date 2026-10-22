import { initializeApp } from "firebase-admin/app";
import { getFirestore, Timestamp } from "firebase-admin/firestore";
import { getMessaging } from "firebase-admin/messaging";
import { onSchedule } from "firebase-functions/v2/scheduler";
import { onDocumentWritten } from "firebase-functions/v2/firestore";

initializeApp();
const db = getFirestore();
const region = "europe-west1";

// Cloud scheduler keeps the 10-minute deadline working after Android has
// stopped the app. The deterministic status transition is safe to retry.
export const markOverdueDosesMissed = onSchedule(
  { schedule: "every 1 minutes", region, timeZone: "UTC", memory: "256MiB" },
  async () => {
    const now = Timestamp.now();
    const scheduledCutoff = Timestamp.fromMillis(now.toMillis() - 10 * 60 * 1000);
    const snoozeCutoff = Timestamp.fromMillis(now.toMillis() - 10 * 60 * 1000);
    const queries = [
      db.collectionGroup("doses").where("status", "in", ["upcoming", "due"])
        .where("scheduledAt", "<=", scheduledCutoff).limit(400).get(),
      db.collectionGroup("doses").where("status", "==", "snoozed")
        .where("snoozedUntil", "<=", snoozeCutoff).limit(400).get(),
    ];
    const snapshots = await Promise.all(queries);
    for (const snapshot of snapshots) {
      for (const doc of snapshot.docs) {
        await db.runTransaction(async (transaction) => {
          const fresh = await transaction.get(doc.ref);
          const data = fresh.data();
          if (!data) return;
          const snoozedUntil = data.snoozedUntil;
          const scheduledAt = data.scheduledAt;
          const overdue = data.status === "snoozed"
            ? snoozedUntil instanceof Timestamp &&
              snoozedUntil.toMillis() <= snoozeCutoff.toMillis()
            : (data.status === "upcoming" || data.status === "due") &&
              scheduledAt instanceof Timestamp &&
              scheduledAt.toMillis() <= scheduledCutoff.toMillis();
          if (!overdue) return;
          transaction.update(doc.ref, {
            status: "missed",
            snoozedUntil: null,
            updatedAt: now,
          });
        });
      }
    }
  },
);

// An idempotent transaction claim prevents a retried Firestore event from
// sending a second caregiver push for the same dose.
export const notifyCaregiverForMissedDose = onDocumentWritten(
  { document: "users/{patientUid}/doses/{doseId}", region },
  async (event) => {
    const before = event.data?.before.data();
    const after = event.data?.after.data();
    if (!after || after.status !== "missed" || before?.status === "missed" ||
        after.caregiverAlertClaimed === true) return;

    const connections = await db.collection("connections")
      .where("patientUid", "==", event.params.patientUid)
      .where("status", "==", "accepted").get();
    const tokens = new Set<string>();
    for (const connection of connections.docs) {
      const caregiverUid = connection.get("caregiverUid") as string | undefined;
      if (!caregiverUid) continue;
      const caregiver = await db.collection("users").doc(caregiverUid).get();
      for (const token of (caregiver.get("fcmTokens") ?? []) as string[]) {
        if (token) tokens.add(token);
      }
    }
    const doseRef = event.data!.after.ref;
    const claimed = await db.runTransaction(async (transaction) => {
      const current = await transaction.get(doseRef);
      const data = current.data();
      if (!data || data.status !== "missed" || data.caregiverAlertClaimed === true) return false;
      transaction.update(doseRef, { caregiverAlertClaimed: true, caregiverAlertAt: Timestamp.now() });
      return true;
    });
    if (!claimed) return;

    const patient = await db.collection("users").doc(event.params.patientUid).get();
    const patientName = (patient.get("name") as string | undefined) ?? "Your patient";
    const notificationId = `${event.params.patientUid}_${event.params.doseId}`;
    const doseName = (after.medicationName as string | undefined) ?? "a medication dose";
    for (const connection of connections.docs) {
      const caregiverUid = connection.get("caregiverUid") as string | undefined;
      if (!caregiverUid) continue;
      await db.collection("users").doc(caregiverUid).collection("notifications")
        .doc(notificationId).set({
          type: "missed_dose",
          title: "Missed medication dose",
          body: `${patientName} did not confirm ${doseName}.`,
          patientUid: event.params.patientUid,
          doseId: event.params.doseId,
          createdAt: Timestamp.now(),
          read: false,
        }, { merge: true });
    }
    if (tokens.size) await getMessaging().sendEachForMulticast({
      tokens: [...tokens],
      notification: {
        title: "Missed medication dose",
        body: `${patientName} did not confirm ${doseName}.`,
      },
      data: {
        type: "missed_dose",
        notificationId,
        patientUid: event.params.patientUid,
        doseId: event.params.doseId,
      },
      android: { priority: "high", collapseKey: notificationId },
    });
  },
);
