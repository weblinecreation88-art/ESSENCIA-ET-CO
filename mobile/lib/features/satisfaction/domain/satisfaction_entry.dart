import "package:cloud_firestore/cloud_firestore.dart";

import "../../feedback/domain/staff_feedback.dart";

/// Avis de satisfaction globale sur l'établissement (pas sur un membre du
/// personnel en particulier — voir `StaffFeedback` pour ça). Anonyme par
/// conception : aucun identifiant d'auteur n'est stocké.
class SatisfactionEntry {
  const SatisfactionEntry({
    required this.id,
    required this.rating,
    required this.comment,
    this.createdAt,
  });

  final String id;
  final FeedbackRating rating;
  final String comment;
  final DateTime? createdAt;

  factory SatisfactionEntry.fromMap(String id, Map<String, dynamic> map) {
    final createdAt = map["createdAt"] as Timestamp?;
    return SatisfactionEntry(
      id: id,
      rating: FeedbackRating.fromStorage(map["rating"] as String),
      comment: map["comment"] as String? ?? "",
      createdAt: createdAt?.toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
    "rating": rating.storageValue,
    "comment": comment,
    "createdAt": FieldValue.serverTimestamp(),
  };
}
