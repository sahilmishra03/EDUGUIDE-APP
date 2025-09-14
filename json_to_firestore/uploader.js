const admin = require("firebase-admin");
const fs = require("fs");
const path = require("path");

// Load service account key
const serviceAccount = require("./service_key.json");

// Initialize Firebase Admin
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

// Path to your JSON file
const filePath = path.join(__dirname, "files", "professors.json");

// Read JSON file
const data = JSON.parse(fs.readFileSync(filePath, "utf8"));

async function uploadData() {
  try {
    const collectionRef = db.collection("professors"); // Firestore collection name

    for (const prof of data) {
      // Use id if exists, otherwise auto-id
      const docRef = prof.id
        ? collectionRef.doc(prof.id.toString())
        : collectionRef.doc();

      await docRef.set(prof);
      console.log(`Uploaded: ${prof.name}`);
    }

    console.log("✅ All data uploaded to Firestore!");
    process.exit(0);
  } catch (error) {
    console.error("❌ Error uploading data:", error);
    process.exit(1);
  }
}

uploadData();