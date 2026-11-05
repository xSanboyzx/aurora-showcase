import { readFile } from "node:fs/promises";
import { after, before, test } from "node:test";
import {
  initializeTestEnvironment,
  assertFails,
  assertSucceeds,
} from "@firebase/rules-unit-testing";
import {
  doc,
  setDoc,
  getDoc,
  updateDoc,
  deleteDoc,
  serverTimestamp,
} from "firebase/firestore";

let environment;
before(async () => {
  environment = await initializeTestEnvironment({
    projectId: "demo-aurora",
    firestore: {
      rules: await readFile(
        new URL("../firestore.rules", import.meta.url),
        "utf8",
      ),
    },
  });
});
after(async () => environment?.cleanup());

test("journal CRUD is owner-only and validates entries", async () => {
  const owner = environment.authenticatedContext("alex").firestore();
  const other = environment.authenticatedContext("sam").firestore();
  const guest = environment.unauthenticatedContext().firestore();
  const path = "users/alex/journalEntries/first";
  const entry = {
    title: "Sample",
    content: "Fictional reflection",
    mood: "calm",
    createdAt: serverTimestamp(),
    updatedAt: serverTimestamp(),
  };
  await assertSucceeds(setDoc(doc(owner, path), entry));
  await assertSucceeds(getDoc(doc(owner, path)));
  await assertFails(getDoc(doc(other, path)));
  await assertFails(getDoc(doc(guest, path)));
  await assertFails(setDoc(doc(other, path), entry));
  await assertFails(
    updateDoc(doc(owner, path), {
      content: "x".repeat(20001),
      updatedAt: serverTimestamp(),
    }),
  );
  await assertSucceeds(
    updateDoc(doc(owner, path), {
      mood: "happy",
      updatedAt: serverTimestamp(),
    }),
  );
  await assertSucceeds(deleteDoc(doc(owner, path)));
  await assertFails(getDoc(doc(owner, "unexpected/private")));
});
