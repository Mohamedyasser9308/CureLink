interface Env {
  FIREBASE_PROJECT_ID: string;
  GOOGLE_SERVICE_ACCOUNT_JSON: string;
}

interface ScheduledController {
  cron: string;
  scheduledTime: number;
}

interface WorkerExecutionContext {
  waitUntil(promise: Promise<unknown>): void;
  passThroughOnException(): void;
}

interface FirestoreDocument {
  name: string;
  updateTime: string;
  fields: Record<string, FirestoreValue>;
}

interface FirestoreValue {
  stringValue?: string;
  integerValue?: string;
  timestampValue?: string;
  booleanValue?: boolean;
  nullValue?: null;
  mapValue?: { fields?: Record<string, FirestoreValue> };
  arrayValue?: { values?: FirestoreValue[] };
}

interface ServiceAccount {
  client_email: string;
  private_key: string;
  project_id?: string;
}

const DATASTORE_SCOPE = "https://www.googleapis.com/auth/datastore";
const MESSAGING_SCOPE = "https://www.googleapis.com/auth/firebase.messaging";
const TOKEN_URL = "https://oauth2.googleapis.com/token";
const LEASE_MS = 5 * 60 * 1000;
const MAX_DOSES_PER_RUN = 40;
const MAX_ALERTS_PER_RUN = 3;
const DOSE_COMMIT_BATCH_SIZE = 20;
const MAX_PARALLEL_REQUESTS = 4;

let cachedAccessToken: { token: string; expiresAt: number } | undefined;

export default {
  async scheduled(
    _controller: ScheduledController,
    env: Env,
    _ctx: WorkerExecutionContext,
  ): Promise<void> {
    const account = parseServiceAccount(env.GOOGLE_SERVICE_ACCOUNT_JSON);
    if (account.project_id && account.project_id !== env.FIREBASE_PROJECT_ID) {
      throw new Error("Service account project does not match FIREBASE_PROJECT_ID");
    }

    const token = await getAccessToken(account);
    await markOverdueDoses(env.FIREBASE_PROJECT_ID, token);
    await deliverPendingAlerts(env.FIREBASE_PROJECT_ID, token);
  },
};

function parseServiceAccount(json: string): ServiceAccount {
  const account = JSON.parse(json) as Partial<ServiceAccount>;
  if (!account.client_email || !account.private_key) {
    throw new Error("Service account JSON must include client_email and private_key");
  }
  return account as ServiceAccount;
}

async function getAccessToken(account: ServiceAccount): Promise<string> {
  const now = Date.now();
  if (cachedAccessToken && cachedAccessToken.expiresAt > now + 60_000) {
    return cachedAccessToken.token;
  }

  const issuedAt = Math.floor(now / 1000);
  const assertion = await signServiceAccountJwt(account, {
    iss: account.client_email,
    scope: `${DATASTORE_SCOPE} ${MESSAGING_SCOPE}`,
    aud: TOKEN_URL,
    iat: issuedAt,
    exp: issuedAt + 3600,
  });
  const response = await fetch(TOKEN_URL, {
    method: "POST",
    headers: { "content-type": "application/x-www-form-urlencoded" },
    body: new URLSearchParams({
      grant_type: "urn:ietf:params:oauth:grant-type:jwt-bearer",
      assertion,
    }),
  });
  const result = (await response.json()) as {
    access_token?: string;
    expires_in?: number;
    error?: string;
    error_description?: string;
  };
  if (!response.ok || !result.access_token) {
    throw new Error(`Google token exchange failed: ${result.error_description ?? result.error ?? response.status}`);
  }
  cachedAccessToken = {
    token: result.access_token,
    expiresAt: now + (result.expires_in ?? 3600) * 1000,
  };
  return result.access_token;
}

async function signServiceAccountJwt(
  account: ServiceAccount,
  claims: Record<string, string | number>,
): Promise<string> {
  const header = base64UrlEncode(JSON.stringify({ alg: "RS256", typ: "JWT" }));
  const payload = base64UrlEncode(JSON.stringify(claims));
  const unsigned = `${header}.${payload}`;
  const pem = account.private_key
    .replace("-----BEGIN PRIVATE KEY-----", "")
    .replace("-----END PRIVATE KEY-----", "")
    .replace(/\s/g, "");
  const key = await crypto.subtle.importKey(
    "pkcs8",
    base64ToBytes(pem).buffer as ArrayBuffer,
    { name: "RSASSA-PKCS1-v1_5", hash: "SHA-256" },
    false,
    ["sign"],
  );
  const signature = await crypto.subtle.sign(
    "RSASSA-PKCS1-v1_5",
    key,
    new TextEncoder().encode(unsigned).buffer as ArrayBuffer,
  );
  return `${unsigned}.${base64UrlEncodeBytes(new Uint8Array(signature))}`;
}

