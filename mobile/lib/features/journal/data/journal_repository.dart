import "package:cloud_firestore/cloud_firestore.dart";

import "../domain/journal_entry.dart";

/// Encapsule la sous-collection Firestore `users/{residentUid}/journal`
/// (journal de vie). Le personnel et les proches peuvent y ajouter des notes
/// sur le quotidien d'un résident ; le résident écrit dans son propre journal.
class JournalRepository {
  JournalRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _journal(String residentUid) =>
      _firestore.collection("users").doc(residentUid).collection("journal");

  Stream<List<JournalEntry>> watch(String residentUid) {
    return _journal(
      residentUid,
    ).orderBy("createdAt", descending: true).snapshots().map(
      (snapshot) => [
        for (final doc in snapshot.docs)
          JournalEntry.fromMap(doc.id, doc.data()),
      ],
    );
  }

  Future<void> add({
    required String residentUid,
    required String authorName,
    required String note,
  }) {
    return _journal(
      residentUid,
    ).add(JournalEntry(id: "", authorName: authorName, note: note).toMap());
  }
}
