import "package:cloud_firestore/cloud_firestore.dart";

import "../domain/agenda_event.dart";

/// Encapsule la sous-collection Firestore `users/{uid}/events` : agenda
/// personnel de l'utilisateur (pas encore partagé entre comptes liés).
class AgendaRepository {
  AgendaRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _events(String uid) =>
      _firestore.collection("users").doc(uid).collection("events");

  Stream<List<AgendaEvent>> watchEvents(String uid) {
    return _events(uid).orderBy("date").snapshots().map(
      (snapshot) => [
        for (final doc in snapshot.docs) AgendaEvent.fromMap(doc.id, doc.data()),
      ],
    );
  }

  Future<void> add(String uid, AgendaEvent event) {
    return _events(uid).add(event.toMap());
  }

  Future<void> remove(String uid, String eventId) {
    return _events(uid).doc(eventId).delete();
  }
}