function base64UrlEncode(value: string): string {
  return base64UrlEncodeBytes(new TextEncoder().encode(value));
}

function base64UrlEncodeBytes(bytes: Uint8Array): string {
  let binary = "";
  for (const byte of bytes) binary += String.fromCharCode(byte);
  return btoa(binary).replace(/=/g, "").replace(/\+/g, "-").replace(/\//g, "_");
}

function base64ToBytes(value: string): Uint8Array {
  const binary = atob(value);
  const bytes = new Uint8Array(binary.length);
  for (let index = 0; index < binary.length; index++) {
    bytes[index] = binary.charCodeAt(index);
  }
  return bytes;
}

async function markOverdueDoses(projectId: string, token: string): Promise<void> {
  const now = new Date();
  const cutoff = new Date(now.getTime() - 10 * 60 * 1000).toISOString();
  const [regularDoses, snoozedDoses] = await Promise.all([
    queryDocuments(projectId, token, "doses", [
      inFilter("status", ["upcoming", "due"]),
      lessThanOrEqualFilter("scheduledAt", cutoff),
    ], MAX_DOSES_PER_RUN),
    queryDocuments(projectId, token, "doses", [
      equalsFilter("status", "snoozed"),
      lessThanOrEqualFilter("snoozedUntil", cutoff),
    ], MAX_DOSES_PER_RUN),
  ]);

  const seen = new Set<string>();
  const overdue = [...regularDoses, ...snoozedDoses].filter((document) => {
    if (seen.has(document.name)) return false;
    seen.add(document.name);
    return isStillOverdue(document, now);
  }).slice(0, MAX_DOSES_PER_RUN);

  // Each commit atomically changes the dose and creates its alert outbox item.
  // updateTime prevents a concurrent dose confirmation or snooze from being lost.
  for (const batch of chunks(overdue, DOSE_COMMIT_BATCH_SIZE)) {
    const writes = batch.flatMap((dose) => {
      const { patientUid, doseId } = parseDosePath(dose.name);
      const jobName = documentName(projectId, `caregiver_alert_jobs/${patientUid}_${doseId}`);
      const job = {
        name: jobName,
        fields: {
          patientUid: { stringValue: patientUid },
          doseId: { stringValue: doseId },
          medicationName: {
            stringValue: dose.fields.medicationName?.stringValue ?? "Medication dose",
          },
          state: { stringValue: "pending" },
          attempts: { integerValue: "0" },
          leaseUntil: { nullValue: null },
          createdAt: { timestampValue: now.toISOString() },
        },
      };
      return [
        {
          update: {
            name: dose.name,
            fields: {
              status: { stringValue: "missed" },
              snoozedUntil: { nullValue: null },
              updatedAt: { timestampValue: now.toISOString() },
            },
          },
          updateMask: { fieldPaths: ["status", "snoozedUntil", "updatedAt"] },
          currentDocument: { updateTime: dose.updateTime },
        },
        { update: job, currentDocument: { exists: false } },
      ];
    });
    const response = await firestoreRequest(projectId, token, "documents:commit", { writes });
    if (!response.ok) {
      const body = await response.text();
      // A stale read is safe: the next minute re-reads and only handles doses
      // that are still overdue. Other errors must stay visible in Worker logs.
      if (response.status === 409 || body.includes("FAILED_PRECONDITION") ||
          body.includes("ALREADY_EXISTS")) continue;
      throw new Error(`Could not mark overdue doses missed (${response.status}): ${body}`);
    }
  }
}

function isStillOverdue(document: FirestoreDocument, now: Date): boolean {
  const status = document.fields.status?.stringValue;
  if (status === "snoozed") {
    const until = document.fields.snoozedUntil?.timestampValue;
    return !!until && Date.parse(until) + 10 * 60 * 1000 <= now.getTime();
  }
  if (status === "upcoming" || status === "due") {
    const scheduledAt = document.fields.scheduledAt?.timestampValue;
    return !!scheduledAt && Date.parse(scheduledAt) + 10 * 60 * 1000 <= now.getTime();
  }
  return false;
}

async function deliverPendingAlerts(projectId: string, token: string): Promise<void> {
  const jobs = await queryDocuments(projectId, token, "caregiver_alert_jobs", [
    inFilter("state", ["pending", "processing"]),
  ], 100);
  let processed = 0;
  for (const job of jobs) {
    if (processed >= MAX_ALERTS_PER_RUN) break;
    const state = job.fields.state?.stringValue;
    const leaseUntil = job.fields.leaseUntil?.timestampValue;
    if (state === "processing" && leaseUntil && Date.parse(leaseUntil) > Date.now()) {
      continue;
    }
    processed++;
    await deliverOneAlert(projectId, token, job);
  }
}

async function deliverOneAlert(
  projectId: string,
  token: string,
  job: FirestoreDocument,
): Promise<boolean> {
  const now = new Date();
  const patientUid = job.fields.patientUid?.stringValue;
  const doseId = job.fields.doseId?.stringValue;
  if (!patientUid || !doseId) {
    console.error(`Alert job has no patientUid/doseId: ${job.name}`);
    return false;
  }

  const attempts = Number(job.fields.attempts?.integerValue ?? "0") + 1;
  const leaseUntil = new Date(now.getTime() + LEASE_MS).toISOString();
  const claim = await firestoreRequest(projectId, token, "documents:commit", {
    writes: [{
      update: {
        name: job.name,
        fields: {
          ...job.fields,
          state: { stringValue: "processing" },
          attempts: { integerValue: String(attempts) },
          leaseUntil: { timestampValue: leaseUntil },
          lastAttemptAt: { timestampValue: now.toISOString() },
        },
      },
      currentDocument: { updateTime: job.updateTime },
    }],
  }, true);
  if (!claim.ok) {
    const body = await claim.text();
    if (claim.status === 409 || body.includes("FAILED_PRECONDITION")) return false;
    throw new Error(`Could not claim alert job (${claim.status}): ${body}`);
  }
  const claimResponse = await claim.json() as {
    writeResults?: Array<{ updateTime?: string }>;
  };
  const claimUpdateTime = claimResponse.writeResults?.[0]?.updateTime;
  if (!claimUpdateTime) throw new Error(`Alert job claim omitted updateTime: ${job.name}`);

  try {
    const patientName = await getUserName(projectId, token, patientUid);
    const connections = await queryDocuments(projectId, token, "connections", [
      equalsFilter("patientUid", patientUid),
      equalsFilter("status", "accepted"),
    ], 100);
    const acceptedConnections = connections.filter((connection) =>
      connection.fields.patientUid?.stringValue === patientUid &&
      connection.fields.status?.stringValue === "accepted",
    );
    const caregivers = await mapWithConcurrency(
      acceptedConnections,
      MAX_PARALLEL_REQUESTS,
      async (connection) => {
        const caregiverUid = connection.fields.caregiverUid?.stringValue;
        if (!caregiverUid) return undefined;
        const caregiver = await getUser(projectId, token, caregiverUid);
        return { caregiverUid, tokens: stringArray(caregiver?.fields.fcmTokens) };
      },
    );
    const recipients = caregivers.filter((value): value is { caregiverUid: string; tokens: string[] } => !!value);
    const title = "Missed medication dose";
    const medicationName = job.fields.medicationName?.stringValue ?? "a medication dose";
    const body = `${patientName} did not confirm ${medicationName}.`;
    const notificationId = `${patientUid}_${doseId}`;

    // The caregiver feed is idempotent and is written even if push delivery fails.
    await writeCaregiverNotifications(
      projectId,
      token,
      recipients.map((recipient) => recipient.caregiverUid),
      notificationId,
      { title, body, patientUid, doseId, now: now.toISOString() },
    );

    const registrationTokens = [...new Set(recipients.flatMap((recipient) => recipient.tokens))];
    const sendResults = await mapWithConcurrency(
      registrationTokens,
      MAX_PARALLEL_REQUESTS,
      (registrationToken) => sendPush(projectId, token, registrationToken, {
        title,
        body,
        notificationId,
        patientUid,
        doseId,
      }),
    );
    const invalidTokens = sendResults.flatMap((result, index) =>
      result === "invalid" ? [registrationTokens[index]] : [],
    );
    if (invalidTokens.length > 0) {
      await removeInvalidTokens(projectId, token, recipients, invalidTokens);
    }
    const failures = sendResults.filter((result) => result === "failed").length;
    if (failures > 0) throw new Error(`FCM delivery failed for ${failures} caregiver device(s)`);

    const finish = await firestoreRequest(projectId, token, "documents:commit", {
      writes: [{
        update: {
          name: job.name,
          fields: {
            ...job.fields,
            state: { stringValue: "sent" },
            attempts: { integerValue: String(attempts) },
            leaseUntil: { nullValue: null },
            sentAt: { timestampValue: new Date().toISOString() },
            recipientCount: { integerValue: String(recipients.length) },
            deviceCount: { integerValue: String(registrationTokens.length) },
          },
        },
        currentDocument: { updateTime: claimUpdateTime },
      }],
    }, true);
    if (!finish.ok) throw new Error(`Could not finish alert job (${finish.status}): ${await finish.text()}`);
    return true;
  } catch (error) {
    const reset = await firestoreRequest(projectId, token, "documents:commit", {
      writes: [{
        update: {
          name: job.name,
          fields: {
            ...job.fields,
            state: { stringValue: "pending" },
            attempts: { integerValue: String(attempts) },
            leaseUntil: { nullValue: null },
            lastError: { stringValue: String(error).slice(0, 500) },
          },
        },
        currentDocument: { updateTime: claimUpdateTime },
      }],
    }, true);
    if (!reset.ok) console.error(`Could not release failed alert job ${job.name}: ${await reset.text()}`);
    console.error(`Alert job failed for ${patientUid}/${doseId}:`, error);
    return false;
  }
}

async function writeCaregiverNotifications(
  projectId: string,
  token: string,
  caregiverUids: string[],
  notificationId: string,
  details: { title: string; body: string; patientUid: string; doseId: string; now: string },
): Promise<void> {
  if (caregiverUids.length === 0) return;
  const writes = caregiverUids.map((caregiverUid) => ({
    update: {
      name: documentName(projectId, `users/${caregiverUid}/notifications/${notificationId}`),
      fields: {
        type: { stringValue: "missed_dose" },
        title: { stringValue: details.title },
        body: { stringValue: details.body },
        patientUid: { stringValue: details.patientUid },
        doseId: { stringValue: details.doseId },
        createdAt: { timestampValue: details.now },
        read: { booleanValue: false },
      },
    },
  }));
  const result = await firestoreRequest(projectId, token, "documents:commit", { writes }, true);
  if (!result.ok) throw new Error(`Could not write caregiver notification feed: ${await result.text()}`);
}

async function sendPush(
  projectId: string,
  token: string,
  registrationToken: string,
  details: { title: string; body: string; notificationId: string; patientUid: string; doseId: string },
): Promise<"sent" | "invalid" | "failed"> {
  const response = await fetch(
    `https://fcm.googleapis.com/v1/projects/${projectId}/messages:send`,
    {
      method: "POST",
      headers: {
        authorization: `Bearer ${token}`,
        "content-type": "application/json",
      },
      body: JSON.stringify({
        message: {
          token: registrationToken,
          notification: { title: details.title, body: details.body },
          data: {
            type: "missed_dose",
            notificationId: details.notificationId,
            patientUid: details.patientUid,
            doseId: details.doseId,
          },
          android: {
            priority: "HIGH",
            notification: { tag: details.notificationId },
          },
        },
      }),
    },
  );
  if (response.ok) return "sent";
  console.error(`FCM send failed (${response.status}): ${await response.text()}`);
  // FCM returns NOT_FOUND when a registration token is no longer registered.
  // Retrying a job with that token would otherwise keep it pending forever.
  return response.status === 404 ? "invalid" : "failed";
}

async function removeInvalidTokens(
  projectId: string,
  token: string,
  recipients: Array<{ caregiverUid: string; tokens: string[] }>,
  invalidTokens: string[],
): Promise<void> {
  const invalid = new Set(invalidTokens);
  const writes = recipients.flatMap((recipient) => {
    const staleTokens = recipient.tokens.filter((value) => invalid.has(value));
    if (staleTokens.length === 0) return [];
    return [{
      transform: {
        document: documentName(projectId, `users/${recipient.caregiverUid}`),
        fieldTransforms: [{
          fieldPath: "fcmTokens",
          removeAllFromArray: { values: staleTokens.map((stringValue) => ({ stringValue })) },
        }],
      },
    }];
  });
  if (writes.length === 0) return;
  const response = await firestoreRequest(projectId, token, "documents:commit", { writes }, true);
  if (!response.ok) {
    throw new Error(`Could not remove invalid FCM tokens: ${await response.text()}`);
  }
}

async function getUserName(projectId: string, token: string, uid: string): Promise<string> {
  const user = await getUser(projectId, token, uid);
  return user?.fields.name?.stringValue ?? "Your patient";
}

async function getUser(
  projectId: string,
  token: string,
  uid: string,
): Promise<FirestoreDocument | undefined> {
  const response = await firestoreRequest(projectId, token, `users/${uid}`, undefined, true);
  if (response.status === 404) return undefined;
  if (!response.ok) throw new Error(`Could not read user ${uid}: ${await response.text()}`);
  return await response.json() as FirestoreDocument;
}

async function queryDocuments(
  projectId: string,
  token: string,
  collectionId: string,
  filters: object[],
  limit: number,
): Promise<FirestoreDocument[]> {
  const where = filters.length === 1
    ? filters[0]
    : { compositeFilter: { op: "AND", filters } };
  const response = await firestoreRequest(projectId, token, "documents:runQuery", {
    structuredQuery: {
      from: [{ collectionId, allDescendants: collectionId === "doses" }],
      where,
      limit,
    },
  }, true);
  if (!response.ok) throw new Error(`Firestore query failed (${response.status}): ${await response.text()}`);
  const rows = await response.json() as Array<{ document?: FirestoreDocument }>;
  return rows.flatMap((row) => row.document ? [row.document] : []);
}

function equalsFilter(fieldPath: string, value: string): object {
  return {
    fieldFilter: {
      field: { fieldPath },
      op: "EQUAL",
      value: { stringValue: value },
    },
  };
}

function inFilter(fieldPath: string, values: string[]): object {
  return {
    fieldFilter: {
      field: { fieldPath },
      op: "IN",
      value: { arrayValue: { values: values.map((stringValue) => ({ stringValue })) } },
    },
  };
}

function lessThanOrEqualFilter(fieldPath: string, timestampValue: string): object {
  return {
    fieldFilter: {
      field: { fieldPath },
      op: "LESS_THAN_OR_EQUAL",
      value: { timestampValue },
    },
  };
}

function parseDosePath(name: string): { patientUid: string; doseId: string } {
  const match = name.match(/\/documents\/users\/([^/]+)\/doses\/([^/]+)$/);
  if (!match) throw new Error(`Unexpected dose document path: ${name}`);
  return { patientUid: match[1], doseId: match[2] };
}

function stringArray(value: FirestoreValue | undefined): string[] {
  return (value?.arrayValue?.values ?? [])
    .map((item) => item.stringValue)
    .filter((item): item is string => !!item);
}

function documentName(projectId: string, path: string): string {
  return `projects/${projectId}/databases/(default)/documents/${path}`;
}

async function firestoreRequest(
  projectId: string,
  token: string,
  path: string,
  body?: unknown,
  allowNotFound = false,
): Promise<Response> {
  const documentsUrl = `https://firestore.googleapis.com/v1/projects/${projectId}/databases/(default)/documents`;
  const url = path.startsWith("documents:")
    ? `${documentsUrl}:${path.slice("documents:".length)}`
    : `${documentsUrl}/${path}`;
  const response = await fetch(url, {
    method: body === undefined ? "GET" : "POST",
    headers: {
      authorization: `Bearer ${token}`,
      ...(body === undefined ? {} : { "content-type": "application/json" }),
    },
    body: body === undefined ? undefined : JSON.stringify(body),
  });
  if (allowNotFound && response.status === 404) return response;
  return response;
}

function chunks<T>(items: T[], size: number): T[][] {
  const result: T[][] = [];
  for (let index = 0; index < items.length; index += size) {
    result.push(items.slice(index, index + size));
  }
  return result;
}

async function mapWithConcurrency<T, R>(
  items: T[],
  concurrency: number,
  callback: (item: T) => Promise<R>,
): Promise<R[]> {
  const results: R[] = new Array(items.length);
  let next = 0;
  const workers = Array.from({ length: Math.min(concurrency, items.length) }, async () => {
    while (true) {
      const index = next++;
      if (index >= items.length) return;
      results[index] = await callback(items[index]);
    }
  });
  await Promise.all(workers);
  return results;
}
