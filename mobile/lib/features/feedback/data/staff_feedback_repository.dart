import "package:cloud_firestore/cloud_firestore.dart";

import "../domain/staff_feedback.dart";

/// Encapsule la sous-collection Firestore `users/{uid}/feedback`. Les avis
/// sont anonymes par conception : aucun identifiant d'auteur n'est stocké.
class StaffFeedbackRepository {
  StaffFeedbackRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _feedback(String uid) =>
      _firestore.collection("users").doc(uid).collection("feedback");

  Future<void> submit({
    required String staffUid,
    required FeedbackRating rating,
    String comment = "",
  }) {
    return _feedback(
      staffUid,
    ).add(StaffFeedback(id: "", rating: rating, comment: comment).toMap());
  }

  Stream<List<StaffFeedback>> watch(String uid) {
    return _feedback(uid).snapshots().map(
      (snapshot) => [
        for (final doc in snapshot.docs)
          StaffFeedback.fromMap(doc.id, doc.data()),
      ],
    );
  }

  /// Réservé aux administrateurs : récupère tous les avis de tous les
  /// professionnels, regroupés par uid de professionnel.
  Future<Map<String, List<StaffFeedback>>> fetchAllGroupedByStaff() async {
    final snapshot = await _firestore.collectionGroup("feedback").get();
    final grouped = <String, List<StaffFeedback>>{};
    for (final doc in snapshot.docs) {
      final staffUid = doc.reference.parent.parent!.id;
      grouped
          .putIfAbsent(staffUid, () => [])
          .add(StaffFeedback.fromMap(doc.id, doc.data()));
    }
    return grouped;
  }
}
