import "package:cloud_firestore/cloud_firestore.dart";

import "../../feedback/domain/staff_feedback.dart";
import "../domain/satisfaction_entry.dart";

/// Encapsule la collection Firestore racine `satisfaction` (avis anonymes
/// sur l'établissement, réservés à la lecture par un administrateur).
class SatisfactionRepository {
  SatisfactionRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _satisfaction =>
      _firestore.collection("satisfaction");

  Future<void> submit({required FeedbackRating rating, String comment = ""}) {
    return _satisfaction.add(
      SatisfactionEntry(id: "", rating: rating, comment: comment).toMap(),
    );
  }

  /// Réservé aux administrateurs.
  Future<List<SatisfactionEntry>> fetchAll() async {
    final snapshot = await _satisfaction
        .orderBy("createdAt", descending: true)
        .get();
    return [
      for (final doc in snapshot.docs)
        SatisfactionEntry.fromMap(doc.id, doc.data()),
    ];
  }
}
