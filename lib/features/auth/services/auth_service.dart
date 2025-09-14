import 'package:cloud_firestore/cloud_firestore.dart';

class UsersService {
  // Reference to 'users' collection
  final CollectionReference usersRef = FirebaseFirestore.instance.collection(
    'users',
  );

  // Add a user document (e.g., during sign up)
  Future<void> addUser(String uid, Map<String, dynamic> data) async {
    await usersRef.doc(uid).set(data);
  }

  // --- ADD THIS METHOD ---
  // Reads a single user's document by their UID
  Future<DocumentSnapshot> readUser(String uid) async {
    return usersRef.doc(uid).get();
  }
  // ----------------------

  // Read all users as stream
  Stream<QuerySnapshot> readUsers() {
    return usersRef.snapshots();
  }

  // Update a user document
  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    await usersRef.doc(uid).update(data);
  }

  // Delete a user document
  Future<void> deleteUser(String uid) async {
    await usersRef.doc(uid).delete();
  }
}
