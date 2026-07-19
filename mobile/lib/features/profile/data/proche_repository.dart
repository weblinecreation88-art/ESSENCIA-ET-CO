import "package:cloud_firestore/cloud_firestore.dart";

import "../domain/proche.dart";

/// Encapsule la sous-collection Firestore `users/{uid}/proches` : un simple
/// carnet de contacts rattaché au profil (pas de compte utilisateur lié).
class ProcheRepository {
  ProcheRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _proches(String uid) =>
      _firestore.collection("users").doc(uid).collection("proches");

  Stream<List<Proche>> watch(String uid) {
    return _proches(uid).orderBy("name").snapshots().map(
      (snapshot) => [
        for (final doc in snapshot.docs) Proche.fromMap(doc.id, doc.data()),
      ],
    );
  }

  Future<void> add(String uid, Proche proche) {
    return _proches(uid).add(proche.toMap());
  }

  Future<void> remove(String uid, String procheId) {
    return _proches(uid).doc(procheId).delete();
  }
}
