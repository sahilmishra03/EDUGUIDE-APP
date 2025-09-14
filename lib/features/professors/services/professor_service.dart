import 'package:cloud_firestore/cloud_firestore.dart';

class ProfessorsService {
  final CollectionReference _professorsCollection = FirebaseFirestore.instance
      .collection('professors');

  Stream<QuerySnapshot> getProfessorsStream() {
    return _professorsCollection.snapshots();
  }

  Future<void> addProfessor(Map<String, dynamic> data) async {
    await _professorsCollection.add(data);
  }

  Future<void> updateProfessor(String id, Map<String, dynamic> data) async {
    await _professorsCollection.doc(id).update(data);
  }

  Future<void> deleteProfessor(String id) async {
    await _professorsCollection.doc(id).delete();
  }
}
